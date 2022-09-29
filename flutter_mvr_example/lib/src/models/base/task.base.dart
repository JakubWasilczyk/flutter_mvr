
part of '../task.dart';

class BaseTask extends BaseModel<String?> with CreatedAt, UpdatedAt {
  final String? _title;
  final String? _subtitle;
  final bool? _isChecked;
  final TestType? _testType;

  BaseTask({
    String? id,
    String? title,
    String? subtitle,
    bool? isChecked,
    TestType? testType,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : _title = title ?? 'test',
        _subtitle = subtitle,
        _isChecked = isChecked ?? false,
        _testType = testType ?? const TestType("stoca"),
        super(id: id) {
      this.createdAt = createdAt;
      this.updatedAt = updatedAt;
    }

  ///The Task's Title
  String? get title => get('title', _title);
  ///The Task's Subtitle
  String? get subtitle => get('subtitle', _subtitle);
  ///Task's IsChecked which is not saved
  bool? get isChecked => get('isChecked', _isChecked);
  ///Task's Test Type
  TestType? get testType => get('testType', _testType);

  ///The Task's Title
  set title(String? value) => set('title', value);
  ///The Task's Subtitle
  set subtitle(String? value) => set('subtitle', value);
  ///Task's IsChecked which is not saved
  set isChecked(bool? value) => set('isChecked', value);
  ///Task's Test Type
  set testType(TestType? value) => set('testType', value);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'test_type': testType,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  static Task fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    subtitle: json['subtitle'],
    testType: json['test_type'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    isChecked,
    testType,
    createdAt,
    updatedAt,
  ];
}
