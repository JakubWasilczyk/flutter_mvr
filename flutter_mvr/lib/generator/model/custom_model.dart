import 'model.dart';

class CustomModel extends Model {
  CustomModel({
    required super.name,
    super.path,
    super.baseDirectory,
    super.extraImports,
    super.extraAnnotations,
  }) : super();
}
