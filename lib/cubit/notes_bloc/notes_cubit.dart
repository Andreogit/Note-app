// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/cubit/dashboard/dashboard_repository.dart';
import 'package:noteapp/cubit/notes_bloc/notes_repository.dart';
import 'package:noteapp/model/note.dart';
import 'package:noteapp/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Timer? _timer;

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository repository;
  NotesCubit({required this.repository}) : super(const NotesState());

  Future<void> deleteNote(String noteUid) async {
    deleteNoteFromCubit(noteUid);

    int index = state.notes.indexWhere((element) => element.uid == noteUid);
    if (index != -1) {
      if (!state.notes[index].updated) {
        DashboardRepository().addAction();
      }
    }
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
      final sp = await SharedPreferences.getInstance();
      final fontSize = sp.getDouble("fontSize") ?? 16;
      initFontSize(fontSize);
      await repository.getNotes().then((value) {
        emit(state.copyWith(notes: value));
      });
    } catch (e) {
      AppToast.showToast("Some error occured");
    }
    sortNotes();
  }

  Future<void> deleteEmptyNotes() async {
    await Future.delayed(const Duration(seconds: 1)).then((value) async {
      for (var note in state.notes.where((e) => e.content.isEmpty).toList()) {
        deleteNoteFromCubit(note.uid);
        try {
          await FirebaseFirestore.instance.collection('notes').doc(note.uid).delete();
        } catch (e) {
          AppToast.showToast("Some error occured");
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

  Future<void> togglePin(String noteUid) async {
    final index = state.notes.indexWhere((element) => element.uid == noteUid);
    if (index != -1) {
      final newNote = state.notes[index].copyWith(pinned: !state.notes[index].pinned);
      emit(
        state.copyWith(
            notes: List.of(state.notes)
              ..removeAt(index)
              ..insert(index, newNote)),
      );
      await repository.updateNote(newNote);
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
        updated: true,
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
        if (!state.notes[index].updated) {
          DashboardRepository().addAction();
        }
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
        updated: true,
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
        if (!state.notes[index].updated) {
          DashboardRepository().addAction();
        }
      });
    }
  }

  void incrementFontSize() async {
    if (state.fontSize < 35) {
      emit(state.copyWith(fontSize: state.fontSize + 1));
      final sp = await SharedPreferences.getInstance();
      await sp.setDouble('fontSize', state.fontSize + 1);
    }
  }

  void decrementFontSize() async {
    if (state.fontSize > 16) {
      emit(state.copyWith(fontSize: state.fontSize - 1));
      final sp = await SharedPreferences.getInstance();
      await sp.setDouble('fontSize', state.fontSize - 1);
    }
  }

  void initFontSize(double fontSize) async {
    emit(state.copyWith(fontSize: fontSize));
  }

  void changeSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim()));
  }

  String createNoteAndGetUid() {
    final newNote = Note(
      creatorUid: FirebaseAuth.instance.currentUser!.uid,
      title: "",
      content: "",
      created: DateTime.now(),
      modified: DateTime.now(),
      uid: const Uuid().v4(),
      updated: true,
    );
    emit(
      state.copyWith(
        notes: [...state.notes, newNote],
      ),
    );
    sortNotes();
    DashboardRepository().addAction();
    return newNote.uid;
  }
}

class NotesState extends Equatable {
  final String searchQuery;
  final bool isLoading;
  final bool isRecording;
  final List<Note> notes;
  final double fontSize;

  const NotesState({
    this.searchQuery = "",
    this.notes = const [],
    this.isLoading = false,
    this.isRecording = false,
    this.fontSize = 14,
  });

  @override
  List<Object?> get props => [
        notes,
        isLoading,
        isRecording,
        searchQuery,
        fontSize,
      ];

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    bool? isRecording,
    String? searchQuery,
    double? fontSize,
  }) {
    return NotesState(
      isLoading: isLoading ?? this.isLoading,
      notes: notes ?? this.notes,
      isRecording: isRecording ?? this.isRecording,
      searchQuery: searchQuery ?? this.searchQuery,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
