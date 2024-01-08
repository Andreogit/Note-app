// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Folder {
  final String name;
  final String id;
  final String creatorId;
  final List<String> noteIds;
  final DateTime updated;
  Folder({
    required this.name,
    required this.id,
    required this.creatorId,
    required this.noteIds,
    required this.updated,
  });

  Folder copyWith({
    String? name,
    String? id,
    String? creatorId,
    List<String>? noteIds,
    DateTime? updated,
  }) {
    return Folder(
      name: name ?? this.name,
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      noteIds: noteIds ?? this.noteIds,
      updated: updated ?? this.updated,
    );
  }

  factory Folder.empty() {
    return Folder(
      name: "",
      id: const Uuid().v4(),
      creatorId: FirebaseAuth.instance.currentUser!.uid,
      noteIds: [],
      updated: DateTime.now(),
    );
  }

  factory Folder.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Folder(
      name: data['name'] ?? "",
      id: doc.id,
      creatorId: data['creatorId'] ?? "",
      noteIds: List<String>.from((data['noteIds'] ?? [])),
      updated: DateTime.fromMillisecondsSinceEpoch(data['updated'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'id': id,
      'creatorId': creatorId,
      'noteIds': noteIds,
      'updated': updated.millisecondsSinceEpoch,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      name: map['name'] as String,
      id: map['id'] as String,
      creatorId: map['creatorId'] as String,
      noteIds: List<String>.from((map['noteIds'] as List<String>)),
      updated: DateTime.fromMillisecondsSinceEpoch(map['updated'] as int),
    );
  }

  @override
  bool operator ==(covariant Folder other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.id == id &&
        other.creatorId == creatorId &&
        listEquals(other.noteIds, noteIds) &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return name.hashCode ^ id.hashCode ^ creatorId.hashCode ^ noteIds.hashCode ^ updated.hashCode;
  }
}
