import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mvr/flutter_mvr.dart';

import 'filter.dart';

class Limit extends Filter {
  final int limit;
  Limit(this.limit);

  @override
  Query<T> apply<T>(Query<T> query) => query.limit(limit);
}

class LimitLast extends Filter {
  final int limit;
  LimitLast(this.limit);

  @override
  Query<T> apply<T>(Query<T> query) => query.limitToLast(limit);
}

class OrderBy extends Filter {
  final Object field;
  final OrderByDirection direction;

  OrderBy(this.field, this.direction);

  bool get isDescending => direction == OrderByDirection.descending;
  bool get isAscending => direction == OrderByDirection.ascending;

  @override
  Query<T> apply<T>(Query<T> query) => query.orderBy(field, descending: isDescending);
}

class IsEqualTo extends Where {
  IsEqualTo(Object field, Object value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, isEqualTo: value);
}

class IsNotEqualTo extends Where {
  IsNotEqualTo(Object field, Object value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, isNotEqualTo: value);
}

class IsLessThan extends Where {
  IsLessThan(Object field, Object value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, isLessThan: value);
}

class IsLessThanOrEqualTo extends Where {
  IsLessThanOrEqualTo(Object field, Object value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, isLessThanOrEqualTo: value);
}

class IsGreaterThan extends Where {
  IsGreaterThan(Object field, Object value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, isGreaterThan: value);
}

class IsGreaterThanOrEqualTo extends Where {
  IsGreaterThanOrEqualTo(Object field, Object value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, isGreaterThanOrEqualTo: value);
}

class ArrayContains extends Where {
  ArrayContains(Object field, List<Object> value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, arrayContains: value);
}

class ArrayContainsAny extends Where {
  ArrayContainsAny(Object field, List<Object> value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, arrayContainsAny: value);
}

class WhereIn extends Where {
  WhereIn(Object field, List<Object> value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, whereIn: value);
}

class WhereNotIn extends Where {
  WhereNotIn(Object field, List<Object> value) : super(field, value: value);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, whereNotIn: value);
}

class IsNull extends Where {
  IsNull(Object field) : super(field);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, isNull: true);
}

class IsNotNull extends Where {
  IsNotNull(Object field) : super(field);

  @override
  Query<T> apply<T>(Query<T> query) => query.where(field, isNull: false);
}

class EndAtDocument extends Filter {
  final DocumentSnapshot document;
  EndAtDocument(this.document) : super();

  @override
  Query<T> apply<T>(Query<T> query) => query.endAtDocument(document);
}

class EndAt extends Filter {
  final List<Object?> values;
  EndAt(this.values) : super();

  @override
  Query<T> apply<T>(Query<T> query) => query.endAt(values);
}

class EndBeforeDocument extends Filter {
  final DocumentSnapshot document;
  EndBeforeDocument(this.document) : super();

  @override
  Query<T> apply<T>(Query<T> query) => query.endBeforeDocument(document);
}

class EndBefore extends Filter {
  final List<Object?> values;
  EndBefore(this.values) : super();

  @override
  Query<T> apply<T>(Query<T> query) => query.endBefore(values);
}

class StartAfterDocument extends Filter {
  final DocumentSnapshot document;
  StartAfterDocument(this.document) : super();

  @override
  Query<T> apply<T>(Query<T> query) => query.startAfterDocument(document);
}

class StartAfter extends Filter {
  final List<Object?> values;
  StartAfter(this.values) : super();

  @override
  Query<T> apply<T>(Query<T> query) => query.startAfter(values);
}

class StartAtDocument extends Filter {
  final DocumentSnapshot document;
  StartAtDocument(this.document) : super();

  @override
  Query<T> apply<T>(Query<T> query) => query.startAtDocument(document);
}

class StartAt extends Filter {
  final List<Object?> values;
  StartAt(this.values) : super();

  @override
  Query<T> apply<T>(Query<T> query) => query.startAt(values);
}
