import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  RxList<User> initialMember = <User>[].obs;
  RxList<User> addNewMembers = <User>[].obs;
  RxList<User> allUserInAChat = <User>[].obs;
  Rx<User?> targetUser = Rx<User?>(null);

  // for group
  // for group chat
  RxList<User> searchFriend =
      <User>[].obs; // this is used for search friend to invite to the group
  RxList<bool> searchFriendIndex = <bool>[].obs;

  // for initial member
  void addNewUser(User newUser) {
    initialMember.value.add(newUser);
  }

  void removeUser(User user) {
    initialMember.value.remove(user);
  }

  void resetInitialMember() {
    initialMember.value = [];
  }

  // for add new member list
  void addNewUserInAddMember(User newUser) {
    addNewMembers.value.add(newUser);
  }

  void removeUserInAddMembers(User user) {
    addNewMembers.value.remove(user);
  }

  void resetAddMember() {
    addNewMembers.value = [];
  }

  //for all user in a chat
  void setValueUserInAChat(List<User> list) {
    allUserInAChat.value = list;
  }

  void deleteUserFromChat(User user) {
    allUserInAChat.value.removeWhere((element) => element.id == user.id);
  }

  void addUser(User user) {
    allUserInAChat.value.add(user);
  }

  // for target user  (it means that creating group with an user)
  void setValueFortargetUser(User? user) {
    targetUser.value = user;
  }

  // filter and return to List<User>
  void filterList(String searchKey, List<User> list) {
    List<User>? result;
    if (searchKey.isEmpty) {
      result = list;
    } else {
      result = list
          .where((element) => element.name!
              .toString()
              .toLowerCase()
              .contains(searchKey.toLowerCase()))
          .toList();
    }
    searchFriend.value = result;
    searchFriendIndex.assignAll(List.filled(result.length, false));
  }

  // set value for searchFriend  ( group)
  void setValueForSearchFriend(List<User> list) {
    searchFriend.value = list;
    searchFriendIndex.assignAll(List.filled(list.length, false));
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  // add new group
  Future createGroup(MessageData messageData) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('messageDatas');
      DocumentReference docRef = ref.doc(messageData.idMessageData);
      MessageData newData = MessageData(
          idAdmin: messageData.idAdmin,
          createdAt: messageData.createdAt,
          chatName: messageData.chatName,
          groupImage: messageData.groupImage,
          listMessages: messageData.listMessages!,
          receivers: messageData.receivers,
          idMessageData: messageData.idMessageData);
      await docRef.set(newData.toJson());
    } catch (e) {
      print("An error occured: $e");
    }
  }

  // add new user
  Future addAnUserToGroup(MessageData messageData, User newUser) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('messageDatas');
      DocumentReference docRef = ref.doc(messageData.idMessageData);
      DocumentSnapshot doc = await docRef.get();
      if (!doc.exists) {
        List<String> receivers = [newUser.id!];
        MessageData newData = MessageData(
            idAdmin: messageData.idAdmin,
            createdAt: Timestamp.now(),
            chatName: messageData.chatName,
            groupImage: messageData.groupImage,
            listMessages: messageData.listMessages!,
            receivers: receivers,
            idMessageData: messageData.idMessageData);
        await docRef.set(newData.toJson());
      } else {
        List<String> receivers = messageData.receivers!;
        receivers.add(newUser.id!);
        final data = {
          'createdAt': Timestamp.now(),
          'receivers': receivers.map((e) => e).toList(),
        };
        await docRef.update(data);
      }
    } catch (e) {
      print("An error occured: $e");
    }
  }

  // update group
  Future updateGroupChat(
      {required MessageData messageData,
      required User user,
      String? groupName,
      String? image}) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('messageDatas');
      DocumentReference docRef = ref.doc(messageData.idMessageData);
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        // messageData.chatName
        String? chatName = groupName ?? messageData.chatName;
        String? photo = image ?? messageData.groupImage;
        final data = {
          'createdAt': Timestamp.now(),
          'groupImage': photo,
          'chatName': chatName
        };
        await docRef.update(data);
      }
    } catch (e) {
      print("An error occured: $e");
    }
  }

// leave group
  Future leaveGroup(MessageData messageData, User user) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('messageDatas')
          .doc(messageData.idMessageData);
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        messageData.receivers!.removeWhere((element) => element == user.id);
        List<String> receivers = messageData.receivers!;
        final data = {
          'createdAt': Timestamp.now(),
          'receivers': receivers.map((e) => e).toList(),
        };
        await docRef.update(data);
      }
    } catch (e) {
      print("An error occured: $e");
    }
  }

// (only admin can do that)
  // delete an user from group
  Future deleteAnUserFromGroup(MessageData messageData, User targetUser) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('messageDatas');
      DocumentReference docRef = ref.doc(messageData.idMessageData);
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        messageData.receivers!
            .removeWhere((element) => element == targetUser.id);
        List<String> receivers = messageData.receivers!;
        final data = {
          'createdAt': Timestamp.now(),
          'receivers': receivers.map((e) => e).toList(),
        };
        await docRef.update(data);
      }
    } catch (e) {
      print("An error occured: $e");
    }
  }

  // delete group
  Future deleteGroup(MessageData messageData) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('messageDatas');
      DocumentReference docRef = ref.doc(messageData.idMessageData);
      final execution = await docRef.delete();
    } catch (e) {
      print("An error occured: $e");
    }
  }
}
