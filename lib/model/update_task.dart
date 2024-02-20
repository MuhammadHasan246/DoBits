import 'package:todo_app/model/category.dart';
import 'package:todo_app/model/sub_tasks.dart';

class UpdateTaskModel {
  final String id;
  final String title;
  final String? description;
  final String date;
  final String time;
  final TaskCategory category;
  final String priority;
  final bool isRemind;
  final List<SubTasksModel>? subTasks;
  UpdateTaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.category,
    required this.priority,
    required this.isRemind,
    this.subTasks,
  });
}
