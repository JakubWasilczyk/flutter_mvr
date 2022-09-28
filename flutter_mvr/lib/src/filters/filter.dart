abstract class BaseFilter {}

abstract class BaseWhere implements BaseFilter {
  final Object field;
  final dynamic value;

  BaseWhere(this.field, {this.value});
}

enum OrderByDirection { ascending, descending }

abstract class BaseOrderBy implements BaseFilter {
  final Object field;
  final OrderByDirection direction;

  BaseOrderBy(this.field, this.direction);

  bool get isDescending => direction == OrderByDirection.descending;
  bool get isAscending => direction == OrderByDirection.ascending;
}
