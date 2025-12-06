import 'package:flutter/material.dart';

class LeaderboardTeacherView extends StatelessWidget {
  const LeaderboardTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADE1FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'PERINGKAT',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 10),
            _buildPodium(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildLeaderboardItem(
                    rank: 1,
                    name: 'Riski Ramadhan',
                    score: 20,
                    level: '5/10',
                    borderColor: Colors.blue,
                  ),
                  const SizedBox(height: 6),
                  _buildLeaderboardItem(
                    rank: 2,
                    name: 'Riski Ramadhan',
                    score: 19,
                    level: '5/9',
                    borderColor: Colors.amber,
                  ),
                  const SizedBox(height: 6),
                  _buildLeaderboardItem(
                    rank: 3,
                    name: 'Riski Ramadhan',
                    score: 18,
                    level: '5/8',
                    borderColor: Colors.orange,
                  ),
                  const SizedBox(height: 6),
                  _buildLeaderboardItem(
                    rank: 4,
                    name: 'Riski Ramadhan',
                    score: 17,
                    level: '5/7',
                    borderColor: Colors.red,
                  ),
                  const SizedBox(height: 6),
                  _buildLeaderboardItem(
                    rank: 5,
                    name: 'Riski Ramadhan',
                    score: 16,
                    level: '5/6',
                    borderColor: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Second place (left, slightly behind)
          Positioned(
            left: 0,
            top: 35,
            child: _buildPodiumCard(
              rank: 2,
              name: 'Riski Ramadhan',
              score: '19',
              imagePath: 'assets/img/juara_2.png',
            ),
          ),
          // First place (center, elevated)
          Positioned(
            top: 0,
            child: _buildPodiumCard(
              rank: 1,
              name: 'Riski Ramadhan',
              score: '20',
              imagePath: 'assets/img/juara_1.png',
            ),
          ),
          // Third place (right, slightly behind)
          Positioned(
            right: 0,
            top: 40,
            child: _buildPodiumCard(
              rank: 3,
              name: 'Riski Ramadhan',
              score: '18',
              imagePath: 'assets/img/juara_3.png',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard({
    required int rank,
    required String name,
    required String score,
    required String imagePath,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card with image background
        Container(
          width: 110,
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              // Username and score at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Username
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Score
                    Text(
                      score,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Nunito',
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int score,
    required String level,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
              image: const DecorationImage(
                image: AssetImage('assets/img/profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
          // Score and level
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Level $level',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
