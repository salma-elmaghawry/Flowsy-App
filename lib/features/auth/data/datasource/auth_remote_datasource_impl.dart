import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:wallet_split/core/error_handling/app_exceptions.dart';
import 'package:wallet_split/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:wallet_split/features/auth/data/models/app_user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

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

  @override
  Future<void> deleteAccount({required String password}) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null) throw const NotAuthenticatedException();

    // Firebase requires a recent sign-in before deleting an account.
    await user.reauthenticateWithCredential(
      fb.EmailAuthProvider.credential(email: email, password: password),
    );

    await _deleteUserData(user.uid);
    await user.delete();
  }

  /// Deletes users/{uid} and all of its sub-collections
  /// (wallets, wallets/*/allocations, transactions).
  Future<void> _deleteUserData(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final refs = <DocumentReference<Map<String, dynamic>>>[];

    final wallets = await userDoc.collection('wallets').get();
    for (final wallet in wallets.docs) {
      final allocations = await wallet.reference
          .collection('allocations')
          .get();
      refs.addAll(allocations.docs.map((d) => d.reference));
      refs.add(wallet.reference);
    }
    final transactions = await userDoc.collection('transactions').get();
    refs.addAll(transactions.docs.map((d) => d.reference));
    refs.add(userDoc);

    // Firestore batches are capped at 500 writes.
    const chunkSize = 450;
    for (var i = 0; i < refs.length; i += chunkSize) {
      final batch = _firestore.batch();
      for (final ref in refs.skip(i).take(chunkSize)) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }
}
