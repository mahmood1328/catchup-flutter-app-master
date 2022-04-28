import 'package:catchup/models/user.dart';

class Task {
  Task({
    this.id,
    this.status,
    this.title,
    this.description,
    this.progressType,
    this.createdBy,
    this.updatedBy,
    this.acceptors,
    this.createdAt,
    this.updatedAt,
    this.completionPercentage = 0.0,
  });

  int id, status, progressType;
  double completionPercentage;
  String admin, title, description, createdBy, updatedBy;
  List<User> acceptors;
  DateTime createdAt, updatedAt;

  bool get isAuto => this.progressType == 1;

  bool get isManual => this.progressType == 2;

  factory Task.fromJson(Map<String, dynamic> json) {
    final List<User> acceptors = List();
    List acceptorsList = List();

    final Map taskInfo = json.containsKey('task_info') ? json['task_info'] : json;

    if (taskInfo.containsKey('acceptors_info')) {
      acceptorsList = taskInfo['acceptors_info'];
    } else if (taskInfo.containsKey('acceptor_info')) {
      acceptorsList = taskInfo['acceptor_info'];
    } else if (taskInfo.containsKey('acceptors_list')) {
      acceptorsList = taskInfo['acceptors_list'];
    } else if (taskInfo.containsKey('acceptor_list')) {
      acceptorsList = taskInfo['acceptor_list'];
    }

    for (final user in acceptorsList) {
      acceptors.add(User.fromJson(user));
    }

    return Task(
      id: json["task_id"],
      acceptors: acceptors,
      title: taskInfo["title"],
      description: taskInfo["description"],
      progressType: taskInfo["progress_type"],
      status: taskInfo["status"],
      createdBy: taskInfo["created_by"],
      updatedBy: taskInfo["updated_by"],
      createdAt: taskInfo["created_at"] != null ? DateTime.tryParse(taskInfo["created_at"]) : null,
      updatedAt: taskInfo["updated_at"] != null ? DateTime.tryParse(taskInfo["updated_at"]) : null,
      completionPercentage: taskInfo["completion_percentage"] != null ? double.tryParse('${taskInfo["completion_percentage"]}') : 0.0,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, status: $status, progressType: $progressType, completionPercentage: $completionPercentage, admin: $admin, title: $title, description: $description, createdBy: $createdBy, updatedBy: $updatedBy, acceptors: $acceptors, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
