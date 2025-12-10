# Summary Modifikasi Sistem Game

## Perubahan yang Telah Dilakukan

### 1. ✅ Sistem Poin
- **Poin awal**: 10 poin per soal
- **Pengurangan**: Berkurang 2 poin setiap kali salah
- **Minimum**: 0 poin (tidak bisa negatif)
- **Logika**: Jika langsung benar = 10 poin, sekali salah = 8 poin, dua kali salah = 6 poin, dst.

**File yang dimodifikasi:**
- `lib/features/student/games/latihan_menulis/latihan_menulis_view.dart`
- `lib/features/student/games/latihan_mengeja/latihan_mengeja_view.dart`
- `lib/features/student/games/latihan_berhitung/latihan_berhitung_view.dart`

### 2. ✅ Notifikasi Suara
- **Audio benar**: `assets/audio/correct.mp3`
- **Audio salah**: `assets/audio/wrong.mp3`
- Menggunakan package `audioplayers`

**Catatan**: Anda perlu menambahkan file audio ke folder `assets/audio/`:
- `correct.mp3` - suara ketika jawaban benar
- `wrong.mp3` - suara ketika jawaban salah

### 3. ✅ Update Leaderboard & Firestore
**Model yang diupdate:**
- `StudentModel` - ditambahkan field `totalPoints`
- `StudentRankModel` - ditambahkan field `totalPoints`
- `_StudentEntry` (di LeaderboardStudentView) - ditambahkan field `totalPoints`

**Service yang ditambahkan:**
- `StudentService.addPoints()` - method untuk menambahkan poin ke Firestore

**Firestore Collection `student_index`:**
- Field baru: `totalPoints` (int)
- Sorting leaderboard: berdasarkan `totalPoints` (descending)

**UI Leaderboard:**
- Podium menampilkan total points
- List item menampilkan level + points

### 4. ✅ Update Level Images (3, 4, 5)
**File yang dimodifikasi:**
- `lib/features/student/views/home_student_view.dart`

**Logika:**
- Level 1-5: menggunakan `assets/img/games/level{X}.png`
- Level > 5: fallback ke `level3.png`

**File yang dibutuhkan:**
- `assets/img/games/level3.png` ✅
- `assets/img/games/level4.png` ⚠️ (perlu ditambahkan)
- `assets/img/games/level5.png` ⚠️ (perlu ditambahkan)

## Yang Perlu Dilakukan Selanjutnya

### 1. Tambahkan File Audio
Buat atau download file audio dan letakkan di:
```
assets/audio/correct.mp3
assets/audio/wrong.mp3
```

Anda bisa menggunakan:
- Sound effect gratis dari freesound.org
- Generate menggunakan AI (elevenlabs.io, etc)
- Rekam sendiri

### 2. Tambahkan Gambar Island
Tambahkan file gambar untuk level 4 dan 5:
```
assets/img/games/level4.png
assets/img/games/level5.png
```

### 3. Jalankan Flutter Pub Get
```bash
flutter pub get
```

### 4. Test Aplikasi
- Test sistem poin (coba jawab benar/salah)
- Test audio (pastikan suara keluar)
- Test leaderboard (cek apakah points muncul)
- Test level images (cek apakah gambar level 3-5 muncul)

## Dependencies yang Ditambahkan
- `audioplayers` - untuk memutar sound effects

## Struktur Data Firestore

### Collection: `student_index`
```json
{
  "studentId": "uid_firebase",
  "studentName": "Nama Siswa",
  "photoUrl": "url_foto",
  "currentLevel": 1,
  "levelProgress": 0.0,
  "totalPoints": 0,  // ← FIELD BARU
  "classId": "class_id",
  "teacherId": "teacher_id",
  "grade": "1",
  "className": "A"
}
```

## Cara Kerja Sistem Poin

1. **Saat memulai soal**: `currentPoints = 10`
2. **Saat jawab salah**: `currentPoints = (currentPoints - 2).clamp(0, 10)`
3. **Saat jawab benar**: 
   - Poin ditambahkan ke Firestore: `totalPoints += currentPoints`
   - Audio "correct" diputar
4. **Saat reset/soal baru**: `currentPoints = 10` (reset)

## Troubleshooting

### Audio tidak keluar?
- Pastikan file audio ada di `assets/audio/`
- Pastikan `pubspec.yaml` sudah include `assets/audio/`
- Jalankan `flutter clean` dan `flutter pub get`

### Points tidak tersimpan?
- Cek koneksi internet
- Cek Firebase rules (pastikan write access diizinkan)
- Cek console log untuk error

### Gambar level tidak muncul?
- Pastikan file PNG ada di `assets/img/games/`
- Pastikan nama file sesuai: `level3.png`, `level4.png`, `level5.png`
