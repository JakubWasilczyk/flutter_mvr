import 'base_type.dart';

class MapType extends BaseType {
  final String valueName;

  MapType({required String key, required this.valueName}) : super(key);

  @override
  String toString() {
    return "${super.toString()}, valueName: $valueName";
  }
}
