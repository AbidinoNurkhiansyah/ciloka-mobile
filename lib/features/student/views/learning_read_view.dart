import 'dart:io';

import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class LearningReadView extends StatefulWidget {
  const LearningReadView({super.key});

  @override
  State<LearningReadView> createState() => _LearningReadViewState();
}

class _LearningReadViewState extends State<LearningReadView> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  final FlutterTts _flutterTts = FlutterTts();

  // Changed from File to XFile for cross-platform support
  XFile? _selectedImage;
  String _extractedText = "";
  bool _isProcessing = false;
  
  // TTS State
  bool _isPlaying = false;
  int _start = 0;
  int _end = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);

    // On Web, some handlers might behave differently, but generally supported.
    _flutterTts.setStartHandler(() {
      setState(() {
        _isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _start = 0;
        _end = 0;
      });
    });

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      setState(() {
        _start = start;
        _end = end;
      });
    });
    
    _flutterTts.setCancelHandler(() {
      setState(() {
        _isPlaying = false;
        _start = 0;
        _end = 0;
      });
    });
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image; // Store XFile directly
          _extractedText = "";
          _start = 0;
          _end = 0;
        });
        await _processImage();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    if (kIsWeb) {
      setState(() {
        _extractedText = "Maaf, fitur OCR (Scan Teks) belum didukung di versi Web.\n\nSilakan gunakan aplikasi Mobile untuk fitur ini.";
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // InputImage.fromFile requires dart:io File, which crashes on Web
      // We guarded this with !kIsWeb above, so it's safe here on mobile.
      final inputImage = InputImage.fromFile(File(_selectedImage!.path));
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
        if (_extractedText.isEmpty) {
          _extractedText = "Tidak ditemukan teks dalam gambar.";
        }
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses gambar: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _speak() async {
    if (_extractedText.isEmpty) return;
    if (_isPlaying) {
      await _flutterTts.stop();
    } else {
      await _flutterTts.speak(_extractedText);
    }
  }
  
  // Helper to build rich text with highlighting
  List<TextSpan> _buildHighlightedText() {
    if (_extractedText.isEmpty) return [];
    
    List<TextSpan> spans = [];
    String text = _extractedText;
    
    if (!_isPlaying || _end == 0) {
      return [TextSpan(text: text)];
    }

    // Ensure indices are within bounds
    int safeStart = _start.clamp(0, text.length);
    int safeEnd = _end.clamp(0, text.length);
    
    if (safeStart > safeEnd) {
      return [TextSpan(text: text)];
    }

    // Before highlight
    if (safeStart > 0) {
      spans.add(TextSpan(text: text.substring(0, safeStart)));
    }
    
    // Highlighted part
    spans.add(TextSpan(
      text: text.substring(safeStart, safeEnd),
      style: const TextStyle(
        backgroundColor: Colors.yellow,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ));
    
    // After highlight
    if (safeEnd < text.length) {
      spans.add(TextSpan(text: text.substring(safeEnd)));
    }
    
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Belajar Membaca"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Display
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb 
                        ? Image.network(
                            _selectedImage!.path,
                            fit: BoxFit.contain,
                          )
                        : Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.contain,
                          ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Belum ada gambar yang dipilih"),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Kamera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Galeri"),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Text Display
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_extractedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Teks Terdeteksi:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: _speak,
                          icon: Icon(
                            _isPlaying ? Icons.stop_circle : Icons.volume_up,
                            color: _isPlaying ? Colors.red : Colors.blue,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          height: 1.5,
                        ),
                        children: _buildHighlightedText(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
