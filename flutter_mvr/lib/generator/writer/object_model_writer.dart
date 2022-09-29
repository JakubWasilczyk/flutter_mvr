import 'package:flutter_mvr/generator/util/list_extensions.dart';

import '../field.dart';
import '../model/field_type/map_type.dart';
import '../model/object_model.dart';
import '../pubspec_config.dart';
import '../util/case_util.dart';
import '../util/dart_type.dart';
import '../util/type_checker.dart';
import '../yml_generator_config.dart';

class ObjectModelWriter {
  final PubspecConfig pubspecConfig;
  final ObjectModel jsonModel;
  final List<Field> extendsFields;
  final YmlGeneratorConfig yamlConfig;

  const ObjectModelWriter(
    this.pubspecConfig,
    this.jsonModel,
    this.extendsFields,
    this.yamlConfig,
  );

  List<Field> get fields => jsonModel.fields;
  List<Field> get fieldsNoId => fields.where((field) => field.name != 'id').toList();
  Field? get idField => fields.firstWhereOrNull((field) => field.name == 'id');

  String write() {
    final sb = StringBuffer();
    final imports = <String>{}..add("import 'package:flutter_mvr/flutter_mvr.dart';");
    for (final element in (jsonModel.extraImports ?? pubspecConfig.extraImports)) {
      imports.add('import \'$element\';');
    }
    final extendsModel = jsonModel.extendsModel;

    if (extendsModel != null) {
      if (!TypeChecker.isKnownDartType(extendsModel)) {
        imports.addAll(_getImportsFromPath(extendsModel));
      }
    }

    for (final field in fields) {
      final type = field.type;
      if (!TypeChecker.isKnownDartType(type.name) && type.name != jsonModel.name) {
        imports.addAll(_getImportsFromPath(type.name));
      }
      if (type is MapType && !TypeChecker.isKnownDartType(type.valueName)) {
        imports.addAll(_getImportsFromPath(type.valueName));
      }
    }
    for (final field in extendsFields) {
      imports.addAll(_getImportsFromField(field));
    }

    (imports.toList()..sort((i1, i2) => i1.compareTo(i2))).forEach(sb.writeln);

    fields.sort((a, b) {
      final b1 = a.isRequired ? 1 : 0;
      final b2 = b.isRequired ? 1 : 0;
      return b2 - b1;
    });

    sb
      ..writeln()
      ..writeln("part 'base/${jsonModel.fileName}.base.dart';")
      ..writeln();

    _modelDescription(sb);

    (jsonModel.extraAnnotations ?? pubspecConfig.extraAnnotations).forEach(sb.writeln);

    final modelName = jsonModel.name;
    _declaration(sb);
    sb.writeln('  $modelName ({');
    _constructorFields(sb);
    sb.writeln('  }) : super();');
    sb.writeln();
    sb.writeln('  factory $modelName.fromJson(Map<String, dynamic> json) => Base$modelName.fromJson(json);');
    sb.writeln();

    sb.writeln('}');

    return sb.toString();
  }

  void _declaration(StringBuffer sb) {
    final className = jsonModel.name;
    sb.writeln("class $className extends Base$className {");
  }

  void _modelDescription(StringBuffer sb) {
    final modelDescription = jsonModel.description?.trim();
    if (modelDescription != null && modelDescription.isNotEmpty) {
      sb.writeln("///$modelDescription");
    }
  }

  void _constructorFields(StringBuffer sb) {
    for (final key in fields.where((key) => (key.isRequired && !key.hasDefaultValue))) {
      sb.writeln('    required super.${key.name},');
    }
    for (final key in extendsFields.where((key) => (key.isRequired && !key.hasDefaultValue))) {
      sb.writeln('    required super.${key.name},');
    }
    for (final key in fields.where((key) => !(key.isRequired && !key.hasDefaultValue))) {
      sb.writeln('    super.${key.name},');
    }
    for (final key in extendsFields.where((key) => !(key.isRequired && !key.hasDefaultValue))) {
      sb.writeln('    super.${key.name},');
    }
    if (jsonModel.createdAt) sb.writeln('    super.createdAt,');
    if (jsonModel.updatedAt) sb.writeln('    super.updatedAt,');
  }

  Iterable<String> _getImportsFromField(Field field) {
    final imports = <String>{};
    final type = field.type;
    if (!TypeChecker.isKnownDartType(type.name)) {
      imports.addAll(_getImportsFromPath(type.name));
    }
    if (type is MapType && !TypeChecker.isKnownDartType(type.valueName)) {
      imports.addAll(_getImportsFromPath(type.valueName));
    }
    return imports;
  }

  Iterable<String> _getImportsFromPath(String name) {
    final imports = <String>{};
    for (final leaf in DartType(name).leaves) {
      final projectName = pubspecConfig.projectName;
      final reCaseFieldName = CaseUtil(leaf);
      final paths = yamlConfig.getPathsForName(pubspecConfig, leaf);
      for (final path in paths) {
        String pathWithPackage;
        if (path.startsWith('package:')) {
          pathWithPackage = path;
        } else {
          pathWithPackage = 'package:$projectName/$path';
        }

        print("projectName: $projectName");

        if (path.endsWith('.dart')) {
          imports.add("import '$pathWithPackage';");
        } else {
          imports.add("import '$pathWithPackage/${reCaseFieldName.snakeCase}.dart';");
        }
      }
    }
    return imports.toList()..sort((i1, i2) => i1.compareTo(i2));
  }
}
