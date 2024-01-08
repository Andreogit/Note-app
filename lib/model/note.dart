import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class Note {
  final String title;
  final String content;
  final DateTime created;
  final DateTime modified;
  final String uid;
  final bool pinned;
  final String creatorUid;
  final List<String> undos;
  final List<String> redos;
  final List<String> audioPaths;

  Note({
    required this.title,
    required this.content,
    required this.created,
    required this.modified,
    required this.uid,
    this.pinned = false,
    required this.creatorUid,
    this.undos = const [],
    this.redos = const [],
    this.audioPaths = const [],
  });

  factory Note.empty() {
    return Note(creatorUid: "", uid: "", title: "", content: "", pinned: false, created: DateTime.now(), modified: DateTime.now());
  }

  factory Note.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Note(
      content: data?['content'] ?? "",
      title: data?['title'] ?? "",
      uid: doc.id,
      creatorUid: data?['creatorUid'] ?? "",
      pinned: data?['pinned'] ?? false,
      audioPaths: data?['audioPaths']?.cast<String>() ?? [],
      created: DateTime.fromMillisecondsSinceEpoch(data?['created'] ?? 0),
      modified: DateTime.fromMillisecondsSinceEpoch(data?['modified'] ?? 0),
    );
  }

  Note copyWith({
    String? title,
    String? content,
    DateTime? created,
    DateTime? modified,
    String? uid,
    bool? pinned,
    String? creatorUid,
    List<String>? undos,
    List<String>? redos,
    List<String>? audioPaths,
  }) {
    return Note(
      title: title ?? this.title,
      content: content ?? this.content,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      uid: uid ?? this.uid,
      pinned: pinned ?? this.pinned,
      creatorUid: creatorUid ?? this.creatorUid,
      undos: undos ?? this.undos,
      redos: redos ?? this.redos,
      audioPaths: audioPaths ?? this.audioPaths,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'content': content,
      'created': created.millisecondsSinceEpoch,
      'modified': modified.millisecondsSinceEpoch,
      'uid': uid,
      'pinned': pinned,
      'creatorUid': creatorUid,
      'undos': undos,
      'redos': redos,
      'audioPaths': audioPaths,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'] ?? "",
      content: map['content'] ?? "",
      created: DateTime.fromMillisecondsSinceEpoch(map['created'] ?? 0),
      modified: DateTime.fromMillisecondsSinceEpoch(map['modified'] ?? 0),
      uid: map['uid'] ?? "",
      pinned: map['pinned'] ?? false,
      creatorUid: map['creatorUid'] ?? "",
      undos: List<String>.from((map['undos'] ?? [])),
      redos: List<String>.from((map['redos'] ?? [])),
      audioPaths: List<String>.from((map['audioPaths'] ?? [])),
    );
  }

  @override
  String toString() {
    return 'Note(title: $title, content: $content, created: $created, modified: $modified, uid: $uid, pinned: $pinned, creatorUid: $creatorUid, undos: $undos, redos: $redos, audioPaths: $audioPaths)';
  }

  @override
  bool operator ==(covariant Note other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.content == content &&
        other.created == created &&
        other.modified == modified &&
        other.uid == uid &&
        other.pinned == pinned &&
        other.creatorUid == creatorUid &&
        listEquals(other.undos, undos) &&
        listEquals(other.redos, redos) &&
        listEquals(other.audioPaths, audioPaths);
  }

  @override
  int get hashCode {
    return title.hashCode ^
        content.hashCode ^
        created.hashCode ^
        modified.hashCode ^
        uid.hashCode ^
        pinned.hashCode ^
        creatorUid.hashCode ^
        undos.hashCode ^
        redos.hashCode ^
        audioPaths.hashCode;
  }
}
