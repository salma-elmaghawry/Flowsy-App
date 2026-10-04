import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowsy/core/error_handling/app_exceptions.dart';
import 'package:flowsy/features/notes/data/datasource/notes_remote_datasource.dart';
import 'package:flowsy/features/notes/data/models/note_model.dart';

/// Firestore layout: users/{uid}/notes/{noteId}
class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotesRemoteDataSourceImpl(this._firestore, this._auth);

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const NotAuthenticatedException();
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _notesCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('notes');

  @override
  Stream<List<NoteModel>> watchNotes() {
    final uid = _requireUid();
    return _notesCol(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => NoteModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> createNote({
    required String title,
    required String content,
  }) async {
    final uid = _requireUid();
    final ref = _notesCol(uid).doc();
    final now = DateTime.now();
    final model = NoteModel(
      id: ref.id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    await ref.set(model.toMap());
  }

  @override
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    final uid = _requireUid();
    await _notesCol(uid).doc(noteId).update({
      'title': title,
      'content': content,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> deleteNote(String noteId) async {
    final uid = _requireUid();
    await _notesCol(uid).doc(noteId).delete();
  }
}
