import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthParentService {
  final FirebaseFirestore _firestore;

  AuthParentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> loginParent({
    required String parentName,
    required String nis,
  }) async {
    try {
      // Cari di semua subcollection bernama "students"
      final snapshot = await _firestore
          .collectionGroup('students')
          .where('nis', isEqualTo: nis)
          .where('parentName', isEqualTo: parentName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint(
          '❌ Tidak ditemukan siswa dengan NIS dan nama orang tua ini.',
        );
        return null;
      }

      final studentData = snapshot.docs.first.data();

      debugPrint('✅ Login parent berhasil: ${studentData['studentName']}');
      return studentData;
    } catch (e, stack) {
      debugPrint('⚠️ Error loginParent: $e');
      debugPrint('$stack');
      rethrow;
    }
  }
}
