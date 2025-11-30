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
    // Ini udah bener, ngambil data dari 'users'
    final studentStream = StudentService().streamStudentProfile(uid); 

    return Scaffold(
      body: StreamBuilder<StudentModel?>(
        stream: studentStream,
        builder: (context, snapshot) {
          // Versi Loading
          if (!snapshot.hasData || snapshot.data == null) {
            final defaultStudent = StudentModel(
              uid: uid ?? '',
              username: 'Siswa',
              email: '',
              photoUrl: '',
              currentLevel: 1,
              levelProgress: 0.1,
            );
            // Ambil data level (ini yang nentuin gembok)
            final levels = LevelModel.getDefaultLevels(
              defaultStudent.currentLevel,
            );

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
          // Ambil data level (ini yang nentuin gembok)
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
    // Ini udah bagus, gw biarin
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
            offset: Offset(0, 4),
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
                  // Nampilin level dari data stream
                  'LEVEL ${student.currentLevel}/5',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(1, 1),
                              blurRadius: 2)
                        ],
                      ),
                ),
                AppSpacing.vSm,
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: student.levelProgress,
                    minHeight: 10, // Ditebelin dikit
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
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
    List<LevelModel> levels, // levels[0]=Lvl 1, levels[1]=Lvl 2, dst.
  ) {
    return SingleChildScrollView(
      child: Container(
        height: 2200, // <-- Tinggi total peta
        child: Stack(
          children: [
            // LAPISAN 1: DEKORASI
            _buildDecorativeElements(context),

            // LAPISAN 2: SEMUA ELEMEN PETA
            // KORDINAT LU NGGAK GW UBAH
            // Level 5 (Paling Atas Kiri)
            Positioned(
              top: 290,
              left: 30,
              child: _buildLevelIsland(context, levels[4]), // levels[4] = Level 5
            ),
            // Path (Jembatan) dari 4 ke 5
            Positioned(
              top: 230,
              left: -20,
              child: _buildPathConnection(true), // true = tangga.png
            ),

            // Level 4 (Tengah Kanan)
            Positioned(
              top: 520,
              right: 0,
              child: _buildLevelIsland(context, levels[3]), // levels[3] = Level 4
            ),
            // Path (Lengkung) dari 3 ke 4
            Positioned(
              top: 450,
              right: -70,
              child: _buildPathConnection(false), // false = lengkung.png
            ),

            // Level 3 (Tengah Kiri)
            Positioned(
              top: 650,
              left: 25,
              child: _buildLevelIsland(context, levels[2]), // levels[2] = Level 3
            ),
            // Path (Jembatan) dari 2 ke 3
            Positioned(
              top: 600,
              left: -40,
              child: _buildPathConnection(true), // true = tangga.png
            ),

            // Path (Lengkung) dari 1 ke 2
            Positioned(
              top: 800,
              right: -40,
              child: _buildPathConnection(false), // false = lengkung.png
            ),

            // Level 2 (Bawah Kanan)
            Positioned(
              top: 870,
              right: 30,
              child: _buildLevelIsland(context, levels[1]), // levels[1] = Level 2
            ),

            // Starting Point (Level 1) (Paling Bawah Kiri)
            Positioned(
              top: 1000,
              left: 10,
              child: _buildStartingPoint(context), // <-- INI YANG DIKLIK
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DEKORASI (BALON & BINTANG) ---
  Widget _buildDecorativeElements(BuildContext context) {
    // Nggak diubah
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
    // Bikin balonnya lebih berkilau
    return Container(
      width: 35,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        gradient: RadialGradient(
          center: Alignment(-0.5, -0.5),
          colors: [
            Colors.white.withOpacity(0.7),
            color,
          ],
          stops: [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(2, 2))
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
  // --- NAVIGASI DIBENERIN ---
  Widget _buildStartingPoint(BuildContext context) {
    const islandColor = Color(0xFF4CAF50); // Green

    return GestureDetector(
      onTap: () {
        // --- 2. INI KODE YANG UDAH BENER ---
        // Pake nama rute dari AppRoutes, BUKAN string '/play_level_1'
        Navigator.pushNamed(context, AppRoutes.playLevel1);

        print('Masuk ke Level 1!');
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: islandColor,
          shape: BoxShape.circle,
          // Bikin berkilau (shiny)
          gradient: RadialGradient(
            center: Alignment(-0.7, -0.7), // Titik kilau di kiri atas
            radius: 1.0,
            colors: [
              Colors.white.withOpacity(0.5), // Warna kilau
              islandColor, // Warna asli
            ],
            stops: [0.0, 1.0],
          ),
          boxShadow: [
            // Bayangan utama
            BoxShadow(
              color: Colors.black.withOpacity(0.4), // Bayangan lebih gelap
              blurRadius: 15,
              offset: const Offset(4, 4),
            ),
            // Efek 'rim' 3D
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

  // --- WIDGET JALAN (PATH) - BALIK PAKE PNG ---
  Widget _buildPathConnection(bool useLadder) {
    // KORDINAT LU NGGAK GW UBAH
    return Container(
      width: 450,
      height: 450,
      child: Image.asset(
        useLadder ? 'assets/img/tangga.png' : 'assets/img/lengkung.png',
        height: 220, // Ukuran asli gambar
        width: 220, // Ukuran asli gambar
        fit: BoxFit.contain,
      ),
    );
  }

  // --- WIDGET PULAU LEVEL (DIPERBAGUS) ---
  // --- NAVIGASI DIBENERIN ---
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
              // --- 3. INI KODE YANG UDAH BENER ---
              Navigator.pushNamed(
                context,
                AppRoutes.playLevel, // <-- Pake AppRoutes
                arguments: level.levelNumber, // <-- Kirim nomor level
              );

              print('Masuk ke ${level.levelName}');
            }
          : null, // Kalo 'isUnlocked' false, onTap-nya null (nggak bisa diklik)
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: cloudColor.withOpacity(0.9),
          shape: BoxShape.circle,
          // Bikin berkilau (shiny)
          gradient: RadialGradient(
            center: Alignment(-0.7, -0.7), // Titik kilau di kiri atas
            radius: 1.0,
            colors: [
              Colors.white.withOpacity(0.5), // Warna kilau
              cloudColor, // Warna asli
            ],
            stops: [0.0, 1.0],
          ),
          boxShadow: [
            // Bayangan utama
            BoxShadow(
              color: Colors.black.withOpacity(0.4), // Bayangan lebih gelap
              blurRadius: 15,
              offset: const Offset(4, 4),
            ),
            // Efek 'rim' 3D
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
                          // Kasih bayangan di teks biar kebaca
                          shadows: [
                            Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(1, 1),
                                blurRadius: 2)
                          ],
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (!level.isUnlocked)
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none, // Biar gemboknya bisa keluar
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3), // Bikin gelap
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.water_drop,
                            color: cloudColor.withOpacity(0.5),
                            size: 30,
                          ),
                        ),
                        // Gemboknya gw taruh di atas
                        Positioned(
                          top: -10, // Keluar dari lingkaran
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 4,
                                    offset: Offset(0, 2))
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