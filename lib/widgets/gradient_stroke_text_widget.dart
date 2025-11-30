import 'package:flutter/material.dart';

class GradientStrokeTextWidget extends StatelessWidget {
  final String text;
  final TextStyle style;
  final LinearGradient gradient;
  final double strokeWidth;
  final Color fillColor;

  const GradientStrokeTextWidget({
    super.key,
    required this.text,
    required this.gradient,
    required this.style,
    this.strokeWidth = 12,
    this.fillColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Hitung ukuran teks
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final textSize = textPainter.size;
    // Buat shader dengan ukuran sesuai teks
    final shader = gradient.createShader(
      Rect.fromLTWH(0, 0, textSize.width, textSize.height),
    );
    return Stack(
      children: [
        // Stroke dengan gradient
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..shader = shader,
          ),
        ),

        // Fill dengan warna solid
        Text(text, style: style.copyWith(color: fillColor)),
      ],
    );
  }
}
