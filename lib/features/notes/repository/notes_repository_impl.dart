import 'package:dartz/dartz.dart';
import 'package:flowsy/core/error_handling/error_mapper.dart';
import 'package:flowsy/core/error_handling/failures.dart';
import 'package:flowsy/features/notes/data/datasource/notes_remote_datasource.dart';
import 'package:flowsy/features/notes/domain/entities/note.dart';
import 'package:flowsy/features/notes/repository/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource _remoteDataSource;

  NotesRepositoryImpl(this._remoteDataSource);

  @override
  Stream<Either<Failure, List<Note>>> watchNotes() async* {
    try {
      await for (final models in _remoteDataSource.watchNotes()) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      yield Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> createNote({
    required String title,
    required String content,
  }) async {
    try {
      await _remoteDataSource.createNote(title: title, content: content);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    try {
      await _remoteDataSource.updateNote(
        noteId: noteId,
        title: title,
        content: content,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await _remoteDataSource.deleteNote(noteId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.map(e));
    }
  }
}
