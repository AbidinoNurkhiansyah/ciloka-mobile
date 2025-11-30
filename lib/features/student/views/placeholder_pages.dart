import 'package:flutter/material.dart';

// Halaman Home (Index 0)
class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Halaman Utama (Home)', style: TextStyle(fontSize: 20)));
  }
}

// Halaman Leaderboard (Index 2)
class PlaceholderLeaderboardPage extends StatelessWidget {
  const PlaceholderLeaderboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Halaman Peringkat (Leaderboard)',
            style: TextStyle(fontSize: 20)));
  }
}

// Halaman Profile/Bird (Index 3)
class PlaceholderBirdPage extends StatelessWidget {
  const PlaceholderBirdPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Halaman Profil', style: TextStyle(fontSize: 20)));
  }
}
