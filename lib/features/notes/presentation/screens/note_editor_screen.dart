import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/helpers/responsive.dart';
import 'package:flowsy/features/notes/domain/entities/note.dart';
import 'package:flowsy/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:flowsy/features/notes/presentation/widgets/delete_note_dialog.dart';

/// Writes or edits one note. Changes save automatically when leaving the
/// screen, so a quick thought never gets lost. Empty new notes are discarded.
class NoteEditorScreen extends StatefulWidget {
  final Note? existing;

  const NoteEditorScreen({super.key, this.existing});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );
  late final _contentController = TextEditingController(
    text: widget.existing?.content,
  );
  bool _skipSave = false;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveIfNeeded() {
    if (_skipSave) return;
    _skipSave = true;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    // Nothing written: don't create a blank note, and don't wipe an
    // existing one by accident. Deleting is done with the delete button.
    if (title.isEmpty && content.isEmpty) return;

    final existing = widget.existing;
    if (existing != null &&
        existing.title == title &&
        existing.content == content) {
      return;
    }

    context.read<NotesCubit>().saveNote(
      noteId: existing?.id,
      title: title,
      content: content,
    );
  }

  Future<void> _delete() async {
    if (!await confirmDeleteNote(context) || !mounted) return;
    _skipSave = true;
    context.read<NotesCubit>().deleteNote(widget.existing!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _saveIfNeeded();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? 'notes.edit_title'.tr() : 'notes.new_title'.tr(),
          ),
          actions: [
            if (_isEditing)
              IconButton(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'common.delete'.tr(),
              ),
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.check_rounded),
              tooltip: 'common.done'.tr(),
            ),
          ],
        ),
        body: SafeArea(
          child: ResponsiveCenter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    autofocus: !_isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    style: theme.textTheme.displaySmall,
                    decoration: _plainDecoration('notes.title_hint'.tr()),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: theme.textTheme.bodyLarge,
                      decoration: _plainDecoration('notes.content_hint'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A borderless field so the editor reads like a page, not a form.
  InputDecoration _plainDecoration(String hint) => InputDecoration(
    hintText: hint,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    filled: false,
    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
  );
}
