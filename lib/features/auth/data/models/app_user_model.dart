import 'package:wallet_split/features/auth/domain/entities/app_user.dart';

class AppUserModel {
  final String uid;
  final String? email;

  const AppUserModel({required this.uid, this.email});

  AppUser toEntity() => AppUser(uid: uid, email: email);
}
