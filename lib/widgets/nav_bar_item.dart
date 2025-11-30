import 'package:flutter/material.dart';

// Item navigasi bawah kustom
class NavBarItem extends StatelessWidget {
  final String imagePath;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const NavBarItem({
    super.key,
    required this.imagePath,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == selectedIndex;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isActive
                ? 1.0
                : 0.7, // Penuh saat aktif, 70% redup saat tidak aktif
            // Menggunakan Image.asset untuk ikon navigasi
            child: Image.asset(
              imagePath,
              width: 40,
              height: 40,
              // Fallback jika gambar tidak ditemukan
              errorBuilder: (context, error, stackTrace) {
                IconData icon;
                switch (index) {
                  case 0:
                    icon = Icons.home;
                    break;
                  case 1:
                    icon = Icons.school;
                    break;
                  case 2:
                    icon = Icons.leaderboard;
                    break;
                  case 3:
                    icon = Icons.pets;
                    break;
                  default:
                    icon = Icons.question_mark;
                }
                return Icon(icon,
                    size: 40, color: isActive ? Colors.white : Colors.white70);
              },
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
