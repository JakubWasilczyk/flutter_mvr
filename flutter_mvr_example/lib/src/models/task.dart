import 'package:flutter_mvr/flutter_mvr.dart';
import 'package:flutter_mvr_example/src/test_type.dart';

part 'base/task.base.dart';

///This is an example Task Model
class Task extends BaseTask {
  Task ({
    super.id,
    super.title,
    super.subtitle,
    super.isChecked,
    super.testType,
    super.createdAt,
    super.updatedAt,
  }) : super();

  factory Task.fromJson(Map<String, dynamic> json) => BaseTask.fromJson(json);

}
