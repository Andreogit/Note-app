// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/cubit/notes/notes_repository.dart';
import 'package:noteapp/model/note.dart';
import 'package:noteapp/utils/toast.dart';
import 'package:uuid/uuid.dart';

Timer? _timer;

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository repository;
  NotesCubit({required this.repository}) : super(const NotesState());

  Future<void> deleteNote(String noteUid) async {
    deleteNoteFromCubit(noteUid);
    await repository.deleteNote(noteUid);
  }

  void redoPressed(String noteId) {
    final int index = state.notes.indexWhere((element) => element.uid == noteId);
    if (index != -1) {
      final newNote = state.notes.elementAt(index).copyWith(
          redos: List.of(state.notes[index].redos)
            ..removeLast()
            ..toSet()
            ..toList(),
          undos: List.of(state.notes[index].undos)
            ..add(state.notes[index].redos.last)
            ..toSet()
            ..toList());
      emit(
        state.copyWith(
          notes: List.of(state.notes)
            ..removeAt(index)
            ..insert(index, newNote),
        ),
      );
    }
  }

  void undoPressed(String noteId) {
    final int index = state.notes.indexWhere((element) => element.uid == noteId);
    if (index != -1) {
      final newNote = state.notes.elementAt(index).copyWith(
          undos: List.of(state.notes[index].undos)
            ..removeLast()
            ..toSet()
            ..toList(),
          redos: List.of(state.notes[index].redos)
            ..add(List.of(state.notes[index].undos).last)
            ..toSet()
            ..toList());
      emit(
        state.copyWith(
          notes: List.of(state.notes)
            ..removeAt(index)
            ..insert(index, newNote),
        ),
      );
    }
  }

  void addNoteUndo(Note note) {
    final int index = state.notes.indexWhere((element) => element.uid == note.uid);
    if (index != -1) {
      final newNote = List.of(state.notes).elementAt(index).copyWith(
        undos: [...state.notes[index].undos, note.content],
      );
      emit(state.copyWith(
          notes: List.of(state.notes)
            ..removeAt(index)
            ..insert(index, newNote)));
    }
  }

  void addNoteRedo(Note note, String content) {
    final int index = state.notes.indexWhere((element) => element.uid == note.uid);
    if (index != -1) {
      final newNote = List.of(state.notes).elementAt(index).copyWith(redos: [...state.notes[index].redos, content]);
      emit(state.copyWith(
          notes: List.of(state.notes)
            ..removeAt(index)
            ..insert(index, newNote)));
    }
  }

  Future<void> init() async {
    try {
      await repository.getNotes().then((value) {
        emit(state.copyWith(notes: value));
      });
    } catch (e) {
      AppToast.showToast("Some error occured");
      print(e);
    }
    sortNotes();
  }

  Future<void> deleteEmptyNotes() async {
    await Future.delayed(const Duration(seconds: 1)).then((value) async {
      for (var note in state.notes.where((e) => e.content.isEmpty && e.audioPaths.isEmpty).toList()) {
        deleteNoteFromCubit(note.uid);
        try {
          await FirebaseFirestore.instance.collection('notes').doc(note.uid).delete();
        } catch (e) {
          AppToast.showToast("Some error occured");
          print(e);
        }
      }
    });
  }

  void deleteNoteFromCubit(String noteUid) {
    emit(
      state.copyWith(
        notes: List.of(state.notes)..removeWhere((e) => e.uid == noteUid),
      ),
    );
  }

  void togglePin(String noteUid) {
    final index = state.notes.indexWhere((element) => element.uid == noteUid);
    if (index != -1) {
      final newNote = state.notes[index].copyWith(pinned: !state.notes[index].pinned);
      emit(
        state.copyWith(
            notes: List.of(state.notes)
              ..removeAt(index)
              ..insert(index, newNote)),
      );
      repository.updateNote(newNote);
    }
    sortNotes();
  }

  void sortNotes() {
    emit(state.copyWith(
        notes: List.of(state.notes)
          ..sort(
            (a, b) => a.modified.compareTo(b.modified),
          )
          ..sort((a, b) => a.pinned ? 0 : 1)));
  }

  void changeNoteContent({required String noteUid, required String content, bool? isUndo, bool? isRedo}) {
    final index = state.notes.indexWhere((element) => element.uid == noteUid);
    if (index != -1) {
      if (isUndo != true) {
        addNoteUndo(state.notes[index]);
      }
      if (isRedo == true) {
        emit(
          state.copyWith(
            notes: List.of(state.notes)
              ..removeAt(index)
              ..insert(
                index,
                state.notes[index].copyWith(redos: []),
              ),
          ),
        );
      }
      final newNote = state.notes[index].copyWith(
        content: content.trimRight(),
        modified: DateTime.now(),
        redos: [],
      );
      emit(
        state.copyWith(
            notes: List.of(state.notes)
              ..removeAt(index)
              ..insert(index, newNote)),
      );
      if (_timer != null) {
        _timer!.cancel();
      }
      _timer = Timer(const Duration(milliseconds: 500), () async {
        await repository.updateNote(newNote);
        sortNotes();
      });
    }
  }

  void updateNoteContent(String noteId, String content) {
    final index = state.notes.indexWhere((element) => element.uid == noteId);
    if (index != -1) {
      final newNote = state.notes[index].copyWith(
        content: content.trimRight(),
        modified: DateTime.now(),
      );
      emit(
        state.copyWith(
            notes: List.of(state.notes)
              ..removeAt(index)
              ..insert(index, newNote)),
      );
      if (_timer != null) {
        _timer!.cancel();
      }
      _timer = Timer(const Duration(milliseconds: 500), () async {
        await repository.updateNote(newNote);
        sortNotes();
      });
    }
  }

  String createNoteAndGetUid() {
    final newNote = Note(
      creatorUid: FirebaseAuth.instance.currentUser!.uid,
      title: "",
      content: "",
      created: DateTime.now(),
      modified: DateTime.now(),
      uid: const Uuid().v4(),
    );
    emit(
      state.copyWith(
        notes: [...state.notes, newNote],
      ),
    );
    sortNotes();
    return newNote.uid;
  }
}

class NotesState extends Equatable {
  final bool isLoading;
  final bool isRecording;
  final List<Note> notes;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.isRecording = false,
  });

  @override
  List<Object?> get props => [notes, isLoading, isRecording];

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    bool? isRecording,
  }) {
    return NotesState(
      isLoading: isLoading ?? this.isLoading,
      notes: notes ?? this.notes,
      isRecording: isRecording ?? this.isRecording,
    );
  }
}
