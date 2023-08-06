import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Friends {
  String? userID;
  List<FriendData>? listFriend;
  List<FriendData>? requestedList;
  List<FriendData>? queueList;
  Friends({this.userID, this.listFriend, this.queueList, this.requestedList});
  factory Friends.fromJson(Map<String, dynamic> json) {
    return Friends(
      userID: json['userID'],
      listFriend: (json['listFriend'] as List<dynamic>)
          .map((e) => FriendData.fromJson(e))
          .toList(),
      queueList: (json['queueList'] as List<dynamic>)
          .map((e) => FriendData.fromJson(e))
          .toList(),
      requestedList: (json['requestedList'] as List<dynamic>)
          .map((e) => FriendData.fromJson(e))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        "userID": userID,
        "listFriend": listFriend != null
            ? listFriend!.map((e) => e.toJson()).toList()
            : null,
        "requestedList": requestedList != null
            ? requestedList!.map((e) => e.toJson()).toList()
            : null,
        "queueList": queueList != null
            ? queueList!.map((e) => e.toJson()).toList()
            : null
      };
}

class FriendData {
  String? idFriend;
  Timestamp? createdAt;
  FriendData({this.createdAt, this.idFriend});
  factory FriendData.fromJson(Map<String, dynamic> json) {
    return FriendData(
      createdAt: (json['createdAt'] as Timestamp?),
      idFriend: json['idFriend'],
    );
  }
  Map<String, dynamic> toJson() =>
      {"createdAt": createdAt, "idFriend": idFriend};
}
