import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. JANGAN LUPA IMPORT INI
import 'package:flutter/material.dart';

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

      // --- 🔥 STEP PENTING: LOGIN KE FIREBASE AUTH 🔥 ---
      // Kita login secara 'Anonymous' karena siswa cuma pake NIS
      final userCredential = await _auth.signInAnonymously();
      final String newUid = userCredential.user!.uid;
      debugPrint("✅ Berhasil Login ke Firebase! UID Baru: $newUid");

      // --- 🔥 STEP PENTING: UPDATE UID DI DATABASE 🔥 ---
      // Kita harus update 'studentId' di database dengan UID yang baru login ini.
      // Supaya nanti pas main game, game-nya bisa nemu data ini pake UID.
      await _firestore.collection('student_index').doc(nis).update({
        'studentId': newUid,
      });
      debugPrint("✅ Database student_index diupdate dengan UID baru.");

      // STEP 2 — AMBIL DATA SISWA (OPSIONAL, BUAT TAMPILAN AJA)
      final teacherId = indexData['teacherId'];
      final classId = indexData['classId'];
      // Note: studentId di sini mungkin masih yang lama, tapi gak apa2,
      // yang penting di 'student_index' udah kita update.

      return {
        'studentName': indexData['studentName'],
        'nis': indexData['nis'],
        'classId': classId,
        'teacherId': teacherId,
        // Balikin data lain kalo perlu
      };
    } catch (e, stack) {
      debugPrint("🔥 ERROR login student: $e");
      debugPrint("$stack");
      return null;
    }
  }
}
