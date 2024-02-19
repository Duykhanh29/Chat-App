import 'package:chat_app/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MessageData {
  String? idAdmin;
  Timestamp? createdAt;
  String? idMessageData;
  String? groupImage;
  // User? sender;
  List<String>? receivers;
  List<Message>? listMessages;
  String? chatName;
  MessageData(
      {this.idAdmin,
      this.groupImage,
      this.listMessages,
      this.receivers,
      this.idMessageData,
      this.chatName,
      this.createdAt}) {
    if (idMessageData == null) {
      idMessageData = Uuid().v4();
    }
  }
  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
        idAdmin: json['idAdmin'],
        createdAt: (json['createdAt'] as Timestamp?),
        groupImage: json['groupImage'],
        idMessageData: json['idMessageData'],
        listMessages: (json['listMessages'] as List<dynamic>)
            .map((e) => Message.fromJson(e))
            .toList(),
        // sender: User.fromJson(json['sender']),
        receivers: List.from(json['receivers']),
        chatName: json['chatName']);
  }
  Map<String, dynamic> toJson() => {
        'idAdmin': idAdmin,
        'createdAt': createdAt,
        'groupImage': groupImage,
        'idMessageData': idMessageData,
        // 'sender': sender!.toJson(),
        'receivers': receivers!.map((e) => e).toList(),
        'listMessages':
            listMessages!.map((message) => message.toJson()).toList(),
        'chatName': chatName
      };
  void showALlAttribute() {
    print("ID nha: $idMessageData");
    print("How many receivers: ${receivers!.length}");
    print("How many messages: ${listMessages!.length}");
    // sender!.showALlAttribute();
  }
}

class Message {
  bool isFoward;
  bool isDeleted;
  bool isSearch;
  bool? isSeen;
  Timestamp? dateTime;
  String? text;
  MessageStatus? messageStatus;
  String? senderID;
  ChatMessageType? chatMessageType;
  int? longTime;
  String? idMessage;
  bool? isReply;
  String? idReplyText;
  String? replyToUserID;
  List<String>? seenBy;
  Message(
      {this.text,
      this.chatMessageType,
      this.senderID,
      this.messageStatus,
      this.dateTime,
      this.isSeen,
      this.longTime,
      this.isSearch = false,
      this.idMessage,
      this.isDeleted = false,
      this.isReply = false,
      this.seenBy,
      this.idReplyText,
      this.replyToUserID,
      this.isFoward = false}) {
    if (this.idMessage == null) {
      this.idMessage = Uuid().v4();
    }
  }
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      isFoward: json['isFoward'],
      seenBy: json['seenBy'] != null ? List<String>.from(json['seenBy']) : null,
      dateTime: (json['dateTime'] as Timestamp?),
      chatMessageType: ChatMessageType.values.firstWhere(
        (element) =>
            element.toString().split(".").last == json['chatMessageType'],
        orElse: () => ChatMessageType.VIDEOCALL,
      ),
      idMessage: json['idMessage'],
      idReplyText: json['idReplyText'],
      isDeleted: json['isDeleted'],
      isReply: json['isReply'],
      isSearch: json['isSearch'],
      isSeen: json['isSeen'],
      senderID: json['senderID'],
      longTime: json['longTime'],
      messageStatus: MessageStatus.values.firstWhere(
        (element) =>
            element.toString().split(".").last == json['messageStatus'],
        orElse: () => MessageStatus.SENDING,
      ),
      replyToUserID: json['replyToUserID'],
      text: json['text'],
    );
  }
  Map<String, dynamic> toJson() => {
        "seenBy": seenBy != null ? seenBy!.map((e) => e).toList() : null,
        "dateTime": dateTime,
        "chatMessageType": chatMessageType?.toString().split(".").last,
        "idMessage": idMessage,
        "idReplyText": idReplyText,
        "isDeleted": isDeleted,
        "isReply": isReply,
        "isSearch": isSearch,
        "isSeen": isSeen,
        "senderID": senderID,
        "longTime": longTime,
        "messageStatus": messageStatus?.toString().split(".").last,
        "replyToUserID": replyToUserID,
        "text": text,
        "isFoward": isFoward
      };
  void showALlAttribute() {
    print("Message: ID: $idMessage,senderID: $senderID");
    print("Sender: \n");
    // sender!.showALlAttribute();
  }
}

enum MessageStatus {
  SENT,
  SENDING,
  RECEIVED,
  SEEN,
}

MessageStatus getMessageStatus(String status) {
  if (status == "SENT") {
    return MessageStatus.SENT;
  } else if (status == "SENDING") {
    return MessageStatus.SENDING;
  } else if (status == "RECEIVED") {
    return MessageStatus.RECEIVED;
  }
  return MessageStatus.SEEN;
}

ChatMessageType getChatMessageType(String type) {
  if (type == "AUDIO") {
    return ChatMessageType.AUDIO;
  } else if (type == "TEXT") {
    return ChatMessageType.TEXT;
  } else if (type == "MEME") {
    return ChatMessageType.GIF;
  } else if (type == "GIF") {
    return ChatMessageType.EMOJI;
  } else if (type == "IMAGE") {
    return ChatMessageType.IMAGE;
  } else if (type == "EMOJI") {
    return ChatMessageType.GIF;
  } else if (type == "AUDIOCALL") {
    return ChatMessageType.AUDIOCALL;
  } else if (type == "LOCATION") {
    return ChatMessageType.LOCATION;
  } else if (type == "NOTIFICATION") {
    return ChatMessageType.NOTIFICATION;
  } else if (type == "MISSEDAUDIOCALL") {
    return ChatMessageType.MISSEDAUDIOCALL;
  } else if (type == "MISSEDVIDEOCALL") {
    return ChatMessageType.MISSEDVIDEOCALL;
  }
  return ChatMessageType.VIDEOCALL;
}

enum ChatMessageType {
  AUDIO,
  TEXT,
  GIF,
  EMOJI,
  IMAGE,
  VIDEO,
  AUDIOCALL,
  VIDEOCALL,
  FILE,
  LOCATION,
  NOTIFICATION,
  MISSEDVIDEOCALL,
  MISSEDAUDIOCALL,
}
