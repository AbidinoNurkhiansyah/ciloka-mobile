import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. JANGAN LUPA IMPORT INI
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStudentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth; // <-- 2. Tambah FirebaseAuth

  // Update Constructor
  AuthStudentService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Ganti nama jadi loginStudent biar gak bingung
  Future<Map<String, dynamic>?> loginStudent({
    required String studentName,
    required String nis,
  }) async {
    try {
      // STEP 1 — CARI INDEX LOGIN
      final indexDoc = await _firestore
          .collection('student_index')
          .doc(nis)
          .get();

      if (!indexDoc.exists) {
        debugPrint("❌ NIS tidak ditemukan di student_index");
        return null;
      }

      final indexData = indexDoc.data()!;

      // Cek apakah nama cocok (Case insensitive biar aman)
      if (indexData['studentName'].toString().toLowerCase() !=
          studentName.toLowerCase()) {
        debugPrint("❌ Nama siswa tidak cocok!");
        return null;
      }

      // --- 🔥 STEP PENTING: LOGIN ANONYMOUS TAPI UID TETAP 🔥 ---
      final prefs = await SharedPreferences.getInstance();
      String? savedUid = prefs.getString('student_uid_$nis');
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        savedUid = currentUser.uid;
        debugPrint('✅ Sudah ada user anonymous aktif, pakai UID: $savedUid');
      } else {
        final userCredential = await _auth.signInAnonymously();
        savedUid = userCredential.user!.uid;
        debugPrint('✅ Login anonymous baru, UID: $savedUid');
      }
      // Tidak perlu cek (savedUid != null) karena sudah pasti bukan null
      debugPrint("✅ Berhasil Login ke Firebase! UID: $savedUid");

      // --- 🔥 STEP PENTING: UPDATE UID DI DATABASE 🔥 ---
      await _firestore.collection('student_index').doc(nis).update({
        'studentId': savedUid,
      });
      debugPrint("✅ Database student_index diupdate dengan UID baru.");

      // STEP 2 — AMBIL DATA SISWA (OPSIONAL, BUAT TAMPILAN AJA)
      final teacherId = indexData['teacherId'];
      final classId = indexData['classId'];
      final photoUrl = indexData['photoUrl'];
      final grade = indexData['grade'];
      final className = indexData['className'];

      return {
        'studentName': indexData['studentName'],
        'nis': indexData['nis'],
        'photoUrl': photoUrl,
        'classId': classId,
        'teacherId': teacherId,
        'studentId': savedUid,
        'grade': grade,
        'className': className,
        // Balikin data lain kalo perlu
      };
    } catch (e, stack) {
      debugPrint("🔥 ERROR login student: $e");
      debugPrint("$stack");
      return null;
    }
  }
}
