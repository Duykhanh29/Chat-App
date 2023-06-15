import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageController extends GetxController {
  RxList<User> listAllUser = <User>[].obs;
  RxList<User> listUser = <User>[].obs;
  RxList<MessageData> listMessageData = <MessageData>[].obs;
  RxList<MessageData> searchListMessageData = <MessageData>[].obs;
  RxList<User> searchListUser = <User>[].obs;
  RxBool isSearch = false.obs; // it is used for chatting_details
  RxInt searchMessageIndex = RxInt(-1);
  TextEditingController searchController = TextEditingController(text: "");
  RxBool isRecorder = false.obs;
  RxBool isChoosen = false.obs;
  RxString deletedID = "".obs;
  RxBool deleteJustForYou = false.obs;
  RxBool isReply = false.obs;
  RxBool isMore = false.obs;
  Message? replyMessage;
  User? replyToUser;
  final authController = Get.find<AuthController>();

  RxList<User> listReceivers = <User>[].obs;
  Rx<User?> aReceiver = Rx<User?>(null);

  void resetReceivers() {
    aReceiver.value = null;
    listReceivers.value = <User>[].obs;
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
        );
      }
    });
    aReceiver.value = user;
  }

  Future getListReceivers(List<String> listID) async {
    List<User> list = <User>[].obs;
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    for (int i = 0; i < listID.length; i++) {
      // User? user = await getUserByID(listID[i]);
      // if (user != null) {
      //   list.add(user);
      // }
      User? user;
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      snapshot.docs.forEach((element) {
        if (listID[i] == element.id) {
          user = User(
            id: element.data()['id'],
            name: element.data()['name'],
            email: element.data()['email'],
            phoneNumber: element.data()['phoneNumber'],
            story: element.data()['story'],
            urlImage: element.data()['urlImage'],
            userStatus: getUserStatus(element.data()['userStatus']),
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

  @override
  void onInit() async {
    // String id = "9Q6tAOynd2XdIGQFVi9QYyOhA0y1";
    // aReceiver.value = await getUserFromID(id);

    // TODO: implement onInit
    super.onInit();
    print("On inut");
    User? currentUser = authController.currentUser.value;
    print("First check user: \n");
    currentUser!.showALlAttribute();
    listUser.value = await getListUserInDB();
    listAllUser.value = await getListUserInDB();
    listMessageData.value = await getAllMessageDataOfCurrentUser(currentUser);
    searchListMessageData.value = listMessageData;
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
      if (element.receivers!.last == receiver.id &&
          element.receivers!.first == sender.id) {
        print('Same User:${element.receivers!.last} with list ${receiver.id} ');
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

  void sentAMessage(Message message, MessageData messageData) async {
    try {
      CollectionReference messageDataCollections =
          FirebaseFirestore.instance.collection('messageDatas');
      QuerySnapshot querySnapshot = await messageDataCollections.get();
      int documentCount = querySnapshot.size;

      print('Số lượng tài liệu trong collection: $documentCount');
      // Lấy tham chiếu đến tài liệu của người dùng trong collection "messageData"
      DocumentReference userDocRef =
          messageDataCollections.doc(messageData.idMessageData);
      print("ID ò messageData: ${messageData.idMessageData}");
      // Lấy thông tin tài liệu của người dùng từ Firebase Firestore
      DocumentSnapshot messageDataDoc = await userDocRef.get();

      if (!messageDataDoc.exists) {
        // haven't sent any message before
        messageData.listMessages!.add(message); // update to GetX
        print('I am crazy\n');
        message.showALlAttribute();
        // update to firebase
        MessageData newMessageData = MessageData(
            // sender: messageData.sender,
            listMessages: messageData.listMessages!,
            receivers: messageData.receivers,
            idMessageData: messageData.idMessageData);
        final data = newMessageData.toJson();
        print(data);
        await userDocRef.set(data); // fix at here
        listMessageData.refresh();
      } else {
        // update to GetX
        messageData.listMessages!.add(message);
        // update to FIrebase
        final data = {
          'listMessages':
              messageData.listMessages!.map((msg) => msg.toJson()).toList(),
        };
        await userDocRef.update(data);
        // update data
        listMessageData.refresh();
      }
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
      if (!data.listMessages!.isEmpty) {
        list.add(data);
      } else {
        // if list<message> of a messageData is null -> remove it
        list.remove(data);
      }
    }
    // sort by time
    list.sort(
      (a, b) => b.listMessages!.last.dateTime!
          .compareTo(a.listMessages!.last.dateTime!),
    );
    print("Print list to check/n");
    for (var element in list) {
      element.showALlAttribute();
    }
    return list;
  }

  // to filter list messageData from input
  void filterListMessageData(String userName) async {
    print("Search list user");
    List<MessageData> list = [];
    if (userName.isEmpty) {
      list = listMessageData.value;
    } else {
      list = listMessageData.where((data) {
        List<MessageData> temtList = [];
        if (data.receivers!.length == 1) {
          User? user = userGetUserFromIDBYGetX(data.receivers!.last);
          return user!.name
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
          if (!isCheckExistUser(listMessageData.value, user)) {
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
    replyToUser = message.sender;
    update();
  }

  void resetReplyMessage() {
    replyMessage = null;
    replyToUser = null;
    update();
  }

  void printListDataMessage(MessageData messageData) {
    for (var element in messageData.listMessages!) {
      print(
          "ID: ${element.idMessage} and text: ${element.text} and type: ${element.chatMessageType} ");
    }
  }

  // to foward a message
  Message findMessageFromIdAndUser(String id, User user, String idMessageData) {
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

  int differenceHours(Message message) {
    return DateTime.now().difference(message.dateTime!).inHours;
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
              if (differenceHours(listMessageData[i].listMessages![j]) < 3) {
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

  // infinished feature
  void deleteAConversation(String id) {
    for (var data in listMessageData.value) {
      if (data.idMessageData == id) {
        data.listMessages != [];
      }
    }
  }

  // check functions
  void printALlUser(List<MessageData> list) {
    for (var element in list) {
      // print(
      //     "User: ID: ${element.sender!.id} and email:  ${element.sender!.email},name ${element.sender!.name}");
    }
  }

  // User user1 = User(
  //     id: "ID01",
  //     name: "Nguyen Tung",
  //     story: false,
  //     userStatus: UserStatus.ONLINE,
  //     urlImage:
  //         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSRKouGaC5wkHjgKIuSSZTrTBBQWc5gEIOPFw&usqp=CAU");
  // User user2 = User(
  //     id: "ID02",
  //     name: "Nguyen Manh",
  //     userStatus: UserStatus.PRIVACY,
  //     story: false,
  //     urlImage:
  //         "https://imgv3.fotor.com/images/share/Unblur-image-online-automatically-with-Fotor-AI-image-deburring-tool.jpg");
  // User user3 = User(
  //     id: "ID03",
  //     name: "Nguyen Huong",
  //     story: true,
  //     userStatus: UserStatus.ONLINE,
  //     urlImage:
  //         "https://topten.review/wp-content/uploads/sites/3/2022/02/VanceAI-Image-Sharpener-700-360@2x-300x154.png");
  // User user4 = User(
  //     id: "ID04",
  //     name: "Nguyen Hung1",
  //     userStatus: UserStatus.OFFLINE,
  //     story: true,
  //     urlImage:
  //         "https://images.unsplash.com/photo-1635468872214-8d30953f0057?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=437&q=80");
  // User user5 = User(
  //     id: "ID05",
  //     name: "Nguyen Hung",
  //     story: true,
  //     userStatus: UserStatus.PRIVACY,
  //     urlImage:
  //         "https://assets.ayobandung.com/crop/0x0:0x0/750x500/webp/photo/2023/02/20/ascxzcsafag-1165003792.jpg");
  // User user6 = User(
  //     id: "ID06",
  //     name: "Nguyen Luc",
  //     story: true,
  //     userStatus: UserStatus.ONLINE,
  //     urlImage: "https://pixlr.com/images/index/remove-bg.webp");
  // User user7 = User(
  //     id: "ID07",
  //     name: "Nguyen Quang",
  //     story: true,
  //     userStatus: UserStatus.OFFLINE,
  //     urlImage:
  //         "https://images.unsplash.com/photo-1613323593608-abc90fec84ff?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80");
  // User user8 = User(
  //     id: "ID08",
  //     name: "Doctor Strange",
  //     story: true,
  //     userStatus: UserStatus.ONLINE,
  //     urlImage:
  //         "https://play-lh.googleusercontent.com/MqXH34arO8Yb0Wm8UVw99eknd1a4Oltj959fls29wlfo9xHg5oKdi9RlgliORSQGSltklw");
  // User user9 = User(
  //     id: "ID09",
  //     name: "David James",
  //     story: true,
  //     urlImage:
  //         "https://images.freeimages.com/images/previews/e6e/cn-tower-1636717.jpg",
  //     userStatus: UserStatus.ONLINE);
  // User user10 = User(
  //     id: "ID010",
  //     name: "natural",
  //     story: true,
  //     urlImage:
  //         "https://images.unsplash.com/photo-1566438480900-0609be27a4be?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8aW1hZ2V8ZW58MHx8MHx8&w=1000&q=80",
  //     userStatus: UserStatus.ONLINE);
  // listUser.value = [
  //   user1,
  //   user2,
  //   user3,
  //   user4,
  //   user5,
  //   user6,
  //   user7,
  //   user8,
  //   user9,
  //   user10,
  // ];
  // listMessageData.value = [
  //   MessageData(
  //     user: user1,
  //     listMessages: [
  //       Message(
  //           idMessage: "ID01",
  //           text:
  //               "The above code specifies that our app should execute a command when there is a match in the string specified in the first argument that is passed to our intent function call.",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID02",
  //           text: "I",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID03",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID04",
  //           text:
  //               "https://www.youtube.com/watch?v=PwkxZq5Ef4g&list=RDMM&index=2",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID05",
  //           text:
  //               "https://64.media.tumblr.com/8b4c01edd9f4c95f92197a961dd7b1af/2177eda79af71270-7e/s1280x1920/920265619ec74632fd83faca04abaddb5d7b3e38.jpg",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID06",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID07",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //     ],
  //   ),
  //   MessageData(
  //     user: user2,
  //     listMessages: [
  //       Message(
  //           idMessage: "ID01",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID02",
  //           text:
  //               "https://media-cdn-v2.laodong.vn/storage/newsportal/2023/2/17/1148971/Lee-Je-Hoon-01.jpg",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID03",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID04",
  //           text:
  //               "https://www.youtube.com/watch?v=1KCHzbgu4no&list=RDMM&start_radio=1&rv=nSBMAQpvMjE",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID05",
  //           text: "guys",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID06",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID07",
  //           text: "Nha",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: false),
  //     ],
  //   ),
  //   MessageData(
  //     user: user3,
  //     listMessages: [
  //       Message(
  //           idMessage: "ID01",
  //           text: "text",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID02",
  //           text: "I",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID03",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID04",
  //           text:
  //               "https://www.youtube.com/watch?v=nSBMAQpvMjE&list=RDGMEMYH9CUrFO7CfLJpaD7UR85w&start_radio=1&rv=HXkh7EOqcQ4",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID05",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID06",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID07",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: false,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID08",
  //           text:
  //               "https://bloganchoi.com/wp-content/uploads/2021/05/lee-je-hoon-chia-se.jpg",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID09",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID10",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID11",
  //           text: "you",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID12",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID13",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID14",
  //           text: "Nha",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID15",
  //           text: "Nha",
  //           chatMessageType: ChatMessageType.VIDEOCALL,
  //           isSender: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true,
  //           longTime: 200),
  //     ],
  //   ),
  //   MessageData(
  //     user: user4,
  //     listMessages: [
  //       Message(
  //           idMessage: "ID01",
  //           text: "text",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID02",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID03",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID04",
  //           text: "https://www.youtube.com/watch?v=HXkh7EOqcQ4",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID05",
  //           text: "guys",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID06",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID07",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: false,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID08",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID09",
  //           text: "I",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID10",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID11",
  //           text: "you",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID12",
  //           text:
  //               "https://media.doisongphapluat.com/media/trieu-phuong-linh/2023/04/03/kim-do-ki-phat-hien-black-sun-la-cau-lac-bo-co-nhieu-te-nan11.png",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID13",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID14",
  //           text: "Nha",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(days: 1)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID15",
  //           text: "Nha",
  //           chatMessageType: ChatMessageType.VIDEOCALL,
  //           isSender: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(days: 1)),
  //           isSeen: true,
  //           longTime: 500),
  //     ],
  //   ),
  //   MessageData(
  //     user: user5,
  //     listMessages: [
  //       Message(
  //           idMessage: "ID01",
  //           text: "text",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID02",
  //           text: "I",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID03",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID04",
  //           text: "https://www.youtube.com/watch?v=QWvXm_AppeE",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID05",
  //           text: "guys",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID06",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID07",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: false,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID08",
  //           text: "text",
  //           chatMessageType: ChatMessageType.CALL,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true,
  //           longTime: 100),
  //       Message(
  //           idMessage: "ID09",
  //           text: "https://www.youtube.com/",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID10",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID11",
  //           text: "you",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID12",
  //           text:
  //               "https://images2.minutemediacdn.com/image/upload/c_crop,w_4000,h_2250,x_0,y_96/c_fill,w_1440,ar_16:9,f_auto,q_auto,g_auto/images/GettyImages/mmsport/90min_en_international_web/01grp5mzkmtn0ef8dzjz.jpg",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID13",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID14",
  //           text: "Nha",
  //           chatMessageType: ChatMessageType.CALL,
  //           isSender: false,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: false,
  //           longTime: 230),
  //     ],
  //   ),
  //   MessageData(
  //     user: user6,
  //     listMessages: [
  //       Message(
  //           idMessage: "ID01",
  //           text: "text",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID02",
  //           text: "I",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID03",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID04",
  //           text:
  //               "https://www.youtube.com/watch?v=Zi9To04PO78&list=RDZi9To04PO78&start_radio=1",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID05",
  //           text: "guys",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID06",
  //           text: "Oke",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID07",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: false,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID08",
  //           text: "text",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID09",
  //           text: "I",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 4, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID10",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now()
  //               .subtract(const Duration(minutes: 2, seconds: 30)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID11",
  //           text: "you",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID12",
  //           text: "https://translate.google.com/?hl=vi",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID13",
  //           text: "https://i.ytimg.com/vi/JF29HwVuXlc/maxresdefault.jpg",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: false),
  //       Message(
  //           idMessage: "ID14",
  //           text: "Nani",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID15",
  //           chatMessageType: ChatMessageType.CALL,
  //           isSender: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true,
  //           longTime: 320),
  //     ],
  //   ),
  //   MessageData(
  //     user: user8,
  //     listMessages: [
  //       Message(
  //           idMessage: "ID01",
  //           text: "text",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: false,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID02",
  //           text: "I",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(days: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID03",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(days: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID04",
  //           text: "https://www.youtube.com/watch?v=eegl7of4g-o",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(days: 3)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID05",
  //           text: "guys",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SEEN,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 2)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID06",
  //           text:
  //               "https://assets.ayobandung.com/crop/0x0:0x0/750x500/webp/photo/2023/02/18/lee-je-hoon-285042092.jpg",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: false,
  //           messageStatus: MessageStatus.RECEIVED,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID07",
  //           text: "Nha",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID08",
  //           text: "Nha",
  //           chatMessageType: ChatMessageType.TEXT,
  //           isSender: true,
  //           isRepy: true,
  //           replyToUser: user8,
  //           idReplyText: "ID06",
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID09",
  //           text:
  //               "https://assets.goal.com/v3/assets/bltcc7a7ffd2fbf71f5/blt4cf439c6adcd9edc/64365f75ecfd62869e093e8b/Luka_Modric_Real_Madrid_2022-23_(2).jpg",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: true,
  //           replyToUser: user8,
  //           isRepy: true,
  //           idReplyText: "ID06",
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID10",
  //           text:
  //               "https://assets.goal.com/v3/assets/bltcc7a7ffd2fbf71f5/blt4cf439c6adcd9edc/64365f75ecfd62869e093e8b/Luka_Modric_Real_Madrid_2022-23_(2).jpg",
  //           chatMessageType: ChatMessageType.IMAGE,
  //           isSender: true,
  //           isDeleted: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID11",
  //           text:
  //               "https://www.youtube.com/watch?v=x8Hv2Cst3oY&list=WL&index=9",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: false,
  //           isRepy: true,
  //           replyToUser: user8,
  //           idReplyText: "ID04",
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID12",
  //           text:
  //               "https://www.youtube.com/watch?v=x8Hv2Cst3oY&list=WL&index=9",
  //           chatMessageType: ChatMessageType.VIDEO,
  //           isSender: false,
  //           isDeleted: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID13",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: false,
  //           isDeleted: true,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID14",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: false,
  //           isRepy: true,
  //           idReplyText: "ID03",
  //           replyToUser: user8,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //       Message(
  //           idMessage: "ID15",
  //           text: "audios/SonTingMTP.mp3",
  //           chatMessageType: ChatMessageType.AUDIO,
  //           isSender: false,
  //           isRepy: true,
  //           idReplyText: "ID03",
  //           replyToUser: user8,
  //           messageStatus: MessageStatus.SENT,
  //           dateTime: DateTime.now().subtract(const Duration(minutes: 0)),
  //           isSeen: true),
  //     ],
  //   ),
  // ];
}
