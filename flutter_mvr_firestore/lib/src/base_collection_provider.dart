import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mvr/flutter_mvr.dart';

import 'base_firestore.dart';
import 'filters/filter.dart';
import 'filters/where.dart';

abstract class BaseCollectionProvider<T extends BaseModel> extends BaseFirestore<T> {
  BaseCollectionProvider(FirebaseFirestore firestore) : super(firestore);

  Future<T?> baseGet(String parent, String id) => doc(id, parent).get().then((v) => v.data());

  Future<T?> baseGetWhere(String parent, List<Filter>? filters) async {
    Query<T> query = collection(parent);
    filters?.removeWhere((element) => (element is Limit) || (element is LimitLast));
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    query = query.limit(1);
    final docs = await query.get().then((v) => v.docs);
    return docs.isEmpty ? null : docs.first.data();
  }

  Future<List<T>> baseGetList(String parent, {List<Filter>? filters}) async {
    Query<T> query = collection(parent);
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    final docs = await query.get().then((v) => v.docs);
    return docs.map((e) => e.data()).toList();
  }

  Future<String> _create(String parent, T model) async {
    final ref = await collection(parent).add(model);
    return ref.id;
  }

  Future<String> _update(String parent, T model) async {
    final ref = doc(model.id, parent);
    await ref.set(model, SetOptions(merge: true));
    return ref.id;
  }

  Future<String> baseSave(String parent, T model) {
    if (model.id == null) return _create(parent, model);
    return _update(parent, model);
  }

  Future<void> baseDelete(String parent, T model) async {
    return doc(model.id, parent).delete();
  }

  Stream<T?> baseListen(String parent, String id) {
    return doc(id, parent).snapshots().map((event) => event.data());
  }

  Stream<T?> baseListenWhere(String parent, List<Filter>? filters) {
    Query<T> query = collection(parent);
    filters?.removeWhere((element) => (element is Limit) || (element is LimitLast));
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    query = query.limit(1);
    return query.snapshots().map((e) => e.size == 0 ? null : e.docs.first).map((item) => item?.data());
  }

  Stream<List<T>> baseListenList(String parent, {List<Filter>? filters}) {
    Query<T> query = collection(parent);
    filters = applyDefaultOrderBy(filters);
    query = applyFilters(query, filters);
    return query.snapshots().map((e) => e.docs).map((list) => list.map((e) => e.data()).toList());
  }
}
