import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

class CustomClassCard extends StatelessWidget {
  final double height;
  final String title;
  final String imagePath;
  final IconData trailingIcon;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  const CustomClassCard({
    super.key,
    required this.height,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    required this.imagePath,
    this.trailingIcon = Icons.arrow_forward_ios,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(imagePath, height: 40),
                ],
              ),
              Icon(trailingIcon, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
