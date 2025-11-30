import 'package:flutter/material.dart';

class CustomMethodAuthWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double height;
  final double width;
  final double size;
  final VoidCallback? onTap;

  const CustomMethodAuthWidget({
    super.key,
    required this.icon,
    this.color = Colors.white,
    this.height = 60,
    this.width = 60,
    this.size = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}
