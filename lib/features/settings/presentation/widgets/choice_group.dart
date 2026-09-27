import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/helpers/spacing.dart';

/// A row of single-select chips built from `value -> label` [options].
class ChoiceGroup<T> extends StatelessWidget {
  const ChoiceGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.expanded = false,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Stretch chips to share the full width instead of wrapping.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final MapEntry(key: value, value: label) in options.entries)
        ChoiceChip(
          label: Text(label),
          selected: value == selected,
          onSelected: (_) => onSelected(value),
        ),
    ];
    if (!expanded) return Wrap(spacing: 12.w, children: chips);
    return Row(
      children: [
        for (final chip in chips) ...[
          if (chip != chips.first) horizontalSpace(12),
          Expanded(child: chip),
        ],
      ],
    );
  }
}
