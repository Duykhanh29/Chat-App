import 'package:chat_app/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MessageData {
  String? idMessageData;
  String? groupImage;
  // User? sender;
  List<String>? receivers;
  List<Message>? listMessages;
  String? chatName;
  MessageData(
      {this.groupImage,
      this.listMessages,
      this.receivers,
      this.idMessageData,
      this.chatName}) {
    if (idMessageData == null) {
      idMessageData = Uuid().v4();
    }
  }
  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
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
  bool isDeleted;
  bool isSearch;
  bool? isSeen;
  DateTime? dateTime;
  String? text;
  MessageStatus? messageStatus;
  User? sender;
  ChatMessageType? chatMessageType;
  int? longTime;
  String? idMessage;
  bool isRepy;
  String? idReplyText;
  User? replyToUser;
  List<String>? seenBy;
  Message(
      {this.text,
      this.chatMessageType,
      this.sender,
      this.messageStatus,
      this.dateTime,
      this.isSeen,
      this.longTime,
      this.isSearch = false,
      this.idMessage,
      this.isDeleted = false,
      this.isRepy = false,
      this.seenBy,
      this.idReplyText,
      this.replyToUser}) {
    if (this.idMessage == null) {
      this.idMessage = Uuid().v4();
    }
  }
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      seenBy: json['seenBy'] != null ? List<String>.from(json['seenBy']) : null,
      dateTime: (json['dateTime'] as Timestamp?)?.toDate(),
      chatMessageType: ChatMessageType.values.firstWhere(
        (element) =>
            element.toString().split(".").last == json['chatMessageType'],
        orElse: () => ChatMessageType.VIDEOCALL,
      ),
      idMessage: json['idMessage'],
      idReplyText: json['idReplyText'],
      isDeleted: json['isDeleted'],
      isRepy: json['isRepy'],
      isSearch: json['isRepy'],
      isSeen: json['isSeen'],
      sender: User.fromJson(json['sender']),
      longTime: json['longTime'],
      messageStatus: MessageStatus.values.firstWhere(
        (element) =>
            element.toString().split(".").last == json['messageStatus'],
        orElse: () => MessageStatus.SENDING,
      ),
      replyToUser: json['replyToUser'] != null
          ? User.fromJson(json['replyToUser'])
          : null,
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
        "isRepy": isRepy,
        "isSearch": isSearch,
        "isSeen": isSeen,
        "sender": sender!.toJson(),
        "longTime": longTime,
        "messageStatus": messageStatus?.toString().split(".").last,
        "replyToUser": replyToUser != null ? replyToUser!.toJson() : null,
        "text": text
      };
  void showALlAttribute() {
    print(
        "Message: ID: $idMessage, dateTime: $dateTime, messageStatus: $messageStatus,  text: $text");
    print("Sender: \n");
    sender!.showALlAttribute();
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
  } else if (type == "CALL") {
    return ChatMessageType.CALL;
  } else if (type == "LOCATION") {
    return ChatMessageType.LOCATION;
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
  CALL,
  VIDEOCALL,
  FILE,
  LOCATION
}
