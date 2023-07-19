import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_app/modules/messeger/controllers/audio_call_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';
import 'package:chat_app/utils/settings/settings.dart';

class VideoCall extends StatefulWidget {
  const VideoCall({super.key});

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Wakelock.enable(); // Turn on wakelock feature till call is running
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Wakelock.disable(); // Turn off wakelock feature after call end
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callController = Get.put(AudioVideoController());
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => Padding(
          padding: EdgeInsets.all(10),
          child: Stack(
            children: [
              Center(
                child: callController.localUserJoined == true
                    ? callController.videoPaused == true
                        ? Container(
                            color: Theme.of(context).primaryColor,
                            child: Center(
                                child: Text(
                              "Remote Video Paused",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.white70),
                            )))
                        : AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: callController.rtcEngine,
                              canvas: VideoCanvas(
                                  uid: callController.myremoteUid.value),
                              connection:
                                  const RtcConnection(channelId: channelId),
                            ),
                          )
                    : const Center(
                        child: Text(
                          'No Remote',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: Center(
                      child: callController.localUserJoined.value
                          ? AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: callController.rtcEngine,
                                canvas: const VideoCanvas(uid: 0),
                              ),
                            )
                          : CircularProgressIndicator()),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            callController.onToggleMute();
                          },
                          child: Icon(
                            callController.muted.value
                                ? Icons.mic
                                : Icons.mic_off,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            callController.onCallEnd();
                          },
                          child: const Icon(
                            Icons.call,
                            size: 35,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            callController.onVideoOff();
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Icon(
                                  Icons.photo_camera_front,
                                  size: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            callController.onSwitchCamera();
                          },
                          child: const Icon(
                            Icons.switch_camera,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
