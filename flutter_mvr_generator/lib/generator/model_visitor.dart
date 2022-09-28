import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';

class ModelVisitor extends SimpleElementVisitor<void> {
  late String className;
  final Map<String, ParameterElement> params = {};
  final Map<String, DartType> fields = {};

  @override
  void visitConstructorElement(ConstructorElement element) {
    try {
      if (element.isFactory) return;
      final elementReturnType = element.type.returnType.toString();
      className = elementReturnType.replaceFirst('*', '');
      for (final param in element.parameters) {
        if (!param.isFinal) params[param.name] = param;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void visitFieldElement(FieldElement element) {
    try {
      fields[element.name] = element.type;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
