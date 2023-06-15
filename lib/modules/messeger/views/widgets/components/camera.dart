import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Camera extends StatefulWidget {
  Camera({super.key, required this.cameras});
  final List<CameraDescription>? cameras;
  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  File? file;
  ImagePicker picker = ImagePicker();
  Future getImage() async {
    try {
      final imagePicker = await picker.pickImage(source: ImageSource.camera);
      if (imagePicker != null) {
        final imageTemporary = File(imagePicker.path);
        setState(() {
          file = imageTemporary;
        });
      }
    } catch (e) {
      print("Fialed to connect to camera: $e");
    }
  }

  late CameraController controller;
  XFile? pictureFile;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = CameraController(widget.cameras![0], ResolutionPreset.max);
    controller.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     await getImage();
      //   },
      //   child: Text("Camera"),
      // ),
      body: !controller.value.isInitialized
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      height: 300,
                      width: 400,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      pictureFile = await controller.takePicture();
                      setState(() {});
                    },
                    child: const Text('Capture Image'),
                  ),
                ),
                if (pictureFile != null)
                  Image.network(
                    pictureFile!.path,
                    height: 200,
                  )
                //Android/iOS
                // Image.file(File(pictureFile!.path)))
              ],
            ),
    );
  }
}
