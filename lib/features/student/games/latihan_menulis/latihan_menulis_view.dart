import 'package:flutter/material.dart';
import 'dart:ui';

// --- IMPORT ROUTES ---
import 'package:ciloka_app/core/routes/app_routes.dart';

// --- 1. IMPORT FEEDBACK OVERLAY ---
import '../../../../widgets/game_feedback_overlay.dart';

class LatihanMenulisView extends StatefulWidget { 
  final int levelNumber;

  const LatihanMenulisView({
    Key? key,
    required this.levelNumber,
  }) : super(key: key);

  @override
  State<LatihanMenulisView> createState() => _LatihanMenulisViewState();
}

class _LatihanMenulisViewState extends State<LatihanMenulisView> {
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  final GlobalKey _papanKey = GlobalKey();
  List<Offset?> points = [];

  // --- 2. TAMBAHIN STATE BUAT OVERLAY ---
  int status = 0; // 0=normal, 2=benar, 3=salah

  String _getQuestion() {
    if (widget.levelNumber == 1) {
      return "Setiap pagi, sebelum berangkat sekolah,\n"
          "Rina selalu membantu ibunya ____ bunga di halaman.";
    } else if (widget.levelNumber == 2) {
      return "Ayah sedang ____ koran di teras.";
    }
    return "Soal tidak ditemukan";
  }

  String _getAnswer() {
    if (widget.levelNumber == 1) {
      return "MENYIRAM";
    } else if (widget.levelNumber == 2) {
      return "MEMBACA";
    }
    return "ERROR";
  }

  // --- 3. CEK JAWABAN (DIUBAH JADI PAKE STATE) ---
  void cekJawaban() {
    // TODO: Implementasi handwriting recognition di sini
    
    // Untuk sekarang, kita anggap aja jawabannya SELALU BENAR
    bool jawabanBenar = true; 
    
    if (jawabanBenar) {
      // GANTI showDialog JADI setState
      setState(() {
        status = 2; // BENAR
      });
    } else {
      setState(() {
        status = 3; // SALAH
      });
    }
  }

  // --- 4. BIKIN FUNGSI NAVIGASI & RESET ---
  void _goToNextGame() {
    // Hapus tulisan & pindah ke game 2
    hapusTulisannya();
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.gameLatihanMengeja, // <-- Pindah ke Game 2
      arguments: widget.levelNumber, // Kirim level number
    );
  }

  void _tryAgain() {
    setState(() {
      status = 0; // Balik normal
      hapusTulisannya();
    });
  }


  void hapusTulisannya() {
    setState(() => points.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.primary, 
      body: Stack( // <-- 5. BODY DIUBAH JADI STACK
        children: [
          // --- KONTEN UTAMA ---
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                // ... (APPBAR, SOAL, PAPAN TULIS, TOMBOL HAPUS & CEK) ...
                // --- 5. APPBAR DIBENERIN (Pake SafeArea) ---
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAppBarButton(
                        context, 
                        icon: Icons.arrow_back_ios_new_rounded, 
                        onTap: () => Navigator.pop(context)
                      ),
                      Text(
                        "LATIHAN MENULIS",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      _buildAppBarButton(
                        context, 
                        icon: Icons.volume_up_rounded, 
                        onTap: () { /* TODO: Suara */ }
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // --- 6. SOAL DIBIKIN DINAMIS ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getQuestion(), // <-- Pake fungsi
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black, height: 1.5),
                      ),
                      SizedBox(height: 10),
                      Image.asset("assets/img/rina.webp", height: 120), // <-- GANTI PATH INI
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // --- 7. PAPAN TULIS DENGAN HURUF PUTUS-PUTUS ---
                Container(
                  key: _papanKey,
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A6B35), // Warna papan tulis
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF5D4037), // Border coklat
                      width: 10,
                    ),
                  ),
                  // --- Pake Stack buat nimpuk ---
                  child: Stack(
                    children: [
                      // LAPISAN 1: HURUF PUTUS-PUTUS (JAWABAN)
                      _buildDottedText(_getAnswer()),

                      // LAPISAN 2: CANVAS BUAT NULIS
                      GestureDetector(
                        onPanUpdate: (details) {
                          RenderBox renderBox =
                              _papanKey.currentContext!.findRenderObject() as RenderBox;
                          final localPosition = renderBox.globalToLocal(
                            details.globalPosition,
                          );

                          // Batasi coretan hanya di dalam papan
                          if (localPosition.dx >= 0 &&
                              localPosition.dx <= renderBox.size.width &&
                              localPosition.dy >= 0 &&
                              localPosition.dy <= renderBox.size.height) {
                            setState(() {
                              points.add(localPosition);
                            });
                          }
                        },
                        onPanEnd: (details) => setState(() => points.add(null)),
                        child: CustomPaint(
                          painter: DrawingPainter(points),
                          size: Size.infinite,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                TextButton(
                  onPressed: hapusTulisannya,
                  child: Text(
                    "Hapus Tulisan",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                SizedBox(height: 25),

                ElevatedButton(
                  onPressed: cekJawaban,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff35D46A),
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Cek Jawaban",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          // --- 6. LAYER OVERLAY DITAMBAHIN DI SINI ---
          if (status == 2)
            CorrectOverlay(
              onContinue: _goToNextGame, // Pindah ke Game 2
            ),

          if (status == 3)
            IncorrectOverlay(
              correctAnwerText: _getAnswer(),
              onContinue: _tryAgain, // Coba lagi
            ),
        ],
      ),
    );
  }

  // --- WIDGET BARU BUAT APPBAR ---
  Widget _buildAppBarButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
  
  // --- WIDGET BARU BUAT HURUF PUTUS-PUTUS ---
  Widget _buildDottedText(String answer) {
    return Center(
      child: Text(
        answer,
        style: TextStyle(
          // TODO: Kalo lu punya font 'putus-putus' (dashed/dotted),
          // ganti 'fontFamily' di bawah ini.
          // fontFamily: 'DottedFont', 
          
          // Kalo nggak punya, kita akalin pake warna transparan
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.3), // Bikin transparan
          letterSpacing: 2, // Kasih jarak dikit
        ),
      ),
    );
  }
}

// 🎨 Painter tetap sama
class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}