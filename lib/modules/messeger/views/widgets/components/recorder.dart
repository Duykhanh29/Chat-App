import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class Recorder extends StatefulWidget {
  Recorder({super.key, required this.messageController});
  MessageController messageController;

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  final recorder = FlutterSoundRecorder();
  bool isInitialized = false;
  final StreamController<RecordingDisposition> recorderController =
      StreamController<RecordingDisposition>();
  bool _isRecording = false;
  Future record() async {
    await recorder.startRecorder(toFile: 'audio2');
  }

  Future stop() async {
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    print("Audio recorder: $audioFile");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialRecorder();
  }

  Future initialRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    isInitialized = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    recorder.closeRecorder();
    recorderController.close();
    isInitialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity * 0.6,
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.amber),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onLongPressStart: (LongPressStartDetails details) async {
                await record();
                setState(() {});
              },
              onLongPressMoveUpdate:
                  (LongPressMoveUpdateDetails details) async {
                await stop();
                setState(() {});
              },
              onLongPressEnd: (LongPressEndDetails details) async {
                await stop();
                setState(() {});
              },
              child: InkWell(
                splashColor: Colors.blue,
                highlightColor: Colors.red,
                child: Icon(
                  recorder.isRecording ? Icons.stop : Icons.mic,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            StreamBuilder<RecordingDisposition>(
              builder: (context, snapshot) {
                final duration =
                    snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                String twoDigits(int n) => n.toString().padLeft(2, '0');

                final twoDigitMinutes =
                    twoDigits(duration.inMinutes.remainder(60));
                final twoDigitSeconds =
                    twoDigits(duration.inSeconds.remainder(60));

                return Text(
                  '$twoDigitMinutes:$twoDigitSeconds',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                );
              },
              stream: recorder.onProgress,
            ),
            IconButton(
              onPressed: () {
                widget.messageController.changeRecorder();
              },
              icon: const Icon(Icons.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
