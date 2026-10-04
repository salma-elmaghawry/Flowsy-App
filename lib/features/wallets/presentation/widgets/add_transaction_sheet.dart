import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/animations/animations.dart';
import 'package:flowsy/core/helpers/amount_parser.dart';
import 'package:flowsy/core/helpers/spacing.dart';
import 'package:flowsy/core/utils/app_text_styles.dart';
import 'package:flowsy/features/wallets/domain/entities/money_transaction.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallet_detail_cubit.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallet_detail_state.dart';

Future<void> showAddTransactionSheet(
  BuildContext context, {
  required TransactionType type,
  MoneyTransaction? existing,
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
      child: _AddTransactionSheetContent(type: type, existing: existing),
    ),
  );
}

class _AddTransactionSheetContent extends StatefulWidget {
  final TransactionType type;
  final MoneyTransaction? existing;

  const _AddTransactionSheetContent({required this.type, this.existing});

  @override
  State<_AddTransactionSheetContent> createState() =>
      _AddTransactionSheetContentState();
}

class _AddTransactionSheetContentState
    extends State<_AddTransactionSheetContent> {
  final _formKey = GlobalKey<FormState>();
  bool _closed = false;
  String? _error;
  late final _amountController = TextEditingController(
    text: widget.existing != null ? _formatAmount(widget.existing!.amount) : '',
  );
  late final _noteController = TextEditingController(
    text: widget.existing?.note,
  );
  late String? _selectedAllocationId = widget.existing?.allocationId;
  late DateTime _date = widget.existing?.createdAt ?? DateTime.now();

  bool get _isTopUp => widget.type == TransactionType.topUp;
  bool get _isEditing => widget.existing != null;
  WalletDetailAction get _action => _isEditing
      ? WalletDetailAction.updateTransaction
      : _isTopUp
      ? WalletDetailAction.topUp
      : WalletDetailAction.spend;

  static String _formatAmount(double amount) => amount == amount.truncate()
      ? amount.truncate().toString()
      : amount.toString();

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (!mounted) return;
    final time = pickedTime ?? TimeOfDay.fromDateTime(_date);
    setState(() {
      _date = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('transactions.delete_confirm_title'.tr()),
        content: Text('transactions.delete_confirm_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'common.delete'.tr(),
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _error = null);
      context.read<WalletDetailCubit>().deleteTransaction(widget.existing!.id);
    }
  }

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
    if (_isEditing) {
      cubit.updateTransaction(
        transactionId: widget.existing!.id,
        amount: amount,
        createdAt: _date,
        allocationId: _isTopUp ? null : _selectedAllocationId,
        note: note,
      );
    } else if (_isTopUp) {
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
        final isDelete =
            _isEditing && state.action == WalletDetailAction.deleteTransaction;
        if (state.action != _action && !isDelete) return;
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
                    ? 'transactions.edit_title'.tr()
                    : _isTopUp
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
                    // A deleted allocation can't be re-selected, so fall
                    // back to "something else" instead of crashing the menu.
                    final hasSelected = state.allocations.any(
                      (a) => a.id == _selectedAllocationId,
                    );
                    return DropdownButtonFormField<String?>(
                      initialValue: hasSelected ? _selectedAllocationId : null,
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
              if (_isEditing) ...[
                verticalSpace(16),
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'transactions.date_label'.tr(),
                      suffixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      DateFormat.yMMMd(
                        context.locale.toString(),
                      ).add_jm().format(_date),
                    ),
                  ),
                ),
              ],
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
              if (_isEditing) ...[
                verticalSpace(8),
                Center(
                  child: TextButton.icon(
                    onPressed: _confirmDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      'transactions.delete'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
