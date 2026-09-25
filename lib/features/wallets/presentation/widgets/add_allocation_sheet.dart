import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/animations/animations.dart';
import 'package:wallet_split/core/helpers/amount_parser.dart';
import 'package:wallet_split/core/helpers/spacing.dart';
import 'package:wallet_split/core/utils/app_text_styles.dart';
import 'package:wallet_split/features/wallets/domain/entities/allocation.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallet_detail_cubit.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallet_detail_state.dart';

Future<void> showAddAllocationSheet(
  BuildContext context, {
  Allocation? existing,
}) {
  final cubit = context.read<WalletDetailCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _AddAllocationSheetContent(existing: existing),
    ),
  );
}

class _AddAllocationSheetContent extends StatefulWidget {
  final Allocation? existing;

  const _AddAllocationSheetContent({this.existing});

  @override
  State<_AddAllocationSheetContent> createState() =>
      _AddAllocationSheetContentState();
}

class _AddAllocationSheetContentState
    extends State<_AddAllocationSheetContent> {
  final _formKey = GlobalKey<FormState>();
  bool _closed = false;
  String? _error;
  late final _labelController = TextEditingController(
    text: widget.existing?.label,
  );
  late final _amountController = TextEditingController(
    text: widget.existing != null ? widget.existing!.amount.toString() : '',
  );

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseAmount(_amountController.text)!;
    setState(() => _error = null);
    final cubit = context.read<WalletDetailCubit>();
    if (_isEditing) {
      cubit.updateAllocation(
        allocationId: widget.existing!.id,
        label: _labelController.text.trim(),
        amount: amount,
        note: widget.existing!.note,
      );
    } else {
      cubit.createAllocation(
        label: _labelController.text.trim(),
        amount: amount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletDetailCubit, WalletDetailState>(
      listener: (context, state) {
        final matchesAction = _isEditing
            ? state.action == WalletDetailAction.updateAllocation
            : state.action == WalletDetailAction.createAllocation;
        if (!matchesAction) return;
        if (state.isSuccess) {
          // Several success states can arrive for one save (the save result
          // plus live stream updates). Close the sheet only once, otherwise
          // the extra pops close the screens underneath it.
          if (_closed) return;
          _closed = true;
          Navigator.of(context).pop();
        } else if (state.isFailure) {
          setState(
            () => _error = state.message ?? 'errors.unexpected_error'.tr(),
          );
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
                    ? 'allocations.edit_title'.tr()
                    : 'allocations.add_title'.tr(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              verticalSpace(20),
              TextFormField(
                controller: _labelController,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  labelText: 'allocations.label_label'.tr(),
                  hintText: 'allocations.label_hint'.tr(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'allocations.label_required'.tr()
                    : null,
              ),
              verticalSpace(16),
              TextFormField(
                controller: _amountController,
                textAlign: TextAlign.start,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'allocations.amount_label'.tr(),
                  hintText: 'allocations.amount_hint'.tr(),
                ),
                validator: (value) {
                  final parsed = parseAmount(value);
                  if (parsed == null || parsed <= 0) {
                    return 'allocations.amount_invalid'.tr();
                  }
                  return null;
                },
              ),
              if (_error != null) ...[
                verticalSpace(16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              verticalSpace(24),
              BlocBuilder<WalletDetailCubit, WalletDetailState>(
                builder: (context, state) {
                  final isLoading =
                      state.isLoading &&
                      state.action ==
                          (_isEditing
                              ? WalletDetailAction.updateAllocation
                              : WalletDetailAction.createAllocation);
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
