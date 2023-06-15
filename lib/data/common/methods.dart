import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';

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

  static List<User> getAllUserInChat(
      List<String> listID, List<User> listUser, User currentUser) {
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
}
