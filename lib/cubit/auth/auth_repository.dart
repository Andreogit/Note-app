import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noteapp/utils/storage.dart';

class AuthRepository {
  Future<void> register(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((value) async {
      await FirebaseFirestore.instance.collection("users").doc(value.user?.uid).set({
        "email": value.user?.email,
      });
    });
  }

  Future<String> getAvatarUrl() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Storage storage = Storage();
      final String avatarUrl = await storage.uploadFileAndGetUrl(image.path, FirebaseAuth.instance.currentUser!.uid);
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update({
        "avatarUrl": avatarUrl,
      });
      return avatarUrl;
    }
    throw "File not selected";
  }
}
