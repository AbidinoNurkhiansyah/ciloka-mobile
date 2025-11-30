import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// --- 1. IMPORT ROUTES ---
import 'package:ciloka_app/core/routes/app_routes.dart';

// --- 2. IMPORT FEEDBACK OVERLAY EKSTERNAL ---
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
    if (widget.levelNumber == 1) {
      _targetWord = "burung";
    } else if (widget.levelNumber == 2) {
      _targetWord = "gajah";
    } else {
      _targetWord = "kucing";
    }
    _resetGame(); 
    setState(() {});
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
    setState(() {
      _showCorrectOverlay = false;
    });
    
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.gameLatihanBerhitung, // <-- Pindah ke Game 3
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

  // 🔠 Kotak Huruf
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

// --- 3. FUNGSI _buildCorrectOverlay() DIHAPUS ---
// Widget _buildCorrectOverlay() { ... }

// --- 4. FUNGSI _buildWrongOverlay() DIHAPUS ---
// Widget _buildWrongOverlay() { ... }


  @override
  Widget build(BuildContext context) {
    int targetLength = _targetWord.isEmpty ? 1 : _targetWord.length;

    return Scaffold(
      backgroundColor: const Color(0xFFB0DAFD), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.black),
            onPressed: () {
              // Fungsi play audio
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- 1. Konten Game Utama ---
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Ayo Mengeja Bersama!",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.blueGrey, blurRadius: 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Kartu Kata dan Huruf ---
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
                          onPressed: () {},
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
                        color:
                            _isListening ? Colors.lightGreen : Colors.pinkAccent,
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- 5. OVERLAY DIUBAH PAKAI FILE EKSTERNAL ---
          if (_showCorrectOverlay)
            CorrectOverlay(
              onContinue: _goToNextGame,
            ),

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