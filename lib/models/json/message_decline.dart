import 'package:catchup/models/user.dart';

class Decline {
  User user;
  String message;
  int typeMessage;
  String createdBy;
  DateTime createdAt;
  String updatedBy;
  DateTime updatedAt;

  Decline(
      {this.user,
      this.message,
      this.typeMessage,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  factory Decline.formJson(Map<String, dynamic> json)=> Decline(
    user: User.fromJsonInfo(json['user_info']),
    updatedBy: json['updated_by'],
    createdBy: json['created_by'],
    message: json['message'],
    typeMessage: json['type_message'],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
  );
}
