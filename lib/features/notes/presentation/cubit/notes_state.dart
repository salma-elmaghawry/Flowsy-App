import 'package:flowsy/core/bloc/base_bloc.dart';
import 'package:flowsy/features/notes/domain/entities/note.dart';

enum NotesAction { watch, saveNote, deleteNote }

class NotesState extends BaseState {
  final List<Note> notes;
  final NotesAction? action;

  const NotesState({
    super.status = Status.initial,
    super.message,
    this.notes = const [],
    this.action,
  });

  NotesState copyWith({
    Status? status,
    String? message,
    List<Note>? notes,
    NotesAction? action,
  }) {
    return NotesState(
      status: status ?? this.status,
      message: message ?? this.message,
      notes: notes ?? this.notes,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [status, message, notes, action];
}
