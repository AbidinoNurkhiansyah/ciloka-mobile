import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:ciloka_app/core/routes/app_routes.dart';
import '../../../../widgets/game_feedback_overlay.dart';

class PengejaanView extends StatefulWidget {
  final int levelNumber;

  const PengejaanView({
    super.key,
    required this.levelNumber,
  });

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

  final List<Color> _boxColors = const [
    Color(0xFFFFD966),
    Color(0xFFFF9999),
    Color(0xFF99CCFF),
    Color(0xFFB3E6B3),
    Color(0xFFCC99FF),
    Color(0xFF66FF99),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadSoal();
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
    _resetGame();
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
      onError: (error) => print("Speech Error: ${error.errorMsg}"),
      onStatus: (status) => print("Speech Status: $status"),
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
      print("Layanan Speech Recognition tidak tersedia");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _checkAnswer() {
    if (_spokenText.isEmpty || _isListening) return;

    setState(() {
      _isCorrect = _spokenText.trim() == _targetWord.toLowerCase();
      if (_isCorrect) {
        _showCorrectOverlay = true;
        _showWrongOverlay = false;
      } else {
        _showCorrectOverlay = false;
        _showWrongOverlay = true;
      }
    });
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
    });
  }

  // 🔠 Kotak Huruf (PERSIS seperti kode awalmu)
  Widget _buildLetterBox(int index) {
    String letter =
        index < _spokenText.length ? _spokenText[index].toUpperCase() : "";
    Color boxColor = _boxColors[index % _boxColors.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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

  // -------------- APP BAR CUSTOM ----------------------
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E98F5),
                size: 20,
              ),
            ),
          ),
          Column(
            children: [
              const Text(
                'LATIHAN MENG-EJA',
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
          Container(
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
            child: const Icon(
              Icons.volume_up_rounded,
              color: Color(0xFF1E98F5),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int targetLength = _targetWord.isEmpty ? 1 : _targetWord.length;

    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND: langit + bentuk bulat-bulat
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6BCBFF),
                  Color(0xFFB8E5FF),
                ],
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          // --- KARTU DARI KODE AWALMU (TIDAK DIUBAH) ---
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _targetWord.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                    color: Colors.pinkAccent,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF74E0E0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    // TODO: play audio
                                  },
                                  icon: const Icon(Icons.volume_up, color: Colors.white),
                                  label: const Text(
                                    "Klik untuk Mendengar",
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    targetLength,
                                    (index) => _buildLetterBox(index),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // --- Tombol Mic ---
                          GestureDetector(
                            onTap: _isListening ? _stopListening : _startListening,
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
                                    ? "Tekan Mic untuk Mengeja"
                                    : "Kamu berkata: $_spokenText",
                            style: const TextStyle(
                              fontFamily: 'Nunito',
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
                                        fontFamily: 'Nunito',
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
                                    fontFamily: 'Nunito',
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
                ),
              ],
            ),
          ),

          if (_showCorrectOverlay)
            CorrectOverlay(onContinue: _goToNextGame),
          if (_showWrongOverlay)
            IncorrectOverlay(
              correctAnwerText: _targetWord,
              onContinue: _resetGame,
            ),
        ],
      ),
    );
  }
}