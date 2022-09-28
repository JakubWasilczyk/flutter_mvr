import 'package:flutter_mvrs_firestore/flutter_mvrs_firestore.dart';

mixin ModelGet<T extends BaseModel> on BaseFirestore<T> {
  Future<T?> get(String id) => doc(id).get().then((v) => v.data());

  Future<T?> getWhere(List<Filter>? filters) async {
    Query<T> query = collection();
    filters?.removeWhere((element) => (element is Limit) || (element is LimitLast));
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    query = query.limit(1);
    final docs = await query.get().then((v) => v.docs);
    return docs.isEmpty ? null : docs.first.data();
  }

  Future<List<T>> getList({List<Filter>? filters}) async {
    Query<T> query = collection();
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    final docs = await query.get().then((v) => v.docs);
    return docs.map((e) => e.data()).toList();
  }
}

mixin ModelParamGet<P extends PathProvider, T extends BaseModel> on BaseFirestore<T> {
  Future<T?> get(P parent, String id) => doc(id, parent.toPath()).get().then((v) => v.data());

  Future<T?> getWhere(P parent, List<Filter>? filters) async {
    Query<T> query = collection(parent.toPath());
    filters?.removeWhere((element) => (element is Limit) || (element is LimitLast));
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    query = query.limit(1);
    final docs = await query.get().then((v) => v.docs);
    return docs.isEmpty ? null : docs.first.data();
  }

  Future<List<T>> getList(P parent, {List<Filter>? filters}) async {
    Query<T> query = collection(parent.toPath());
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    final docs = await query.get().then((v) => v.docs);
    return docs.map((e) => e.data()).toList();
  }
}
