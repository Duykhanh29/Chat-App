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
  bool? isSeen;
  DateTime? dateTime;
  String? text;
  MessageStatus? messageStatus;
  bool? isSender;
  ChatMessageType? chatMessageType;
  Message(this.text, this.chatMessageType, this.isSender, this.messageStatus,
      this.dateTime, this.isSeen);
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
}
