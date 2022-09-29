import 'package:flutter_mvr/generator/model/field_type/string_type.dart';
import 'package:flutter_mvr/generator/util/list_extensions.dart';

import '../field.dart';
import '../model/field_type/array_type.dart';
import '../model/field_type/map_type.dart';
import '../model/object_model.dart';
import '../pubspec_config.dart';
import '../yml_generator_config.dart';

class BaseObjectModelWriter {
  final PubspecConfig pubspecConfig;
  final ObjectModel jsonModel;
  final List<Field> extendsFields;
  final YmlGeneratorConfig yamlConfig;

  const BaseObjectModelWriter(
    this.pubspecConfig,
    this.jsonModel,
    this.extendsFields,
    this.yamlConfig,
  );

  List<Field> get fields => jsonModel.fields;
  List<Field> get fieldsNoId => fields.where((field) => field.name != 'id').toList();
  Field? get idField => fields.firstWhereOrNull((field) => field.name == 'id');

  Future<String> write() async {
    final sb = StringBuffer();

    jsonModel.fields.sort((a, b) {
      final b1 = a.isRequired ? 1 : 0;
      final b2 = b.isRequired ? 1 : 0;
      return b2 - b1;
    });

    sb.writeln();
    sb.writeln("part of '../${jsonModel.fileName}.dart';");
    sb.writeln();

    _declaration(sb);
    _fields(sb);
    sb.writeln();
    sb.writeln("  Base${jsonModel.name}({");
    _constructorFields(sb);
    sb.write("  })  : ");
    _fieldsLoad(sb);
    _superConstructor(sb);
    _constructor(sb);
    sb.writeln();
    _getters(sb);
    sb.writeln();
    _setters(sb);
    sb.writeln();
    _toJson(sb);
    sb.writeln();
    _fromJson(sb);
    sb.writeln();
    _equatable(sb);

    sb.writeln("}");

    return sb.toString();
  }

  void _declaration(StringBuffer sb) {
    final className = jsonModel.name;
    final idType = idField != null ? _getKeyType(idField!) : "void";
    final mixins = [];
    if (jsonModel.createdAt) mixins.add("CreatedAt");
    if (jsonModel.updatedAt) mixins.add("UpdatedAt");
    String mixinsString = "";
    if (mixins.isNotEmpty) {
      mixinsString += " with ";
      for (final mixin in mixins) {
        if (mixins.indexOf(mixin) != 0) mixinsString += ", ";
        mixinsString += mixin;
      }
    }
    sb.writeln("class Base$className extends BaseModel<$idType>$mixinsString {");
  }

  void _fields(StringBuffer sb) {
    for (final key in fieldsNoId) {
      sb.writeln('  final ${_getKeyType(key)} _${key.name};');
    }
  }

  void _constructorFields(StringBuffer sb) {
    for (final key in fields.where((key) => (key.isRequired && !key.hasDefaultValue))) {
      sb.writeln('    required ${_getKeyType(key)} ${key.name},');
    }
    for (final key in fields.where((key) => !(key.isRequired && !key.hasDefaultValue))) {
      sb.writeln('    ${_getKeyType(key)} ${key.name},');
    }
    if (jsonModel.createdAt) sb.writeln('    DateTime? createdAt,');
    if (jsonModel.updatedAt) sb.writeln('    DateTime? updatedAt,');
  }

  void _fieldsLoad(StringBuffer sb) {
    for (final key in fieldsNoId) {
      if (fieldsNoId.indexOf(key) != 0) sb.write("        ");
      sb.writeln('_${key.name} = ${key.name}${_ifNullDefaultValue(key)},');
    }
  }

  void _constructor(StringBuffer sb) {
    final cb = StringBuffer();
    if (jsonModel.createdAt) cb.writeln('      this.createdAt = createdAt;');
    if (jsonModel.updatedAt) cb.writeln('      this.updatedAt = updatedAt;');
    if (cb.isNotEmpty) {
      sb.writeln(" {");
      sb.write(cb);
      sb.writeln("    }");
    } else {
      sb.writeln(";");
    }
  }

  void _superConstructor(StringBuffer sb) {
    final idType = idField?.name ?? "null";
    sb.write('        super(id: $idType)');
  }

  void _getters(StringBuffer sb) {
    for (final key in fieldsNoId) {
      if (key.description != null) {
        sb.writeln('  ///${key.description}');
      }
      sb.writeln("  ${_getKeyType(key)} get ${key.name} => get('${key.name}', _${key.name});");
    }
  }

  void _setters(StringBuffer sb) {
    for (final key in fieldsNoId) {
      if (key.description != null) {
        sb.writeln('  ///${key.description}');
      }
      sb.writeln("  set ${key.name}(${_getKeyType(key)} value) => set('${key.name}', value);");
    }
  }

  void _toJson(StringBuffer sb) {
    sb.writeln("  Map<String, dynamic> toJson() => {");
    for (final key in jsonModel.fields) {
      if (key.toJsonIgnore) continue;
      sb.writeln("    '${key.serializedName}': ${key.name},");
    }
    if (jsonModel.createdAt) {
      sb.writeln("    'createdAt': createdAt,");
    }
    if (jsonModel.updatedAt) {
      sb.writeln("    'updatedAt': updatedAt,");
    }
    sb.writeln("  };");
  }

  void _fromJson(StringBuffer sb) {
    sb.writeln("  static ${jsonModel.name} fromJson(Map<String, dynamic> json) => ${jsonModel.name}(");
    for (final key in jsonModel.fields) {
      if (key.fromJsonIgnore) continue;
      sb.writeln("    ${key.name}: json['${key.serializedName}'],");
    }
    if (jsonModel.createdAt) {
      sb.writeln("    createdAt: json['createdAt'],");
    }
    if (jsonModel.updatedAt) {
      sb.writeln("    updatedAt: json['updatedAt'],");
    }
    sb.writeln("  );");
  }

  void _equatable(StringBuffer sb) {
    sb.writeln("  @override");
    sb.writeln("  List<Object?> get props => [");
    for (final key in jsonModel.fields) {
      sb.writeln("    ${key.name},");
    }
    if (jsonModel.createdAt) sb.writeln("    createdAt,");
    if (jsonModel.updatedAt) sb.writeln("    updatedAt,");
    sb.writeln("  ];");
  }

  String _getKeyType(Field key) {
    final nullableFlag = key.isRequired || key.type.name == 'dynamic' ? '' : '?';
    final keyType = key.type;
    if (keyType is ArrayType) {
      return 'List<${keyType.name}>$nullableFlag';
    } else if (keyType is MapType) {
      return 'Map<${keyType.name}, ${keyType.valueName}>$nullableFlag';
    } else {
      return '${keyType.name}$nullableFlag';
    }
  }

  String _ifNullDefaultValue(Field key) {
    if (key.hasDefaultValue) {
      String value = key.defaultValue ?? "''";
      if (key.type is StringType) value = "'$value'";
      return ' ?? $value';
    } else {
      return '';
    }
  }
}
