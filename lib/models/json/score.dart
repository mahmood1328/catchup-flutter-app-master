// To parse this JSON data, do
//
//     final score = scoreFromJson(jsonString);

import 'dart:convert';

Score scoreFromJson(String str) => Score.fromJson(json.decode(str));

String scoreToJson(Score data) => json.encode(data.toJson());

class Score {
  Score({
    this.timeManagement,
    this.efficiency,
    this.taskDelegation,
    this.followUp,
    this.reportUpdates,
    this.taskCompletion,
    this.workQuality,
    this.overallScore,
  });

  int timeManagement;
  int efficiency;
  int taskDelegation;
  int followUp;
  int reportUpdates;
  int taskCompletion;
  int workQuality;
  int overallScore;

  factory Score.fromJson(Map<String, dynamic> json) => Score(
    timeManagement: json["time_management"] ?? 0,
    efficiency: json["efficiency"] ?? 0,
    taskDelegation: json["task_delegation"] ?? 0,
    followUp: json["follow_up"] ?? 0,
    reportUpdates: json["report_updates"] ?? 0,
    taskCompletion: json["task_completion"] ?? 0,
    workQuality: json["work_quality"] ?? 0,
    overallScore: json["overall_score"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "time_management": timeManagement,
    "efficiency": efficiency,
    "task_delegation": taskDelegation,
    "follow_up": followUp,
    "report_updates": reportUpdates,
    "task_completion": taskCompletion,
    "work_quality": workQuality,
    "overall_score": overallScore,
  };
}
