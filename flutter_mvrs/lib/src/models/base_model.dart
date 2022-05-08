import 'change_tracker.dart';

abstract class BaseModel<T> extends ChangeTracker {
  final T _id;

  BaseModel({required T id}) : _id = id;

  T get id => get('id', _id);
  set id(T value) => set('id', value);
}
