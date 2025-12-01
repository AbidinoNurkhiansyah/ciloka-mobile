import 'package:ciloka_app/core/theme/app_spacing.dart';
import 'package:ciloka_app/features/student/models/level_model.dart';
import 'package:ciloka_app/features/student/models/user_student_model.dart';
import 'package:ciloka_app/features/student/services/student_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- 1. PASTIKAN IMPORT INI BENER ---
import 'package:ciloka_app/core/routes/app_routes.dart';

class HomeStudentView extends StatelessWidget {
  const HomeStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // --- Versi "Logged Out" atau "Default" ---
    if (uid == null) {
      final defaultStudent = StudentModel(
        uid: '',
        username: 'Siswa',
        email: '',
        photoUrl: '',
        currentLevel: 1,
        levelProgress: 0.1,
      );
      final levels = LevelModel.getDefaultLevels(defaultStudent.currentLevel);

      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFB0DAFD), // Light blue background
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildProfileSection(context, defaultStudent),
                Expanded(
                  child: _buildLevelMap(context, defaultStudent, levels),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- Versi "Logged In" (Pakai StreamBuilder) ---
    final studentStream = StudentService().streamStudentProfile(uid);

    return Scaffold(
      body: StreamBuilder<StudentModel?>(
        stream: studentStream,
        builder: (context, snapshot) {
          // Versi Loading
          if (!snapshot.hasData || snapshot.data == null) {
            final defaultStudent = StudentModel(
              uid: uid,
              username: 'Siswa',
              email: '',
              photoUrl: '',
              currentLevel: 1,
              levelProgress: 0.1,
            );
            final levels =
                LevelModel.getDefaultLevels(defaultStudent.currentLevel);

            return Container(
              decoration: const BoxDecoration(color: Color(0xFFB0DAFD)),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildProfileSection(context, defaultStudent),
                    Expanded(
                      child: _buildLevelMap(context, defaultStudent, levels),
                    ),
                  ],
                ),
              ),
            );
          }

          // Versi Ada Data
          final student = snapshot.data!;
          final levels = LevelModel.getDefaultLevels(student.currentLevel);

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFB0DAFD), // Light blue background
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildProfileSection(context, student),
                  Expanded(child: _buildLevelMap(context, student, levels)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET ATAS (PROFILE) ---
  Widget _buildProfileSection(BuildContext context, StudentModel student) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF2ACCF0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: student.photoUrl.isNotEmpty
                ? NetworkImage(student.photoUrl)
                : null,
            child: student.photoUrl.isEmpty
                ? const Icon(Icons.person, size: 36, color: Colors.white)
                : null,
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEVEL ${student.currentLevel}/5',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          )
                        ],
                      ),
                ),
                AppSpacing.vSm,
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: student.levelProgress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PETA LEVEL ---
  Widget _buildLevelMap(
    BuildContext context,
    StudentModel student,
    List<LevelModel> levels,
  ) {
    return SingleChildScrollView(
      child: Container(
        height: 2200, // Tinggi total peta (tetap)
        child: Stack(
          children: [
            // LAPISAN 1: DEKORASI
            _buildDecorativeElements(context),

            // LAPISAN 2: PULAU & PATH
            // Level 5 (Paling Atas Kiri)
            Positioned(
              top: 290,
              left: 30,
              child: _buildLevelIsland(context, levels[4]),
            ),
            // Path (Jembatan) dari 4 ke 5
            Positioned(
              top: 230,
              left: -20,
              child: _buildPathConnection(true),
            ),

            // Level 4 (Tengah Kanan)
            Positioned(
              top: 520,
              right: 0,
              child: _buildLevelIsland(context, levels[3]),
            ),
            // Path (Lengkung) dari 3 ke 4
            Positioned(
              top: 450,
              right: -70,
              child: _buildPathConnection(false),
            ),

            // Level 3 (Tengah Kiri)
            Positioned(
              top: 650,
              left: 25,
              child: _buildLevelIsland(context, levels[2]),
            ),
            // Path (Jembatan) dari 2 ke 3
            Positioned(
              top: 600,
              left: -40,
              child: _buildPathConnection(true),
            ),

            // Path (Lengkung) dari 1 ke 2
            Positioned(
              top: 800,
              right: -40,
              child: _buildPathConnection(false),
            ),

            // Level 2 (Bawah Kanan)
            Positioned(
              top: 870,
              right: 30,
              child: _buildLevelIsland(context, levels[1]),
            ),

            // Starting Point (Level 1) (Paling Bawah Kiri)
            Positioned(
              top: 1000,
              left: 10,
              child: _buildStartingPoint(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DEKORASI (BALON & BINTANG) ---
  Widget _buildDecorativeElements(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(left: 50, top: 80, child: _buildStar(Colors.yellow, 12)),
          Positioned(left: 120, top: 150, child: _buildStar(Colors.pink, 8)),
          Positioned(left: 200, top: 100, child: _buildStar(Colors.purple, 10)),
          Positioned(right: 60, top: 120, child: _buildStar(Colors.yellow, 9)),
          Positioned(right: 100, top: 200, child: _buildStar(Colors.blue, 7)),
          Positioned(left: 80, top: 300, child: _buildStar(Colors.pink, 6)),
          Positioned(right: 80, top: 350, child: _buildStar(Colors.yellow, 8)),
          Positioned(
            left: 20,
            top: 180,
            child: _buildBalloon(const Color(0xFFFF9800)),
          ),
          Positioned(
            right: 30,
            top: 160,
            child: _buildBalloon(const Color(0xFFB0DAFD)),
          ),
          Positioned(
            left: 150,
            top: 400,
            child: _buildBalloon(const Color(0xFF9C27B0)),
          ),
        ],
      ),
    );
  }

  Widget _buildStar(Color color, double size) {
    return Icon(Icons.star, color: color, size: size);
  }

  Widget _buildBalloon(Color color) {
    return Container(
      width: 35,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        gradient: RadialGradient(
          center: const Alignment(-0.5, -0.5),
          colors: [
            Colors.white.withOpacity(0.7),
            color,
          ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET TITIK AWAL (START) ---
  Widget _buildStartingPoint(BuildContext context) {
    const islandColor = Color(0xFF4CAF50); // Green

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.playLevel1);
        print('Masuk ke Level 1!');
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: islandColor,
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.7, -0.7),
            radius: 1.0,
            colors: [
              Colors.white.withOpacity(0.5),
              islandColor,
            ],
            stops: const [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(4, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 15,
              left: 15,
              child: Icon(Icons.eco, color: Colors.green.shade900, size: 24),
            ),
            Positioned(
              bottom: 15,
              right: 15,
              child: Icon(Icons.eco, color: Colors.green.shade900, size: 24),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B4513), // Brown hat
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 35,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFDBAC), // Skin color
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          top: 20,
                          child: Container(
                            width: 20,
                            height: 25,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
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
    );
  }

  // --- WIDGET JALAN (PATH) - TIDAK MENGHALANGI TAP ---
  Widget _buildPathConnection(bool useLadder) {
    // Layout, ukuran, posisi TETAP sama – hanya dibungkus IgnorePointer
    return IgnorePointer(
      child: Container(
        width: 450,
        height: 450,
        child: Image.asset(
          useLadder ? 'assets/img/tangga.png' : 'assets/img/lengkung.png',
          height: 220, // Ukuran asli gambar
          width: 220, // Ukuran asli gambar
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // --- WIDGET PULAU LEVEL ---
  Widget _buildLevelIsland(BuildContext context, LevelModel level) {
    Color cloudColor;
    switch (level.levelNumber) {
      case 2:
        cloudColor = const Color(0xFF9C27B0); // Purple
        break;
      case 3:
        cloudColor = const Color(0xFF2196F3); // Blue
        break;
      case 4:
        cloudColor = const Color(0xFF4CAF50); // Green
        break;
      case 5:
        cloudColor = const Color(0xFFE91E63); // Pink
        break;
      default:
        cloudColor = Colors.grey;
    }

    return GestureDetector(
      onTap: level.isUnlocked
          ? () {
              Navigator.pushNamed(
                context,
                AppRoutes.playLevel,
                arguments: level.levelNumber,
              );
              print('Masuk ke ${level.levelName}');
            }
          : null,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: cloudColor.withOpacity(0.9),
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.7, -0.7),
            radius: 1.0,
            colors: [
              Colors.white.withOpacity(0.5),
              cloudColor,
            ],
            stops: const [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(4, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    level.levelName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            )
                          ],
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (!level.isUnlocked)
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.water_drop,
                            color: cloudColor.withOpacity(0.5),
                            size: 30,
                          ),
                        ),
                        Positioned(
                          top: -10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 30,
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
