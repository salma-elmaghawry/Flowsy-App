import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get font32Bold =>
      GoogleFonts.cairo(fontSize: 32.sp, fontWeight: FontWeight.bold);

  static TextStyle get font24Bold =>
      GoogleFonts.cairo(fontSize: 24.sp, fontWeight: FontWeight.bold);

  static TextStyle get font20SemiBold =>
      GoogleFonts.cairo(fontSize: 20.sp, fontWeight: FontWeight.w600);

  static TextStyle get font20Bold =>
      GoogleFonts.cairo(fontSize: 20.sp, fontWeight: FontWeight.bold);

  static TextStyle get font18Normal =>
      GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.normal);
  static TextStyle get font16Normal =>
      GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.normal);

  static TextStyle get font14Normal =>
      GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.normal);

  static TextStyle get font14SemiBold =>
      GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get font12SemiBold =>
      GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w500);

  static TextStyle get font10Normal =>
      GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.normal);
}
