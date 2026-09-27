import 'package:flutter/cupertino.dart';
import 'package:wallet_split/core/theme/app_colors.dart';

Widget centeredCupertinoLoader({Color? color, double size = 30}) {
  return Center(
    child: SizedBox(
      width: size,
      height: size,
      child: CupertinoActivityIndicator(
        color: color ?? AppColors.primary,
        radius: size / 2,
      ),
    ),
  );
}
