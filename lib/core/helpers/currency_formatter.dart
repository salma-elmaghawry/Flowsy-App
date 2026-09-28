import 'package:easy_localization/easy_localization.dart';

String formatCurrency(double amount) {
  final formatted = NumberFormat('#,##0.##').format(amount);
  return '$formatted ${'common.currency'.tr()}';
}
