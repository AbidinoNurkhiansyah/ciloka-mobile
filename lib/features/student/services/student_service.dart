import 'package:ciloka_app/features/student/models/user_student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final _firestore = FirebaseFirestore.instance;

  // --- 1. FUNGSI BACA DATA (STREAM) DARI student_index ---
  // Fungsi ini akan "mendengarkan" perubahan di student_index.
  // Jadi kalau level berubah, tampilan Home otomatis update.
  Stream<StudentModel?> streamStudentProfile(String uid) {
    print("DEBUG STREAM: Mencari data untuk UID: $uid di student_index...");

    return _firestore
        .collection('student_index') // Target koleksi: student_index
        .where(
          'studentId',
          isEqualTo: uid,
        ) // Cari dokumen yg punya studentId ini
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            print(
              "DEBUG STREAM: ❌ Data tidak ditemukan di student_index untuk UID: $uid",
            );
            return null;
          }

          // Data ketemu!
          final doc = snapshot.docs.first;
          final data = doc.data();

          print(
            "DEBUG STREAM: ✅ Data ditemukan! Level saat ini: ${data['currentLevel']}",
          );

          // Convert data Firestore ke StudentModel
          return StudentModel.fromFirestore(data, doc.id);
        });
  }

  // --- 2. FUNGSI UPDATE PROFIL (Nama, Foto, dll) ---
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    // Cari dulu dokumennya pake Query (karena kita nggak tau ID dokumennya/NIS-nya)
    final query = await _firestore
        .collection('student_index')
        .where('studentId', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // Kalau ketemu, update dokumen tersebut
      await query.docs.first.reference.update(data);
    } else {
      print("Error updateProfile: Dokumen tidak ditemukan untuk UID $uid");
    }
  }

  // --- 3. FUNGSI UPDATE LEVEL (Dipanggil dari Game) ---
  // Ini buat ngebuka level selanjutnya di student_index
  Future<void> unlockNextLevel(String uid, int newLevel) async {
    print(
      "DEBUG UNLOCK: Mencoba update level ke $newLevel di student_index...",
    );

    final query = await _firestore
        .collection('student_index')
        .where('studentId', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // Update field 'currentLevel' di dokumen yang sama
      // Firestore otomatis nambahin field ini kalau belum ada
      await query.docs.first.reference.update({
        'currentLevel': newLevel,
        'levelProgress': 0.0, // Reset progress bar kalau naik level
      });
      print("DEBUG UNLOCK: ✅ Berhasil update level di student_index!");
    } else {
      print("DEBUG UNLOCK: ❌ Gagal! Dokumen tidak ditemukan di student_index.");
    }
  }

  // --- 4. FUNGSI UPDATE PROGRESS BAR (Opsional) ---
  Future<void> updateLevelProgress(
    String uid,
    int currentLevel,
    double progress,
  ) async {
    final query = await _firestore
        .collection('student_index')
        .where('studentId', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'currentLevel': currentLevel,
        'levelProgress': progress,
      });
    }
  }
}
