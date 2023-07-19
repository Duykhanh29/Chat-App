import 'dart:async';

import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/friend.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/utils/constants/constants.dart';
import 'package:chat_app/utils/constants/servers_data.dart';
import 'package:chat_app/utils/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MessageController extends GetxController {
  // import auth
  final authController = Get.find<AuthController>();

  final StreamController<List<MessageData>> listAllMsgDataForCurrentUser =
      StreamController<List<MessageData>>.broadcast();
  final StreamController<RxList<MessageData>> searchListMsgDataForCurrentUser =
      StreamController<RxList<MessageData>>.broadcast();
  RxString searchKey = "".obs;

  // kind of list users
  RxList<User> listAllUser =
      <User>[].obs; // this should to move to data_controller
  RxList<User> listUser = <User>[].obs;
  RxList<User> searchListUser = <User>[].obs;
  RxList<User> relatedUserToCurrentUser = <User>[].obs;
  RxList<User> listReceivers = <User>[].obs;
  Rx<User?> aReceiver = Rx<User?>(null);

  // kind of list msgData
  RxList<MessageData> listMessageData = <MessageData>[].obs;
  RxList<MessageData> searchListMessageData = <MessageData>[].obs;
  Stream<RxList<MessageData>> streamSearchListMessageData =
      const Stream<RxList<MessageData>>.empty();

  RxInt searchMessageIndex = RxInt(-1);

  // options
  RxBool isRecorder = false.obs;
  RxBool isChoosen = false.obs;
  RxBool isMore = false.obs;
  RxBool isSearch = false.obs; // it is used for chatting_details
  TextEditingController searchController = TextEditingController(text: "");

  // for a msg
  RxString deletedID = "".obs;
  RxBool deleteJustForYou = false.obs;
  RxBool isReply = false.obs;
  Message? replyMessage;
  String? replyToUserID;

  // location
  RxString latitude = "".obs;
  RxString longtitude = "".obs;

  // for detail page
  RxList<String> listLink = RxList<String>();
  RxList<Map<String, String>>? listMedia = RxList<Map<String, String>>();

  void resetReceivers() {
    aReceiver.value = null;
    listReceivers.value = <User>[].obs;
  }

  // stream get all msgData in db
  Stream<List<MessageData>> getAllMsgDatainDB() async* {
    final ref =
        FirebaseFirestore.instance.collection('messageDatas').snapshots();
    StreamController<List<MessageData>> streamController =
        StreamController<List<MessageData>>();
    final subscription = ref.listen((event) {
      List<MessageData> listMsgData = [];
      for (var element in event.docs) {
        listMsgData.add(MessageData.fromJson(element.data()));
      }
      streamController.sink.add(listMsgData);
    });
    //close subscription and controller
    streamController.onCancel = () {
      subscription.cancel();
      streamController.close();
    };
    yield* streamController.stream;
  }

  // way 1: stream to get all msgData of current User
  Stream<List<MessageData>> getListMsgDataOfCurrentUser(
      User? currentUser) async* {
    final ref = FirebaseFirestore.instance
        .collection('messageDatas')
        .where('receivers', arrayContains: currentUser!.id)
        .snapshots();
    StreamController<List<MessageData>> streamController =
        StreamController<List<MessageData>>();
    final subscription = ref.listen((event) {
      List<MessageData> listMsgData = [];
      for (var element in event.docs) {
        listMsgData.add(MessageData.fromJson(element.data()));
      }
      listAllMsgDataForCurrentUser.sink.add(listMsgData);
    });
    //close subscription and controller
    streamController.onCancel = () {
      subscription.cancel();
      streamController.close();
    };
    yield* listAllMsgDataForCurrentUser.stream;
  }

  // way 2: stream to get all msgData of current User
  Stream<RxList<MessageData>> getAllMsgDataOfCurrentUser(
      User? currentUser) async* {
    final msgDatas = FirebaseFirestore.instance.collection('messageDatas');
    final result =
        msgDatas.where('receivers', arrayContains: currentUser!.id).snapshots();
    StreamController<RxList<MessageData>> streamController =
        StreamController<RxList<MessageData>>();
    result.listen((event) {
      List<MessageData> messages = [];
      for (var doc in event.docs) {
        messages.add(MessageData.fromJson(doc.data()));
      }
      RxList<MessageData> rxMessages = messages.obs;
      streamController.add(rxMessages);
    });
    yield* streamController.stream;
  }

  Stream<MessageData> getMesgData(MessageData messageData) async* {
    final ref = FirebaseFirestore.instance
        .collection('messageDatas')
        .doc(messageData.idMessageData)
        .snapshots();
    StreamController<MessageData> controller = StreamController<MessageData>();
    final subscription = ref.listen((event) {
      if (event.exists) {
        MessageData messageData = MessageData(
            chatName: event.data()!['chatName'],
            createdAt: event.data()!['createdAt'],
            idMessageData: event.id,
            groupImage: event.data()!['groupImage'],
            listMessages: (event.data()!['listMessages'] as List<dynamic>)
                .map((e) => Message.fromJson(e))
                .toList(),
            receivers: List<String>.from(event.data()!['receivers'])
                .map((e) => e.toString())
                .toList());
        controller.sink.add(messageData);
      } else {
        controller.close();
      }
    });
    //close subscription and controller
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    yield* controller.stream;
  }

  Stream<List<MessageData>> updateDisplay(
      User? currentUser, String searchKey) async* {
    final ref = FirebaseFirestore.instance
        .collection('messageDatas')
        .where('receivers', arrayContains: currentUser!.id)
        .snapshots();

    StreamController<List<MessageData>> streamController =
        StreamController<List<MessageData>>();
    StreamSubscription subscription = ref.listen((event) {
      List<MessageData> listMsgData = [];
      for (var element in event.docs) {
        listMsgData.add(MessageData.fromJson(element.data()));
      }
      if (searchKey.isEmpty) {
        streamController.sink.add(listMsgData);
      } else {
        List<MessageData> result = listMsgData.where((data) {
          if (data.receivers!.length == 2) {
            String? receiver = CommonMethods.getUserFromListReceiverIDs(
                data.receivers, authController.currentUser.value);
            User? user = userGetUserFromIDBYGetX(receiver!);

            return user!.name
                .toString()
                .toLowerCase()
                .contains(searchKey.toLowerCase());
          } else {
            return data.chatName
                .toString()
                .toLowerCase()
                .contains(searchKey.toLowerCase());
          }
        }).toList();
        if (result.isEmpty) {
          List<User> userList = [];
          // List<User> result = [];
          for (var user in listAllUser) {
            if (!isCheckExistUser(listMsgData, user)) {
              userList.add(user);
            }
          }
          searchListUser.value = userList
              .where((data) => data.name
                  .toString()
                  .toLowerCase()
                  .contains(searchKey.toLowerCase()))
              .toList();
        }
        streamController.sink.add(result);
      }
    });
    //close subscription and controller
    streamController.onCancel = () {
      subscription.cancel();
      streamController.close();
    };
    yield* streamController.stream;
  }

  Stream<RxList<MessageData>> updateDisplayedMsgData(String searchKey) async* {
    List<MessageData> list = await listAllMsgDataForCurrentUser.stream.first;
    RxList<MessageData> displayedChatList = RxList<MessageData>();
    List<MessageData> result = [];
    if (searchKey.isEmpty) {
      result = list;
      // displayedChatList.value = result;
      // displayedChatList.addAll(list);
    } else {
      result = list.where((data) {
        List<MessageData> temtList = [];
        if (data.receivers!.length == 2) {
          String? receiver = CommonMethods.getUserFromListReceiverIDs(
              data.receivers, authController.currentUser.value);
          User? user = userGetUserFromIDBYGetX(receiver!);
          print(user!.name
              .toString()
              .toLowerCase()
              .contains(searchKey.toLowerCase()));
          return user.name
              .toString()
              .toLowerCase()
              .contains(searchKey.toLowerCase());
        } else {
          return data.chatName
              .toString()
              .toLowerCase()
              .contains(searchKey.toLowerCase());
        }
      }).toList();
      if (result.isEmpty) {
        List<User> userList = [];
        // List<User> result = [];
        for (var user in listAllUser) {
          if (!isCheckExistUser(list, user)) {
            userList.add(user);
          }
        }
        searchListUser.value = userList
            .where((data) => data.name
                .toString()
                .toLowerCase()
                .contains(searchKey.toLowerCase()))
            .toList();
      }
      print("Size of list: ${list.length}");
    }

    displayedChatList.value = result;
    searchListMsgDataForCurrentUser.add(displayedChatList);
    yield* searchListMsgDataForCurrentUser.stream;
  }

  void changeSearchKey(String value) {
    searchKey.value = value;
  }

  Future loadAllUserRelatedToCurrentUser(User currentUser) async {
    List<User> list = <User>[].obs;
    try {
      // final owner = await FirebaseFirestore.instance
      //     .collection("friends")
      //     .doc(currentUser.id)
      //     .get();
      // final snapshot =
      //     await FirebaseFirestore.instance.collection('users').get();
      // // get all user from friend list
      // var data = owner.data() as Map<String, dynamic>;
      // final friends = data['listFriend'];
      // for (var element in friends) {
      //   User? user = await getUserFromID(element);
      //   list.add(user!);
      // }

      // get all user who are stranger but in the same group
      var listMsgData = listMessageData.value;
      for (var element in listMsgData) {
        for (var el1 in element.receivers!) {
          if (!checkExist(el1, list)) {
            User? user = await getUserFromID(el1);
            list.add(user!);
          }
        }
      }
      return list;
    } catch (e) {
      print("An error occured: $e");
    }
  }

  bool checkExist(String id, List<User> list) {
    for (var element in list) {
      if (id == element.id) {
        return true;
      }
    }
    return false;
  }

  Future<User?> getUserFromID(String id) async {
    User? user;
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final size = snapshot.size;
    print("Size is: $size");
    // await Future.forEach(snapshot.docs, (element) {
    //   if (id == element.id) {
    //     user = User(
    //       id: element.data()['id'],
    //       name: element.data()['name'],
    //       email: element.data()['email'],
    //       phoneNumber: element.data()['phoneNumber'],
    //       story: element.data()['story'],
    //       urlImage: element.data()['urlImage'],
    //       userStatus: getUserStatus(element.data()['userStatus']),
    //     );
    //   }
    // });
    for (var element in snapshot.docs) {
      if (id == element.id) {
        user = User(
          id: element.data()['id'],
          name: element.data()['name'],
          email: element.data()['email'],
          phoneNumber: element.data()['phoneNumber'],
          story: element.data()['story'],
          urlImage: element.data()['urlImage'],
          userStatus: getUserStatus(element.data()['userStatus']),
          urlCoverImage: element.data()['urlCoverImage'],
        );
        break;
      }
    }

    return user;
  }

  Future<User?> getUserByID(String id) async {
    User? user;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (querySnapshot.size > 0) {
      final userDoc = querySnapshot.docs.first;
      user = User(
        id: userDoc['id'],
        name: userDoc['name'],
        email: userDoc['email'],
        phoneNumber: userDoc['phoneNumber'],
        story: userDoc['story'],
        urlImage: userDoc['urlImage'],
        userStatus: getUserStatus(userDoc['userStatus']),
        urlCoverImage: userDoc['urlCoverImage'],
      );
    }

    return user;
  }

  Future returnUserFromID(String id) async {
    User? user;
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    snapshot.docs.forEach((element) {
      if (id == element.id) {
        user = User(
          id: element.data()['id'],
          name: element.data()['name'],
          email: element.data()['email'],
          phoneNumber: element.data()['phoneNumber'],
          story: element.data()['story'],
          urlImage: element.data()['urlImage'],
          userStatus: getUserStatus(element.data()['userStatus']),
          urlCoverImage: element.data()['urlCoverImage'],
        );
      }
    });
    aReceiver.value = user;
  }

  // get list receivers from a list string of receiverID in a chat
  Future getListReceivers(List<String> listIDReceivers) async {
    List<User> list = <User>[].obs;
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    for (int i = 0; i < listIDReceivers.length; i++) {
      // User? user = await getUserByID(listID[i]);
      // if (user != null) {
      //   list.add(user);
      // }
      User? user;
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      snapshot.docs.forEach((element) {
        if (listIDReceivers[i] == element.id) {
          user = User(
            id: element.data()['id'],
            name: element.data()['name'],
            email: element.data()['email'],
            phoneNumber: element.data()['phoneNumber'],
            story: element.data()['story'],
            urlImage: element.data()['urlImage'],
            userStatus: getUserStatus(element.data()['userStatus']),
            urlCoverImage: element.data()['urlCoverImage'],
          );
          list.add(user!);
        }
      });
    }
    listReceivers.value = list;
  }

  User? userGetUserFromIDBYGetX(String id) {
    for (var element in listAllUser.value) {
      if (element.id == id) {
        return element;
      }
    }
  }

  // Future<RxList<User>> listALlUserNearbyWithCurrentUser(
  //     User currentUser) async {
  //   RxList<User> list = <User>[].obs;
  //   final snapshot =
  //       await FirebaseFirestore.instance.collection('messageDatas').get();
  //   snapshot.docs.forEach((element) {
  //     final receivers = List<String>.from(element.data()['receivers'])
  //         .map((e) => e.toString())
  //         .toList();
  //     if (receivers.contains(currentUser.id)) {
  //       for (var element in receivers) {
  //   //      User? user=await getUserByID(element);
  //       }
  //     }
  //   });
  // }

  Future<RxList<User>> getListUserInDB() async {
    RxList<User> list = <User>[].obs;

    final snapsort = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) => value.docs.forEach((element) {
              User user = User(
                id: element.data()['id'],
                name: element.data()['name'],
                email: element.data()['email'],
                phoneNumber: element.data()['phoneNumber'],
                story: element.data()['story'],
                urlImage: element.data()['urlImage'],
                userStatus: getUserStatus(element.data()['userStatus']),
                urlCoverImage: element.data()['urlCoverImage'],
              );
              list.value.add(user);
            }));

    print("stop read");
    print("Leght: ${list.value.length}");
    return list;
  }

  Future<RxList<MessageData>> getAllMessageDataOfCurrentUser(
      User? currentUser) async {
    RxList<MessageData> list = <MessageData>[].obs;
    final snapshort =
        await FirebaseFirestore.instance.collection('messageDatas').get();
    snapshort.docs.forEach((element) {
      final messages = (element.data()['listMessages'] as List<dynamic>);
      final receivers = List<String>.from(element.data()['receivers'])
          .map((e) => e.toString())
          .toList();

      final chatName = element.data()['chatName'];
      final idMessageData = element.data()['idMessageData'];
      print("ID mEssageData value: $idMessageData");
      final groupImage = element.data()['groupImage'];
      final isVlid =
          CommonMethods.isContainUserInAList(currentUser!, receivers);
      if (isVlid) {
        if (messages != null) {
          MessageData messageData = MessageData(
              idAdmin: element.data()['idAdmin'],
              createdAt: element.data()['createdAt'],
              chatName: chatName,
              groupImage: groupImage,
              idMessageData: idMessageData,
              listMessages: messages.map((e) => Message.fromJson(e)).toList(),
              receivers: receivers);
          list.add(messageData);
        }
      }
    });
    return list;
  }

  // this is unnecessary
  Future<RxList<MessageData>> getAllMessageData() async {
    RxList<MessageData> list = <MessageData>[].obs;
    print("Get list MessageData");
    final snapsort =
        await FirebaseFirestore.instance.collection('messageDatas').get();
    snapsort.docs.forEach((element) {
      final messages = (element.data()['listMessages'] as List<dynamic>);
      final receivers = List<String>.from(element.data()['receivers'])
          .map((e) => e.toString())
          .toList();

      final chatName = element.data()['chatName'];
      final idMessageData = element.data()['idMessageData'];
      final groupImage = element.data()['groupImage'];

      if (messages != null) {
        MessageData messageData = MessageData(
            idAdmin: element.data()['idAdmin'],
            createdAt: element.data()['createdAt'],
            listMessages: messages.map((e) => Message.fromJson(e)).toList(),
            chatName: chatName,
            groupImage: groupImage,
            idMessageData: idMessageData,
            receivers: receivers);
        list.add(messageData);
      }
    });
    return list;
  }

  void setListMessageData(List<MessageData> list) {
    listMessageData.value = list;
    searchListMessageData.value = list;
  }

  @override
  void onInit() async {
    // String id = "9Q6tAOynd2XdIGQFVi9QYyOhA0y1";
    // aReceiver.value = await getUserFromID(id);

    // TODO: implement onInit
    super.onInit();
    print("On inut");
    User? currentUser = authController.currentUser.value;
    //if (authController.isLogin.value == true) {
    print("First check user: \n");
    if (currentUser != null) {
      currentUser.showALlAttribute();
      listUser.value =
          await getListUserInDB(); // this listUser isn's used in filter function. It is unneccesary
      listAllUser.value = await getListUserInDB();
      listMessageData.value = await getAllMessageDataOfCurrentUser(currentUser);
      searchListMessageData.value = listMessageData;
      relatedUserToCurrentUser.value =
          await loadAllUserRelatedToCurrentUser(currentUser);
      getListMsgDataOfCurrentUser(currentUser);
      updateDisplayedMsgData(searchKey.value);
    }
  }

  Future updateListAllUser() async {
    listAllUser.value = await getListUserInDB();
  }

  @override
  void onReady() {
    print("on Ready");
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  MessageData? getMessageDataFromID(String idMessageData) {
    //print("User id ${user.id}");
    for (var element in listMessageData) {
      //print("Check User id ${element.user!.id}");
      if (element.idMessageData == idMessageData) {
        //  print('Same User:${user.id} with list ${element.user!.id} ');
        return element;
      }
    }
  }

  MessageData? getMessageDataOneByOne(User sender, User receiver) {
    //print("User id ${user.id}");
    for (var element in listMessageData) {
      if (!CommonMethods.isAGroup(element.receivers)) {
        if (element.receivers!.last == receiver.id &&
            element.receivers!.first == sender.id) {
          print(
              'Same User:${element.receivers!.last} with list ${receiver.id} ');
          return element;
        }
      }
    }
  }

  void addNewChat(MessageData messageData) {
    listMessageData.insert(0, messageData);
  }

  void deleteAChat(MessageData? messageData) {
    messageData = null;
  }

  var lock = Object();

  void sendAMessage(Message message, MessageData messageData) async {
    try {
      CollectionReference messageDataCollections =
          FirebaseFirestore.instance.collection('messageDatas');
      QuerySnapshot querySnapshot = await messageDataCollections.get();
      int documentCount = querySnapshot.size;

      print('Số lượng tài liệu trong collection: $documentCount');
      // Lấy tham chiếu đến tài liệu của người dùng trong collection "messageData"
      DocumentReference userDocRef =
          messageDataCollections.doc(messageData.idMessageData);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot messageDataDoc = await transaction.get(userDocRef);
        if (!messageDataDoc.exists) {
          // haven't sent any message before
          messageData.listMessages!.add(
            Message(
              chatMessageType: message.chatMessageType,
              dateTime: Timestamp.fromMicrosecondsSinceEpoch(
                  DateTime.now().microsecondsSinceEpoch),
              isDeleted: message.isDeleted,
              isFoward: message.isFoward,
              isReply: message.isReply,
              isSearch: message.isSearch,
              isSeen: message.isSeen,
              idMessage: Uuid().v4(),
              idReplyText: message.idReplyText,
              longTime: message.longTime,
              messageStatus: message.messageStatus,
              replyToUserID: message.replyToUserID,
              seenBy: message.seenBy,
              senderID: firebaseAuth.currentUser!.uid,
              text: message.text,
            ),
          ); // update to GetX

          // DateTime serverTime = await ServerData.getServerTime();

          message.showALlAttribute();
          // update to firebase
          MessageData newMessageData = MessageData(
              // sender: messageData.sender,

              createdAt: Timestamp.now(),
              listMessages: messageData.listMessages!,
              receivers: messageData.receivers,
              idMessageData: messageData.idMessageData);
          final data = newMessageData.toJson();
          print(data);
          transaction.set(userDocRef, data);
          //  await userDocRef.set(data); // fix at here
          listMessageData.refresh();
        } else {
          // update to GetX

          String newMessageId = Uuid().v4();
          messageData.listMessages!.add(
            Message(
              chatMessageType: message.chatMessageType,
              dateTime: Timestamp.fromMicrosecondsSinceEpoch(
                  DateTime.now().microsecondsSinceEpoch),
              isDeleted: message.isDeleted,
              isFoward: message.isFoward,
              isReply: message.isReply,
              isSearch: message.isSearch,
              isSeen: message.isSeen,
              idMessage: Uuid().v4(),
              idReplyText: message.idReplyText,
              longTime: message.longTime,
              messageStatus: message.messageStatus,
              replyToUserID: message.replyToUserID,
              seenBy: message.seenBy,
              senderID: firebaseAuth.currentUser!.uid,
              text: message.text,
            ),
          );
          // update to FIrebase
          final data = {
            'createdAt': Timestamp.now(),
            'listMessages': FieldValue.arrayUnion([message.toJson()]),
            // messageData.listMessages!
            //     .map((msg) => {
            //           ...msg.toJson(),
            //           if (msg.idMessage == message.idMessage)
            //             'senderID': message.senderID,
            //         })
            //     .toList(),

            // 'listMessages':
            //     messageData.listMessages!.map((msg) => msg.toJson()).toList(),
          };
          transaction.update(userDocRef, data);
          // await userDocRef.update(data);
          // update data
          listMessageData.refresh();
          for (var element in listMessageData) {
            if (element.idMessageData ==
                "a110fc82-c493-4613-81d1-ce07468174de") {
              print("Image: ${element.groupImage}");
            }
          }
        }
      });
      print("ID ò messageData: ${messageData.idMessageData}");

      // Lấy thông tin tài liệu của người dùng từ Firebase Firestore
    } catch (error) {
      print("An error occurred: $error");
    }
  }

  void updateMessageData(MessageData messageData) {
    for (var element in listMessageData) {
      if (element.idMessageData == messageData.idMessageData) {}
    }
  }

  int sizeOfMessages(MessageData messageData) {
    return messageData.listMessages!.length;
  }

  List<MessageData> getListMessageData(List<MessageData> messageDataList) {
    //searchListMessageData.value = listMessageData.value;
    List<MessageData> list = [];
    for (var data in messageDataList) {
      if (CommonMethods.isAGroup(data.receivers)) {
        list.add(data);
      } else {
        if (!data.listMessages!.isEmpty) {
          list.add(data);
        } else {
          // if list<message> of a messageData is null -> remove it
          list.remove(data);
        }
      }
    }
    // sort by time
    list.sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    print("Print list to check/n");
    for (var element in list) {
      element.showALlAttribute();
    }
    return list;
  }

  // to filter list messageData from input
  void filterListMessageData(
      String userName, List<MessageData> rootedList) async {
    print("Search list user");
    List<MessageData> list = [];
    if (userName.isEmpty) {
      list = rootedList;
    } else {
      list = rootedList.where((data) {
        List<MessageData> temtList = [];
        if (data.receivers!.length == 2) {
          String? receiver = CommonMethods.getUserFromListReceiverIDs(
              data.receivers, authController.currentUser.value);
          User? user = userGetUserFromIDBYGetX(receiver!);
          print(user!.name
              .toString()
              .toLowerCase()
              .contains(userName.toLowerCase()));
          return user.name
              .toString()
              .toLowerCase()
              .contains(userName.toLowerCase());
        } else {
          return data.chatName
              .toString()
              .toLowerCase()
              .contains(userName.toLowerCase());
        }
      }).toList();
      if (list.isEmpty) {
        List<User> userList = [];
        List<User> result = [];
        for (var user in listAllUser) {
          if (!isCheckExistUser(rootedList, user)) {
            userList.add(user);
          }
        }
        searchListUser.value = userList
            .where((data) => data.name
                .toString()
                .toLowerCase()
                .contains(userName.toLowerCase()))
            .toList();
      }
      print("Size of list: ${list.length}");
    }
    searchListMessageData.value = list;
  }

  bool isCheckExistUser(List<MessageData> list, User user) {
    for (var data in list) {
      if (data.receivers!.length == 1) {
        if (data.receivers!.last == user.id) {
          return true;
        }
      }
    }
    return false;
  }

  void searchMode() {
    isSearch.value = true;
  }

  void cancelSearch() {
    isSearch.value = false;
  }

  void stopSearch(String value, MessageData data) {
    for (int i = 0; i < data.listMessages!.length; i++) {
      if (data.listMessages![i].chatMessageType == ChatMessageType.TEXT) {
        if (value.toLowerCase().toString() ==
            data.listMessages![i].text!.toLowerCase().toString()) {
          data.listMessages![i].isSearch = false;
          searchController.text = "";
        }
      }
    }
  }

  void searchMessages(String value, MessageData data) {
    for (int i = 0; i < data.listMessages!.length; i++) {
      if (data.listMessages![i].chatMessageType == ChatMessageType.TEXT) {
        print("Text: ${data.listMessages![i].text}");
        if (value.toLowerCase().toString() ==
            data.listMessages![i].text!.toLowerCase().toString()) {
          print("Text: ${data.listMessages![i].text}");
          data.listMessages![i].isSearch = true;
          searchController.text = value;
        } else {
          print("Text wrong: ${data.listMessages![i].text}");
          data.listMessages![i].isSearch = false;
        }
      }
    }
  }

  void printListDataMessage(MessageData messageData) {
    for (var element in messageData.listMessages!) {
      print(
          "ID: ${element.idMessage} and text: ${element.text} and type: ${element.chatMessageType} ");
    }
  }

  // to foward a message
  Message findMessageFromIdAndUser(
      String id, String userID, String idMessageData) {
    // if converstion is one by one
    for (var element in listMessageData) {
      if (element.idMessageData == idMessageData) {
        for (var data in element.listMessages!) {
          if (data.idMessage == id) {
            return data;
          }
        }
      }
    }

    return Message();

    // if conversation is a group
  }

  //for a message

  void changeRecorder() {
    isRecorder.value = !isRecorder.value;
  }

  void changeIsChoose() {
    isChoosen.value = !isChoosen.value;
  }

  void toggleDeleteID(String value) {
    deletedID.value = value;
  }

  Message? findMessageFromID(String id, MessageData messageData) {
    for (var element in messageData.listMessages!) {
      if (element.idMessage! == id) {
        return element;
      }
    }
  }

  void changeisReply() {
    isReply.value = !isReply.value;
  }

  void changeIsMore() {
    isMore.value = !isMore.value;
  }

  void changeReplyMessage(Message message) {
    replyMessage = message;
    replyToUserID = message.senderID;
    update();
  }

  void changeLongTitudeVsLattitude(
      {required String newLong, required String newLat}) {
    longtitude.value = newLong;
    latitude.value = newLat;
  }

  void resetLongVsLat() {
    longtitude.value = "";
    latitude.value = "";
  }

  void resetReplyMessage() {
    replyMessage = null;
    replyToUserID = null;
    update();
  }

  void deleteAMessage(String idMessage, MessageData messageData,
      {bool justForYou = false}) {
    for (int i = 0; i < listMessageData.length; i++) {
      // if (listMessageData[i].user!.id == messageData.user!.id) {
      if (listMessageData[i].idMessageData == messageData.idMessageData) {
        for (int j = 0; j < messageData.listMessages!.length; j++) {
          if (messageData.listMessages![j].idMessage == idMessage) {
            if (justForYou) {
              listMessageData[i].listMessages![j].isDeleted = true;
              deleteJustForYou.value = true; // I forget why I do this code
            } else {
              if (Validators.differenceHours(
                      listMessageData[i].listMessages![j]) <
                  3) {
                listMessageData[i].listMessages![j].isDeleted = true;
                listMessageData[i].listMessages![j].text = "NULL";
              } else {
                listMessageData[i].listMessages![j].isDeleted = true;
              }
            }
          }
        }
      }
    }
    listMessageData.refresh(); // update data
    resetDeleteForYou();
  }

  void resetDeleteForYou() {
    deleteJustForYou.value = false;
  }

  // for detailed page
  void getAllLink(List<String> list) {
    listLink.value = list;
  }

  void getAllMedia(List<Map<String, String>> list) {
    listMedia!.value = list;
  }

  void resetAllLink() {
    listLink.value = [];
  }

  void resetAllMedia() {
    listMedia!.value = [];
  }

  // infinished feature
  void deleteAConversation(String id) {
    for (var data in listMessageData.value) {
      if (data.idMessageData == id) {
        data.listMessages != [];
      }
    }
  }

  // consider to add
  Future checkForChanges() async {
    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference ref = FirebaseFirestore.instance.collection('users');
    });
  }
}


// what is this function

//  Stream<RxList<User>> convertToRxListStream(
//       Stream<List<User>> originalStream) {
//     final streamController = StreamController<RxList<User>>();

//     originalStream.listen((userList) {
//       final rxList = RxList<User>.from(userList);
//       streamController.sink.add(rxList);
//     });

//     return streamController.stream;
//   }