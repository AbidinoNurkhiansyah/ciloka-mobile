import 'package:flutter/material.dart';

void main() {
  runApp(const FeedbackStudent());
}

class FeedbackStudent extends StatelessWidget {
  const FeedbackStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFB0DAFD),
          secondary: Color(0xFF0090D4),
          surface: Color(0xFF2ACCF0),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFB0DAFD),
        fontFamily: 'Nunito',
      ),
      debugShowCheckedModeBanner: false,
      home: const PilihCaraBelajarScreen(),
    );
  }
}

class PilihCaraBelajarScreen extends StatefulWidget {
  const PilihCaraBelajarScreen({super.key});

  @override
  State<PilihCaraBelajarScreen> createState() =>
      _PilihCaraBelajarScreenState();
}

class _PilihCaraBelajarScreenState extends State<PilihCaraBelajarScreen>
    with SingleTickerProviderStateMixin {
  String? selectedType;

  Color getBackgroundColor(String type) {
    if (selectedType == type) {
      switch (type) {
        case 'Visual':
          return const Color(0xFFF5DB96);
        case 'Auditory':
          return const Color(0xFF40A9C8);
        case 'Visual & Auditory':
          return const Color(0xFF56B391);
      }
    }
    return Colors.white;
  }

  Color getTextColor(String type) {
    switch (type) {
      case 'Visual':
        return const Color(0xFF33588C);
      case 'Auditory':
        return const Color(0xFF66A698);
      case 'Visual & Auditory':
        return const Color(0xFFD78EC3);
      default:
        return Colors.black87;
    }
  }

  Widget buildSpeechBubble(String text) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildOption(String type, String imagePath) {
    bool isSelected = selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: isSelected
            ? (Matrix4.identity()..scale(1.05))
            : Matrix4.identity(),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: getBackgroundColor(type),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isSelected ? 0.9 : 1,
              child: Image.asset(imagePath, height: 90),
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: getTextColor(type),
                shadows: const [
                  Shadow(
                    color: Colors.white,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSelected
                  ? buildSpeechBubble(
                      type == 'Visual'
                          ? 'Kamu lebih suka belajar dengan melihat'
                          : type == 'Auditory'
                              ? 'Kamu lebih suka belajar dengan mendengar'
                              : 'Kamu suka belajar dengan melihat dan mendengar',
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void showFeedbackOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF40A9C8),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/img/burung_feedback.webp',
                  height: 180,
                ),
                const SizedBox(height: 20),
                const Text(
                  'TERIMAKASIH ATAS\nJAWABANMU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 50),
                    decoration: BoxDecoration(
                      color: const Color(0xFF33588C),
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'LANJUT',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: const [
                  Text(
                    'YUK, PILIH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D7A),
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'CARA BELAJARMU!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D7A),
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Kotak pilihan kiri & kanan
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        buildOption('Visual', 'assets/img/visual.webp'),
                        const SizedBox(height: 12),
                        buildOption('Auditory', 'assets/img/auditory.webp'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: buildOption('Visual & Auditory',
                          'assets/img/visual_auditory.webp'),
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: selectedType != null
                    ? () {
                        showFeedbackOverlay();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF33588C), // 🔹 Warna baru
                  disabledBackgroundColor: Colors.grey[400],
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Lanjut',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
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
