import 'package:catchup/models/goal.dart';
import 'package:catchup/models/json/message_decline.dart';
import 'package:catchup/models/user.dart';

class Datum {
  Datum({
    this.taskId,
    this.acceptor,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.goals,
    this.declines,
    this.pending,
    this.title ,
    this.completionPercentage,
    this.seen,
    this.description,
    this.progressType
  });

  int taskId;
  bool seen;
  String title;
  String description;
  double completionPercentage;
  int progressType;
  List<User> acceptor;
  List<User> pending;
  List<Decline> declines;
  List<Goal> goals;
  int status;
  String createdBy;
  DateTime createdAt;
  String updatedBy;
  DateTime updatedAt;



  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    taskId: json["task_id"],
    title: json["task_info"]['title'],
    description: json["task_info"]['description'],
    status: json["status"],
    createdBy:json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedBy:json["updated_by"],
    updatedAt: DateTime.parse(json["updated_at"]),
    goals: json["goals"] == null ?  [] : List<Goal>.from(json["goals"].map((x) => Goal.fromJson(x))),
  );

  factory Datum.fromJsonAdmin(Map<String, dynamic> json) => Datum(
    taskId: json["task_id"],
    title: json['title'],
    seen: json['seen'],
    progressType: json['progress_type'],
    completionPercentage: json['completion_percentage'].toDouble(),
    description: json['description'],
    acceptor: json["acceptor"] == null ?  [] : List<User>.from(json["goals"].map((x) => User.fromJsonInfo(x))),
    pending: json["pending"] == null ?  [] : List<User>.from(json["goals"].map((x) => User.fromJsonInfo(x))),
    status: json["status"],
    createdBy:json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedBy:json["updated_by"],
    updatedAt: DateTime.parse(json["updated_at"]),
    goals: json["goals"] == null ?  [] : List<Goal>.from(json["goals"].map((x) => Goal.fromJsonInfo(x))),
    declines: json["declined_messages"] == null ?  [] : List<Decline>.from(json["declined_messages"].map((x) => Decline.formJson(x))),
  );
}
