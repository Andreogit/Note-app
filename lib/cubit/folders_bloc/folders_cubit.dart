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
    emit(state.copyWith(folders: List.of(state.folders)..removeWhere((e) => e.id == folderUid)));
    await repository.deleteFolder(folderUid);
  }

  void deleteNoteFromFolders(String nodeId) {
    for (var i = 0; i < state.folders.length; i++) {
      final newFolder = state.folders[i].copyWith(
        noteIds: List.of(state.folders[i].noteIds)..removeWhere((element) => element == nodeId),
      );
      emit(state.copyWith(
          folders: List.of(state.folders)
            ..removeAt(i)
            ..insert(i, newFolder)));
    }
  }

  void sort() {
    state.sortByDate ? sortByDate() : sortByName();
  }

  void sortByDate() {
    emit(state.copyWith(
      folders: state.folders.toList()..sort((a, b) => b.updated.compareTo(a.updated)),
    ));
  }

  void sortByName() {
    emit(state.copyWith(
      folders: state.folders.toList()..sort((a, b) => b.name.compareTo(a.name)),
    ));
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
      sortByDate();
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
      final newFolder = state.folders[index].copyWith(name: newName, updated: DateTime.now());
      emit(
        state.copyWith(
            folders: List.of(state.folders)
              ..removeAt(index)
              ..insert(index, newFolder)),
      );
      if (_t != null) _t?.cancel();
      _t = Timer(const Duration(milliseconds: 500), () async {
        await FirebaseFirestore.instance
            .collection("folders")
            .doc(folderId)
            .update({"name": newName, "updated": DateTime.now().millisecondsSinceEpoch});
      });
    }
    sort();
  }

  void addNoteToFolder(Note note, String folderId) async {
    final int index = state.folders.indexWhere((element) => element.id == folderId);
    if (index != -1) {
      if (state.folders[index].noteIds.contains(note.uid)) {
        AppToast.showToast("This note is already in folder");
        return;
      }

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
      sort();
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
    sort();
  }
}

class FoldersState extends Equatable {
  final List<Folder> folders;
  final bool sortByDate;
  const FoldersState({
    this.folders = const [],
    this.sortByDate = true,
  });
  @override
  List<Object?> get props => [folders, sortByDate];

  FoldersState copyWith({
    List<Folder>? folders,
    bool? sortByDate,
  }) {
    return FoldersState(
      folders: folders ?? this.folders,
      sortByDate: sortByDate ?? this.sortByDate,
    );
  }
}
