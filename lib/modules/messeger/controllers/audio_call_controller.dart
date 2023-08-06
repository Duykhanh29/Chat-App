import 'dart:async';

import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/call_data.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_app/utils/settings/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_app/routes/app_routes.dart';

class AudioCallController extends GetxController {
  final callDB = FirebaseFirestore.instance;
  RxList<int> remoteUsers = <int>[].obs;
  RxList<String> userIDs = <String>[].obs;
  Rx<int> myRemoteUid = 0.obs;
  RxString senderID = "".obs;
  RxBool isMuted = false.obs;
  RxBool isJoinedSucceed = false.obs;
  RxBool localUserJoined = false.obs;
  RxBool isEnded = false.obs;
  late RtcEngine engine;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    clear();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  void setSenderID(String id) {
    senderID.value = id;
  }

  void resetSenderID() {
    senderID.value = "id";
  }

  Future initialize() async {
    Future.delayed(
      Duration.zero,
      () async {
        await [Permission.microphone].request();
        await initializeRtcEngine();
        addAgoraEventHandlers();
        await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await engine.joinChannel(
            token: token,
            channelId: channelId,
            uid: 0,
            options: const ChannelMediaOptions());
        update();
      },
    );
  }

  void clear() {
    engine.leaveChannel();
    isMuted.value = false;

    update();
  }

  Future initializeRtcEngine() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
        appId: appID,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
    await engine.enableAudio();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
  }

  void addAgoraEventHandlers() {
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          isJoinedSucceed.value = true;
          print("onJoinChannelSuccess");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          localUserJoined.value = true;
          print("User: $senderID");
          remoteUsers.value.add(remoteUid);
          update();
        },
        onLeaveChannel: (connection, stats) {
          // if (remoteUsers.value.length == 1) {
          //   remoteUsers.value.clear();
          //   isCalled.value = false;
          //   onCallEnd(); // End the call
          // }
          isJoinedSucceed.value = false;
          update();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          remoteUsers.value.remove(remoteUid);
          print("User: $senderID");

          if (remoteUsers.value.isEmpty) {
            remoteUsers.value.clear();
            isEnded.value = true;
            localUserJoined.value = false;
            onCallEnd();
          }
          update();

          //
        },
      ),
    );
  }

  void onCallEnd() {
    clear();
    update();
    Get.back();
  }

  void onToggleMute() {
    isMuted.value = !isMuted.value;
    engine.muteLocalAudioStream(isMuted.value);
    update();
  }

  // database
  Future addCreatorInfor(String msgID, String senderID) async {
    CallData callData = CallData(
        currentAudience: [senderID],
        listAudience: [senderID],
        creatorId: senderID,
        createdAt: Timestamp.now(),
        idChannel: msgID);
    final ref = await callDB
        .collection('audioCalls')
        .doc(callData.callID)
        .set(callData.toJson())
        .whenComplete(() {
      print("Add success");
    });
  }

  Future<String?> getCreatorID(String msgID) async {
    final querySnapshot = callDB.collection('audioCalls');
    final where = querySnapshot.where('idChannel', isEqualTo: msgID);
    final order = where.orderBy('createdAt', descending: true);
    final limit = order.limit(1);
    final snapshot = await limit.get();
    // .orderBy()
    // .l
    // .get();
    if (snapshot.docs.isNotEmpty) {
      final callData = snapshot.docs.first;
      return callData['creatorId'] as String;
      // final creator = callData['creator'] as CallDetails;
      // return creator.creatorId;
    }
  }

  Future<String?> getCallID(String msgID) async {
    final querySnapshot = await callDB
        .collection('audioCalls')
        .where('idChannel', isEqualTo: msgID)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final callData = querySnapshot.docs.first;
      return callData['callID'] as String;
    }
  }

  Future<List<String>?> getListAudence(String callID) async {
    final snapshot = await callDB.collection('audioCalls').doc(callID).get();
    if (snapshot.exists) {
      final callData = snapshot.data() as Map<String, dynamic>;
      final list = callData['listAudience'] as List<dynamic>;
      List<String>? listAudience = list.map((e) => e.toString()).toList();
      return listAudience;
    }
  }

  Future<List<String>?> getListCurrentAudence(String callID) async {
    final snapshot = await callDB.collection('audioCalls').doc(callID).get();
    if (snapshot.exists) {
      final callData = snapshot.data() as Map<String, dynamic>;
      final list = callData['currentAudience'] as List<dynamic>;
      List<String>? listAudience = list.map((e) => e.toString()).toList();
      return listAudience;
    }
  }

  Future joinChannel(String callID, String anAudience) async {
    DocumentReference docRef = callDB.collection('audioCalls').doc(callID);
    DocumentSnapshot snapshot = await docRef.get();
    if (snapshot.exists) {
      final callData = snapshot.data() as Map<String, dynamic>;
      final currentAudienceData = callData['currentAudience'] as List<dynamic>;
      final listAudienceData = callData['listAudience'] as List<dynamic>;
      List<String>? currentAudience =
          currentAudienceData.map((e) => e.toString()).toList();
      List<String>? listAudience =
          listAudienceData.map((e) => e.toString()).toList();

      if (!CommonMethods.isIDFromListID(anAudience, listAudience)) {
        listAudience.add(anAudience);
        currentAudience.add(anAudience);
        final data = {
          'listAudience': listAudience.map((e) => e.toString()).toList(),
          'currentAudience': currentAudience.map((e) => e.toString()).toList()
        };
        await docRef.update(data);
      } else {
        currentAudience.add(anAudience);
        final data = {
          'currentAudience': currentAudience.map((e) => e).toList()
        };
        await docRef.update(data);
      }
    }
  }

  Future leaveChannel(String callID, String anAudience) async {
    DocumentReference docRef = callDB.collection('audioCalls').doc(callID);
    DocumentSnapshot snapshot = await docRef.get();
    if (snapshot.exists) {
      final callData = snapshot.data() as Map<String, dynamic>;
      final list = callData['currentAudience'] as List<dynamic>;
      List<String>? currentAudience = list.map((e) => e.toString()).toList();
      currentAudience.remove(anAudience);
      final data = {'currentAudience': currentAudience.map((e) => e).toList()};
      await docRef.update(data);
    }
  }

  Stream<int> getNumberOfCurrentAudience(String callID) async* {
    final ref = callDB.collection('audioCalls').doc(callID);
    StreamController<int> controller = StreamController<int>();
    StreamSubscription subscription = ref.snapshots().listen((event) async {
      if (event.exists) {
        final callData = event.data() as Map<String, dynamic>;
        final list = callData['currentAudience'] as List<dynamic>;
        List<String>? currentAudience = list.map((e) => e.toString()).toList();
        controller.sink.add(currentAudience.length);
      } else {
        controller.close();
      }
    });
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };
    yield* controller.stream;
  }

  // // update audience
  // Future updateAudience(String msgID, String anAudience) async {
  //   try {
  //     final ref = callDB.collection('audioCalls').doc(msgID);
  //     final snapshot = await ref.get();
  //     if (snapshot.exists) {
  //       final callData = snapshot.data() as Map<String, dynamic>;
  //       final listAUdience = callData['listAudience'] as List<String>;
  //       if (listAUdience.isNotEmpty) {
  //         listAUdience.add(anAudience);
  //       } else {
  //         listAUdience.add(anAudience);
  //       }
  //       final data = {
  //         'listAudience': listAUdience.map((e) => e.toString()).toList(),
  //       };
  //       ref.update(data);
  //     }
  //   } catch (e) {
  //     print("object");
  //   }
  // }

  // // leave channel
  // Future leaveChannelUpdate(
  //     String msgID, String leaver, String senderID) async {
  //   try {
  //     final ref = callDB.collection('audioCalls').doc(msgID);
  //     final snapshot = await ref.get();
  //     if (snapshot.exists) {
  //       final callData = snapshot.data() as Map<String, dynamic>;
  //       final listAudience = callData['listAudience'] as List<String>;
  //       listAudience.remove(leaver);
  //       final data = {
  //         'listAudience': listAudience.map((e) => e.toString()).toList()
  //       };
  //       ref.update(data);
  //     }
  //   } catch (e) {
  //     print("object");
  //   }
  // }

  // Future<String?> getCreatorID(String msgID) async {
  //   try {
  //     final snapshot = await callDB.collection('audioCalls').doc(msgID).collection(collectionPath);
  //     if (snapshot.exists) {
  //       final callData = snapshot.data() as Map<String, dynamic>;
  //       return (callData['creatorId'] as String);
  //     }
  //   } catch (e) {
  //     print("object");
  //   }
  // }

  // Future<int?> getTotalNumberOfMembers(String msgID) async {
  //   try {
  //     final snapshot = await callDB.collection('audioCalls').doc(msgID).get();
  //     if (snapshot.exists) {
  //       final callData = snapshot.data() as Map<String, dynamic>;
  //       final listAudience = callData['listAudience'] as List<String>;
  //       return listAudience.length;
  //     }
  //   } catch (e) {
  //     print("object");
  //   }
  // }
}
