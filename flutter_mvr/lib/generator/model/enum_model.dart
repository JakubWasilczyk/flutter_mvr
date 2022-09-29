import 'model.dart';

class EnumModel extends Model {
  final List<EnumField>? fields;
  final bool generateMap;
  final bool generateExtensions;

  EnumModel({
    required super.name,
    super.path,
    super.baseDirectory,
    this.fields,
    super.extraImports,
    super.extraAnnotations,
    this.generateMap = false,
    this.generateExtensions = false,
    super.description,
  }) : super();

  @override
  String toString() {
    return """
    EnumModel(
      base: ${super.toString()},
      fields: $fields,
      generateMap: $generateMap,
      generateExtensions: $generateExtensions,
    )""";
  }
}

class EnumField {
  final String name;
  final String serializedName;
  final String? value;
  final String? description;

  EnumField._({
    required this.name,
    required this.serializedName,
    required this.value,
    required this.description,
  });

  factory EnumField({
    required String name,
    required String rawName,
    String? value,
    String? description,
  }) =>
      EnumField._(
        name: name,
        serializedName: rawName,
        value: value,
        description: description,
      );

  @override
  String toString() {
    return """
    EnumField(
      name: $name,
      serializedName: $serializedName,
      value: $value,
      description: $description,
    )
    """;
  }
}
