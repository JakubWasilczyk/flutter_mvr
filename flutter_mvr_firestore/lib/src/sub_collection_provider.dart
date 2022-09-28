import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mvr/flutter_mvr.dart';
import 'package:flutter_mvr_firestore/src/base_collection_provider.dart';

import 'filters/filter.dart';

abstract class SubCollectionProvider<T extends BaseModel, P> extends BaseCollectionProvider<T> {
  SubCollectionProvider(FirebaseFirestore firestore) : super(firestore);

  String getParentPath(P parent) => parent.toString();

  Future<T?> get(P parent, String id) => super.baseGet(getParentPath(parent), id);

  Future<T?> getWhere(P parent, List<Filter>? filters) => super.baseGetWhere(getParentPath(parent), filters);

  Future<List<T>> getList(P parent, {List<Filter>? filters}) =>
      super.baseGetList(getParentPath(parent), filters: filters);

  Future<String> save(P parent, T model) => super.baseSave(getParentPath(parent), model);

  Future<void> delete(P parent, T model) => super.baseDelete(getParentPath(parent), model);

  Stream<T?> listen(P parent, String id) => super.baseListen(getParentPath(parent), id);

  Stream<T?> listenWhere(P parent, List<Filter>? filters) => super.baseListenWhere(getParentPath(parent), filters);

  Stream<List<T>> listenList(P parent, {List<Filter>? filters}) =>
      super.baseListenList(getParentPath(parent), filters: filters);
}
