class User {
  String? id;
  String? email;
  String? phoneNumber;
  String? name;
  bool story;
  String? urlImage;
  UserStatus? userStatus;
  String? urlCoverImage;
  User(
      {this.id,
      this.name,
      this.story = false,
      this.urlImage,
      this.userStatus,
      this.email,
      this.phoneNumber,
      this.urlCoverImage});

  Map<String, dynamic> toJson() => {
        "name": name,
        "urlImage": urlImage,
        "email": email,
        "phoneNumber": phoneNumber,
        "id": id,
        "story": story,
        "userStatus": userStatus?.toString().split('.').last,
        "urlCoverImage": urlCoverImage
      };
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phoneNumber: json['email'],
        story: json['story'],
        userStatus: UserStatus.values.firstWhere(
          (status) => status.toString().split('.').last == json['userStatus'],
          orElse: () => UserStatus.PRIVACY,
        ),
        urlImage: json['urlImage'],
        urlCoverImage: json['urlCoverImage']);
  }
  void showALlAttribute() {
    print("User ID: $id, name: $name, image: $urlImage,email: $email");
  }
}

UserStatus getUserStatus(String status) {
  if (status == "ONLINE") {
    return UserStatus.ONLINE;
  } else if (status == "OFFLINE") {
    return UserStatus.OFFLINE;
  } else {
    return UserStatus.PRIVACY;
  }
}

enum UserStatus { ONLINE, OFFLINE, PRIVACY }
