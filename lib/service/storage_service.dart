import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class Storage {
  final storage = FirebaseStorage.instance;
  Future<bool> uploadFile(
      String filePath, String fileName, String id, String type) async {
    File file = File(filePath);
    try {
      await storage.ref('$type/$id/$fileName').putFile(file);
      return true;
    } on FirebaseException catch (e) {
      print(e);
      return false;
    }
  }

  Future<Uint8List> _downloadFile(String fileURL) async {
    var response = await http.get(Uri.parse(fileURL));
    return response.bodyBytes;
  }

  Future uploadFromURL(String fileURL, String id) async {
    // Tải tệp tin từ URL
    Uint8List fileData = await _downloadFile(fileURL);
    try {
      Reference ref = storage.ref().child('avatars/$id');
      UploadTask uploadTask = ref.putData(fileData);
      await uploadTask.whenComplete(() => print('File uploaded successfully'));
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<List<Reference>> downloaddAllImages() async {
    final ListResult list = await storage.ref('test/').listAll();
    List<Reference> listItems = list.items;
    // List<String> listURL = [];
    // for (var element in listItems) {
    //   String imageURL = await element.getDownloadURL();
    //   listURL.add(imageURL);
    // }
    return listItems;
  }

  Future<String> downloadURL(String fileName, String id, String type) async {
    print("fileName: $fileName,id: $id, type: $type ");
    Reference ref = storage.ref('$type/$id');
    final result = await ref.listAll();
    int count = result.items.length;
    print("How many: ${count}");
    String downloadURL =
        await storage.ref('$type/$id/$fileName').getDownloadURL();
    return downloadURL;
  }

  Future downloadFileToLocal(String imageName) async {
    Reference ref = storage.ref('test/$imageName');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');
    await ref.writeToFile(file);
  }

  Future getVideo() async {
    final ListResult list = await storage.ref('/videosTest').listAll();
    List<Reference> listItems = list.items;
    return listItems;
  }

  Future downloadFileToLocalDevice(String Url, String fileType) async {
    try {
// Tải xuống và lưu trữ hình ảnh
      final reference = storage.refFromURL(Url);
      final url = await reference.getDownloadURL();
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/${reference.name}';
      await Dio().download(url, path);
      if (fileType == "video") {
        await GallerySaver.saveVideo(path, toDcim: true).whenComplete(
          () => Get.snackbar("Success", "",
              snackPosition: SnackPosition.TOP,
              titleText: const Text("Download successfully"),
              backgroundColor: Colors.greenAccent),
        );
        ;
      } else if (fileType == "image") {
        await GallerySaver.saveImage(path, toDcim: true).whenComplete(
          () => Get.snackbar("Success", "",
              snackPosition: SnackPosition.TOP,
              titleText: const Text("Download successfully"),
              backgroundColor: Colors.greenAccent),
        );
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> downloadAndSaveImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File('${documentDirectory.path}/image.jpg');
    await file.writeAsBytes(response.bodyBytes);
    final galleryPath = await GallerySaver.saveImage(file.path);
    if (galleryPath != null) {
      print('Ảnh đã được lưu: $galleryPath');
    } else {
      print('Lỗi khi download ảnh');
    }
  }

  //pdf
  Future uploadFilePDF(String fileName, String filePath) async {
    try {
      Reference ref = storage.ref().child('files/pdf/${fileName}');
      File file = File(filePath);
      UploadTask uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() => print('File uploaded successfully'));
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  // pdf
  Future loadPDFFromFirebase(String fileName) async {
    try {
      final refPDF = storage.ref().child('files/pdf/${fileName}');
      final bytes = await refPDF.getData();
      return storeFile(fileName, bytes);
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  //pdf
  Future storeFile(String fileName, Uint8List? bytes) async {
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$fileName}');
    await file.writeAsBytes(bytes!, flush: true);
    return file;
  }
}
