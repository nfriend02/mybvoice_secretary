import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore CRUD service.
///
/// Documents always carry `createdAt` and `status`. List queries that combine
/// those fields are backed by `firestore.indexes.json`.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  /// Example helper used by [UploadPage] for PDF metadata.
  Future<void> uploadFileMetadata(
    String fileName,
    String status, {
    Map<String, dynamic> extra = const {},
  }) async {
    await _db.collection('uploads').add({
      'fileName': fileName,
      'kind': 'upload',
      'title': fileName,
      'body': extra['body'] ?? fileName,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      ...extra,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUploads() {
    return _db
        .collection('uploads')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Create a document. Auto-sets `createdAt` and default `status`.
  Future<String> addData(String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': data['status'] ?? 'active',
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getData(
    String collection, {
    int? limit,
    String status = 'active',
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection(collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true);
    if (limit != null) {
      query = query.limit(limit.clamp(1, 100));
    }
    return query.snapshots();
  }

  Future<void> updateData(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(collection).doc(docId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteData(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  /// Client-safe page. Falls back to an unordered read if the composite
  /// index is still building.
  Future<List<Map<String, dynamic>>> listPage({
    required String collection,
    String? status = 'active',
    int limit = 10,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection(collection);
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      final snap = await query
          .orderBy('createdAt', descending: true)
          .limit(limit.clamp(1, 100))
          .get();
      return snap.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .toList();
    } catch (e, st) {
      debugPrint('FirestoreService.listPage error: $e\n$st');
      final snap = await _db.collection(collection).limit(100).get();
      final rows =
          snap.docs
              .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
              .where(
                (row) =>
                    status == null ||
                    (row['status'] as String? ?? 'active') == status,
              )
              .toList()
            ..sort(
              (a, b) =>
                  createdAtMs(b['createdAt'])
                      .compareTo(createdAtMs(a['createdAt'])),
            );
      return rows.take(limit).toList();
    }
  }

  static int createdAtMs(dynamic value) {
    if (value == null) return 0;
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    if (value is String) {
      return DateTime.tryParse(value)?.millisecondsSinceEpoch ?? 0;
    }
    return 0;
  }
}
