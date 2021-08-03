import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteit/configs/configs.dart';
import 'package:noteit/helpers/helpers.dart';
import 'package:noteit/models/models.dart';
import 'package:meta/meta.dart';

class DatabaseService {
  final String userId;
  final Firestore _firestore = Firestore.instance;
  final Duration _timeoutDuration = Duration(seconds: 5);

  DatabaseService({@required this.userId});

  Future<void> addNote({@required Note note}) async {
    try {
      await _firestore
          .collection(Paths.notes(userId))
          .add(note.toDocument())
          .timeout(_timeoutDuration);
    } on TimeoutException {
      throw Failure('Couldn\'t add new note');
    }
  }

  Future<void> updateNote({@required Note note}) async {
    try {
      await _firestore
          .collection(Paths.notes(userId))
          .document(note.id)
          .updateData(note.toDocument())
          .timeout(_timeoutDuration);
    } on TimeoutException {
      throw Failure('Couldn\'t update note');
    }
  }

  Future<void> deleteNote({@required Note note}) async {
    try {
      await _firestore
          .collection(Paths.notes(userId))
          .document(note.id)
          .delete()
          .timeout(_timeoutDuration);
    } on TimeoutException {
      throw Failure('Couldn\'t delete note');
    }
  }

  Future<List<Note>> notes() async {
    return await _firestore.collection(Paths.notes(userId)).getDocuments().then(
          (snapshot) =>
              snapshot.documents.map((doc) => Note.fromSnapshot(doc)).toList()
                ..sort(
                  (a, b) => b.timestamp.compareTo(a.timestamp),
                ),
        );
  }
}
