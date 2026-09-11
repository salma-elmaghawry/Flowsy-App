import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/helpers/currency_formatter.dart';
import 'package:wallet_split/core/helpers/spacing.dart';
import 'package:wallet_split/core/theme/app_colors.dart';
import 'package:wallet_split/features/wallets/domain/entities/money_transaction.dart';

class TransactionTile extends StatelessWidget {
  final MoneyTransaction transaction;
  final bool showWalletName;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.showWalletName = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTopUp = transaction.type == TransactionType.topUp;
    final color = isTopUp ? AppColors.success : AppColors.error;
    final sign = isTopUp ? '+' : '-';

    final subtitleParts = <String>[
      if (showWalletName) transaction.walletName,
      if (transaction.allocationLabel != null) transaction.allocationLabel!,
      if (transaction.note != null && transaction.note!.isNotEmpty)
        transaction.note!,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTopUp
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 18.sp,
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTopUp
                      ? 'transactions.type_top_up'.tr()
                      : 'transactions.type_spend'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitleParts.isNotEmpty) ...[
                  verticalSpace(2),
                  Text(
                    subtitleParts.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${formatCurrency(transaction.amount)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                DateFormat.MMMd(context.locale.toString()).add_Hm().format(
                  transaction.createdAt,
                ),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
