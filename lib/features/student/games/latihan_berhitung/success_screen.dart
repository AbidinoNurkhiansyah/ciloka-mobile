import 'package:flutter/material.dart';

// Warna-warna yang diestimasi dari gambar desain Anda
const Color successLightBlueBg = Color(0xFFC7EDFF);
const Color successYellowBox = Color(0xFFFFF4CC);
const Color successYellowBorder = Color(0xFFFFD966);
const Color successButtonGreen = Color(0xFF7BD9B8);
const Color successTextDarkBlue = Color(0xFF2C3E50);

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: successLightBlueBg,
      body: Stack(
        children: [
          // --- LAYER 1: Background (Pelangi, Balon, Confetti) ---
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/img/success_background.png',
                ), // <-- GANTI PATH INI
                // Sesuai komen lu "mengecilkan", 'contain' adalah cara terbaik
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // --- LAYER 2: Konten Utama ---
          SafeArea(
            child: Column(
              children: [
                // --- Header (Back, Judul, Volume) ---
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Kembali
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),

                      // Judul (Hardcode dari gambar, bisa diganti)
                      Text(
                        'BERHASIL!', // <-- Udah gw ganti
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              blurRadius: 3,
                              color: Colors.black38,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),

                      // Tombol Volume
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1), // Beri jarak ke tengah
                // --- Burung dengan Piala ---
                Image.asset(
                  'assets/img/bird_trophy.png', // <-- GANTI PATH INI
                  height: 200,
                  width: 200,
                  errorBuilder: (c, e, s) =>
                      SizedBox(height: 200, child: Icon(Icons.star, size: 150)),
                ),
                const SizedBox(height: 30),

                // --- Kotak Teks Kuning ---
                Container(
                  width: 300, // Sesuaikan lebar
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: successYellowBox,
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(color: successYellowBorder, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: successYellowBorder.withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Berhasil',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: successTextDarkBlue,
                        ),
                      ),
                      Text(
                        'Kamu Hebat!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: successTextDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Tombol "Selanjutnya" ---
                ElevatedButton(
                  onPressed: () {
                    // Tutup layar ini untuk kembali ke layar game
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successButtonGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Selanjutnya',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(flex: 2), // Beri jarak ke bawah
              ],
            ),
          ),
        ],
      ),
    );
  }
}
