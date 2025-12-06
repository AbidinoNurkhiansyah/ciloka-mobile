import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  return TextStyle(
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

  // --- SOAL PER LEVEL (maksimal 5) ---
  void _generateNewQuestion() {
    switch (widget.levelNumber) {
      case 1:
        numbers = [12, 25, 9, 18];
        break;
      case 2:
        numbers = [145, 132, 167, 120];
        break;
      case 3:
        numbers = [2345, 2375, 2550, 2874];
        break;
      case 4:
        numbers = [5100, 5050, 5005, 5105];
        break;
      case 5:
        numbers = [9999, 1000, 7500, 8750];
        break;
      default:
        numbers = [5, 10, 3, 8];
    }

    correctNumber = numbers.reduce(max);
    numbers.shuffle();
    selectedNumber = null;
    status = 0;
    setState(() {});
  }

  void _selectNumber(int chosenNumber) {
    if (status > 1) return; // kalau sudah benar/salah, ga bisa pilih lagi
    setState(() {
      selectedNumber = chosenNumber;
      status = 1;
    });
  }

  void _checkAnswer() {
    if (selectedNumber == null) return;
    setState(() {
      if (selectedNumber == correctNumber) {
        status = 2;
      } else {
        status = 3;
      }
    });
  }

  // --- UPDATE LEVEL KE FIREBASE (student_index + users, max 5) ---
  void _navigateToSuccessScreen() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // level maksimal 5
        int newLevel = widget.levelNumber < 5 ? widget.levelNumber + 1 : 5;

        // 1) UPDATE DI student_index
        final querySnapshot = await FirebaseFirestore.instance
            .collection('student_index')
            .where('studentId', isEqualTo: uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final docRef = querySnapshot.docs.first.reference;
          await docRef.update({'currentLevel': newLevel});
        }

        // 2) UPDATE DI users (dipakai HomeStudentView)
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'currentLevel': newLevel,
          // optional: reset progress
          'levelProgress': 0.0,
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG ERROR: $e');
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuccessScreen()),
    ).then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // --- OVERLAY BENAR / SALAH ---
  Widget _buildFeedbackOverlay() {
    if (status == 2) {
      return CorrectOverlay(onContinue: _navigateToSuccessScreen);
    } else if (status == 3) {
      return IncorrectOverlay(
        correctAnwerText: "$correctNumber",
        onContinue: _generateNewQuestion,
      );
    }
    return Container();
  }

  // --- TOMBOL ANGKA ---
  Widget _buildNumberButton(int number, Color baseColor) {
    bool isSelected = selectedNumber == number;
    bool isDisabled = status > 1;

    Color bg = baseColor;
    if (isSelected && status == 1) {
      bg = correctGreen;
    }

    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          elevation: 6,
          child: InkWell(
            onTap: isDisabled ? null : () => _selectNumber(number),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [bg.withOpacity(0.95), bg.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  if (!isDisabled)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    List<Color> colors = [lightGreen, lightRed, lightOrange, lightPurple];

    bool isCheckButtonEnabled =
        selectedNumber != null && (status == 0 || status == 1);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          // BACKGROUND GRADIENT + BUBBLE
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6BCBFF), Color(0xFFB8E5FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -40,
            child: _bubble(140, const Color(0xFF92D8FF).withOpacity(0.7)),
          ),
          Positioned(
            top: 30,
            right: -30,
            child: _bubble(110, const Color(0xFFFFF3B0).withOpacity(0.9)),
          ),
          Positioned(
            bottom: 120,
            left: -30,
            child: _bubble(100, const Color(0xFF6DD17C)),
          ),
          Positioned(
            bottom: 90,
            right: -40,
            child: _bubble(130, const Color(0xFF5EC76D)),
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          Text(
                            'LATIHAN BERHITUNG',
                            style: TextStyle(
                              fontSize: 18,
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
                          const SizedBox(height: 4),
                          _buildLevelDots(),
                        ],
                      ),
                      _circleButton(
                        icon: Icons.volume_up_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // TITLE SOAL
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Pilih Angka Terbesar',
                    style: getStrokeTextStyle(
                      Colors.white,
                      Colors.deepOrange,
                      30,
                    ),
                  ),
                ),

                // KARTU SOAL + GRID
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        // Kartu info level / instruksi
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.96),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF4FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.calculate_rounded,
                                  color: Color(0xFF1E98F5),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Level ${widget.levelNumber} dari 5',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pilih angka yang nilainya paling besar di antara pilihan di bawah.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Kartu grid angka
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.96),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
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
                      ],
                    ),
                  ),
                ),

                // MASCOT + TEKS PETUNJUK
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: SizedBox(
                    height: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          child: Image.asset(
                            'assets/img/bird_wizard.png',
                            height: 90,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.flutter_dash,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 50,
                          right: 50,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              selectedNumber == null
                                  ? 'Klik salah satu angka dulu ya!'
                                  : 'Sudah yakin? Tekan tombol hijau di bawah.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF444444),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // TOMBOL CEK JAWABAN
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 10,
                  ),
                  child: GestureDetector(
                    onTap: isCheckButtonEnabled ? _checkAnswer : null,
                    child: Opacity(
                      opacity: isCheckButtonEnabled ? 1.0 : 0.5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CD964), Color(0xFF34C759)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade800.withOpacity(0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cek Jawaban',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // TANAH
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

          _buildFeedbackOverlay(),
        ],
      ),
    );
  }

  // --- WIDGET BANTUAN UI ---

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E98F5), size: 20),
      ),
    );
  }

  Widget _buildLevelDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final level = index + 1;
        final isActive = level == widget.levelNumber;
        final isPassed = level < widget.levelNumber;

        Color color;
        if (isPassed) {
          color = const Color(0xFFFFD93D);
        } else if (isActive) {
          color = const Color(0xFF34C759);
        } else {
          color = Colors.white.withOpacity(0.8);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: Container(
            width: isActive ? 12 : 9,
            height: isActive ? 12 : 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: isActive
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
