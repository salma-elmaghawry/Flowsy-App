import 'package:flowsy/features/notes/data/models/note_model.dart';

abstract class NotesRemoteDataSource {
  Stream<List<NoteModel>> watchNotes();

  Future<void> createNote({required String title, required String content});
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  });
  Future<void> deleteNote(String noteId);
}
