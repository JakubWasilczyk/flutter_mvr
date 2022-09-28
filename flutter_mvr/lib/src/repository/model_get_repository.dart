abstract class ModelGetRepository<T> {
  Future<T?> get(String id);
  Future<List<T>> getList();
}

abstract class ModelGetParamRepository<T, P> {
  Future<T?> get(String id, P param);
  Future<List<T>> getList(P param);
}
