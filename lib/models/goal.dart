import 'package:catchup/models/user.dart';
import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  Goal({
    this.id,
    this.taskId,
    this.status,
    this.title,
    this.description,
    this.completionPercentage,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.startDate,
    this.endDate,
    this.seen
  });

  int id, taskId, status;
 final double completionPercentage;
  final  String title, description, createdBy, updatedBy;
  final  DateTime createdAt, updatedAt, startDate, endDate;
  final bool seen;

  factory Goal.fromJson(Map<String, dynamic> json) {
    if (json['status'] == true) {
      json['status'] = 1;
    }

    return Goal(
      id: json["goal_id"],
      title: json["title"],
      description: json["description"],
      status: json["status"],
      createdBy: json["created_by"],
      updatedBy: json["updated_by"],
      createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"]) : null,
      updatedAt: json["updated_at"] != null ? DateTime.tryParse(json["updated_at"]) : null,
      startDate: json["start_date"] != null ? DateTime.tryParse(json["start_date"]) : null,
      endDate: json["end_date"] != null ? DateTime.tryParse(json["end_date"]) : null,
      seen: json['seen'],
      completionPercentage: json["ratio"].toDouble(),
    );
  }

  factory Goal.fromJsonInfo(Map<String, dynamic> json) {
    return Goal(
      id: json["goal_id"],
      title: json['goal_info']["title"],
      description: json['goal_info']["description"],
      status: json['goal_info']["status"],
      createdBy: json['goal_info']["created_by"],
      updatedBy: json['goal_info']["updated_by"],
      createdAt: json['goal_info']["created_at"] != null ? DateTime.tryParse(json['goal_info']["created_at"]) : null,
      updatedAt: json['goal_info']["updated_at"] != null ? DateTime.tryParse(json['goal_info']["updated_at"]) : null,
      startDate: json['goal_info']["start_date"] != null ? DateTime.tryParse(json['goal_info']["start_date"]) : null,
      endDate: json['goal_info']["end_date"] != null ? DateTime.tryParse(json['goal_info']["end_date"]) : null,
      completionPercentage: json['goal_info']["ratio"].toDouble(),
    );
  }


  @override
  String toString() {
    return 'Goal{id: $id, taskId: $taskId, status: $status, completionPercentage: $completionPercentage, title: $title, description: $description, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt, startDate: $startDate, endDate: $endDate}';
  }

  @override
  List<Object> get props => [id];
}
