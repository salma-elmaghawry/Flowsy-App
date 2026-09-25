import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/animations/animations.dart';
import 'package:wallet_split/core/helpers/spacing.dart';
import 'package:wallet_split/core/theme/app_colors.dart';
import 'package:wallet_split/core/utils/app_text_styles.dart';
import 'package:wallet_split/features/wallets/domain/entities/wallet.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallets_state.dart';

const _walletColors = <Color>[
  AppColors.primary,
  AppColors.secondary,
  AppColors.third,
  Color(0xFF9333EA),
  Color(0xFFDB2777),
  Color(0xFF0891B2),
];

Future<void> showAddWalletSheet(BuildContext context, {Wallet? existing}) {
  final cubit = context.read<WalletsCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _AddWalletSheetContent(existing: existing),
    ),
  );
}

class _AddWalletSheetContent extends StatefulWidget {
  final Wallet? existing;

  const _AddWalletSheetContent({this.existing});

  @override
  State<_AddWalletSheetContent> createState() =>
      _AddWalletSheetContentState();
}

class _AddWalletSheetContentState extends State<_AddWalletSheetContent> {
  final _formKey = GlobalKey<FormState>();
  bool _closed = false;
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late Color _selectedColor = widget.existing != null
      ? Color(widget.existing!.colorValue)
      : _walletColors.first;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<WalletsCubit>();
    if (_isEditing) {
      cubit.updateWallet(
        walletId: widget.existing!.id,
        name: _nameController.text.trim(),
        colorValue: _selectedColor.toARGB32(),
      );
    } else {
      cubit.createWallet(
        name: _nameController.text.trim(),
        colorValue: _selectedColor.toARGB32(),
      );
    }
  }

  bool get _isCustomColor => !_walletColors.any(
    (color) => color.toARGB32() == _selectedColor.toARGB32(),
  );

  Future<void> _pickCustomColor() async {
    final picked = await showColorPickerDialog(
      context,
      _selectedColor,
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
    if (!mounted) return;
    // The dialog returns the starting color when cancelled.
    setState(() => _selectedColor = picked.withAlpha(0xFF));
  }

  /// A rainbow circle that opens the full color picker. Once a custom color
  /// is chosen, the circle shows that color with a check mark.
  Widget _buildCustomColorButton(BuildContext context) {
    final isSelected = _isCustomColor;
    return Tooltip(
      message: 'wallets.custom_color_title'.tr(),
      child: AnimatedTap(
        onTap: _pickCustomColor,
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? _selectedColor : null,
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
    return BlocListener<WalletsCubit, WalletsState>(
      listener: (context, state) {
        final matchesAction = _isEditing
            ? state.action == WalletsAction.updateWallet
            : state.action == WalletsAction.createWallet;
        if (!matchesAction) return;
        if (state.isSuccess) {
          // Several success states can arrive for one save (the save result
          // plus live stream updates). Close the sheet only once, otherwise
          // the extra pops close the screens underneath it.
          if (_closed) return;
          _closed = true;
          Navigator.of(context).pop();
        } else if (state.isFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message ?? '')));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing
                    ? 'wallets.edit_wallet_title'.tr()
                    : 'wallets.add_wallet_title'.tr(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              verticalSpace(20),
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  labelText: 'wallets.name_label'.tr(),
                  hintText: 'wallets.name_hint'.tr(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'wallets.name_required'.tr()
                    : null,
              ),
              verticalSpace(16),
              Text(
                'wallets.color_label'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              verticalSpace(8),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: _walletColors.map<Widget>((color) {
                  final isSelected = color.toARGB32() == _selectedColor.toARGB32();
                  return AnimatedTap(
                    onTap: () => setState(() => _selectedColor = color),
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
                }).toList()
                  ..add(_buildCustomColorButton(context)),
              ),
              verticalSpace(24),
              BlocBuilder<WalletsCubit, WalletsState>(
                builder: (context, state) {
                  final isLoading =
                      state.isLoading &&
                      state.action ==
                          (_isEditing
                              ? WalletsAction.updateWallet
                              : WalletsAction.createWallet);
                  return AnimatedButton(
                    isLoading: isLoading,
                    onPressed: _submit,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Text(
                      'common.save'.tr(),
                      style: AppTextStyles.font16Normal.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
