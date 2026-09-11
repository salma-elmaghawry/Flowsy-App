import 'package:wallet_split/features/auth/data/models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<AppUserModel?> get authStateChanges;
  AppUserModel? get currentUser;

  Future<AppUserModel> signIn({
    required String email,
    required String password,
  });

  Future<AppUserModel> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
