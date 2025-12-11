import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:ciloka_app/features/student/services/student_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ciloka_app/core/routes/app_routes.dart';
import '../../../../widgets/game_feedback_overlay.dart';
import '../../../../widgets/exit_game_dialog.dart';

class PengejaanView extends StatefulWidget {
  final int levelNumber;

  const PengejaanView({super.key, required this.levelNumber});

  @override
  _PengejaanViewState createState() => _PengejaanViewState();
}

class _PengejaanViewState extends State<PengejaanView> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "";
  String _targetWord = "";
  bool _isCorrect = false;
  bool _showCorrectOverlay = false;
  bool _showWrongOverlay = false;

  final player = AudioPlayer();
  int currentPoints = 10;
  final StudentService _studentService = StudentService();

  final FlutterTts flutterTts = FlutterTts();

  String? currentWord; // kata yang sedang dibacakan
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadSoal();
    _resetGame();

    flutterTts.awaitSpeakCompletion(true); // penting supaya progress keluar

    flutterTts.setProgressHandler((
      String text,
      int start,
      int end,
      String word,
    ) {
      if (word.trim().isEmpty) return; // cegah highlight aneh
      setState(() => currentWord = word);

      // Auto-scroll ke kata yang sedang dibacakan
      _scrollToWord(word);
    });

    // completion handler untuk reset highlight
    flutterTts.setCompletionHandler(() {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            currentWord = null;
          });
        }
      });

      debugPrint("TTS selesai → highlight direset");
    });
  }

  void _scrollToWord(String word) {
    if (_targetWord.isEmpty) return;

    final words = _targetWord.split(" ");
    // normalisasi semua kata
    final normalizedWords = words.map(normalize).toList();

    // cari index pertama yang mengandung 'word' atau sama persis
    int index = normalizedWords.indexWhere(
      (w) => w == word || w.contains(word) || word.contains(w),
    );

    if (index == -1) {
      // kalau belum ketemu, coba cari kata terdekat (misalnya partial match)
      index = normalizedWords.indexWhere((w) => w.contains(word));
    }

    if (index == -1) return;

    final position = index * 40.0;
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _checkAndSpeak() async {
    // Ambil daftar bahasa yang tersedia di device
    List<dynamic> languages = await flutterTts.getLanguages;

    // Debug: print semua bahasa
    debugPrint("Bahasa tersedia: $languages");

    // Cek apakah bahasa Indonesia ada
    bool isAvailable = await flutterTts.isLanguageAvailable("id-ID");

    if (isAvailable) {
      await flutterTts.setLanguage("id-ID");
      await flutterTts.setSpeechRate(0.2);
      await flutterTts.awaitSpeakCompletion(true);
      // SET soal dulu
      _loadSoal();

      // Pre-process soal untuk dibacakan
      final textToSpeak = preprocessText(_targetWord);
      await flutterTts.speak(textToSpeak); // pakai soal biar sinkron
    } else {
      // Kalau tidak tersedia, kasih fallback
      await flutterTts.setLanguage("en-US");
      await flutterTts.speak(
        "Bahasa Indonesia tidak tersedia di perangkat ini.",
      );
    }
  }

  String preprocessText(String text) {
    // Ganti ellipsis "..." dengan kata "titik titik titik"
    String result = text
        .replaceAll("...", "titik titik titik")
        .replaceAll(".", "")
        .replaceAll(",", "");

    // Bisa juga ganti tanda baca lain kalau mau
    result = result.replaceAll("?", "tanda tanya");
    result = result.replaceAll("!", "tanda seru");

    return result;
  }

  String normalize(String word) {
    return word.toLowerCase().replaceAll(
      RegExp(r'[^\w\s]'),
      '',
    ); // buang tanda baca
  }

  void _loadSoal() {
    switch (widget.levelNumber) {
      case 1:
        _targetWord = "burung";
        break;
      case 2:
        _targetWord = "gajah";
        break;
      case 3:
        _targetWord = "kucing";
        break;
      case 4:
        _targetWord = "monyet";
        break;
      case 5:
        _targetWord = "singa";
        break;
      default:
        _targetWord = "hewan";
    }
  }

  void _startListening() async {
    if (_isListening) {
      _stopListening();
      return;
    }

    setState(() {
      _spokenText = "";
      _isCorrect = false;
      _showCorrectOverlay = false;
      _showWrongOverlay = false;
    });

    bool available = await _speech.initialize(
      onError: (error) => debugPrint("Speech Error: ${error.errorMsg}"),
      onStatus: (status) => debugPrint("Speech Status: $status"),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'id_ID',
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords.toLowerCase();
            if (result.finalResult) {
              _stopListening();
            }
          });
        },
      );
    } else {
      setState(() => _isListening = false);
      debugPrint("Layanan Speech Recognition tidak tersedia");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _checkAnswer() async {
    if (_spokenText.isEmpty || _isListening) return;

    final isCorrect = _spokenText.trim() == _targetWord.toLowerCase();

    if (isCorrect) {
      await player.play(AssetSource('audio/correct.mp3'));

      // Add points to Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _studentService.addPoints(uid, currentPoints);
      }

      setState(() {
        _isCorrect = true;
        _showCorrectOverlay = true;
        _showWrongOverlay = false;
      });
    } else {
      await player.play(AssetSource('audio/wrong.mp3'));

      setState(() {
        currentPoints = (currentPoints - 2).clamp(0, 10);
        _isCorrect = false;
        _showCorrectOverlay = false;
        _showWrongOverlay = true;
      });
    }
  }

  void _goToNextGame() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.gameLatihanBerhitung,
      arguments: widget.levelNumber,
    );
  }

  void _resetGame() {
    setState(() {
      _spokenText = "";
      _isCorrect = false;
      _isListening = false;
      _showCorrectOverlay = false;
      _showWrongOverlay = false;
      currentPoints = 10; // Reset points
    });
  }

  // 🔠 Kotak Huruf (PERSIS seperti kode awalmu)
  Widget _buildLetterBox(int index) {
    String letter = index < _spokenText.length
        ? _spokenText[index].toUpperCase()
        : "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xff1e1e1e),
          shadows: [
            Shadow(
              color: Colors.grey.shade400,
              offset: Offset(1, 1),
              blurRadius: 1,
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
            color: color.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  // -------------- LEVEL DOTS (5 LEVEL) -----------------
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
          color = Colors.white.withValues(alpha: 0.7);
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

  // -------------- APP BAR CUSTOM ----------------------
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              final shouldPop = await showExitGameDialog(context);

              if (shouldPop == true && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E98F5),
                size: 20,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Latihan Membaca',
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
            onTap: () async {
              await _checkAndSpeak();

              debugPrint('speech aktif');
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
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1E98F5), size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int targetLength = _targetWord.isEmpty ? 1 : _targetWord.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showExitGameDialog(context);

        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
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
              child: _bubble(
                140,
                const Color(0xFF92D8FF).withValues(alpha: 0.7),
              ),
            ),
            Positioned(
              top: 40,
              right: -40,
              child: _bubble(
                110,
                const Color(0xFFFAE27C).withValues(alpha: 0.8),
              ),
            ),
            // RUMPUT + HILL
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: _buildTargetWord(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  child: Text(
                                    'Klik speaker di atas untuk mendengar',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              children: List.generate(
                                targetLength,
                                (index) => _buildLetterBox(index),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // --- Tombol Mic ---
                          GestureDetector(
                            onTap: _isListening
                                ? _stopListening
                                : _startListening,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isListening
                                    ? Colors.lightGreen
                                    : Colors.pinkAccent,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  _isListening ? Icons.hearing : Icons.mic,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            _isListening
                                ? "Mendengarkan..."
                                : _spokenText.isEmpty
                                ? "Tekan Mic untuk Membaca"
                                : "Kamu berkata: $_spokenText",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- Tombol Cek & Ulangi ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_spokenText.isNotEmpty &&
                                  !_isListening &&
                                  !_isCorrect)
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: ElevatedButton(
                                    onPressed: _checkAnswer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Cek Jawaban",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ElevatedButton(
                                onPressed: _resetGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Ulangi",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_showCorrectOverlay) CorrectOverlay(onContinue: _goToNextGame),
            if (_showWrongOverlay)
              IncorrectOverlay(
                correctAnwerText: _targetWord,
                onContinue: _resetGame,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWord() {
    final words = _targetWord.split(" ");

    return Text.rich(
      TextSpan(
        children: words.map((w) {
          final isActive =
              (currentWord != null && normalize(w) == normalize(currentWord!));

          return TextSpan(
            text: "${w.toUpperCase()} ",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              color: Color(0xff1e1e1e),
              backgroundColor: isActive
                  ? Colors.blue[300]?.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          );
        }).toList(),
      ),
      textAlign: TextAlign.center,
    );
  }
}
