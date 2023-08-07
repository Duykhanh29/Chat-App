import 'package:chat_app/data/models/friend.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/service/notification_service.dart';
import 'package:chat_app/service/services_method.dart';
import 'package:chat_app/utils/helpers/validators.dart';
import 'package:intl/intl.dart';

class CommonMethods {
  CommonMethods();
  static User? getReceiver(List<User>? list, User? currentUser) {
    // int check = 0;
    for (var element in list!) {
      if (element.id != currentUser!.id) {
        return element;
      }
    }
    return currentUser; // when sender and receiver is the same user
  }

  static String? getUserFromListReceiverIDs(
      List<String>? list, User? currentUser) {
    for (var element in list!) {
      if (element != currentUser!.id) {
        return element;
      }
    }
    return currentUser!.id!; // when sender and receiver is the same user
  }

  static User? getReceiverCanbeNull(List<User>? list, User? currentUser) {
    // int check = 0;
    for (var element in list!) {
      if (element.id != currentUser!.id) {
        return element;
      }
    }
  }

  static getCurrentUserInAList(List<User>? list, User? currentUser) {}
  static addToReceiverListOneByOne(
      {List<String>? list, String? sender, String? receiver}) {
    list!.add(sender!);
    list.add(receiver!);
  }

  static List<User>? getReceivers(List<User>? list, User? currentUser) {
    List<User>? listReceivers = [];
    for (var element in list!) {
      if (element.id != currentUser!.id) {
        listReceivers.add(element);
      }
    }
    return listReceivers;
  }

  static bool isAGroup(List<String>? list) {
    if (list!.length > 2) {
      return true;
    }
    return false;
  }

  static isOnlineChat(List<User>? list, User? currentUser) {
    if (list!.length <= 2) {
      User? receiver = getReceiver(list, currentUser);
      if (receiver!.userStatus == UserStatus.ONLINE) {
        return true;
      } else {
        return false;
      }
    } else {
      for (var data in list) {
        if (data.id != currentUser!.id) {
          if (data.userStatus == UserStatus.ONLINE) {
            return true;
          }
        }
      }
      return false;
    }
  }

  static MessageStatus getMessageStatus(List<User>? list, User? currentUser) {
    if (list!.length <= 2) {
      User? receiver = getReceiver(list, currentUser);
      if (receiver!.userStatus == UserStatus.ONLINE) {
        return MessageStatus.RECEIVED;
      } else {
        return MessageStatus.SENT;
      }
    } else {
      for (var data in list) {
        if (data.userStatus == UserStatus.ONLINE) {
          return MessageStatus.RECEIVED;
        }
      }
      return MessageStatus.SENT;
    }
  }

  static bool isContainUserInAList(User user, List<String> list) {
    for (var data in list) {
      if (data == user.id) {
        return true;
      }
    }
    return false;
  }

  static List<User> getAllUserInChat(List<String> listID, List<User> listUser) {
    List<User> list = [];
    for (var data1 in listID) {
      for (var element in listUser) {
        if (element.id == data1) {
          // if (element.id != currentUser.id) {
          User user = element;
          list.add(user);
          // }
        }
      }
    }
    return list;
  }

  static List<User>? showAllUserOnline(
      List<User>? listAllUser, User? currentUser) {
    List<User>? list = [];
    for (var element in listAllUser!) {
      if (element.userStatus == UserStatus.ONLINE) {
        list.add(element);
      }
    }
    return list;
  }

  static List<String> convertListUserToListStringID(List<User>? list) {
    List<String> result = [];
    for (var element in list!) {
      result.add(element.id!);
    }
    return result;
  }

  static User? getUserFromID(List<User> list, String? idUser) {
    for (var element in list) {
      if (idUser == element.id) {
        return element;
      }
    }
  }

  static List<Map<String, String>> getAllMedias(MessageData msgData) {
    List<Map<String, String>> list = [];
    for (var msg in msgData.listMessages!) {
      if (msg.chatMessageType == ChatMessageType.IMAGE) {
        bool isExisted = list.any((element) => element['images'] == msg.text!);
        if (!isExisted) {
          Map<String, String> map = {'images': msg.text!};
          list.add(map);
        }
      } else if (msg.chatMessageType == ChatMessageType.VIDEO) {
        bool isExisted = list.any((element) => element['videos'] == msg.text!);
        if (!isExisted) {
          Map<String, String> map = {'videos': msg.text!};
          list.add(map);
        }
      }
    }
    return list;
  }

  // get media and link from a messageData
  static Map<String, List<String>> getAllMedia(MessageData msgData) {
    Map<String, List<String>> list = {};
    list['images'] = [];
    list['videos'] = [];
    for (var msg in msgData.listMessages!) {
      if (msg.chatMessageType == ChatMessageType.IMAGE

          //|| msg.chatMessageType == ChatMessageType.VIDEO
          ) {
        if (!list['images']!.contains(msg.text!)) {
          list['images'] = [msg.text!];
        }

        // if (!list.contains(msg.text)) {
        //   list.add(msg.text!);
        // }
      } else {
        if (!list['videos']!.contains(msg.text!)) {
          list['videos'] = [msg.text!];
        }
      }
    }
    return list;
  }

  static List<String> getAllLink(MessageData msgData) {
    List<String> list = [];
    for (var msg in msgData.listMessages!) {
      if (msg.chatMessageType == ChatMessageType.TEXT) {
        if (Validators.isUrl(msg.text!)) {
          if (!list.contains(msg.text)) {
            list.add(msg.text!);
          }
        }
      }
    }
    return list;
  }

  // friends
  static bool isFriend(String receiverID, List<User>? friends) {
    for (var data in friends!) {
      if (data.id == receiverID) {
        return true;
      }
    }
    return false;
  }

  static bool isSentRequest(String uid, List<User>? list) {
    for (var data in list!) {
      if (data.id == uid) {
        return true;
      }
    }
    return false;
  }

  static bool isReceivedRequest(String uid, List<User>? list) {
    for (var data in list!) {
      if (data.id == uid) {
        return true;
      }
    }
    return false;
  }

  // static Future<List<User>?> getSentList(List<FriendData> list) async {
  //   List<User>? listUser;
  //   for (var element in list) {
  //     User? user =
  //         await ServiceMethod.getUserFromIDWithoutGetAllDB(element.idFriend!);
  //     listUser!.add(user!);
  //   }
  //   return listUser;
  // }
  static List<User>? getListUserFromFriends(
      List<FriendData> list, List<User>? listAllUser) {
    List<User> listUser = [];
    if (listAllUser != null) {
      for (var element in list) {
        User? user = getUserFromID(listAllUser, element.idFriend);
        if (user != null) {
          listUser.add(user);
        }
      }
    }

    return listUser;
  }

  // for group module

  // this function is used for add new members from group members
  static List<User> getAllNoExistedUserInChatGroup(
      List<User> allUser, List<String>? existedUser) {
    List<User> result =
        allUser.where((element) => !existedUser!.contains(element.id)).toList();
    return result;
  }

  static bool isIDFromListID(String id, List<String>? list) {
    for (var element in list!) {
      if (element == id) {
        return true;
      }
    }
    return false;
  }

  // for merge friend and user on the same group
  static List<User> mergeList(List<User> listFriend, List<User>? listUser) {
    List<User> list = List.from(listFriend);
    for (var element in listUser!) {
      if (!checkExistInList(list, element)) {
        list.add(element);
      }
    }
    return list;
  }

  static bool checkExistInList(List<User> list, User user) {
    for (var element in list) {
      if (user.id == element.id) {
        return true;
      }
    }
    return false;
  }

  static bool checkUserInChats(List<MessageData> list, User user) {
    for (var element in list) {
      if (element.receivers!.contains(user.id)) {
        return true;
      }
    }
    return false;
  }

  // for groupHeaderBuilder in chatting page
  static String showHeaderTime(DateTime dateTime) {
    if (Validators.compareDate(dateTime)) {
      if (Validators.compareHour(dateTime)) {
        return DateFormat.Hm().format(dateTime);
      } else {
        return "Today";
      }
    } else if (Validators.isSameWeek(DateTime.now(), dateTime)) {
      return DateFormat.EEEE().format(dateTime);
    } else {
      return DateFormat.yMd().format(dateTime);
    }
  }

  static List<String>? getTokens(List<User>? listUser) {
    List<String>? list = [];
    for (var element in listUser!) {
      if (element.token != null) {
        list.add(element.token!);
      }
    }
    return list;
  }

  static List<User>? getReceiversExceptCurrentUser(
      List<User>? list, User? currentUser) {
    List<User>? listReceivers = List.from(list!);
    listReceivers.removeWhere((element) => element.id == currentUser!.id);
    return listReceivers;
  }

  static void sendNotifications(List<User>? receivers, User? currentUser,
      User? receiver, MessageData? messageData, String body) {
    // send notifications to others
    List<String>? tokens = [];
    List<User>? listReceivers =
        CommonMethods.getReceiversExceptCurrentUser(receivers, currentUser);
    if (receiver != null) {
      if (receiver.id != currentUser!.id) {
        if (receiver.token != null) {
          NotificationService.sendPushMessage(
              [receiver.token!],
              body,
              currentUser.name!,
              Paths.CHATTINGPAGE,
              messageData!.idMessageData!);
        }
      }
    } else {
      tokens = CommonMethods.getTokens(listReceivers);
      NotificationService.sendPushMessage(
          tokens!,
          body,
          "${currentUser!.name} sent to ${messageData!.chatName}",
          Paths.CHATTINGPAGE,
          messageData.idMessageData!);
    }
  }

  static void sendFriendNotification(User? user, String body, String path) {
    String tokens = user!.token!;
    NotificationService.sendPushMessage(
        [tokens], body, "Friend request", path, "");
  }
}
