import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/payment.dart';

class PaymentRepository {
  PaymentRepository(this._db, this._functions);
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  /// SCAFFOLD: create a (stub) payment that auto-succeeds, returns its id.
  Future<String> createPayment({
    required String communityId,
    required int amountCents,
    String currency = 'USD',
  }) async {
    final callable = _functions.httpsCallable('createPayment');
    final r = await callable.call<Map<String, dynamic>>({
      'communityId': communityId,
      'amountCents': amountCents,
      'currency': currency,
    });
    return r.data['paymentId'] as String;
  }

  Stream<List<Payment>> watchForUser(String cid, String uid) => _db
      .collection('communities')
      .doc(cid)
      .collection('payments')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((q) => q.docs
          .map((d) => Payment.fromJson({...d.data(), 'id': d.id}))
          .toList());
}

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  ),
);

final myPaymentsProvider = StreamProvider<List<Payment>>((ref) {
  final cid = ref.watch(currentCommunityIdProvider);
  final uid = ref.watch(currentUidProvider);
  if (cid == null || uid == null) return Stream.value(const []);
  return ref.watch(paymentRepositoryProvider).watchForUser(cid, uid);
});
