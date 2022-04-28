import 'dart:math' as math;

class UserProfile {
  static const STAR_COUNT = 6;

  int tasksDoneCounter;
  int timeManagement;
  int efficiency;
  int taskDelegation;
  int followUp;
  int reportUpdates;
  int taskCompletion;
  int workQuality;
  int overallScore;

  UserProfile({
    this.tasksDoneCounter = 0,
    this.timeManagement = 0,
    this.efficiency = 0,
    this.taskDelegation = 0,
    this.followUp = 0,
    this.reportUpdates = 0,
    this.taskCompletion = 0,
    this.workQuality = 0,
    this.overallScore = 0,
  });

  static double map(
    int x,
    double in_min,
    double in_max,
    double out_min,
    double out_max,
  ) {
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  }

  int get tasksDoneCounterStar =>
      math.min(UserProfile.map(this.tasksDoneCounter, 0, 100, 0, 6).round(), 6);

  int get timeManagementStar =>
      math.min(UserProfile.map(this.timeManagement, 0, 100, 0, 6).round(), 6);

  int get efficiencyStar =>
      math.min(UserProfile.map(this.efficiency, 0, 100, 0, 6).round(), 6);

  int get taskDelegationStar =>
      math.min(UserProfile.map(this.taskDelegation, 0, 100, 0, 6).round(), 6);

  int get followUpStar =>
      math.min(UserProfile.map(this.followUp, 0, 100, 0, 6).round(), 6);

  int get reportUpdatesStar =>
      math.min(UserProfile.map(this.reportUpdates, 0, 100, 0, 6).round(), 6);

  int get taskCompletionStar =>
      math.min(UserProfile.map(this.taskCompletion, 0, 100, 0, 6).round(), 6);

  int get workQualityStar =>
      math.min(UserProfile.map(this.workQuality, 0, 100, 0, 6).round(), 6);

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      tasksDoneCounter: json["tasks_done_counter"],
      timeManagement: json["time_management"],
      efficiency: json["efficiency"],
      taskDelegation: json["task_delegation"],
      followUp: json["follow_up"],
      reportUpdates: json["report_updates"],
      taskCompletion: json["task_completion"],
      workQuality: json["work_quality"],
      overallScore: json["overall_score"],
    );
  }
}
