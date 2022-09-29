import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_mvr/generator/field.dart';
import 'package:flutter_mvr/generator/model/custom_model.dart';
import 'package:flutter_mvr/generator/model/enum_model.dart';
import 'package:flutter_mvr/generator/model/json_converter_model.dart';
import 'package:flutter_mvr/generator/model/model.dart';
import 'package:flutter_mvr/generator/model/object_model.dart';
import 'package:flutter_mvr/generator/pubspec_config.dart';
import 'package:flutter_mvr/generator/util/list_extensions.dart';
import 'package:flutter_mvr/generator/writer/base_object_model_writer.dart';
import 'package:flutter_mvr/generator/writer/enum_model_writer.dart';
import 'package:flutter_mvr/generator/writer/object_model_writer.dart';
import 'package:flutter_mvr/generator/yml_generator_config.dart';
import 'package:path/path.dart';

Future<void> main(List<String> args) async {
  final argParser = ArgParser()
    ..addOption('path',
        help:
            'Override the default model configuration path. This value will be used instead of the default OR what you have configured in pubspec.yaml')
    ..addFlag('help', help: 'Displays this help screen', defaultsTo: false, negatable: false);

  final results = argParser.parse(args);
  if (results['help']) {
    print(argParser.usage);
    return;
  }

  final pubspecYaml = File(join(Directory.current.path, 'pubspec.yaml'));
  if (!pubspecYaml.existsSync()) {
    throw Exception('This program should be run from the root of a flutter/dart project');
  }
  final pubspecContent = pubspecYaml.readAsStringSync();
  final pubspecConfig = PubspecConfig(pubspecContent);

  final configPath = results['path'] ?? pubspecConfig.configPath;
  File configFile;
  if (isAbsolute(configPath)) {
    configFile = File(configPath);
  } else {
    configFile = File(join(Directory.current.path, configPath));
  }

  if (!configFile.existsSync()) {
    throw Exception('This program requires a config file. `$configPath`');
  }
  final modelGeneratorContent = configFile.readAsStringSync();
  final modelGeneratorConfig = YmlGeneratorConfig(pubspecConfig, modelGeneratorContent);

  for (final model in modelGeneratorConfig.models) {
    if (model is JsonConverterModel) {
      continue;
    } else if (model is CustomModel) {
      continue;
    }
    print('Generating Model for ${model.name}');
    await writeToFiles(model, pubspecConfig, modelGeneratorConfig);
    print('Generating Base Model for ${model.name}');
    await writeBaseToFiles(model, pubspecConfig, modelGeneratorConfig);
  }
  print('Done!!!');
}

Future<void> writeToFiles(Model model, PubspecConfig pubspecConfig, YmlGeneratorConfig modelGeneratorConfig) async {
  final modelDirectory = Directory(join('lib', model.baseDirectory));
  if (!modelDirectory.existsSync()) {
    modelDirectory.createSync(recursive: true);
  }
  String? content;
  if (model is ObjectModel) {
    final extendsModelfields = <Field>[];
    var extendsModelextends = model.extendsModel;
    while (extendsModelextends != null) {
      final extendsModelextendsModel = modelGeneratorConfig.models
          .firstWhereOrNull((element) => element.name == extendsModelextends) as ObjectModel?; // ignore: avoid_as
      extendsModelfields.addAll(extendsModelextendsModel?.fields ?? []);
      extendsModelextends = extendsModelextendsModel?.extendsModel;
    }
    content = ObjectModelWriter(
      pubspecConfig,
      model,
      extendsModelfields,
      modelGeneratorConfig,
    ).write();
  } else if (model is EnumModel) {
    content = EnumModelWriter(model).write();
  }
  if (content == null) {
    throw Exception(
        'content is null for ${model.name}. File a bug report on github. This is not normal. https://github.com/icapps/flutter-model-generator/issues');
  }
  File file;
  if (model.path == null) {
    file = File(join('lib', model.baseDirectory, '${model.fileName}.dart'));
  } else {
    file = File(join('lib', model.path, '${model.fileName}.dart'));
  }
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  await file.writeAsString(content);
}

Future<void> writeBaseToFiles(Model model, PubspecConfig pubspecConfig, YmlGeneratorConfig modelGeneratorConfig) async {
  if (model is! ObjectModel) return;
  final modelDirectory = Directory(join('lib', model.baseDirectory, 'base'));
  if (!modelDirectory.existsSync()) {
    modelDirectory.createSync(recursive: true);
  }
  String? content;
  final extendsModelfields = <Field>[];
  var extendsModelextends = model.extendsModel;
  while (extendsModelextends != null) {
    final extendsModelextendsModel = modelGeneratorConfig.models
        .firstWhereOrNull((element) => element.name == extendsModelextends) as ObjectModel?; // ignore: avoid_as
    extendsModelfields.addAll(extendsModelextendsModel?.fields ?? []);
    extendsModelextends = extendsModelextendsModel?.extendsModel;
  }
  content = await BaseObjectModelWriter(
    pubspecConfig,
    model,
    extendsModelfields,
    modelGeneratorConfig,
  ).write();

  File file;
  if (model.path == null) {
    file = File(join('lib', model.baseDirectory, 'base', '${model.fileName}.base.dart'));
  } else {
    file = File(join('lib', model.path, 'base', '${model.fileName}.base.dart'));
  }
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  await file.writeAsString(content);
}
