class User {
  String? id;
  String? name;
  bool? story;
  String? urlImage;
  UserStatus? userStatus;
  User({this.id, this.name, this.story, this.urlImage, this.userStatus});
}

enum UserStatus { ONLINE, OFFLINE, PRIVACY }
