// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../task.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

class BaseTask extends BaseModel<String?> {
  final String _title;
  final String _subtitle;
  final bool _isChecked;
  final TestType _testType;

  BaseTask({
    String? id,
    String? title,
    required String subtitle,
    bool? isChecked,
    TestType? testType,
  })  : _title = title ?? "",
        _subtitle = subtitle,
        _isChecked = isChecked ?? false,
        _testType = testType ?? const TestType("stoca"),
        super(id: id);

  //GETTERS
  String get title => get('title', _title);
  String get subtitle => get('subtitle', _subtitle);
  bool get isChecked => get('isChecked', _isChecked);
  TestType get testType => get('testType', _testType);

  //SETTERS
  set title(String value) => set('title', value);
  set subtitle(String value) => set('subtitle', value);
  set isChecked(bool value) => set('isChecked', value);
  set testType(TestType value) => set('testType', value);

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'testType': testType,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        subtitle: json['subtitle'],
        testType: json['testType'],
      );

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        isChecked,
        testType,
      ];
}
