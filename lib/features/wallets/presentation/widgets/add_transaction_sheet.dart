import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/animations/animations.dart';
import 'package:wallet_split/core/helpers/amount_parser.dart';
import 'package:wallet_split/core/helpers/spacing.dart';
import 'package:wallet_split/core/utils/app_text_styles.dart';
import 'package:wallet_split/features/wallets/domain/entities/money_transaction.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallet_detail_cubit.dart';
import 'package:wallet_split/features/wallets/presentation/cubit/wallet_detail_state.dart';

Future<void> showAddTransactionSheet(
  BuildContext context, {
  required TransactionType type,
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
      child: _AddTransactionSheetContent(type: type),
    ),
  );
}

class _AddTransactionSheetContent extends StatefulWidget {
  final TransactionType type;

  const _AddTransactionSheetContent({required this.type});

  @override
  State<_AddTransactionSheetContent> createState() =>
      _AddTransactionSheetContentState();
}

class _AddTransactionSheetContentState
    extends State<_AddTransactionSheetContent> {
  final _formKey = GlobalKey<FormState>();
  bool _closed = false;
  String? _error;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedAllocationId;

  bool get _isTopUp => widget.type == TransactionType.topUp;
  WalletDetailAction get _action =>
      _isTopUp ? WalletDetailAction.topUp : WalletDetailAction.spend;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseAmount(_amountController.text)!;
    setState(() => _error = null);
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    final cubit = context.read<WalletDetailCubit>();
    if (_isTopUp) {
      cubit.topUp(amount: amount, note: note);
    } else {
      cubit.spend(
        amount: amount,
        allocationId: _selectedAllocationId,
        note: note,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletDetailCubit, WalletDetailState>(
      listener: (context, state) {
        if (state.action != _action) return;
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
                _isTopUp
                    ? 'transactions.top_up_title'.tr()
                    : 'transactions.spend_title'.tr(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              verticalSpace(20),
              TextFormField(
                controller: _amountController,
                textAlign: TextAlign.start,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'transactions.amount_label'.tr(),
                  hintText: 'transactions.amount_hint'.tr(),
                ),
                validator: (value) {
                  final parsed = parseAmount(value);
                  if (parsed == null || parsed <= 0) {
                    return 'allocations.amount_invalid'.tr();
                  }
                  return null;
                },
              ),
              if (!_isTopUp) ...[
                verticalSpace(16),
                BlocBuilder<WalletDetailCubit, WalletDetailState>(
                  builder: (context, state) {
                    if (state.allocations.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedAllocationId,
                      decoration: InputDecoration(
                        labelText: 'transactions.allocation_label'.tr(),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('transactions.no_allocation'.tr()),
                        ),
                        ...state.allocations.map(
                          (allocation) => DropdownMenuItem<String?>(
                            value: allocation.id,
                            child: Text(allocation.label),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedAllocationId = value),
                    );
                  },
                ),
              ],
              verticalSpace(16),
              TextFormField(
                controller: _noteController,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  labelText: 'allocations.note_label'.tr(),
                  hintText: 'allocations.note_hint'.tr(),
                ),
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
                  final isLoading = state.isLoading && state.action == _action;
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
