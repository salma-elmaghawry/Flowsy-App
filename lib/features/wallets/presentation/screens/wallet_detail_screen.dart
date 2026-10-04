import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flowsy/core/animations/animations.dart';
import 'package:flowsy/core/helpers/currency_formatter.dart';
import 'package:flowsy/core/helpers/extensions.dart';
import 'package:flowsy/core/helpers/responsive.dart';
import 'package:flowsy/core/helpers/spacing.dart';
import 'package:flowsy/core/routes/routes.dart';
import 'package:flowsy/core/theme/app_colors.dart';
import 'package:flowsy/features/wallets/domain/entities/allocation.dart';
import 'package:flowsy/features/wallets/domain/entities/money_transaction.dart';
import 'package:flowsy/features/wallets/domain/entities/wallet.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallet_detail_cubit.dart';
import 'package:flowsy/features/wallets/presentation/cubit/wallet_detail_state.dart';
import 'package:flowsy/features/wallets/presentation/widgets/add_allocation_sheet.dart';
import 'package:flowsy/features/wallets/presentation/widgets/add_transaction_sheet.dart';
import 'package:flowsy/features/wallets/presentation/widgets/allocation_tile.dart';
import 'package:flowsy/features/wallets/presentation/widgets/transaction_tile.dart';
import 'package:flowsy/features/wallets/presentation/widgets/wallet_color_picker.dart';

class WalletDetailScreen extends StatefulWidget {
  final Wallet wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletDetailCubit>().watchAll();
  }

  Future<void> _editWallet(Wallet wallet) async {
    final controller = TextEditingController(text: wallet.name);
    var selectedColor = Color(wallet.colorValue);
    final result = await showDialog<({String name, Color color})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('wallets.edit_wallet_title'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: 'wallets.name_label'.tr(),
                  ),
                ),
                verticalSpace(16),
                Text(
                  'wallets.color_label'.tr(),
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
                verticalSpace(8),
                WalletColorPicker(
                  selectedColor: selectedColor,
                  onChanged: (color) =>
                      setDialogState(() => selectedColor = color),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop((name: controller.text.trim(), color: selectedColor)),
              child: Text('common.save'.tr()),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result != null && result.name.isNotEmpty && mounted) {
      context.read<WalletDetailCubit>().updateWallet(
        name: result.name,
        colorValue: result.color.toARGB32(),
      );
    }
  }

  Future<void> _confirmDeleteWallet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('wallets.delete_confirm_title'.tr()),
        content: Text('wallets.delete_confirm_message'.tr()),
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
      context.read<WalletDetailCubit>().deleteWallet();
    }
  }

  Future<void> _confirmDeleteAllocation(Allocation allocation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('allocations.delete_confirm_title'.tr()),
        content: Text(allocation.label),
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
      context.read<WalletDetailCubit>().deleteAllocation(allocation.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletDetailCubit, WalletDetailState>(
      listener: (context, state) {
        if (state.action == WalletDetailAction.deleteWallet) {
          if (state.isSuccess) {
            context.pushNamedAndRemoveUntil(
              Routes.home,
              predicate: (route) => false,
            );
          } else if (state.isFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message ?? '')));
          }
        }
      },
      builder: (context, state) {
        final wallet = state.wallet ?? widget.wallet;
        final color = Color(wallet.colorValue);
        return Scaffold(
          appBar: AppBar(
            title: Text(wallet.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editWallet(wallet);
                  } else if (value == 'delete') {
                    _confirmDeleteWallet();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('wallets.edit_wallet_menu'.tr()),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('common.delete'.tr()),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: Responsive.scrollPadding(context),
            children: [
              _BalanceSummaryCard(
                color: color,
                balance: wallet.balance,
                allocated: state.allocatedTotal,
                remaining: state.remaining,
              ),
              verticalSpace(16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showAddTransactionSheet(
                        context,
                        type: TransactionType.topUp,
                      ),
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: Text('transactions.top_up_title'.tr()),
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showAddTransactionSheet(
                        context,
                        type: TransactionType.spend,
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: Text('transactions.spend_title'.tr()),
                    ),
                  ),
                ],
              ),
              verticalSpace(28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'allocations.section_title'.tr(),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  IconButton(
                    onPressed: () => showAddAllocationSheet(context),
                    icon: Icon(
                      Icons.add_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 26.sp,
                    ),
                    tooltip: 'allocations.add_title'.tr(),
                  ),
                ],
              ),
              verticalSpace(8),
              if (state.allocations.isEmpty)
                _EmptyHint(text: 'allocations.empty'.tr())
              else
                ...AnimationBuilder.staggerColumn(
                  children: state.allocations
                      .map(
                        (allocation) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: AllocationTile(
                            allocation: allocation,
                            onTap: () => showAddAllocationSheet(
                              context,
                              existing: allocation,
                            ),
                            onDelete: () =>
                                _confirmDeleteAllocation(allocation),
                          ),
                        ),
                      )
                      .toList(),
                ),
              verticalSpace(20),
              Text(
                'transactions.history_section'.tr(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              verticalSpace(8),
              if (state.transactions.isEmpty)
                _EmptyHint(text: 'transactions.empty'.tr())
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: state.transactions
                        .map(
                          (transaction) => TransactionTile(
                            transaction: transaction,
                            showWalletName: false,
                            onTap: () => showAddTransactionSheet(
                              context,
                              type: transaction.type,
                              existing: transaction,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ).fadeInSlideUp(),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceSummaryCard extends StatelessWidget {
  final Color color;
  final double balance;
  final double allocated;
  final double remaining;

  const _BalanceSummaryCard({
    required this.color,
    required this.balance,
    required this.allocated,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final isOverAllocated = remaining < 0;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'wallets.balance_label'.tr(),
            value: formatCurrency(balance),
          ),
          verticalSpace(10),
          _SummaryRow(
            label: 'wallets.allocated_label'.tr(),
            value: '- ${formatCurrency(allocated)}',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(height: 1, color: color.withValues(alpha: 0.3)),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'wallets.remaining_label'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                formatCurrency(remaining),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: isOverAllocated ? AppColors.error : color,
                ),
              ),
            ],
          ),
        ],
      ),
    ).fadeInScale();
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
