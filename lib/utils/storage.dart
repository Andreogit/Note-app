import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Storage {
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> uploadFile(String filePath, String fileName) async {
    firebase_storage.Reference reference = storage.ref("images/$userId/$fileName");
    File file = File(filePath);
    try {
      await reference.putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<String> uploadFileAndGetUrl(String filePath, String fileName) async {
    firebase_storage.Reference reference = storage.ref("images/$userId/$fileName");
    String? url;
    try {
      File file = File(filePath);
      final firebase_storage.TaskSnapshot snapshot = await reference.putFile(file);
      url = await snapshot.ref.getDownloadURL();
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    if (url != null) {
      return url;
    } else {
      return "";
    }
  }
}
