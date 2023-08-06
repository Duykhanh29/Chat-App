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
// import 'package:wakelock/wakelock.dart';

class CallController extends GetxController {
  final callDB = FirebaseFirestore.instance;

  RxList<int> remoteUsers = <int>[].obs;
  // Rx<int> myremoteUid = 0.obs;
  // RxBool isGroupCall = false.obs;
  RxBool localUserJoined = false.obs;
  RxBool muted = false.obs;
  RxBool switchMainView = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool isFront = false.obs;
  RxBool isAudioCall = true.obs;
  RxBool isLoading = true.obs;
  RxString senderID = "".obs;
  late RtcEngine rtcEngine;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initilize();
  }

  void setSenderID(String id) {
    senderID.value = id;
  }

  void resetSenderID() {
    senderID.value = "id";
  }

  // void changeIsGroup() {
  //   isGroupCall.value = true;
  // }

  // void resetIsGroup() {
  //   isGroupCall.value = false;
  // }

  void changeIsAudioCall(bool value) {
    isAudioCall.value = value;
  }

  void resetIsAudioCall() {
    isAudioCall.value = false;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    clear();
  }

  clear() {
    rtcEngine.leaveChannel();
    isFront.value = false;
    reConnectingRemoteView.value = false;
    muted.value = false;
    mutedVideo.value = false;
    switchMainView.value = false;
    localUserJoined.value = false;
    update();
  }

  Future<void> initilize() async {
    Future.delayed(
      Duration.zero,
      () async {
        await _initAgoraRtcEngine();
        _addAgoraEventHandlers();
        await rtcEngine.setClientRole(
            role: ClientRoleType.clientRoleBroadcaster);
        VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
        await rtcEngine.setVideoEncoderConfiguration(configuration);
        await rtcEngine.leaveChannel();
        await rtcEngine.joinChannel(
          token: token,
          channelId: channelId,
          uid: 0,
          options: const ChannelMediaOptions(),
        );
        update();
      },
    );
  }

  Future _initAgoraRtcEngine() async {
    rtcEngine = createAgoraRtcEngine();
    await rtcEngine.initialize(const RtcEngineContext(
        appId: appID,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
    await rtcEngine.enableVideo();
    await rtcEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
  }

  void _addAgoraEventHandlers() {
    rtcEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          localUserJoined.value = true;
          update();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          // localUserJoined.value = true;
          remoteUsers.value.add(remoteUid);
          isLoading.value = false;
          update();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          // if (reason == UserOfflineReasonType.userOfflineDropped) {
          //   if (localUserJoined.value) {
          //     remoteUsers.value.removeWhere(
          //       (element) => element == remoteUid,
          //     );
          //     if (remoteUsers.value.length == 1) {
          //       localUserJoined.value = false;
          //       remoteUsers.value.clear();
          //       update();
          //       onCallEnd();
          //     }

          //     // update();
          //   } else {
          //   remoteUsers.value.removeWhere(
          //     (element) => element == remoteUid,
          //   );
          //   // onCallEnd();
          //   update();
          //   // }
          // } else
          // if (reason == UserOfflineReasonType.userOfflineQuit) {
          // if (localUserJoined.value) {
          //   remoteUsers.value.removeWhere(
          //     (element) => element == remoteUid,
          //   );
          //   if (remoteUsers.value.length == 0) {
          // localUserJoined.value = false;
          // remoteUsers.value = [];
          // // update();
          // onCallEnd();
          // update();
          remoteUsers.remove(remoteUid);
          if (remoteUsers.isEmpty) {
            remoteUsers.clear();
            onCallEnd();
          }
          update();
          // }
          // update();
          //   } else {
          //     remoteUsers.value.removeWhere(
          //       (element) => element == remoteUid,
          //     );
          //     // onCallEnd();
          //     update();
          //     // }
          //   }
          //   //  else {
          //   //   update();
          // }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print("I am leaving");
        },
      ),
    );
  }

  void onCallEnd() {
    clear();
    update();
    // if (remoteUsers.value.length < 2) {
    Get.back();
    // }
  }

  void onVideoOff() {
    mutedVideo.value = !mutedVideo.value;
    rtcEngine.muteLocalVideoStream(mutedVideo.value);
    update();
  }

  void onToggleMute() {
    muted.value = !muted.value;
    rtcEngine.muteLocalAudioStream(muted.value);
    update();
  }

  void onToggleMuteVideo() {
    mutedVideo.value = !mutedVideo.value;
    rtcEngine.muteLocalVideoStream(mutedVideo.value);
    update();
  }

  void onSwitchCamera() {
    rtcEngine.switchCamera().then((value) => {}).catchError((err) {});
  }

  // database
  Future addCreatorInfor(String msgID, String senderID) async {
    CallData callData = CallData(
        createdAt: Timestamp.now(),
        creatorId: senderID,
        currentAudience: [senderID],
        idChannel: msgID,
        listAudience: [senderID]);
    await callDB.collection('videoCalls').doc(msgID).set(callData.toJson());
  }

  Future<String?> getCreatorID(String msgID) async {
    final querySnapshot = callDB.collection('videoCalls');
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
        .collection('videoCalls')
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
    final snapshot = await callDB.collection('videoCalls').doc(callID).get();
    if (snapshot.exists) {
      final callData = snapshot.data() as Map<String, dynamic>;
      final list = callData['listAudience'] as List<dynamic>;
      List<String>? listAudience = list.map((e) => e.toString()).toList();
      return listAudience;
    }
  }

  Future<List<String>?> getListCurrentAudence(String callID) async {
    final snapshot = await callDB.collection('videoCalls').doc(callID).get();
    if (snapshot.exists) {
      final callData = snapshot.data() as Map<String, dynamic>;
      final list = callData['currentAudience'] as List<dynamic>;
      List<String>? listAudience = list.map((e) => e.toString()).toList();
      return listAudience;
    }
  }

  Future joinChannel(String callID, String anAudience) async {
    DocumentReference docRef = callDB.collection('videoCalls').doc(callID);
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
    DocumentReference docRef = callDB.collection('videoCalls').doc(callID);
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
    final ref = callDB.collection('videoCalls').doc(callID);
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
}
