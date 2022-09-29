import 'package:flutter_mvr/generator/field.dart';

import 'model.dart';

class ObjectModel extends Model {
  final List<Field> fields;
  final bool createdAt;
  final bool updatedAt;

  ObjectModel({
    required super.name,
    required this.fields,
    super.path,
    super.baseDirectory,
    super.extraImports,
    super.extraAnnotations,
    super.extendsModel,
    this.createdAt = false,
    this.updatedAt = false,
    super.description,
  }) : super();
}
