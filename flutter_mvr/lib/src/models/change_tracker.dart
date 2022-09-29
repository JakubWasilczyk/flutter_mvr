mixin ChangeTracker {
  final Map<String, dynamic> changes = {};

  bool get hasChanges => changes.isNotEmpty;

  void set(String field, dynamic value) {
    changes[field] = value;
  }

  dynamic get(String field, [dynamic orValue]) {
    if (changes.containsKey(field)) return changes[field];
    return orValue;
  }

  void reset() => changes.clear();
}
