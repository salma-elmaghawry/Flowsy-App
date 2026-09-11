import 'package:easy_localization/easy_localization.dart';

/// Formats an amount with the app's currency suffix (localized).
String formatCurrency(double amount) {
  final formatted = NumberFormat('#,##0.##').format(amount);
  return '$formatted ${'common.currency'.tr()}';
}
