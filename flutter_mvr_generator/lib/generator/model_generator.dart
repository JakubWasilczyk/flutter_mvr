import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mvrs/flutter_mvrs.dart';
import 'package:source_gen/source_gen.dart';

import 'model_visitor.dart';

class ModelGenerator extends GeneratorForAnnotation<Model> {
  final String _template = "assets/model_template.dart.tmpl";

  bool hasCreatedAt = false;
  bool hasUpdatedAt = false;
  List<String> fromJsonIgnore = [];
  List<String> toJsonIgnore = [];
  Map<String, String> defaultValues = {};
  Map<String, ParameterElement> params = {};

  static const jsonIgnoreChecker = TypeChecker.fromRuntime(JsonIgnore);
  static const fromJsonIgnoreChecker = TypeChecker.fromRuntime(FromJsonIgnore);
  static const toJsonIgnoreChecker = TypeChecker.fromRuntime(ToJsonIgnore);
  static const defaultValueChecker = TypeChecker.fromRuntime(DefaultValue);

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    try {
      final visitor = ModelVisitor();
      element.visitChildren(visitor);

      hasCreatedAt = annotation.read('createdAt').boolValue;
      hasUpdatedAt = annotation.read('updatedAt').boolValue;
      fromJsonIgnore = annotation.read('fromJsonIgnore').listValue.map((e) => e.toStringValue()!).toList();
      toJsonIgnore = annotation.read('toJsonIgnore').listValue.map((e) => e.toStringValue()!).toList();
      defaultValues = annotation.read('defaultValues').mapValue.map(
            (e, v) => MapEntry(e!.toStringValue()!, v!.toStringValue() ?? ""),
          );
      defaultValues.removeWhere((key, value) => key.isEmpty || value.isEmpty);
      params = visitor.params;

      params.forEach((key, value) {
        if (defaultValueChecker.hasAnnotationOf(value)) {
          final defaultAnnotation = defaultValueChecker.firstAnnotationOf(value, throwOnUnresolved: false);
          final field = defaultAnnotation?.getField("declaration");
          final defaultValue = field?.toStringValue() ?? "";
          defaultValues[key] = defaultValue;
        }
        if (fromJsonIgnoreChecker.hasAnnotationOf(value)) {
          if (!fromJsonIgnore.contains(key)) fromJsonIgnore.add(key);
        }
        if (toJsonIgnoreChecker.hasAnnotationOf(value)) {
          if (!toJsonIgnore.contains(key)) toJsonIgnore.add(key);
        }
        if (jsonIgnoreChecker.hasAnnotationOf(value)) {
          if (!fromJsonIgnore.contains(key)) fromJsonIgnore.add(key);
          if (!toJsonIgnore.contains(key)) toJsonIgnore.add(key);
        }
      });
      params.forEach((key, value) {
        if (defaultValues.containsKey(key)) return;
        if (!value.hasDefaultValue) return;
        defaultValues[key] = value.defaultValueCode ?? "";
      });

      final className = visitor.className;
      final baseClassName = "Base$className";
      //final fields = visitor.fields;
      String idType = params['id'] != null ? params['id']!.type.toString() : 'void';
      idType = idType.replaceFirst('*', '');

      String template = await rootBundle.loadString(_template);
      template = template.replaceAll("{{baseClassName}}", baseClassName);
      template = template.replaceAll("{{className}}", className);
      template = template.replaceAll("{{idType}}", idType);
      template = template.replaceAll("{{mixins}}", generateMixins());

      template = template.replaceAll("{{fields}}", generateFields());
      template = template.replaceAll("{{constructorFields}}", generateConstructorFields());

      final fieldsLoad = generateFieldsLoad();
      final superConstructor = params.containsKey('id') ? "super(id: id)" : "super(id: null)";

      template = template.replaceAll("{{fieldsLoad}}", fieldsLoad);
      template = template.replaceAll("{{superConstructor}}", superConstructor);

      template = template.replaceAll("{{getters}}", generateGetters());
      template = template.replaceAll("{{setters}}", generateSetters());

      template = template.replaceAll("{{toJson}}", generateToJson());
      template = template.replaceAll("{{fromJson}}", generateFromJson());

      template = template.replaceAll("{{equatable}}", generateEquatable());

      return template;
    } catch (e) {
      print(e.toString());
      return "//ERROR";
    }
  }

  String generateMixins() {
    final buffer = StringBuffer();

    List<String> _mixins = [];
    if (hasCreatedAt) _mixins.add('CreatedAt');
    if (hasUpdatedAt) _mixins.add('UpdatedAt');
    if (_mixins.isNotEmpty) {
      String _mixin = '';
      for (final mixin in _mixins) {
        _mixin += ", $mixin";
      }
      buffer.write(" with ${_mixin.substring(1).trim()}");
    }

    return buffer.toString();
  }

  String generateFields() {
    final buffer = StringBuffer();
    final overrides = [];
    if (hasCreatedAt) overrides.add("createdAt");
    if (hasUpdatedAt) overrides.add("updatedAt");

    for (final param in params.keys) {
      if (param == 'id') continue;
      String paramType = params[param]!.type.toString().replaceFirst('*', '');
      if (defaultValues.containsKey(param)) paramType = paramType.replaceAll("?", "");
      if (overrides.contains(param)) {
        buffer.writeln("@override");
        buffer.writeln("final $paramType $param;");
      } else {
        buffer.writeln("final $paramType _$param;");
      }
    }

    return buffer.toString();
  }

  String generateConstructorFields() {
    if (params.isEmpty) return "";
    final buffer = StringBuffer();
    final directParams = [];
    if (hasCreatedAt) directParams.add("createdAt");
    if (hasUpdatedAt) directParams.add("updatedAt");

    buffer.write("{");
    for (final param in params.keys) {
      final value = params[param]!;
      final required = value.isRequiredNamed ? 'required ' : '';

      if (directParams.contains(param)) {
        buffer.writeln("${required}this.$param,");
      } else {
        String paramType = value.type.toString().replaceFirst('*', '');

        if (defaultValues.containsKey(param)) paramType = paramType.replaceAll("?", "") + "?";

        buffer.writeln("$required$paramType $param,");
      }
    }
    buffer.write("}");
    return buffer.toString();
  }

  String generateFieldsLoad() {
    final buffer = StringBuffer();
    final directParams = ['id'];
    if (hasCreatedAt) directParams.add("createdAt");
    if (hasUpdatedAt) directParams.add("updatedAt");

    for (final param in params.keys) {
      final value = params[param]!;
      if (directParams.contains(param)) continue;
      String defaultValue = defaultValues[param] ?? "";
      if (defaultValue.isNotEmpty) defaultValue = " ?? $defaultValue";

      buffer.writeln("_$param = $param$defaultValue,");
    }
    return buffer.toString();
  }

  String generateGetters() {
    final buffer = StringBuffer();
    for (final param in params.keys) {
      if (param == 'id') continue;
      if (param == 'createdAt' && hasCreatedAt) continue;
      if (param == 'updatedAt' && hasUpdatedAt) continue;
      final value = params[param]!;
      String paramType = params[param]!.type.toString().replaceFirst('*', '');
      if (defaultValues.containsKey(param)) paramType = paramType.replaceAll("?", "");
      buffer.writeln("$paramType get $param => get('$param', _$param);");
    }
    return buffer.toString();
  }

  String generateSetters() {
    final buffer = StringBuffer();
    for (final param in params.keys) {
      if (param == 'id') continue;
      if (param == 'createdAt' && hasCreatedAt) continue;
      if (param == 'updatedAt' && hasUpdatedAt) continue;
      final value = params[param]!;
      String paramType = params[param]!.type.toString().replaceFirst('*', '');
      if (defaultValues.containsKey(param)) paramType = paramType.replaceAll("?", "");
      buffer.writeln("set $param($paramType value) => set('$param', value);");
    }
    return buffer.toString();
  }

  String generateToJson() {
    final buffer = StringBuffer();
    for (final param in params.keys) {
      if (toJsonIgnore.contains(param)) continue;
      buffer.writeln("'$param': $param,");
    }
    return buffer.toString();
  }

  String generateFromJson() {
    final buffer = StringBuffer();
    for (final param in params.keys) {
      if (fromJsonIgnore.contains(param)) continue;
      buffer.write("$param: json['$param'],");
    }
    return buffer.toString();
  }

  String generateEquatable() {
    final buffer = StringBuffer();
    buffer.writeln("@override");
    buffer.writeln("List<Object?> get props => [");
    for (final param in params.keys) {
      buffer.writeln("$param,");
    }
    buffer.writeln("];");
    return buffer.toString();
  }
}
