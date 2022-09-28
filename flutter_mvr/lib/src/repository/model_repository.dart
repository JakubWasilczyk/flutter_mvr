import 'package:flutter_mvr/flutter_mvr.dart';

abstract class ModelRepository<T> with ModelGetRepository<T>, ModelSetRepository<T> {}

abstract class ModelParamRepository<T, P> with ModelGetParamRepository<T, P>, ModelSetParamRepository<T, P> {}
