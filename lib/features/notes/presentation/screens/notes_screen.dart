import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/animations/animations.dart';
import 'package:flowsy/core/helpers/responsive.dart';
import 'package:flowsy/features/notes/domain/entities/note.dart';
import 'package:flowsy/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:flowsy/features/notes/presentation/cubit/notes_state.dart';
import 'package:flowsy/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:flowsy/features/notes/presentation/widgets/delete_note_dialog.dart';
import 'package:flowsy/features/notes/presentation/widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // Swiped-away notes are hidden right away. The cubit emits before the
  // Firestore snapshot drops them, and a dismissed Dismissible must never
  // be rebuilt.
  final Set<String> _dismissedIds = {};

  @override
  void initState() {
    super.initState();
    context.read<NotesCubit>().watchNotes();
  }

  void _openEditor({Note? note}) {
    final cubit = context.read<NotesCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NoteEditorScreen(existing: note),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('notes.title'.tr())),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        tooltip: 'notes.add'.tr(),
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<NotesCubit, NotesState>(
        listenWhen: (previous, current) =>
            current.isFailure && current.action != NotesAction.watch,
        listener: (context, state) {
          // A failed delete brings the note back.
          if (state.action == NotesAction.deleteNote) {
            setState(_dismissedIds.clear);
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message ?? '')));
        },
        builder: (context, state) {
          final notes = state.notes
              .where((note) => !_dismissedIds.contains(note.id))
              .toList();
          if (notes.isEmpty) {
            if (state.isLoading && state.action == NotesAction.watch) {
              return const Center(child: CircularProgressIndicator());
            }
            return _EmptyNotes(
              text: state.isFailure && state.action == NotesAction.watch
                  ? state.message ?? ''
                  : 'notes.empty'.tr(),
            );
          }

          return ListView(
            padding: Responsive.scrollPadding(context).copyWith(
              // Keep the last note clear of the add button.
              bottom: 96.h,
            ),
            children: AnimationBuilder.staggerColumn(
              children: notes
                  .map(
                    (note) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Dismissible(
                        key: ValueKey(note.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => confirmDeleteNote(context),
                        onDismissed: (_) {
                          setState(() => _dismissedIds.add(note.id));
                          context.read<NotesCubit>().deleteNote(note.id);
                        },
                        background: _DeleteBackground(),
                        child: NoteCard(
                          note: note,
                          onTap: () => _openEditor(note: note),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: EdgeInsetsDirectional.only(end: 20.w),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(Icons.delete_outline_rounded, color: error),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  final String text;

  const _EmptyNotes({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 56.sp,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            SizedBox(height: 12.h),
            Text(
              text,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).fadeInScale();
  }
}
