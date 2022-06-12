abstract class ChangeTracker {
  final Map<String, dynamic> changes = {};

  bool get hasChanges => changes.isNotEmpty;

  void set(String field, dynamic value) {
    changes[field] = value;
  }

  dynamic get(String field, [dynamic orValue]) {
    return changes[field] ?? orValue;
  }

  void reset() => changes.clear();
}
