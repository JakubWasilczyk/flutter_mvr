import 'package:flutter_mvrs_firestore/flutter_mvrs_firestore.dart';

mixin ModelSave<T extends BaseModel> on BaseFirestore<T> {
  Future<String> _create(T model) async {
    final ref = await collection().add(model);
    return ref.id;
  }

  Future<String> _update(T model) async {
    final ref = doc(model.id);
    await ref.set(model, SetOptions(merge: true));
    return ref.id;
  }

  Future<String> save(T model) {
    if (model.id == null) return _create(model);
    return _update(model);
  }
}

mixin ModelParamSave<P extends PathProvider, T extends BaseModel> on BaseFirestore<T> {
  Future<String> _create(P parent, T model) async {
    final ref = await collection(parent.toPath()).add(model);
    return ref.id;
  }

  Future<String> _update(P parent, T model) async {
    final ref = doc(model.id, parent.toPath());
    await ref.set(model, SetOptions(merge: true));
    return ref.id;
  }

  Future<String> save(P parent, T model) {
    if (model.id == null) return _create(parent, model);
    return _update(parent, model);
  }
}
