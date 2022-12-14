import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'util/language_version.dart';

class PubspecConfig {
  static const _DEFAULT_CONFIG_PATH = 'config.yaml';
  static final _defaultBaseDirectory = 'src${Platform.pathSeparator}models';

  late String projectName;
  late String baseDirectory;
  late bool generateForGenerics;
  late String configPath;
  late bool equalsHashCode;
  late bool explicitToJson;
  late bool generateToString;
  late bool staticCreate;
  late bool uppercaseEnums;
  late bool retrofitMappers;
  late bool disallowNullForDefaults;
  LanguageVersion? languageVersion;
  final extraImports = <String>[];
  final extraAnnotations = <String>[];

  PubspecConfig(String pubspecContent) {
    final doc = loadYaml(pubspecContent);
    if (doc is! YamlMap) {
      throw Exception('Could not parse the pubspec.yaml');
    }
    final projectName = doc['name'];
    languageVersion = parseLanguageVersion(doc);

    if (projectName == null || projectName.isEmpty) {
      throw Exception('Could not parse the pubspec.yaml, project name not found');
    }

    this.projectName = projectName;
    final config = doc['flutter_mvs'];
    if (config == null) {
      baseDirectory = _defaultBaseDirectory;
      generateForGenerics = false;
      configPath = _DEFAULT_CONFIG_PATH;
      equalsHashCode = false;
      explicitToJson = true;
      generateToString = false;
      staticCreate = false;
      uppercaseEnums = true;
      retrofitMappers = false;
      disallowNullForDefaults = false;
      return;
    }

    baseDirectory = config['base_directory'] ?? _defaultBaseDirectory;
    generateForGenerics = (config['generate_for_generics'] ?? false) == true;
    configPath = config['config_path'] ?? _DEFAULT_CONFIG_PATH;
    equalsHashCode = (config['equals_and_hash_code'] ?? false) == true;
    explicitToJson = (config['explicit_to_json'] ?? true) == true;
    generateToString = (config['to_string'] ?? false) == true;
    staticCreate = (config['static_create'] ?? false) == true;
    uppercaseEnums = (config['uppercase_enums'] ?? true) == true;
    retrofitMappers = (config['retrofit_compute'] ?? false) == true;
    disallowNullForDefaults = (config['disallow_null_for_defaults'] ?? false) == true;

    final extraImports = config['extra_imports'];
    if (extraImports != null) {
      extraImports.forEach((element) => this.extraImports.add(element.toString()));
    }
    final extraAnnotations = config['extra_annotations'];
    if (extraAnnotations != null) {
      extraAnnotations.forEach((element) => this.extraAnnotations.add(element.toString()));
    }
  }

  @visibleForTesting
  static LanguageVersion? parseLanguageVersion(YamlMap doc) {
    final environmentRoot = doc['environment'];
    if (environmentRoot is! YamlMap) return null;
    final sdk = environmentRoot['sdk'];
    if (sdk is! String) return null;

    final range = VersionConstraint.parse(sdk);
    if (range is Version) {
      return LanguageVersion(range.major, range.minor, range.patch);
    } else if (range is VersionRange) {
      final min = range.min;
      if (min == null) return null;
      return LanguageVersion(min.major, min.minor, min.patch);
    }

    return null;
  }

  @override
  String toString() {
    return """
    projectName: $projectName,
    baseDirectory: $baseDirectory,
    generateForGenerics: $generateForGenerics,
    configPath: $configPath,
    equalsHashCode: $equalsHashCode,
    explicitToJson: $explicitToJson,
    generateToString: $generateToString,
    staticCreate: $staticCreate,
    uppercaseEnums: $uppercaseEnums,
    retrofitMappers: $retrofitMappers,
    disallowNullForDefaults: $disallowNullForDefaults,
    languageVersion: $languageVersion,
    extraImports: $extraImports,
    extraAnnotations: $extraAnnotations""";
  }
}
