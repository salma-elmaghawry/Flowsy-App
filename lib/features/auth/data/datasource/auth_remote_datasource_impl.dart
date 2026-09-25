import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:wallet_split/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:wallet_split/features/auth/data/models/app_user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl(this._firebaseAuth);

  AppUserModel? _map(fb.User? user) {
    if (user == null) return null;
    return AppUserModel(uid: user.uid, email: user.email);
  }

  @override
  Stream<AppUserModel?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_map);

  @override
  AppUserModel? get currentUser => _map(_firebaseAuth.currentUser);

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _map(credential.user)!;
  }

  @override
  Future<AppUserModel> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _map(credential.user)!;
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _firebaseAuth.sendPasswordResetEmail(email: email);
}
