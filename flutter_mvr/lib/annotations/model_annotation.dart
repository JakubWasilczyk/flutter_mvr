class Model {
  final bool createdAt;
  final bool updatedAt;
  @Deprecated("Use the toJsonIgnore or jsonIgnore annotation on the field")
  final List<String> toJsonIgnore;
  @Deprecated("Use the fromJsonIgnore or jsonIgnore annotation on the field")
  final List<String> fromJsonIgnore;
  final Map<String, String> defaultValues;

  const Model({
    this.createdAt = false,
    this.updatedAt = false,
    this.toJsonIgnore = const [],
    this.fromJsonIgnore = const [],
    this.defaultValues = const {},
  });
}

const model = Model();
