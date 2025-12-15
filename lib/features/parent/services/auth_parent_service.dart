import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthParentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthParentService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  Future<Map<String, dynamic>?> loginParent({
    required String parentName,
    required String nis,
  }) async {
    try {
      // 1. Verifikasi kredensial di collectionGroup('students')
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

      // 2. Login Anonymous agar session terdeteksi
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        await _auth.signInAnonymously();
      }

      // 3. Fetch Data Lengkap dari 'student_index' (mengandung classId, teacherId)
      final indexDoc = await _firestore
          .collection('student_index')
          .doc(nis)
          .get();

      if (indexDoc.exists) {
        final data = indexDoc.data();
        debugPrint(
          '✅ Login parent berhasil (from index): ${data?['studentName']}',
        );
        return data;
      } else {
        // Fallback jika tidak ada di index (harusnya ada jika data konsisten)
        debugPrint('⚠️ Data di student_index tidak ditemukan untuk NIS: $nis');
        // Return data dari subcollection students sebagai fallback (mungkin tidak lengkap)
        return snapshot.docs.first.data();
      }
    } catch (e, stack) {
      debugPrint('⚠️ Error loginParent: $e');
      debugPrint('$stack');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchByNis(String nis) async {
    try {
      // Ensure user is signed in
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      // Fetch langsung ke student_index karna sudah terverifikasi sebelumnya
      final indexDoc = await _firestore
          .collection('student_index')
          .doc(nis)
          .get();

      if (indexDoc.exists) {
        return indexDoc.data();
      }

      // Fallback search jika tidak ada di doc ID (legacy support / data issue)
      final snapshot = await _firestore
          .collectionGroup('students')
          .where('nis', isEqualTo: nis)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }

      return null;
    } catch (e) {
      debugPrint("❌ Error fetchByNis: $e");
      return null;
    }
  }
}
