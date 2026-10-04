import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowsy/core/bloc/base_bloc.dart';
import 'package:flowsy/core/error_handling/failures.dart';
import 'package:flowsy/features/notes/presentation/cubit/notes_state.dart';
import 'package:flowsy/features/notes/repository/notes_repository.dart';

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository _repository;
  StreamSubscription? _notesSub;

  NotesCubit(this._repository) : super(const NotesState());

  void watchNotes() {
    emit(state.copyWith(status: Status.loading, action: NotesAction.watch));

    _notesSub?.cancel();
    _notesSub = _repository.watchNotes().listen((either) {
      either.fold(
        (failure) => emit(
          state.copyWith(
            status: Status.failure,
            message: failure.message,
            action: NotesAction.watch,
          ),
        ),
        (notes) => emit(
          state.copyWith(
            status: Status.success,
            notes: notes,
            action: NotesAction.watch,
          ),
        ),
      );
    });
  }

  /// Creates a note when [noteId] is null, otherwise updates it.
  Future<void> saveNote({
    String? noteId,
    required String title,
    required String content,
  }) async {
    emit(state.copyWith(status: Status.loading, action: NotesAction.saveNote));
    final result = noteId == null
        ? await _repository.createNote(title: title, content: content)
        : await _repository.updateNote(
            noteId: noteId,
            title: title,
            content: content,
          );
    _emitResult(result, NotesAction.saveNote);
  }

  Future<void> deleteNote(String noteId) async {
    emit(
      state.copyWith(status: Status.loading, action: NotesAction.deleteNote),
    );
    final result = await _repository.deleteNote(noteId);
    _emitResult(result, NotesAction.deleteNote);
  }

  void _emitResult(Either<Failure, void> result, NotesAction action) {
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          message: failure.message,
          action: action,
        ),
      ),
      (_) => emit(state.copyWith(status: Status.success, action: action)),
    );
  }

  @override
  Future<void> close() {
    _notesSub?.cancel();
    return super.close();
  }
}
