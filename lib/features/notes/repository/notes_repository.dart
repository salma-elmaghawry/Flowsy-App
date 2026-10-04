import 'package:dartz/dartz.dart';
import 'package:flowsy/core/error_handling/failures.dart';
import 'package:flowsy/features/notes/domain/entities/note.dart';

abstract class NotesRepository {
  Stream<Either<Failure, List<Note>>> watchNotes();

  Future<Either<Failure, void>> createNote({
    required String title,
    required String content,
  });
  Future<Either<Failure, void>> updateNote({
    required String noteId,
    required String title,
    required String content,
  });
  Future<Either<Failure, void>> deleteNote(String noteId);
}
