import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallet_split/core/animations/animations.dart';
import 'package:wallet_split/core/helpers/currency_formatter.dart';
import 'package:wallet_split/core/helpers/spacing.dart';
import 'package:wallet_split/features/wallets/domain/entities/allocation.dart';

class AllocationTile extends StatelessWidget {
  final Allocation allocation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AllocationTile({
    super.key,
    required this.allocation,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allocation.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (allocation.note != null &&
                      allocation.note!.isNotEmpty) ...[
                    verticalSpace(2),
                    Text(
                      allocation.note!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              formatCurrency(allocation.amount),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (onDelete != null) ...[
              horizontalSpace(4),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: 'common.delete'.tr(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
