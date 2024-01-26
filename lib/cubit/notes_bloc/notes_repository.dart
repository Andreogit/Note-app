import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noteapp/model/note.dart';

class NotesRepository {
  final db = FirebaseFirestore.instance;
  final notesCollection = FirebaseFirestore.instance.collection("notes");
  Future<void> updateNote(Note note) async {
    await notesCollection.doc(note.uid).set(note.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteNote(String noteUid) async {
    final foldersWithNote = await db.collection("folders").where("noteIds", arrayContains: noteUid).get();
    for (var element in foldersWithNote.docs) {
      await db.collection("folders").doc(element.id).update({
        "noteIds": FieldValue.arrayRemove([noteUid])
      });
    }
    await notesCollection.doc(noteUid).delete();
  }

  Future<List<Note>> getNotes() async {
    final snapshot = await notesCollection.where("creatorUid", isEqualTo: FirebaseAuth.instance.currentUser?.uid).get();
    return snapshot.docs.map((e) => Note.fromMap(e.data())).toList();
  }
}
