import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Warna yang digunakan (bisa diimpor dari file game utama jika Anda mau)
const Color correctGreen = Colors.green;
const Color incorrectRed = Colors.red; // Warna dasar untuk overlay salah
const Color buttonRed = Color(0xFFE57373); // Warna tombol Coba Lagi

/*
--- OVERLAY JAWABAN BENAR ---
*/
class CorrectOverlay extends StatelessWidget {
  final VoidCallback onContinue;

  const CorrectOverlay({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54, // Latar belakang semi-transparan
      child: Center(
        child: Container(
          width: 342, // Sesuai lebar gambar
          height: 416, // Sesuai tinggi gambar
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 30.0,
          ), // Padding disesuaikan
          decoration: BoxDecoration(
            color: correctGreen, // Latar belakang hijau untuk BENAR
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/img/bird_happy.png', // Gambar burung bahagia (asumsi ada)
                height: 120, // Sesuaikan ukuran gambar
                width: 120,
              ),
              const SizedBox(height: 15),
              Text(
                'BENAR!',
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white, // Teks putih
                ),
              ),
              const SizedBox(height: 40), // Jarak ke tombol
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Tombol putih
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50, // Padding disesuaikan
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radius tombol
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Lanjut',
                  style: GoogleFonts.nunito(
                    fontSize: 24, // Ukuran font disesuaikan
                    fontWeight: FontWeight.w900,
                    color: correctGreen, // Warna teks tombol
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
--- OVERLAY JAWABAN SALAH ---
*/
class IncorrectOverlay extends StatelessWidget {
  final VoidCallback onContinue;
  final String correctAnwerText; // Untuk menampilkan jawaban yang benar

  const IncorrectOverlay({
    super.key,
    required this.onContinue,
    required this.correctAnwerText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54, // Latar belakang semi-transparan
      child: Center(
        child: Container(
          width: 342, // Sesuai lebar gambar
          height: 416, // Sesuai tinggi gambar
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          decoration: BoxDecoration(
            color: incorrectRed, // Latar belakang merah untuk SALAH
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gambar burung menangis
              Image.asset(
                'assets/img/bird_crying.png', // Asumsikan Anda memiliki gambar ini
                height: 120, // Sesuaikan ukuran gambar
                width: 120,
              ),
              const SizedBox(height: 15),
              Text(
                'JAWABAN SALAH', // Teks "JAWABAN SALAH"
                style: GoogleFonts.nunito(
                  fontSize: 28, // Ukuran font disesuaikan
                  fontWeight: FontWeight.w900,
                  color: Colors.white, // Teks putih
                ),
              ),
              // Menghapus tampilan jawaban benar di sini, karena tidak ada di desain
              // const SizedBox(height: 10),
              // Text(
              //   'Jawaban benar: $correctAnwerText',
              //   style: GoogleFonts.nunito(
              //     fontSize: 18,
              //     fontWeight: FontWeight.w600,
              //     color: Colors.black54,
              //   ),
              // ),
              const SizedBox(height: 40), // Jarak ke tombol
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonRed, // Warna tombol sesuai desain
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50, // Padding disesuaikan
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Radius tombol
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'COBA LAGI',
                  style: GoogleFonts.nunito(
                    fontSize: 24, // Ukuran font disesuaikan
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}