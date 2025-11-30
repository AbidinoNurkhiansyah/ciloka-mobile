import 'package:flutter/material.dart';

class CardRoleWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;
  final double height;
  const CardRoleWidget({
    super.key,
    required this.imagePath,
    this.onTap,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(height: height, child: Image.asset(imagePath)),
      ),
    );
  }
}
