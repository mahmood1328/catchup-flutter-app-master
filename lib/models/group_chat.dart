class GroupChat {
  final int id;
  final String name;

  GroupChat(this.id, this.name);

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(json['group_id'], json['group_info']['username']);
  }
}