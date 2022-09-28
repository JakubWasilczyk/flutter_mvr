import 'package:flutter_mvr_firestore/flutter_mvr_firestore.dart';

mixin ModelDelete<T extends BaseModel> on BaseFirestore<T> {
  Future<void> delete(T model) async {
    return doc(model.id).delete();
  }
}

mixin ModelParamDelete<P extends PathProvider, T extends BaseModel> on BaseFirestore<T> {
  Future<void> delete(P parent, T model) async {
    return doc(model.id, parent.toPath()).delete();
  }
}
