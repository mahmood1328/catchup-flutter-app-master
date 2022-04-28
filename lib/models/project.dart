import 'package:catchup/global.dart';
import 'package:catchup/models/user.dart';

class Project {
  Project({
    this.id,
    this.status,
    this.admin,
    this.title,
    this.description,
    this.createdBy,
    this.updatedBy,
    this.users,
    this.createdAt,
    this.updatedAt,
    this.completionPercentage = 0.0,
  });

  int id, status;
  double completionPercentage;
  String title, description, createdBy, updatedBy;
  List<User> users;
  User admin;
  DateTime createdAt, updatedAt;

  bool get isCurrentUserAdmin => this.admin.username == Global.user.username;

  factory Project.fromJson(Map<String, dynamic> json) {
    final Map project = json['project_info'];
    final List<User> users = List();

    if (project.containsKey('user_list')) {
      for (final user in project["user_list"]) {
        users.add(User.fromJson(user));
      }
    }

    return Project(
      id: json["project_id"],
      admin: User.fromJson(project["admin"]),
      users: users,
      title: project["title"],
      description: project["description"],
      status: project["status"],
      createdBy: project["created_by"],
      updatedBy: project["updated_by"],
      createdAt: DateTime.tryParse(project["created_at"]),
      updatedAt: DateTime.tryParse(project["updated_at"]),
      completionPercentage: double.tryParse('${project["completion_percentage"]}'),
    );
  }

  @override
  String toString() {
    return this.title;
  }
}
