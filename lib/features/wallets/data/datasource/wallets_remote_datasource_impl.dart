import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowsy/core/error_handling/app_exceptions.dart';
import 'package:flowsy/features/wallets/data/datasource/wallets_remote_datasource.dart';
import 'package:flowsy/features/wallets/data/models/allocation_model.dart';
import 'package:flowsy/features/wallets/data/models/money_transaction_model.dart';
import 'package:flowsy/features/wallets/data/models/wallet_model.dart';
import 'package:flowsy/features/wallets/domain/entities/money_transaction.dart';

/// Firestore layout (all scoped under the signed-in user):
///   users/{uid}/wallets/{walletId}
///   users/{uid}/wallets/{walletId}/allocations/{allocationId}
///   users/{uid}/transactions/{transactionId}   (flat, walletId as a field)
class WalletsRemoteDataSourceImpl implements WalletsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WalletsRemoteDataSourceImpl(this._firestore, this._auth);

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const NotAuthenticatedException();
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _walletsCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('wallets');

  DocumentReference<Map<String, dynamic>> _walletDoc(
    String uid,
    String walletId,
  ) => _walletsCol(uid).doc(walletId);

  CollectionReference<Map<String, dynamic>> _allocationsCol(
    String uid,
    String walletId,
  ) => _walletDoc(uid, walletId).collection('allocations');

  CollectionReference<Map<String, dynamic>> _transactionsCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('transactions');

  @override
  Stream<List<WalletModel>> watchWallets() {
    final uid = _requireUid();
    return _walletsCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => WalletModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<WalletModel> watchWallet(String walletId) {
    final uid = _requireUid();
    return _walletDoc(uid, walletId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) throw StateError('Wallet not found');
      return WalletModel.fromMap(snap.id, data);
    });
  }

  @override
  Stream<List<AllocationModel>> watchAllocations(String walletId) {
    final uid = _requireUid();
    return _allocationsCol(uid, walletId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AllocationModel.fromMap(d.id, walletId, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<MoneyTransactionModel>> watchRecentTransactions({
    int limit = 20,
  }) {
    final uid = _requireUid();
    return _transactionsCol(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MoneyTransactionModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<MoneyTransactionModel>> watchWalletTransactions(String walletId) {
    final uid = _requireUid();
    return _transactionsCol(uid)
        .where('walletId', isEqualTo: walletId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MoneyTransactionModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> createWallet({
    required String name,
    required int colorValue,
  }) async {
    final uid = _requireUid();
    final ref = _walletsCol(uid).doc();
    final model = WalletModel(
      id: ref.id,
      name: name,
      colorValue: colorValue,
      balance: 0,
      createdAt: DateTime.now(),
    );
    await ref.set(model.toMap());
  }

  @override
  Future<void> updateWallet({
    required String walletId,
    required String name,
    required int colorValue,
  }) async {
    final uid = _requireUid();
    await _walletDoc(
      uid,
      walletId,
    ).update({'name': name, 'colorValue': colorValue});
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    final uid = _requireUid();
    final allocations = await _allocationsCol(uid, walletId).get();
    final batch = _firestore.batch();
    for (final doc in allocations.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_walletDoc(uid, walletId));
    await batch.commit();
  }

  @override
  Future<void> createAllocation({
    required String walletId,
    required String label,
    required double amount,
    String? note,
  }) async {
    final uid = _requireUid();
    final ref = _allocationsCol(uid, walletId).doc();
    final model = AllocationModel(
      id: ref.id,
      walletId: walletId,
      label: label,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );
    await ref.set(model.toMap());
  }

  @override
  Future<void> updateAllocation({
    required String walletId,
    required String allocationId,
    required String label,
    required double amount,
    String? note,
  }) async {
    final uid = _requireUid();
    await _allocationsCol(uid, walletId).doc(allocationId).update({
      'label': label,
      'amount': amount,
      'note': note,
    });
  }

  @override
  Future<void> deleteAllocation({
    required String walletId,
    required String allocationId,
  }) async {
    final uid = _requireUid();
    await _allocationsCol(uid, walletId).doc(allocationId).delete();
  }

  @override
  Future<void> topUpWallet({
    required String walletId,
    required double amount,
    String? note,
  }) async {
    final uid = _requireUid();
    final walletRef = _walletDoc(uid, walletId);
    final txnRef = _transactionsCol(uid).doc();

    await _firestore.runTransaction((txn) async {
      final walletSnap = await txn.get(walletRef);
      final walletData = walletSnap.data() ?? const <String, dynamic>{};

      txn.update(walletRef, {'balance': FieldValue.increment(amount)});

      final model = MoneyTransactionModel(
        id: txnRef.id,
        walletId: walletId,
        walletName: walletData['name'] as String? ?? '',
        type: TransactionType.topUp,
        amount: amount,
        note: note,
        createdAt: DateTime.now(),
      );
      txn.set(txnRef, model.toMap());
    });
  }

  @override
  Future<void> spendFromWallet({
    required String walletId,
    required double amount,
    String? allocationId,
    String? note,
  }) async {
    final uid = _requireUid();
    final walletRef = _walletDoc(uid, walletId);
    final allocationRef = allocationId != null
        ? _allocationsCol(uid, walletId).doc(allocationId)
        : null;
    final txnRef = _transactionsCol(uid).doc();

    await _firestore.runTransaction((txn) async {
      final walletSnap = await txn.get(walletRef);
      final walletData = walletSnap.data() ?? const <String, dynamic>{};
      final currentBalance = (walletData['balance'] as num?)?.toDouble() ?? 0;
      if (currentBalance < amount) throw const InsufficientFundsException();

      String? allocationLabel;
      if (allocationRef != null) {
        final allocSnap = await txn.get(allocationRef);
        final allocData = allocSnap.data() ?? const <String, dynamic>{};
        final currentAllocAmount =
            (allocData['amount'] as num?)?.toDouble() ?? 0;
        if (currentAllocAmount < amount) {
          throw const InsufficientFundsException();
        }
        allocationLabel = allocData['label'] as String?;
        txn.update(allocationRef, {'amount': FieldValue.increment(-amount)});
      }

      txn.update(walletRef, {'balance': FieldValue.increment(-amount)});

      final model = MoneyTransactionModel(
        id: txnRef.id,
        walletId: walletId,
        walletName: walletData['name'] as String? ?? '',
        allocationId: allocationId,
        allocationLabel: allocationLabel,
        type: TransactionType.spend,
        amount: amount,
        note: note,
        createdAt: DateTime.now(),
      );
      txn.set(txnRef, model.toMap());
    });
  }
}
