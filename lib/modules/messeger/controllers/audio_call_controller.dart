import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_app/utils/settings/settings.dart';
import 'package:wakelock/wakelock.dart';

class AudioVideoController extends GetxController {
  RxInt myremoteUid = 0.obs;
  RxBool localUserJoined = false.obs;
  RxBool muted = false.obs;
  RxBool videoPaused = false.obs;
  RxBool switchMainView = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool isFront = false.obs;
  late RtcEngine rtcEngine;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initilize();
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
    videoPaused.value = false;
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
        VideoEncoderConfiguration configuration =
            const VideoEncoderConfiguration();
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
          localUserJoined.value = true;
          myremoteUid.value = remoteUid;
          update();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          if (reason == UserOfflineReasonType.userOfflineDropped) {
            Wakelock.disable();
            myremoteUid.value = 0;
            onCallEnd();
            update();
            print("Remote user $remoteUid left channel");
          } else {
            myremoteUid.value = 0;
            onCallEnd();
            update();
            print("Remote user $remoteUid left channel");
          }
        },
      ),
    );
  }

  void onCallEnd() {
    clear();
    update();
    Get.offAll(() => ChattingPage());
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
}
