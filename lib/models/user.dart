import 'package:catchup/api/urls.dart';
import 'package:catchup/ui/user_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String username,
      email,
      password,
      firstName,
      lastName,
      mobile,
      token,
      profileImage;

  int score;

  bool isSelected;

  User({
    this.username,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.mobile,
    this.token,
    this.profileImage,
    this.score,
    this.isSelected = false,
  });

  String get picture {
    return Urls.HOST + this.profileImage;
  }

  String get fullName {
    return '${this.firstName} ${this.lastName}';
  }


  factory User.fromJson(Map<String, dynamic> json,[int score]) {



    return User(
        username: json["username"],
        email: json["email"],
        password: json["password"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        mobile: json["mobile_number"],
        token: json["token"],
        profileImage: json["profile_image"],
        score:
            (score!=null)?score:
            (json['user_profile'] == null ||
                json['user_profile']['overall_score'] == null)
            ? 0
            : json['user_profile']['overall_score']);
  }

  factory User.fromJsonInfo(Map<String, dynamic> json) {
    return User(
        username: json['username'],
        firstName: json["first_name"],
        lastName: json["last_name"],
        profileImage:
            json["image"] == null ? json['profile_image'] : json['image'],
        score: (json['user_profile'] == null ||
                json['user_profile']['overall_score'] == null)
            ? 0
            : json['user_profile']['overall_score']);
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'mobile_number': mobile,
        'token': token,
        'profile_image': profileImage,
      };

  Map<String, dynamic> toDBJson() => {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'profile_image': profileImage,
      };

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("username", this.username);
    await prefs.setString("email", this.email);
    await prefs.setString("firstName", this.firstName);
    await prefs.setString("lastName", this.lastName);
    await prefs.setString("mobile", this.mobile);
    await prefs.setString("token", this.token);
    await prefs.setString("profileImage", this.profileImage);
  }

  static Future<User> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return User(
      username: prefs.getString("username"),
      email: prefs.getString("email"),
      firstName: prefs.getString("firstName"),
      lastName: prefs.getString("lastName"),
      mobile: prefs.getString("mobile"),
      token: prefs.getString("token"),
      profileImage: prefs.getString("profileImage"),
    );
  }

  @override
  bool operator ==(other) => other is User && this.username == other.username;

  @override
  int get hashCode => username.hashCode;

  @override
  String toString() {
    return 'User{username: $username, email: $email, password: $password, firstName: $firstName, lastName: $lastName, mobile: $mobile, token: $token, profileImage: $profileImage, isSelected: $isSelected}';
  }
}
