import 'model/field_type/base_type.dart';
import 'util/case_util.dart';
import 'util/keyword_helper.dart';

class Field {
  final String name;
  final String serializedName;
  final BaseType type;
  final bool isRequired;
  final bool fromJsonIgnore;
  final bool toJsonIgnore;
  final String? description;
  final String? fromJson;
  final String? toJson;
  final bool ignoreEquality;
  final String? defaultValue;

  bool get hasDefaultValue => defaultValue != null;

  Field({
    required String name,
    required this.type,
    required this.isRequired,
    required this.ignoreEquality,
    this.fromJsonIgnore = false,
    this.toJsonIgnore = false,
    this.description,
    this.fromJson,
    this.toJson,
    this.defaultValue,
    String? jsonKey,
  })  : serializedName = jsonKey ?? name,
        name = CaseUtil(KeywordHelper.instance.getCorrectKeyword(name)).camelCase;
}
