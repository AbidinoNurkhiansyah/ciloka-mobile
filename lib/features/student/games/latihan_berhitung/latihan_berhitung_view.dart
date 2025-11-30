import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import file widget bantuan
import '../../../../widgets/game_feedback_overlay.dart';
import 'success_screen.dart';

// --- DEFINISI WARNA ---
const Color primaryBlue = Color(0xFFADD8E6);
const Color lightGreen = Color(0xFFA5D6A7);
const Color lightRed = Color(0xFFFFAB91);
const Color lightOrange = Color(0xFFFFCC80);
const Color lightPurple = Color(0xFFB39DDB);
const Color correctGreen = Colors.green;
const Color incorrectRed = Colors.red;

// --- FUNGSI TEXT STYLE ---
TextStyle getStrokeTextStyle(
  Color strokeColor,
  Color textColor,
  double fontSize,
) {
  const double strokeOffset = 2.0;
  const List<Shadow> strokeShadows = [
    Shadow(
      offset: Offset(strokeOffset, strokeOffset),
      blurRadius: 0.0,
      color: Colors.white,
    ),
    Shadow(
      offset: Offset(-strokeOffset, strokeOffset),
      blurRadius: 0.0,
      color: Colors.white,
    ),
    Shadow(
      offset: Offset(strokeOffset, -strokeOffset),
      blurRadius: 0.0,
      color: Colors.white,
    ),
    Shadow(
      offset: Offset(-strokeOffset, -strokeOffset),
      blurRadius: 0.0,
      color: Colors.white,
    ),
    Shadow(
      offset: Offset(strokeOffset, 0),
      blurRadius: 0.0,
      color: Colors.white,
    ),
    Shadow(
      offset: Offset(-strokeOffset, 0),
      blurRadius: 0.0,
      color: Colors.white,
    ),
    Shadow(
      offset: Offset(0, strokeOffset),
      blurRadius: 0.0,
      color: Colors.white,
    ),
    Shadow(
      offset: Offset(0, -strokeOffset),
      blurRadius: 0.0,
      color: Colors.white,
    ),
  ];

  return GoogleFonts.nunito(
    fontSize: fontSize,
    fontWeight: FontWeight.w900,
    color: textColor,
    shadows: strokeShadows,
  );
}

// --- CLASS UTAMA ---
class LatihanBerhitungView extends StatefulWidget {
  final int levelNumber;

  const LatihanBerhitungView({super.key, required this.levelNumber});

  @override
  State<LatihanBerhitungView> createState() => _LatihanBerhitungViewState();
}

class _LatihanBerhitungViewState extends State<LatihanBerhitungView> {
  List<int> numbers = [];
  late int correctNumber;
  int? selectedNumber;
  int status = 0; // 0: Main, 1: Dipilih, 2: Benar, 3: Salah

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    // Logic soal berdasarkan level
    if (widget.levelNumber == 1) {
      numbers = [2345, 2375, 2550, 2874];
    } else if (widget.levelNumber == 2) {
      numbers = [5100, 5050, 5005, 5105];
    } else {
      numbers = [9999, 1000, 5000, 7500];
    }

    correctNumber = numbers.reduce(max);
    numbers.shuffle();
    selectedNumber = null;
    status = 0;
    setState(() {});
  }

  void _selectNumber(int chosenNumber) {
    if (status > 1)
      return; // Kalo udah ada hasil (benar/salah), gak bisa klik lagi
    setState(() {
      selectedNumber = chosenNumber;
      status = 1;
    });
  }

  void _checkAnswer() {
    if (selectedNumber == null) return;
    setState(() {
      if (selectedNumber == correctNumber) {
        status = 2; // Jawaban Benar -> Muncun Overlay Benar
      } else {
        status = 3; // Jawaban Salah -> Muncul Overlay Salah
      }
    });
  }

  // --- FUNGSI UPDATE LEVEL KE FIREBASE (STUDENT_INDEX) ---
  void _navigateToSuccessScreen() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        int newLevel = widget.levelNumber + 1;

        print("DEBUG: Mencari user di student_index dengan ID: $uid");

        // 1. Cari dokumen di student_index berdasarkan studentId (UID)
        final querySnapshot = await FirebaseFirestore.instance
            .collection('student_index')
            .where('studentId', isEqualTo: uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // 2. Ketemu! Ambil referensi dokumennya
          final docRef = querySnapshot.docs.first.reference;

          // 3. Update level di dokumen tersebut
          await docRef.update({'currentLevel': newLevel});

          print('DEBUG: Sukses update level ke $newLevel di student_index!');
        } else {
          print(
            "DEBUG: GAGAL! Tidak ada data siswa di student_index dengan UID ini.",
          );
        }
      } else {
        print("DEBUG: GAGAL! UID user null (Belum login).");
      }
    } catch (e) {
      print('DEBUG ERROR: $e');
    }

    // Pindah ke halaman Sukses
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuccessScreen()),
    ).then((_) {
      // Pas balik dari halaman sukses, tutup halaman game ini (balik ke Peta)
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // Widget Overlay Benar/Salah
  Widget _buildFeedbackOverlay() {
    if (status == 2) {
      return CorrectOverlay(
        onContinue: () {
          _navigateToSuccessScreen();
        },
      );
    } else if (status == 3) {
      return IncorrectOverlay(
        correctAnwerText: "$correctNumber",
        onContinue: () {
          _generateNewQuestion();
        },
      );
    }
    return Container(); // Kalo status 0 atau 1, gak nampilin apa-apa
  }

  // Widget Tombol Angka
  Widget _buildNumberButton(int number, Color baseColor) {
    bool isCurrentlySelected = selectedNumber == number;
    Color buttonColor = baseColor;
    Color borderColor = Colors.transparent;
    double borderWidth = 0.0;

    if (status == 1 && isCurrentlySelected) {
      borderColor = correctGreen.withOpacity(0.7);
      borderWidth = 4.0;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(15.0),
        elevation: 5,
        child: InkWell(
          onTap: (status == 0 || status == 1)
              ? () => _selectNumber(number)
              : null,
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Text(
              number.toString(),
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- TAMPILAN UTAMA (BUILD) ---
  @override
  Widget build(BuildContext context) {
    List<Color> colors = [lightGreen, lightRed, lightOrange, lightPurple];

    bool isCheckButtonEnabled =
        selectedNumber != null && (status == 0 || status == 1);
    Color checkButtonBackgroundColor = isCheckButtonEnabled
        ? correctGreen
        : Colors.grey;
    Color checkButtonBorderColor = isCheckButtonEnabled
        ? correctGreen
        : Colors.grey;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Flexible(
                        child: Text(
                          'LATIHAN BERHITUNG',
                          style: GoogleFonts.nunito(
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Judul Soal
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Pilih Angka Terbesar',
                    style: getStrokeTextStyle(
                      Colors.white,
                      Colors.deepOrange,
                      32,
                    ),
                  ),
                ),

                // Grid Angka
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: numbers.length,
                      itemBuilder: (context, index) {
                        return _buildNumberButton(
                          numbers[index],
                          colors[index % colors.length],
                        );
                      },
                    ),
                  ),
                ),

                // Gambar Burung
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    'assets/img/bird_wizard.png',
                    height: 100,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.flutter_dash,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Tombol Cek Jawaban
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: isCheckButtonEnabled ? _checkAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: checkButtonBackgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: checkButtonBorderColor,
                          width: 2,
                        ),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Cek Jawaban',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Tanah
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/ground.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlay (Benar/Salah)
          _buildFeedbackOverlay(),
        ],
      ),
    );
  }
}
