import 'package:flutter_mvrs_firestore/flutter_mvrs_firestore.dart';

abstract class BaseFirestore<T extends BaseModel> {
  final FirebaseFirestore firestore;

  BaseFirestore(this.firestore);

  String get collectionName;
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T model);

  bool get hasOrderBy => orderBy != null;
  String? get orderBy => null;
  OrderByDirection get orderByDirection => OrderByDirection.ascending;

  List<Filter>? applyDefaultOrderBy(List<Filter>? filters) {
    if (!hasOrderBy) return filters;
    if (filters != null) {
      for (final filter in filters) {
        if (filter is OrderBy) return filters;
      }
    }
    final result = (filters ?? <Filter>[]);
    result.add(OrderBy(orderBy!, orderByDirection));
    return result;
  }

  Query<T> applyFilters(Query<T> query, List<Filter>? filters) {
    if (filters == null) return query;
    for (final filter in filters) {
      query = filter.apply(query);
    }
    return query;
  }

  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;
    json['id'] = snapshot.id;
    json['path'] = snapshot.reference.path;
    return fromJson(sanitizeFromJson(json));
  }

  Map<String, dynamic> toFirestore(T model, SetOptions? options) {
    Map<String, dynamic> json = toJson(model);
    if (json.containsKey('id')) json.remove('id');
    if (json.containsKey('path')) json.remove('path');
    if (model is CreatedAt) json[CreatedAt.key] ??= Timestamp.now();
    if (model is UpdatedAt) json[UpdatedAt.key] = Timestamp.now();
    return sanitizeToJson(json);
  }

  Map<String, dynamic> sanitizeToJson(Map<String, dynamic> json) {
    for (final key in json.keys) {
      if (json[key] is DateTime) json[key] = Timestamp.fromDate(json[key]);
    }
    return json;
  }

  Map<String, dynamic> sanitizeFromJson(Map<String, dynamic> json) {
    for (final key in json.keys) {
      if (json[key] is Timestamp) json[key] = (json[key] as Timestamp).toDate();
    }
    return json;
  }

  String sanitizePath(String path) {
    if (path.startsWith('/')) path = path.substring(1);
    if (path.endsWith('/')) path = path.substring(0, path.length - 1);
    return path;
  }

  CollectionReference<T> collection([String parent = ""]) {
    final path = sanitizePath(parent + '/' + collectionName);
    return firestore.collection(path).withConverter(fromFirestore: fromFirestore, toFirestore: toFirestore);
  }

  DocumentReference<T> doc(String id, [String parent = ""]) => collection(parent).doc(id);
}
