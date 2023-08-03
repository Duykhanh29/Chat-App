import 'dart:async';

import 'package:chat_app/data/models/friend.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/views/friend_view.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendController extends GetxController {
  final msgController = Get.find<MessageController>();
  final authController = Get.find<AuthController>();
  final dataController = Get.find<DataController>();

  //  variable
  RxBool isSent = false.obs;

  // stream variable
  Stream<List<User>> streamListFriend = const Stream<List<User>>.empty();
  Stream<List<User>> streamQueueList = const Stream<List<User>>.empty();
  Stream<List<User>> streamRequestedList = const Stream<List<User>>.empty();
  //
  Stream<List<FriendData>> streamListFriendData =
      const Stream<List<FriendData>>.empty();
  Stream<List<FriendData>> streamQueueFriendData =
      const Stream<List<FriendData>>.empty();
  Stream<List<FriendData>> streamRequestedFriendData =
      const Stream<List<FriendData>>.empty();

  Stream<Friends?> friends = const Stream<Friends>.empty();

  // unnecessary variables
  // this is used for working in another thing
  RxList<User> listFriends = <User>[].obs;
  RxList<User> listRequestedFriends = <User>[].obs;
  RxList<User> listQueueFriends = <User>[].obs;

  //  this is used for displaying in list friend view/ sent request/ received request
  RxList<FriendData> listAllFriend = <FriendData>[].obs;
  RxList<FriendData> listRequestedFriend = <FriendData>[].obs;
  RxList<FriendData> listQueueFriend = <FriendData>[].obs;

  Future<User?> getUserFromID(String id) async {
    User? user;
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final size = snapshot.size;
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

  // for stream data
  Stream<List<User>> getFriends(User currentUser) async* {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    StreamController<List<User>> streamController =
        StreamController<List<User>>();
    StreamSubscription subscription = docRef.snapshots().listen((event) async {
      if (event.exists) {
        final data = event.data() as Map<String, dynamic>;
        final listData = data['listFriend'] as List<dynamic>;
        if (listData != null) {
          List<FriendData> listFriend =
              listData.map((e) => FriendData.fromJson(e)).toList();
          List<User> listUser = [];
          for (var element in listFriend) {
            User? user = await getUserFromID(element.idFriend!);
            listUser.add(user!);
          }
          streamController.sink.add(listUser);
        } else {
          streamController.close();
        }
      } else {
        streamController.close();
      }
    });
    // when we don't need to listen, we close controller and subscription
    streamController.onCancel = () {
      subscription.cancel();
      streamController.close();
    };
    yield* streamController.stream;
  }

  Stream<List<User>> getSentList(User currentUser) async* {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    StreamController<List<User>> controller = StreamController<List<User>>();
    StreamSubscription subscription = ref.snapshots().listen((event) async {
      if (event.exists) {
        final data = event.data() as Map<String, dynamic>;
        final listData = data['requestedList'] as List<dynamic>;
        if (listData != null) {
          List<FriendData> listFriend =
              listData.map((e) => FriendData.fromJson(e)).toList();
          List<User> listUser = [];
          for (var element in listFriend) {
            User? user = await getUserFromID(element.idFriend!);
            listUser.add(user!);
          }
          controller.sink.add(listUser);
        } else {
          controller.close();
        }
      } else {
        controller.close();
      }
    });
    // when we don't need to listen, we close controller and subscription
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    yield* controller.stream;
  }

  Stream<List<User>> getQueueList(User currentUser) async* {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    StreamController<List<User>> controller = StreamController<List<User>>();
    StreamSubscription subscription = ref.snapshots().listen((event) async {
      if (event.exists) {
        final data = event.data() as Map<String, dynamic>;
        final dataList = data['queueList'] as List<dynamic>;
        if (dataList != null) {
          List<FriendData> list =
              dataList.map((e) => FriendData.fromJson(e)).toList();
          List<User> listUser = [];
          for (var element in list) {
            User? user = await getUserFromID(element.idFriend!);
            listUser.add(user!);
          }
          controller.sink.add(listUser);
        } else {
          controller.close();
        }
      } else {
        controller.close();
      }
    });
    // close controller and subscription
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    yield* controller.stream;
  }

  Stream<List<FriendData>> getAllFriendDataOfCurrentUser(
      User currentUser) async* {
    List<FriendData> list = [];
    DocumentReference ref =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    StreamController<List<FriendData>> controller =
        StreamController<List<FriendData>>();
    StreamSubscription subscription = ref.snapshots().listen((event) async {
      if (event.exists) {
        final data = event.data() as Map<String, dynamic>;
        final dataList = data['listFriend'] as List<dynamic>;
        if (dataList != null) {
          List<FriendData> listFriendData =
              dataList.map((e) => FriendData.fromJson(e)).toList();
          list = listFriendData;
          controller.sink.add(list);
        } else {
          controller.close();
        }
      } else {
        controller.close();
      }
    });
    // close controller and subscription
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    yield* controller.stream;
  }

  Stream<List<FriendData>> getQueueFriendDataOfCurrentUser(
      User currentUser) async* {
    List<FriendData> list = [];
    DocumentReference ref =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    StreamController<List<FriendData>> controller =
        StreamController<List<FriendData>>();
    StreamSubscription subscription = ref.snapshots().listen((event) async {
      if (event.exists) {
        final data = event.data() as Map<String, dynamic>;
        final dataList = data['queueList'] as List<dynamic>;
        if (dataList != null) {
          List<FriendData> listFriendData =
              dataList.map((e) => FriendData.fromJson(e)).toList();
          list = listFriendData;
          controller.sink.add(list);
        } else {
          controller.close();
        }
      } else {
        controller.close();
      }
    });
    // close controller and subscription
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    yield* controller.stream;
  }

  Stream<List<FriendData>> getSentFriendDataOfCurrentUser(
      User currentUser) async* {
    List<FriendData> list = [];
    DocumentReference ref =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    StreamController<List<FriendData>> controller =
        StreamController<List<FriendData>>();
    StreamSubscription subscription = ref.snapshots().listen((event) async {
      if (event.exists) {
        final data = event.data() as Map<String, dynamic>;
        final dataList = data['requestedList'] as List<dynamic>;
        if (dataList != null) {
          List<FriendData> listFriendData =
              dataList.map((e) => FriendData.fromJson(e)).toList();
          list = listFriendData;
          controller.sink.add(list);
        } else {
          controller.close();
        }
      } else {
        controller.close();
      }
    });
    // close controller and subscription
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    yield* controller.stream;
  }

  Stream<Friends?> getFriend(User currentUser) async* {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    StreamController<Friends?> controller = StreamController<Friends>();
    bool isListening = true;
    StreamSubscription? subscription;
    void cancelSubscription() {
      if (isListening) {
        subscription?.cancel();
        controller.close();
        isListening = false;
      }
    }

    subscription = ref.snapshots().listen((event) {
      if (event.exists) {
        final data = event.data() as Map<String, dynamic>;
        final requestedListData = data['requestedList'] as List<dynamic>;

        List<FriendData> requestedList = requestedListData == null
            ? []
            : requestedListData.map((e) => FriendData.fromJson(e)).toList();
        final listFriendData = data['listFriend'] as List<dynamic>;
        List<FriendData> listFriend = listFriendData == null
            ? []
            : listFriendData.map((e) => FriendData.fromJson(e)).toList();
        final queueListData = data['queueList'] as List<dynamic>;
        List<FriendData> queueList = queueListData == null
            ? []
            : queueListData.map((e) => FriendData.fromJson(e)).toList();
        String uid = event.id;
        Friends friend = Friends(
            listFriend: listFriend,
            queueList: queueList,
            requestedList: requestedList,
            userID: uid);
        controller.sink.add(friend);
      } else {
        cancelSubscription();
      }
    });
    //close controller and subscription
    controller.onCancel = () {
      cancelSubscription();
    };
    yield* controller.stream;
  }

  // get a set of friends of current user
  Future<RxList<User>> listFriendsOfCurrentUser(User currentUser) async {
    RxList<User> list = <User>[].obs;
    final snapshot = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUser.id)
        .get();
    var data = snapshot.data() as Map<String, dynamic>;
    final friendsData = data['listFriend'] as List<dynamic>;
    if (friendsData != null) {
      final friends =
          friendsData.map((friend) => FriendData.fromJson(friend)).toList();
      for (var element in friends) {
        User? user = await getUserFromID(element.idFriend!);
        list.add(user!);
      }
    }

    return list;
  }

  Future<RxList<User>> listQueueFriendsOfCurrentUser(User currentUser) async {
    RxList<User> list = <User>[].obs;
    final snapshot = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUser.id)
        .get();
    var data = snapshot.data() as Map<String, dynamic>;

    final friendData = data['queueList'] as List<dynamic>;
    if (friendData != null) {
      final queueList = friendData.map((e) => FriendData.fromJson(e)).toList();
      for (var element in queueList) {
        User? user = await getUserFromID(element.idFriend!);
        list.value.add(user!);
      }
    }

    return list;
  }

  Future<RxList<User>> listRequestedFriendsOfCurrentUser(
      User currentUser) async {
    RxList<User> list = <User>[].obs;
    final snapshot = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUser.id)
        .get();
    var data = snapshot.data() as Map<String, dynamic>;

    final friendData = data['requestedList'] as List<dynamic>;
    if (friendData != null) {
      final friends = friendData.map((e) => FriendData.fromJson(e)).toList();
      for (var element in friends) {
        User? user = await getUserFromID(element.idFriend!);
        list.value.add(user!);
      }
    }

    return list;
  }

  // // for friendData
  // Future<List<FriendData>> getALlFriendOfCurrentUser(User currentUser) async {
  //   List<FriendData> list = [];
  //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('friends')
  //       .doc(currentUser.id)
  //       .get();
  //   var data = snapshot.data() as Map<String, dynamic>;
  //   final friendsData = data['listFriend'] as List<dynamic>;

  //   final friends =
  //       friendsData.map((friend) => FriendData.fromJson(friend)).toList();
  //   list = friends;
  //   // for (var element in friends) {

  //   //   list.add(user!);
  //   // }
  //   return list;
  // }

  // Future<List<FriendData>> getRequestedFriendsOfCurrentUser(
  //     User currentUser) async {
  //   List<FriendData> list = [];
  //   CollectionReference collectionReference =
  //       FirebaseFirestore.instance.collection('friends');
  //   if (collectionReference == null) {
  //     DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('friends')
  //         .doc(currentUser.id)
  //         .get();
  //     var data = snapshot.data() as Map<String, dynamic>;
  //     final friendData = data['requestedList'] as List<dynamic>;
  //     final friends = friendData.map((e) => FriendData.fromJson(e)).toList();
  //     list = friends;
  //     // for (var element in friends) {

  //     //   list.add(user!);
  //     // }
  //     // return list;
  //   }
  //   return list;
  // }

  // Future<List<FriendData>> getQueueFriendsOfCurrentUser(
  //     User currentUser) async {
  //   List<FriendData> list = [];
  //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('friends')
  //       .doc(currentUser.id)
  //       .get();
  //   var data = snapshot.data() as Map<String, dynamic>;
  //   final friendData = data['queueList'] as List<dynamic>;
  //   final queueList = friendData.map((e) => FriendData.fromJson(e)).toList();
  //   list = queueList;
  //   // for (var element in friends) {

  //   //   list.add(user!);
  //   // }
  //   return list;
  // }
  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    User? currentUser = authController.currentUser.value;
    if (currentUser != null) {
      listFriends.value = await listFriendsOfCurrentUser(currentUser);
      listRequestedFriends.value =
          await listRequestedFriendsOfCurrentUser(currentUser);
      listQueueFriends.value = await listQueueFriendsOfCurrentUser(currentUser);
      // // for friendData
      // listAllFriend = await getALlFriendOfCurrentUser(currentUser);
      // listRequestedFriend = await getRequestedFriendsOfCurrentUser(currentUser);
      // listQueueFriend = await getQueueFriendsOfCurrentUser(currentUser);

      // stream variable
      streamListFriend = getFriends(currentUser);
      streamQueueList = getQueueList(currentUser);
      streamRequestedList = getSentList(currentUser);
      //
      streamListFriendData = getAllFriendDataOfCurrentUser(currentUser);
      streamQueueFriendData = getQueueFriendDataOfCurrentUser(currentUser);
      streamRequestedFriendData = getSentFriendDataOfCurrentUser(currentUser);
      friends = getFriend(currentUser);
      listFriends.refresh();
      update();
    }
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();
    // User? currentUser = authController.currentUser.value;
    // listFriends.value = await listFriendsOfCurrentUser(currentUser!);
  }

  void showData() {
    print("Length: ${listFriends.value.length}");
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future addFriend(User? currentUser, User? targetUser) async {
    DocumentReference currentUserRef =
        FirebaseFirestore.instance.collection('friends').doc(currentUser!.id);

    DocumentReference targetUserRef =
        FirebaseFirestore.instance.collection('friends').doc(targetUser!.id);
    DocumentSnapshot targetUserSnapshot = await targetUserRef.get();

    // create a new friend data
    FriendData currentFriendData = createFriendData(targetUser.id!);
    FriendData targetFriendData = createFriendData(currentUser.id!);
    DocumentSnapshot currentSnapshot = await currentUserRef.get();
    if (currentSnapshot.exists && targetUserSnapshot.exists) {
      // for  current User
      final currentListFriendData =
          currentSnapshot.data() as Map<String, dynamic>;
      final currentListFriend =
          currentListFriendData['requestedList'] as List<dynamic>;
      List<FriendData> currentFriends =
          currentListFriend.map((e) => FriendData.fromJson(e)).toList();
      currentFriends.add(currentFriendData);

      final dataForCurrentUser = {
        'requestedList': currentFriends.map((e) => e.toJson()).toList()
      };
      await currentUserRef.update(dataForCurrentUser);

      // for target user
      final targetQueueData = targetUserSnapshot.data() as Map<String, dynamic>;
      final targetQueue = targetQueueData['queueList'] as List<dynamic>;
      if (targetQueue != null) {
        List<FriendData> targetQueueList =
            targetQueue.map((e) => FriendData.fromJson(e)).toList();
        targetQueueList.add(targetFriendData);
        final datatFortargetUser = {
          'queueList': targetQueueList.map((e) => e.toJson()).toList()
        };
        await targetUserRef.update(datatFortargetUser);
      }
    }

    // listRequestedFriend.refresh();

    // listRequestedFriends.refresh();

    // for target User
    // final targetData = targetUserSnapshot.data() as Map<String, dynamic>;
    // final listQueueData = targetData['queueList'] as List<dynamic>;
    // List<FriendData> listQueue =
    //     listQueueData.map((e) => FriendData.fromJson(e)).toList();
    // listQueue.add(newFriendData);
    // final dataFortargetUser = {
    //   'queueList': listQueue.map((e) => e.toJson()).toList()
    // };
    // await targetUserRef.update(dataFortargetUser);
  }

  Future acceptRequest(User currentUser, User targetUser) async {
    // queue list in currentUser will remove targetUser in this list
    // sent list in targetUser also will removew currentUser in that list
    // friend list of both target and current will insert each other in friend list
    DocumentReference currentRef =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    DocumentReference targetRef =
        FirebaseFirestore.instance.collection('friends').doc(targetUser.id);
    DocumentSnapshot currentSnapshot = await currentRef.get();
    DocumentSnapshot targetSnapshot = await targetRef.get();
    final currentFriendData = createFriendData(targetUser.id!);
    final targetFriendData = createFriendData(currentUser.id!);
    if (currentSnapshot.exists && targetSnapshot.exists) {
      // for current user
      final currentData = currentSnapshot.data() as Map<String, dynamic>;
      final currentListFriendData = currentData['listFriend'] as List<dynamic>;
      final currentListQueueData = currentData['queueList'] as List<dynamic>;
      List<FriendData> currentFriend =
          currentListFriendData.map((e) => FriendData.fromJson(e)).toList();
      List<FriendData> currentFriendListQueue =
          currentListQueueData.map((e) => FriendData.fromJson(e)).toList();

      // add to list friend
      currentFriend.add(currentFriendData);
      // remove this user from list queue
      currentFriendListQueue
          .removeWhere((element) => element.idFriend == targetUser.id);
      // update to RxList<user> friends

      // update to firebase
      final dataForCurrentUser = {
        'listFriend': currentFriend.map((e) => e.toJson()).toList(),
        'queueList': currentFriendListQueue.map((e) => e.toJson()).toList(),
      };
      await currentRef.update(dataForCurrentUser);
      listFriends.value = await listFriendsOfCurrentUser(currentUser);

      // for target user
      final targetData = targetSnapshot.data() as Map<String, dynamic>;
      final targetListFriendData = targetData['listFriend'] as List<dynamic>;
      final targetListSentData = targetData['requestedList'] as List<dynamic>;
      List<FriendData> targetFriend =
          targetListFriendData.map((e) => FriendData.fromJson(e)).toList();
      List<FriendData> targetFriendListSent =
          targetListSentData.map((e) => FriendData.fromJson(e)).toList();

      // add to list friend
      targetFriend.add(targetFriendData);
      // remove this user from list sent
      targetFriendListSent
          .removeWhere((element) => element.idFriend == currentUser.id);
      // update to firebase
      final dataForTargetUser = {
        'listFriend': targetFriend.map((e) => e.toJson()).toList(),
        'requestedList': targetFriendListSent.map((e) => e.toJson()).toList(),
      };
      await targetRef.update(dataForTargetUser);
    }
  }

  Future removeRequest(User currentUser, User targetUser) async {
    // queue list in currentUser will remove targetUser from that list
    // sent list in targetUser will be removed currentUser from that list
    DocumentReference currentRef =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    DocumentReference targetRef =
        FirebaseFirestore.instance.collection('friends').doc(targetUser.id);
    DocumentSnapshot currentSnapshot = await currentRef.get();
    DocumentSnapshot targetSnapshot = await targetRef.get();
    if (currentSnapshot.exists && targetSnapshot.exists) {
      // for current user
      final currentData = currentSnapshot.data() as Map<String, dynamic>;
      final currentListQueueData = currentData['queueList'] as List<dynamic>;
      List<FriendData> currentFriendListQueue =
          currentListQueueData.map((e) => FriendData.fromJson(e)).toList();
      currentFriendListQueue
          .removeWhere((element) => element.idFriend == targetUser.id);
      // update to firebase
      final dataForCurrentUser = {
        'queueList': currentFriendListQueue.map((e) => e.toJson()).toList(),
      };
      await currentRef.update(dataForCurrentUser);

      // for target user
      final targetData = targetSnapshot.data() as Map<String, dynamic>;
      final targetListSentData = targetData['requestedList'] as List<dynamic>;
      List<FriendData> targetFriendListSent =
          targetListSentData.map((e) => FriendData.fromJson(e)).toList();
      targetFriendListSent
          .removeWhere((element) => element.idFriend == currentUser.id);
      // update to firebase
      final dataForTargetUser = {
        'requestedList': targetFriendListSent.map((e) => e.toJson()).toList(),
      };
      await targetRef.update(dataForTargetUser);
    }
  }

  Future cancelRequest(User currentUser, User targetUser) async {
    // sent list in currentUser will remove targetUser from that list
    // queue list in targetUser will be removed currentUser from that list
    DocumentReference currentRef =
        FirebaseFirestore.instance.collection('friends').doc(currentUser.id);
    DocumentReference targetRef =
        FirebaseFirestore.instance.collection('friends').doc(targetUser.id);
    DocumentSnapshot currentSnapshot = await currentRef.get();
    DocumentSnapshot targetSnapshot = await targetRef.get();
    if (currentSnapshot.exists && targetSnapshot.exists) {
      // for current user
      final currentData = currentSnapshot.data() as Map<String, dynamic>;
      final currentListSentData = currentData['requestedList'] as List<dynamic>;
      List<FriendData> currentFriendListSent =
          currentListSentData.map((e) => FriendData.fromJson(e)).toList();
      currentFriendListSent
          .removeWhere((element) => element.idFriend == targetUser.id);
      // update to firebase
      final dataForCurrentUser = {
        'requestedList': currentFriendListSent.map((e) => e.toJson()).toList(),
      };
      await currentRef.update(dataForCurrentUser);

      // for target user
      final targetData = targetSnapshot.data() as Map<String, dynamic>;
      final targetListQueueData = targetData['queueList'] as List<dynamic>;
      List<FriendData> targetFriendListQueue =
          targetListQueueData.map((e) => FriendData.fromJson(e)).toList();
      targetFriendListQueue
          .removeWhere((element) => element.idFriend == currentUser.id);
      // update to firebase
      final dataForTargetUser = {
        'queueList': targetFriendListQueue.map((e) => e.toJson()).toList(),
      };
      await targetRef.update(dataForTargetUser);
    }
  }

  FriendData createFriendData(String uid) {
    return FriendData(idFriend: uid, createdAt: Timestamp.now());
  }

  Future<List<User>> getUserFromListFriendData(
      List<FriendData> listFriendData) async {
    List<User>? list = [];
    for (var element in listFriendData) {
      User? user = await getUserFromID(element.idFriend!);
      list.add(user!);
    }
    return list;
  }
}
