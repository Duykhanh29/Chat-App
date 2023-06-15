import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:gallery_saver/gallery_saver.dart';

class Storage {
  final storage = FirebaseStorage.instance;
  Future uploadFile(
      String filePath, String fileName, String idMessageData) async {
    File file = File(filePath);
    try {
      await storage.ref('images/$idMessageData/$fileName').putFile(file);
    } on FirebaseException catch (e) {
      print(e);
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

  Future<String> downloadURL(String imageName, String idMessageData) async {
    String downloadURL =
        await storage.ref('images/$idMessageData/$imageName').getDownloadURL();
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

  Future downloadFileToLocalDevice(
      String imageUrl, String idMessageData, String type) async {
    try {
// Tải xuống và lưu trữ hình ảnh
      final reference = storage.refFromURL(imageUrl);
      final url = await reference.getDownloadURL();
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/${reference.name}';
      await Dio().download(url, path);
      if (type == "video") {
        await GallerySaver.saveVideo(path, toDcim: true);
      } else if (type == "image") {
        await GallerySaver.saveImage(path, toDcim: true);
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future uploadFilePDF(String fileName, String filePath) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('files/pdf/${fileName}');
      File file = File(filePath);
      UploadTask uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() => print('File uploaded successfully'));
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future loadPDFFromFirebase(String fileName) async {
    try {
      final refPDF = storage.ref().child('files/pdf/${fileName}');
      final bytes = await refPDF.getData();
      return storeFile(fileName, bytes);
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future storeFile(String fileName, Uint8List? bytes) async {
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$fileName}');
    await file.writeAsBytes(bytes!, flush: true);
    return file;
  }
}
