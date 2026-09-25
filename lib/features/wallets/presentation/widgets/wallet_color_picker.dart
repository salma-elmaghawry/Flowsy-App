import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/animations/animations.dart';
import 'package:wallet_split/core/theme/app_colors.dart';

/// Preset colors offered for wallets, before the custom color button.
const walletPresetColors = <Color>[
  AppColors.primary,
  AppColors.secondary,
  AppColors.third,
  Color(0xFF9333EA),
  Color(0xFFDB2777),
  Color(0xFF0891B2),
];

/// A row of preset color circles plus a rainbow button that opens a full
/// color picker. Used when creating a wallet and when editing one.
class WalletColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onChanged;

  const WalletColorPicker({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  bool get _isCustomColor => !walletPresetColors.any(
    (color) => color.toARGB32() == selectedColor.toARGB32(),
  );

  Future<void> _pickCustomColor(BuildContext context) async {
    final picked = await showColorPickerDialog(
      context,
      selectedColor,
      title: Text(
        'wallets.custom_color_title'.tr(),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      pickersEnabled: const {
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      pickerTypeLabels: {
        ColorPickerType.primary: 'wallets.custom_color_palette'.tr(),
        ColorPickerType.wheel: 'wallets.custom_color_wheel'.tr(),
      },
      enableShadesSelection: true,
      width: 36,
      height: 36,
      spacing: 6,
      runSpacing: 6,
      borderRadius: 18,
      wheelDiameter: 220,
      showColorCode: true,
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 360),
    );
    // The dialog returns the starting color when cancelled.
    onChanged(picked.withAlpha(0xFF));
  }

  Widget _buildCustomColorButton(BuildContext context) {
    final isSelected = _isCustomColor;
    return Tooltip(
      message: 'wallets.custom_color_title'.tr(),
      child: AnimatedTap(
        onTap: () => _pickCustomColor(context),
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? selectedColor : null,
            gradient: isSelected
                ? null
                : const SweepGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.cyan,
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                    ],
                  ),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 2,
                  )
                : null,
          ),
          child: Icon(
            isSelected ? Icons.check : Icons.colorize_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: walletPresetColors.map<Widget>((color) {
        final isSelected = color.toARGB32() == selectedColor.toARGB32();
        return AnimatedTap(
          onTap: () => onChanged(color),
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 2,
                    )
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList()..add(_buildCustomColorButton(context)),
    );
  }
}
