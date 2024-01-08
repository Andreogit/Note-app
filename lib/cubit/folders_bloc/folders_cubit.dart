// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/cubit/folders_bloc/folders_repository.dart';
import 'package:noteapp/model/folder.dart';
import 'package:uuid/uuid.dart';

import 'package:noteapp/model/note.dart';
import 'package:noteapp/utils/toast.dart';

Timer? _t;

class FoldersCubit extends Cubit<FoldersState> {
  FoldersRepository repository;

  FoldersCubit({required this.repository}) : super(const FoldersState());

  Future<void> deleteFolder(String folderUid) async {
    await repository.deleteFolder(folderUid);
  }

  Future<void> loadFolders() async {
    await FirebaseFirestore.instance
        .collection("folders")
        .where("creatorId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      for (var doc in value.docs.toList()) {
        final noteIds = doc.data()["noteIds"];
        for (var noteId in noteIds) {
          final note = await FirebaseFirestore.instance.collection("notes").doc(noteId).get();
          if (!note.exists) {
            await FirebaseFirestore.instance.collection("folders").doc(doc.id).update({
              "noteIds": FieldValue.arrayRemove([noteId])
            });
          }
        }
      }
      final folders = value.docs.map((e) => Folder.fromDocument(e)).toList();
      emit(state.copyWith(
        folders: folders,
      ));
      updateFolderNotesCount();
    });
  }

  Future<void> updateFolderNotesCount() async {
    final foldersCollection = FirebaseFirestore.instance.collection("folders");
    for (var folder in state.folders.toList()) {
      final newFolderDoc = await foldersCollection.doc(folder.id).get();
      if (newFolderDoc.exists) {
        final int index = state.folders.indexOf(folder);
        if (index != -1) {
          emit(state.copyWith(
              folders: List.of(state.folders)
                ..removeAt(index)
                ..insert(index, Folder.fromDocument(newFolderDoc))));
        }
      }
    }
  }

  void changeFolderName(String folderId, String newName) async {
    final int index = state.folders.indexWhere((element) => element.id == folderId);
    if (index != -1) {
      emit(
        state.copyWith(
          folders: List.of(state.folders)..elementAt(index).copyWith(name: newName),
        ),
      );
      if (_t != null) _t?.cancel();
      _t = Timer(const Duration(milliseconds: 500), () async {
        await FirebaseFirestore.instance.collection("folders").doc(folderId).update({"name": newName});
      });
    }
  }

  void addNoteToFolder(Note note, String folderId) async {
    final int index = state.folders.indexWhere((element) => element.id == folderId);
    if (index != -1) {
      await FirebaseFirestore.instance.collection("folders").doc(folderId).update({
        "noteIds": FieldValue.arrayUnion([note.uid])
      });
      final newFolder = state.folders[index].copyWith(
        noteIds: List.of(state.folders[index].noteIds)..insert(0, note.uid),
      );
      emit(state.copyWith(
        folders: List.of(state.folders)
          ..removeAt(index)
          ..insert(index, newFolder),
      ));
    }
  }

  void createFolder({List<Note>? notes}) async {
    if (state.folders.length < 5) {
      final Folder newFolder = Folder(
        creatorId: FirebaseAuth.instance.currentUser!.uid,
        name: "New folder",
        id: const Uuid().v4(),
        noteIds: notes?.map((e) => e.uid).toList() ?? [],
        updated: DateTime.now(),
      );
      emit(
        FoldersState(folders: [...state.folders, newFolder]),
      );
      await FirebaseFirestore.instance.collection("folders").doc(newFolder.id).set(newFolder.toMap());
    } else {
      AppToast.showToast("To unlock more folders, upgrade your account");
    }
  }
}

class FoldersState extends Equatable {
  final List<Folder> folders;
  const FoldersState({this.folders = const []});
  @override
  List<Object?> get props => [folders];

  FoldersState copyWith({
    List<Folder>? folders,
  }) {
    return FoldersState(
      folders: folders ?? this.folders,
    );
  }
}
