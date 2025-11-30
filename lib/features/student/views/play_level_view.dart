import 'package:flutter/material.dart';
// --- 1. TAMBAHIN IMPORT INI ---
import 'package:ciloka_app/core/routes/app_routes.dart';

class PlayLevelView extends StatelessWidget {
  // Terima nomor level
  final int levelNumber;

  const PlayLevelView({
    super.key,
    required this.levelNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB0DAFD), // Background biru
      // Pakai Stack biar bisa numpuk-numpuk gambar
      body: Stack(
        children: [
          // 1. Landscape di Bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/img/play_background.png', // <-- GANTI PATH INI
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback kalo gambar nggak ada
                return Container(
                    height: 100, color: Colors.green.shade300);
              },
            ),
          ),

          // 2. Karakter Gede di Tengah
          Positioned(
            // Posisikan di tengah agak ke atas
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/img/character_magnifier.png', // <-- GANTI PATH INI
              height: 250, // Ukuran karakter
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person, size: 250, color: Colors.grey);
              },
            ),
          ),

          // 3. Tombol 'MULAI' Gede
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15, // 15% dari bawah
            left: 50,
            right: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ACCF0),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.4),
              ),
              onPressed: () {
                // --- 2. INI YANG DIUBAH ---
                print('Mulai Level $levelNumber!');
                
                // Langsung navigasi ke GAME PERTAMA
                // Pake 'pushReplacement' biar user nggak bisa 'Back' ke sini
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.gameLatihanMenulis, // <-- Langsung ke game 1
                  arguments: levelNumber, // Kirim nomor level
                );
              },
              child: const Text(
                'MULAI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // 4. Burung & Speech Bubble (Pake SafeArea)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: [
                  // Burung
                  Positioned(
                    top: 20,
                    left: 0,
                    child: Image.asset(
                      'assets/img/level/burung_level.png', // <-- Path lu yang bener
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.flutter_dash,
                            size: 100, color: Colors.blue);
                      },
                    ),
                  ),
                  // Speech Bubble
                  Positioned(
                    top: 50,
                    left: 90,
                    child: _buildSpeechBubble(
                        context, 'Ayo Mulai Level $levelNumber!'),
                  ),
                ],
              ),
            ),
          ),

          // 5. Tombol Back
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2ACCF0),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget buat bikin speech bubble
  Widget _buildSpeechBubble(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFF007B9E),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}