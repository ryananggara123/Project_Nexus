import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloud_store.dart';

/// [CloudStore] yang memakai Cloud Firestore.
class FirestoreCloudStore implements CloudStore {
  FirestoreCloudStore(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Map<String, dynamic>>> watch(
    String collection, {
    String? field,
    Object? isEqualTo,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    if (field != null) query = query.where(field, isEqualTo: isEqualTo);
    // Hanya data yang sudah dikonfirmasi server yang diteruskan. Snapshot dari
    // cache (misalnya saat offline) dilewati karena aplikasi sudah memiliki
    // salinan lokal sendiri di Hive. `includeMetadataChanges` diperlukan agar
    // peralihan dari cache ke server tetap terkirim walau isinya sama.
    return query
        .snapshots(includeMetadataChanges: true)
        .where((snapshot) => !snapshot.metadata.isFromCache)
        .map((snapshot) => [for (final doc in snapshot.docs) doc.data()]);
  }

  @override
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final snapshot = await _firestore.collection(collection).doc(id).get();
    return snapshot.data();
  }

  @override
  Future<void> set(String collection, String id, Map<String, dynamic> data) =>
      _firestore.collection(collection).doc(id).set(data);

  @override
  Future<void> delete(String collection, String id) =>
      _firestore.collection(collection).doc(id).delete();
}
