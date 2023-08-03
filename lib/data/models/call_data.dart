import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CallData {
  // CallDetails? creator;
  String? callID;
  String? creatorId;
  Timestamp? createdAt;
  String? idChannel;
  List<String>? currentAudience;
  List<String>? listAudience; // both of sender and receivers
  CallData(
      {this.creatorId,
      this.idChannel,
      this.createdAt,
      this.currentAudience,
      this.listAudience,
      this.callID}) {
    if (callID == null) {
      callID = Uuid().v4();
    }
  }
  factory CallData.fromJson(Map<String, dynamic> json) {
    return CallData(
        // creator: CallDetails.fromjson(json['creator']),
        currentAudience: List<String>.from(json['currentAudience']),
        createdAt: (json['createdAt'] as Timestamp?),
        creatorId: json['creatorId'],
        idChannel: json['idChannel'],
        callID: json['callID'],
        listAudience: List<String>.from(json['listAudience']));
  }
  Map<String, dynamic> toJson() => {
        // 'creator': creator!.toJson(),
        'currentAudience': currentAudience,
        'callID': callID,
        'creatorId': creatorId, 'createdAt': createdAt,
        'idChannel': idChannel,
        'listAudience': listAudience != null
            ? listAudience!.map((e) => e.toString()).toList()
            : null,
      };
}

class CallDetails {
  String? creatorId;
  Timestamp? createdAt;
  CallDetails({this.createdAt, this.creatorId});
  factory CallDetails.fromjson(Map<String, dynamic> json) {
    return CallDetails(
        createdAt: (json['createdAt'] as Timestamp?),
        creatorId: json['creatorId']);
  }
  Map<String, dynamic> toJson() =>
      {'creatorId': creatorId, 'createdAt': createdAt};
}
