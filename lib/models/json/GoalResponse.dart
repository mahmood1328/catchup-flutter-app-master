// To parse this JSON data, do
//
//     final goalResponse = goalResponseFromJson(jsonString);

import 'dart:convert';

import 'package:catchup/models/goal.dart';

GoalResponse goalResponseFromJson(String str) => GoalResponse.fromJson(json.decode(str));

//String goalResponseToJson(GoalResponse data) => json.encode(data.toJson());

class GoalResponse {
  GoalResponse({
    this.statusCode,
    this.goals,
  });

  int statusCode;
  List<Goal> goals;

  factory GoalResponse.fromJson(Map<String, dynamic> json) => GoalResponse(
    statusCode: json["status_code"],
    goals: List<Goal>.from(json["goals"].map((x) => Goal.fromJson(x))),
  );

/*  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "goals": List<dynamic>.from(goals.map((x) => x.toJson())),
  };*/
}

/*class Goal {
  Goal({
    this.goalId,
    this.title,
    this.description,
    this.ratio,
    this.startDate,
    this.endDate,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  int goalId;
  String title;
  String description;
  int ratio;
  DateTime startDate;
  DateTime endDate;
  int status;
  String createdBy;
  DateTime createdAt;
  String updatedBy;
  DateTime updatedAt;

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    goalId: json["goal_id"],
    title: json["title"],
    description: json["description"],
    ratio: json["ratio"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    status: json["status"],
    createdBy: json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedBy: json["updated_by"],
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "goal_id": goalId,
    "title": title,
    "description": description,
    "ratio": ratio,
    "start_date": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    "end_date": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    "status": status,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
    "updated_by": updatedBy,
    "updated_at": updatedAt.toIso8601String(),
  };
}*/
