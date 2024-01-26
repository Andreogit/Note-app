import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class Note extends Equatable {
  final String title;
  final String content;
  final DateTime created;
  final DateTime modified;
  final String uid;
  final bool pinned;
  final String creatorUid;
  final List<String> undos;
  final List<String> redos;
  final bool updated;

  const Note({
    required this.title,
    required this.content,
    required this.created,
    required this.modified,
    required this.uid,
    this.pinned = false,
    required this.creatorUid,
    this.undos = const [],
    this.redos = const [],
    this.updated = false,
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
    bool? updated,
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
      updated: updated ?? this.updated,
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
    );
  }

  @override
  String toString() {
    return 'Note(title: $title, content: $content, created: $created, modified: $modified, uid: $uid, pinned: $pinned, creatorUid: $creatorUid, undos: $undos, redos: $redos, updated: $updated)';
  }

  @override
  List<Object?> get props => [
        title,
        content,
        created,
        modified,
        uid,
        pinned,
        creatorUid,
        undos,
        redos,
        updated,
      ];
}
