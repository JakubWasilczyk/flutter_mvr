import 'package:flutter_mvrs_firestore/flutter_mvrs_firestore.dart';

mixin ModelListen<T extends BaseModel> on BaseFirestore<T> {
  Stream<T?> listen(String id) {
    return doc(id).snapshots().map((event) => event.data());
  }

  Stream<T?> listenWhere(List<Filter>? filters) {
    Query<T> query = collection();
    filters?.removeWhere((element) => (element is Limit) || (element is LimitLast));
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    query = query.limit(1);
    return query.snapshots().map((e) => e.size == 0 ? null : e.docs.first).map((item) => item?.data());
  }

  Stream<List<T>> listenList({List<Filter>? filters}) {
    Query<T> query = collection();
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    return query.snapshots().map((e) => e.docs).map((list) => list.map((e) => e.data()).toList());
  }
}

mixin ModelParamListen<P extends PathProvider, T extends BaseModel> on BaseFirestore<T> {
  Stream<T?> listen(P parent, String id) {
    return doc(id, parent.toPath()).snapshots().map((event) => event.data());
  }

  Stream<T?> listenWhere(P parent, List<Filter>? filters) {
    Query<T> query = collection(parent.toPath());
    filters?.removeWhere((element) => (element is Limit) || (element is LimitLast));
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    query = query.limit(1);
    return query.snapshots().map((e) => e.size == 0 ? null : e.docs.first).map((item) => item?.data());
  }

  Stream<List<T>> listenList(P parent, {List<Filter>? filters}) {
    Query<T> query = collection(parent.toPath());
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    return query.snapshots().map((e) => e.docs).map((list) => list.map((e) => e.data()).toList());
  }
}
