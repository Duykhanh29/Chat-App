import 'package:chat_app/data/models/message_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:image_picker/image_picker.dart';

class MessageController extends GetxController {
  RxList<User> listUser = <User>[].obs;
  RxList<MessageData> listMessageData = <MessageData>[].obs;
  RxList<MessageData> searchListMessageData = <MessageData>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    User user1 = User(
        id: "ID01",
        name: "Nguyen Tung",
        story: false,
        userStatus: UserStatus.ONLINE,
        urlImage:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSRKouGaC5wkHjgKIuSSZTrTBBQWc5gEIOPFw&usqp=CAU");
    User user2 = User(
        id: "ID02",
        name: "Nguyen Manh",
        userStatus: UserStatus.PRIVACY,
        story: false,
        urlImage:
            "https://imgv3.fotor.com/images/share/Unblur-image-online-automatically-with-Fotor-AI-image-deburring-tool.jpg");
    User user3 = User(
        id: "ID03",
        name: "Nguyen Huong",
        story: true,
        userStatus: UserStatus.ONLINE,
        urlImage:
            "https://topten.review/wp-content/uploads/sites/3/2022/02/VanceAI-Image-Sharpener-700-360@2x-300x154.png");
    User user4 = User(
        id: "ID04",
        name: "Nguyen Hung",
        userStatus: UserStatus.OFFLINE,
        story: true,
        urlImage:
            "https://images.unsplash.com/photo-1635468872214-8d30953f0057?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=437&q=80");
    User user5 = User(
        id: "ID05",
        name: "Nguyen Hung",
        story: true,
        userStatus: UserStatus.PRIVACY,
        urlImage:
            "https://assets.ayobandung.com/crop/0x0:0x0/750x500/webp/photo/2023/02/20/ascxzcsafag-1165003792.jpg");
    User user6 = User(
        id: "ID06",
        name: "Nguyen Luc",
        story: true,
        userStatus: UserStatus.ONLINE,
        urlImage: "https://pixlr.com/images/index/remove-bg.webp");
    User user7 = User(
        id: "ID07",
        name: "Nguyen Quang",
        story: true,
        userStatus: UserStatus.OFFLINE,
        urlImage:
            "https://images.unsplash.com/photo-1613323593608-abc90fec84ff?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80");
    User user8 = User(
        id: "ID08",
        name: "Doctor Strange",
        story: true,
        userStatus: UserStatus.ONLINE,
        urlImage:
            "https://play-lh.googleusercontent.com/MqXH34arO8Yb0Wm8UVw99eknd1a4Oltj959fls29wlfo9xHg5oKdi9RlgliORSQGSltklw");
    User user9 = User(
        id: "ID09",
        name: "Mai Thu Hà",
        story: true,
        urlImage:
            "https://instagram.fsgn2-9.fna.fbcdn.net/v/t51.2885-19/334286927_586427636875421_6166844634128991401_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fsgn2-9.fna.fbcdn.net&_nc_cat=105&_nc_ohc=IAlRcbr3EWEAX8RO8vn&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfC4urX9YZkif96OUIrl6TdD2Go0TWXwkKfViVmIkavnqQ&oe=643B6FE4&_nc_sid=8fd12b",
        userStatus: UserStatus.ONLINE);
    User user10 = User(
        id: "ID010",
        name: "natural",
        story: true,
        urlImage:
            "https://www.searchenginejournal.com/wp-content/uploads/2022/06/image-search-1600-x-840-px-62c6dc4ff1eee-sej-1520x800.webp",
        userStatus: UserStatus.ONLINE);
    listUser.value = [
      user1,
      user2,
      user3,
      user4,
      user5,
      user6,
      user7,
      user8,
      user9,
      user10,
    ];
    listMessageData.value = [
      MessageData(
        user: user1,
        listMessages: [
          Message(
              "Dang Duy Khanh wants to love Mai Thu Ha. I hope we will be in the relationship. Mai Thu Ha say that she loves Dang Duy Khanh. Dang Duy Khanh loves Mai Thu Ha too",
              ChatMessageType.TEXT,
              false,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)),
              true),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              true),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message(
              "https://64.media.tumblr.com/8b4c01edd9f4c95f92197a961dd7b1af/2177eda79af71270-7e/s1280x1920/920265619ec74632fd83faca04abaddb5d7b3e38.jpg",
              ChatMessageType.IMAGE,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)),
              false),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), false),
          Message("Nha", ChatMessageType.TEXT, false, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), true),
        ],
      ),
      MessageData(
        user: user2,
        listMessages: [
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), true),
          Message(
              "https://media-cdn-v2.laodong.vn/storage/newsportal/2023/2/17/1148971/Lee-Je-Hoon-01.jpg",
              ChatMessageType.IMAGE,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              true),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("guys", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)), false),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), false),
          Message("Nha", ChatMessageType.TEXT, false, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), false),
        ],
      ),
      MessageData(
        user: user3,
        listMessages: [
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), true),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              true),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("guys", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)), true),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), true),
          Message("Nha", ChatMessageType.AUDIO, false, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), false),
          Message(
              "https://bloganchoi.com/wp-content/uploads/2021/05/lee-je-hoon-chia-se.jpg",
              ChatMessageType.IMAGE,
              false,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)),
              false),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              false),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), false),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), false),
          Message("guys", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)), false),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), false),
          Message("Nha", ChatMessageType.TEXT, true, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), true),
        ],
      ),
      MessageData(
        user: user4,
        listMessages: [
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), true),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              true),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("guys", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)), true),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), true),
          Message("Nha", ChatMessageType.AUDIO, false, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), true),
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), false),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              false),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), false),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), false),
          Message(
              "https://media.doisongphapluat.com/media/trieu-phuong-linh/2023/04/03/kim-do-ki-phat-hien-black-sun-la-cau-lac-bo-co-nhieu-te-nan11.png",
              ChatMessageType.IMAGE,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)),
              false),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), false),
          Message("Nha", ChatMessageType.TEXT, true, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(days: 1)), true),
        ],
      ),
      MessageData(
        user: user5,
        listMessages: [
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), true),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              true),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("guys", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)), true),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), true),
          Message("Nha", ChatMessageType.AUDIO, false, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), true),
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), true),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              true),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcToJtu9c8Iil2zz9fANpsHn5woO7LpVPWojiOihh69viRXL2X5Pob_IDFW1emFgYkVORwA&usqp=CAU",
              ChatMessageType.IMAGE,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)),
              false),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), false),
          Message("Nha", ChatMessageType.TEXT, false, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), false),
        ],
      ),
      MessageData(
        user: user6,
        listMessages: [
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), true),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              true),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("guys", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)), true),
          Message("Oke", ChatMessageType.TEXT, false, MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)), true),
          Message("Nha", ChatMessageType.AUDIO, false, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), true),
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), true),
          Message(
              "I",
              ChatMessageType.TEXT,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4, seconds: 30)),
              true),
          Message(
              "Oke",
              ChatMessageType.AUDIO,
              true,
              MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2, seconds: 30)),
              true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 3)), true),
          Message("guys", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)), false),
          Message(
              "https://i.ytimg.com/vi/JF29HwVuXlc/maxresdefault.jpg",
              ChatMessageType.IMAGE,
              false,
              MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)),
              false),
          Message("Nani", ChatMessageType.TEXT, true, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), true),
        ],
      ),
      MessageData(
        user: user8,
        listMessages: [
          Message("text", ChatMessageType.TEXT, false, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 4)), true),
          Message("I", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(days: 3)), true),
          Message("Oke", ChatMessageType.AUDIO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(days: 3)), true),
          Message("you", ChatMessageType.VIDEO, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(days: 3)), true),
          Message("guys", ChatMessageType.TEXT, true, MessageStatus.SEEN,
              DateTime.now().subtract(const Duration(minutes: 2)), true),
          Message(
              "https://assets.ayobandung.com/crop/0x0:0x0/750x500/webp/photo/2023/02/18/lee-je-hoon-285042092.jpg",
              ChatMessageType.IMAGE,
              false,
              MessageStatus.RECEIVED,
              DateTime.now().subtract(const Duration(minutes: 1)),
              true),
          Message("Nha", ChatMessageType.TEXT, true, MessageStatus.SENT,
              DateTime.now().subtract(const Duration(minutes: 0)), true),
        ],
      ),
    ];
    searchListMessageData.value = listMessageData;
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  MessageData? getMessageData(User user) {
    //print("User id ${user.id}");
    for (var element in listMessageData) {
      print("Check User id ${element.user!.id}");
      if (element.user!.id == user.id) {
        print('Same User:${user.id} with list ${element.user!.id} ');
        return element;
      }
    }
  }

  void addNewChat(MessageData messageData) {
    listMessageData.insert(0, messageData);
  }

  void deleteAChat(MessageData? messageData) {
    messageData = null;
  }

  void sentAMessage(Message message, User user) {
    final messageData =
        listMessageData.firstWhere((data) => user.id == data.user!.id);
    if (messageData == null) {
      print("null");
    } else {
      messageData.listMessages!.add(message);
      listMessageData.refresh(); // update data
    }
  }

  bool removeMessageDataWithoutMessage(MessageData messageData) {
    if (listMessageData.contains(messageData)) {
      if (messageData.listMessages!.isEmpty) {
        return listMessageData.value.remove(messageData);
      }
    }
    return false;
  }

  List<MessageData> getListMessageData(List<MessageData> messageDataList) {
    //searchListMessageData.value = listMessageData.value;
    List<MessageData> list = [];
    for (var data in messageDataList) {
      if (!data.listMessages!.isEmpty) {
        list.add(data);
      } else {
        list.remove(data);
      }
    }
    list.sort(
      (a, b) => b.listMessages!.last.dateTime!
          .compareTo(a.listMessages!.last.dateTime!),
    );
    return list;
  }

  int getListMessageDataLength() {
    int count = 0;
    for (var data in listMessageData) {
      if (!removeMessageDataWithoutMessage(data)) {
        count++;
      }
    }
    return count;
  }

  void filterListMessageData(String userName) {
    List<MessageData> list = [];
    if (userName.isEmpty) {
      list = listMessageData.value;
    } else {
      list = listMessageData
          .where((data) => data.user!.name
              .toString()
              .toLowerCase()
              .contains(userName.toLowerCase()))
          .toList();
      print("Size of list: ${list.length}");
    }
    searchListMessageData.value = list;
  }
}
