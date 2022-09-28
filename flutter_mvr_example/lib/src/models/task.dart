import 'package:flutter_mvrs/flutter_mvrs.dart';

part 'base/task.base.dart';

@Model()
class Task extends BaseTask {
  final bool exists;

  Task({
    @toJsonIgnore String? id,
    @DefaultValue('""') String? title,
    required String subtitle,
    @jsonIgnore @DefaultValue("false") bool isChecked = false,
    @DefaultValue('const TestType("stoca")') TestType? testType,
    this.exists = false,
  }) : super(
          id: id,
          title: title,
          subtitle: subtitle,
          isChecked: isChecked,
        );

  factory Task.fromJson(Map<String, dynamic> json) => BaseTask.fromJson(json);
}

class TestType {
  final String hello;

  const TestType(this.hello);
}
