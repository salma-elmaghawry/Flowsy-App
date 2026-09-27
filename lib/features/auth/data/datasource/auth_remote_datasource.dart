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

  Future<void> sendPasswordResetEmail(String email);

  /// Re-authenticates with [password], erases every Firestore document owned
  /// by the user, then deletes the Firebase Auth account itself.
  Future<void> deleteAccount({required String password});
}
