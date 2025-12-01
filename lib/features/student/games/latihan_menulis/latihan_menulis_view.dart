import 'package:ciloka_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Impor yang BENAR untuk HapticFeedback

import '../../../../widgets/game_feedback_overlay.dart';

// ---------------- MODEL HURUF ----------------
class _LetterTile {
  final String char;
  final int id;

  _LetterTile({required this.char, required this.id});
}

// --------------- VIEW -----------------------
class LatihanMenulisView extends StatefulWidget {
  final int levelNumber;

  const LatihanMenulisView({
    super.key,
    required this.levelNumber,
  });

  @override
  State<LatihanMenulisView> createState() => _LatihanMenulisViewState();
}

class _LatihanMenulisViewState extends State<LatihanMenulisView> {
  int status = 0; // 0=normal, 2=benar, 3=salah

  late String correctAnswer;
  late List<_LetterTile> availableLetters;
  late List<_LetterTile?> slotLetters;

  @override
  void initState() {
    super.initState();
    correctAnswer = _getAnswer();
    _setupLetters();
  }

  // ---------------- DATA LEVEL ----------------

  String _getQuestion() {
    switch (widget.levelNumber) {
      case 1:
        return 'Setiap pagi, sebelum berangkat sekolah, Rina selalu membantu ibunya ____ bunga di halaman.';
      case 2:
        return 'Ayah sedang ____ koran di teras.';
      case 3:
        return 'Dina sedang ____ surat untuk temannya.';
      case 4:
        return 'Setiap sore, Andi ____ di lapangan bersama teman-temannya.';
      case 5:
        return 'Untuk menjaga kesehatan, mereka rutin ____ di taman setiap pagi.';
      default:
        return 'Soal tidak ditemukan';
    }
  }

  String _getAnswer() {
    switch (widget.levelNumber) {
      case 1:
        return 'MENYIRAM';
      case 2:
        return 'MEMBACA';
      case 3:
        return 'MENULIS';
      case 4:
        return 'BERMAIN';
      case 5:
        return 'BERLARI';
      default:
        return 'ERROR';
    }
  }

  String _getCharacterAsset() {
    switch (widget.levelNumber) {
      case 1:
        return 'assets/img/games/girl_watering.png';
      case 2:
        return 'assets/img/father_reading.png';
      case 3:
        return 'assets/img/girl_writing.png';
      case 4:
        return 'assets/img/boy_playing.png';
      case 5:
        return 'assets/img/kids_running.png';
      default:
        return 'assets/img/games/girl_watering.png';
    }
  }

  // ---------------- LOGIC HURUF ----------------

  void _setupLetters() {
    final chars = correctAnswer.split('');
    availableLetters = [];
    for (int i = 0; i < chars.length; i++) {
      availableLetters.add(_LetterTile(char: chars[i], id: i));
    }
    availableLetters.shuffle();
    slotLetters = List<_LetterTile?>.filled(chars.length, null);
  }

  void _checkAnswer() {
    final userAnswer = slotLetters.map((t) => t?.char ?? '').join();
    if (userAnswer == correctAnswer) {
      HapticFeedback.mediumImpact(); // ✅ Aman & berfungsi
      setState(() {
        status = 2; // BENAR
      });
    } else {
      HapticFeedback.lightImpact(); // ✅ Aman & berfungsi
      setState(() {
        status = 3; // SALAH
      });
    }
  }

  void _goToNextGame() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.gameLatihanMengeja,
      arguments: widget.levelNumber,
    );
  }

  void _tryAgain() {
    setState(() {
      status = 0;
      _setupLetters();
    });
  }

  Widget _buildFeedbackOverlay() {
    if (status == 2) {
      return CorrectOverlay(
        onContinue: _goToNextGame,
      );
    } else if (status == 3) {
      return IncorrectOverlay(
        correctAnwerText: correctAnswer,
        onContinue: _tryAgain,
      );
    }
    return const SizedBox.shrink();
  }

  // ---------------- UI ------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
            left: -60,
            child: _bubble(140, const Color(0xFF92D8FF).withOpacity(0.7)),
          ),
          Positioned(
            top: 40,
            right: -40,
            child: _bubble(110, const Color(0xFFFAE27C).withOpacity(0.8)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFF6DD17C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: -40,
            child: _bubble(120, const Color(0xFF63C96C)),
          ),
          Positioned(
            bottom: 70,
            right: -30,
            child: _bubble(100, const Color(0xFF59C263)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildHeaderCard(),
                          const SizedBox(height: 18),
                          _buildQuestionCard(),
                          const SizedBox(height: 22),
                          _buildChalkboard(),
                          const SizedBox(height: 12),
                          _buildHintText(),
                          const SizedBox(height: 18),
                          _buildLetterPool(),
                          const SizedBox(height: 26),
                          _buildCheckButton(),
                          const SizedBox(height: 26),
                        ],
                      ),
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

  // -------------- APP BAR ----------------------
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Column(
            children: [
              const Text(
                'LATIHAN MENULIS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              _buildLevelDots(),
            ],
          ),
          _circleButton(
            icon: Icons.volume_up_rounded,
            onTap: () {
              // TODO: suara
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1E98F5),
          size: 20,
        ),
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
          color = Colors.white.withOpacity(0.7);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: Container(
            width: isActive ? 12 : 8,
            height: isActive ? 12 : 8,
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

  // -------------- HEADER -----------------
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3C4), Color(0xFFFFD76A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                _getCharacterAsset(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: Colors.orange, size: 36),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ayo susun kata yang tepat!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 20, color: Colors.amber.shade400),
                    Icon(Icons.star_rounded, size: 20, color: Colors.amber.shade400),
                    Icon(Icons.star_rounded, size: 20, color: Colors.grey.shade300),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '+10 XP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E98F5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: slotLetters.where((e) => e != null).length / slotLetters.length,
                    backgroundColor: const Color(0xFFE5F2FF),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CD964)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------- SOAL -------------------
  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF1E98F5),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getQuestion(),
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF444444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------- PAPAN TULIS -------------------
 // -------------- PAPAN TULIS (FIXED: No Overflow + Responsive) -------------------
Widget _buildChalkboard() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFF1A4A2E),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFF5D3A1A), width: 8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        )
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final totalSlots = slotLetters.length;
        const minSpacing = 6.0;
        const minTileSize = 32.0;

        // Hitung total lebar minimum yang dibutuhkan
        final availableWidth = constraints.maxWidth;
        final totalMinWidth = (minTileSize * totalSlots) + (minSpacing * (totalSlots - 1));

        if (totalMinWidth <= availableWidth) {
          // Cukup lebar → pakai ukuran normal
          return _buildSlotRow(tileSize: minTileSize, spacing: minSpacing);
        } else {
          // Terlalu sempit → kurangi ukuran tile agar pas
          final calculatedTileSize = (availableWidth - (minSpacing * (totalSlots - 1))) / totalSlots;
          final tileSize = calculatedTileSize.clamp(24.0, minTileSize);
          return _buildSlotRow(tileSize: tileSize, spacing: minSpacing);
        }
      },
    ),
  );
}

Widget _buildSlotRow({required double tileSize, required double spacing}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(slotLetters.length, (index) {
          final letter = slotLetters[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: SizedBox(
              width: tileSize,
              height: tileSize,
              child: DragTarget<_LetterTile>(
                onWillAccept: (data) => true,
                onAccept: (tile) {
                  setState(() {
                    if (slotLetters[index] != null) {
                      availableLetters.add(slotLetters[index]!);
                    }
                    slotLetters[index] = tile;
                    availableLetters.removeWhere((t) => t.id == tile.id);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovering = candidateData.isNotEmpty;
                  final bgColors = letter != null
                      ? const [Colors.white, Colors.white]
                      : (isHovering
                          ? [Colors.yellowAccent.shade100, Colors.white]
                          : [Colors.grey.shade300, Colors.grey.shade400]);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeInOut,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: bgColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: letter != null
                            ? Colors.green.shade600
                            : (isHovering ? Colors.yellow.shade700 : Colors.grey.shade500),
                        width: letter != null ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                    child: Text(
                      letter?.char ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: tileSize * 0.5,
                        fontWeight: FontWeight.bold,
                        shadows: letter != null
                            ? [Shadow(color: Colors.grey.shade400, offset: Offset(1, 1), blurRadius: 1)]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    ],
  );
}
  // -------------- PETUNJUK -----------------
  Widget _buildHintText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.touch_app_rounded, size: 18, color: Color(0xFF2873FF)),
        SizedBox(width: 6),
        Text(
          'Seret huruf ke kotak di papan tulis',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2873FF),
          ),
        ),
      ],
    );
  }

  // -------------- POOL HURUF --------------------
  Widget _buildLetterPool() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: availableLetters.map((tile) {
            return Draggable<_LetterTile>(
              data: tile,
              feedback: Transform.scale(scale: 1.2, child: _buildLetterTile(tile.char, isDragging: true)),
              childWhenDragging: Opacity(opacity: 0.3, child: _buildLetterTile(tile.char)),
              child: _buildLetterTile(tile.char),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLetterTile(String char, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 52,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            if (!isDragging)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
        ),
        child: Text(
          char,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)],
          ),
        ),
      ),
    );
  }

  // -------------- TOMBOL CEK --------------------
  Widget _buildCheckButton() {
    Color bgStart, bgEnd, textColor;
    switch (status) {
      case 2:
        bgStart = const Color(0xFF4CD964);
        bgEnd = const Color(0xFF34C759);
        textColor = Colors.white;
        break;
      case 3:
        bgStart = const Color(0xFFFF6B6B);
        bgEnd = const Color(0xFFD32F2F);
        textColor = Colors.white;
        break;
      default:
        bgStart = const Color(0xFF4CD964);
        bgEnd = const Color(0xFF34C759);
        textColor = Colors.white;
    }

    return GestureDetector(
      onTap: _checkAnswer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgStart, bgEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: status == 2
                  ? Colors.green.shade800.withOpacity(0.4)
                  : (status == 3 ? Colors.red.shade800.withOpacity(0.4) : Colors.green.shade800.withOpacity(0.4)),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 2 ? Icons.check_circle : (status == 3 ? Icons.error : Icons.check_rounded),
              color: textColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              status == 2
                  ? 'Benar! Lanjut ke Level Berikutnya'
                  : (status == 3 ? 'Coba Lagi!' : 'Cek Jawaban'),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------- BUBBLE DEKORASI -----------------
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
          )
        ],
      ),
    );
  }
}