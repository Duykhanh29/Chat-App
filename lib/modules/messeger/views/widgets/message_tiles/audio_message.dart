import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:flutter/services.dart';

class AudioMessage extends StatefulWidget {
  AudioMessage({super.key, required this.message});
  Message message;

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  String audioAssest = "assets/audios/SonTingMTP.mp3";
  bool isDisposed = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  AudioPlayer audioPlayer = AudioPlayer();
  void doNothing() {}

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          if (state == PlayerState.playing) {
            //  duration = audioPlayer.d;
            isPlaying = true;
          } else if (state == PlayerState.paused) {
            isPlaying = false;
          }
          // else {
          //   isPlaying = false;
          //   position = Duration();
          // }
        });
      }
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
  }

  String formatTime(int seconds) {
    // return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');   // result is to return 00:00:00

    return '${(Duration(seconds: seconds)).toString().split(':').sublist(1).join(':')}' // result is to return 00:00
        .split('.')[0];
  }

  @override
  void dispose() {
    print("dispose() is called");
    audioPlayer.stop();
    // stopAudio();
    audioPlayer.release();
    super.dispose();
  }

  Future<void> stopAudio() async {
    await audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      width: MediaQuery.of(context).size.width * 0.6,
      padding: const EdgeInsets.only(right: 10),
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 192, 253, 168),
        borderRadius: widget.message.isSender!
            ? const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //  FittedBox(
          // child:
          Container(
            width: 30,
            height: double.infinity,
            child: IconButton(
              onPressed: () {
                if (isPlaying) {
                  setState(() {
                    isPlaying = false;
                  });
                  audioPlayer.pause();
                } else {
                  audioPlayer.play(AssetSource("audios/SonTingMTP.mp3"));
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color:
                    widget.message.isSender! ? Colors.amberAccent : Colors.red,
              ),
            ),
          ),
          // ),

          Flexible(
            child: SizedBox(
              width: double.infinity,
              child: Slider(
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);

                  //if audio was paused
                  await audioPlayer.resume();
                },
                min: 0,
                max: duration.inSeconds.toDouble(),
              ),
            ),
          ),

          Text(
            formatTime((duration - position).inSeconds),
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }
}
