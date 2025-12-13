import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LearningReadView extends StatefulWidget {
  const LearningReadView({super.key});

  @override
  State<LearningReadView> createState() => _LearningReadViewState();
}

class _LearningReadViewState extends State<LearningReadView> {
  // Camera State
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;

  // ML & TTS State
  final TextRecognizer _textRecognizer = TextRecognizer();
  final FlutterTts _flutterTts = FlutterTts();

  // Results State
  XFile? _capturedImage;
  String _extractedText = "";
  RecognizedText? _recognizedText; // Store full object for boxes
  ui.Image? _imageDimensions;
  bool _isProcessing = false;

  // TTS Playback State
  bool _isPlaying = false;
  int _start = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No cameras found");
        return;
      }
      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  void _initTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.3);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setProgressHandler((
      String text,
      int start,
      int end,
      String word,
    ) {
      if (mounted) {
        setState(() {
          _start = start;
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _start = 0;
        });
      }
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _start = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (_cameraController!.value.isTakingPicture) return;

    try {
      final image = await _cameraController!.takePicture();
      if (mounted) {
        setState(() {
          _capturedImage = image;
          _isProcessing = true;
          _recognizedText = null;
        });
      }
      await _processImage(image);
    } catch (e) {
      debugPrint("Error capturing image: $e");
    }
  }

  Future<void> _processImage(XFile image) async {
    try {
      // 1. Get Image Dimensions
      final data = await image.readAsBytes();
      final decodedImage = await decodeImageFromList(data);

      // 2. Perform OCR
      final inputImage = InputImage.fromFile(File(image.path));
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (mounted) {
        setState(() {
          _imageDimensions = decodedImage;
          _recognizedText = recognizedText;
          _extractedText = recognizedText.text;
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint("Error processing OCR: $e");
      if (mounted) {
        setState(() {
          _extractedText = "Gagal memproses gambar: $e";
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _speakText(String text) async {
    if (_isPlaying) {
      await _flutterTts.stop();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      if (mounted) setState(() => _isPlaying = true);
      await _flutterTts.speak(text);
    }
  }

  void _resetScan() {
    if (_isPlaying) _flutterTts.stop();
    setState(() {
      _capturedImage = null;
      _extractedText = "";
      _recognizedText = null;
      _imageDimensions = null;
      _isProcessing = false;
      _isPlaying = false;
      _start = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (_capturedImage != null) return _buildResultView();
    if (_isCameraInitialized && _cameraController != null)
      return _buildCameraPreview();
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildCameraPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),

        // Helper Text
        Positioned(
          bottom: 150,
          left: 0,
          right: 0,
          child: Text(
            "Arahkan kamera ke teks",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.8),
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ),

        // Corner Brackets (Center Overlay)
        Center(
          child: CustomPaint(
            size: const Size(250, 250),
            painter: ScannerOverlayPainter(),
          ),
        ),

        // Capture Button
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    if (_capturedImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                width: double.infinity,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. The Captured Image
                      Image.file(
                        File(_capturedImage!.path),
                        fit: BoxFit.contain,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),

                      // 2. Overlays (Only if NOT processing and we have results)
                      if (!_isProcessing &&
                          _recognizedText != null &&
                          _imageDimensions != null)
                        _buildOverlayWidgets(constraints),

                      // 3. Loading Overlay (If Processing)
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  "Sedang memproses teks...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Controls
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _resetScan,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Scan Lagi"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _speakText(_extractedText),
                    icon: Icon(_isPlaying ? Icons.stop : Icons.volume_up),
                    label: Text(_isPlaying ? "Stop" : "Baca Semua"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverlayWidgets(BoxConstraints constraints) {
    if (_imageDimensions == null || _recognizedText == null) {
      return const SizedBox.shrink();
    }

    double renderedWidth = constraints.maxWidth;
    double renderedHeight = constraints.maxHeight;
    final aspectRatio = _imageDimensions!.width / _imageDimensions!.height;

    if (renderedWidth / renderedHeight > aspectRatio) {
      renderedWidth = renderedHeight * aspectRatio;
    } else {
      renderedHeight = renderedWidth / aspectRatio;
    }

    final scaleX = renderedWidth / _imageDimensions!.width;
    final scaleY = renderedHeight / _imageDimensions!.height;

    return SizedBox(
      width: renderedWidth,
      height: renderedHeight,
      child: Stack(children: _buildWordOverlays(scaleX, scaleY)),
    );
  }

  List<Widget> _buildWordOverlays(double scaleX, double scaleY) {
    List<Widget> overlayWidgets = [];
    int currentTextSearchIndex = 0;

    for (var block in _recognizedText!.blocks) {
      for (var line in block.lines) {
        for (var element in line.elements) {
          final rect = element.boundingBox;
          final text = element.text;

          int indexInFullText = _extractedText.indexOf(
            text,
            currentTextSearchIndex,
          );

          bool isHighlighted = false;
          if (indexInFullText != -1) {
            if (_isPlaying &&
                _start >= indexInFullText &&
                _start < (indexInFullText + text.length)) {
              isHighlighted = true;
            }
            currentTextSearchIndex = indexInFullText + text.length;
          }

          overlayWidgets.add(
            Positioned(
              left: rect.left * scaleX,
              top: rect.top * scaleY,
              width: rect.width * scaleX,
              height: rect.height * scaleY,
              child: GestureDetector(
                onTap: () => _speakText(text),
                child: Container(
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.blue[300]?.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    return overlayWidgets;
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final double cornerSize = 24.0;

    // Top Left
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerSize), paint);
    canvas.drawLine(const Offset(0, 0), Offset(cornerSize, 0), paint);

    // Top Right
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerSize),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerSize, 0),
      paint,
    );

    // Bottom Left
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerSize),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerSize, size.height),
      paint,
    );

    // Bottom Right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerSize),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerSize, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
