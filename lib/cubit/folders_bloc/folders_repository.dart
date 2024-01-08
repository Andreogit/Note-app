import 'package:cloud_firestore/cloud_firestore.dart';

class FoldersRepository {
  final db = FirebaseFirestore.instance;
  final foldersCollection = FirebaseFirestore.instance.collection("folders");

  Future<void> deleteFolder(String folderUid) async {
    await db.collection("folders").doc(folderUid).delete();
  }
}
