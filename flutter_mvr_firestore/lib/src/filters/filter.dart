import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mvr/flutter_mvr.dart';

abstract class Filter implements BaseFilter {
  Query<T> apply<T>(Query<T> query);

  dynamic convert(dynamic value) {
    if (value is DateTime) return Timestamp.fromDate(value);
    return value;
  }
}

abstract class Where extends Filter {
  final Object field;
  final dynamic _value;

  dynamic get value => convert(_value);

  Where(this.field, {dynamic value}) : _value = value;
}
