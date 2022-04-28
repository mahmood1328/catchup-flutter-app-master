import 'user.dart';

class Comment {
  final int id;
  final User user;
  final String userName;
  final String message;
   int likesCount;
  final String file;
   bool youLiked;
  final DateTime createdAt;
  String taskId;

  bool downloaded;
  String localPath;
  Comment(
      {this.id,
      this.user,
      this.message,
      this.file,
      this.userName,
      this.likesCount = 0,
      this.youLiked = false,
      this.createdAt,
      this.localPath,
      this.downloaded=false});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      user: User.fromJsonInfo(json['user_info']),
      userName: json['created_by'],
      message: json['message'],
      likesCount: json['likes'],
      youLiked: json['liked_by_user'],
      file: json['file'] == null ? null : json['file'],
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
    );
  }

  @override
  String toString() {
    return 'Comment{id: $id, user: $user, message: $message, likesCount: $likesCount, youLiked: $youLiked}';
  }
}
