import 'package:chat_app/data/models/user.dart';

class MessageData {
  User? user;
  List<Message>? listMessages;
  MessageData({
    this.user,
    this.listMessages,
  });
}

class Message {
  bool isDeleted;
  bool isSearch;
  bool? isSeen;
  DateTime? dateTime;
  String? text;
  MessageStatus? messageStatus;
  bool? isSender;
  ChatMessageType? chatMessageType;
  int? longTime;
  String? idMessage;
  bool isRepy;
  String? idReplyText;
  User? replyToUser;
  Message(
      {this.text,
      this.chatMessageType,
      this.isSender,
      this.messageStatus,
      this.dateTime,
      this.isSeen,
      this.longTime,
      this.isSearch = false,
      this.idMessage,
      this.isDeleted = false,
      this.isRepy = false,
      this.idReplyText,
      this.replyToUser});
}

enum MessageStatus {
  SENT,
  SENDING,
  RECEIVED,
  SEEN,
}

enum ChatMessageType {
  AUDIO,
  TEXT,
  MEME,
  ICON,
  IMAGE,
  VIDEO,
  CALL,
  VIDEOCALL,
}
