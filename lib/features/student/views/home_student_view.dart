import 'package:ciloka_app/core/theme/app_spacing.dart';
import 'package:ciloka_app/features/student/models/level_model.dart';
import 'package:ciloka_app/features/student/models/user_student_model.dart';
import 'package:ciloka_app/features/student/services/student_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ciloka_app/core/routes/app_routes.dart';

class HomeStudentView extends StatefulWidget {
  const HomeStudentView({super.key});

  @override
  State<HomeStudentView> createState() => _HomeStudentViewState();
}

class _HomeStudentViewState extends State<HomeStudentView> {
  final ScrollController _mapScrollController = ScrollController();
  bool _hasScrolledToStart = false;

  void _scrollToLevel1IfNeeded(BuildContext context) {
    if (_hasScrolledToStart) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mapScrollController.hasClients) return;

      const double level1Top = 1000.0;
      const double level1Height = 120.0;

      final position = _mapScrollController.position;
      final viewport = position.viewportDimension;

      double targetOffset = level1Top - (viewport / 2 - level1Height / 2);

      if (targetOffset < 0) targetOffset = 0;
      if (targetOffset > position.maxScrollExtent) {
        targetOffset = position.maxScrollExtent;
      }

      _mapScrollController.jumpTo(targetOffset);
      _hasScrolledToStart = true;
    });
  }

  @override
  void dispose() {
    _mapScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      final defaultStudent = StudentModel(
        uid: '',
        username: '',
        studentName: 'Siswa',
        email: '',
        photoUrl: '',
        currentLevel: 1,
        levelProgress: 0.1,
      );
      final levels = LevelModel.getDefaultLevels(defaultStudent.currentLevel);

      return Scaffold(
        body: _background(
          child: SafeArea(
            child: Column(
              children: [
                _profile(context, defaultStudent),
                Expanded(child: _levelMap(context, defaultStudent, levels)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: _background(
        child: StreamBuilder<StudentModel?>(
          stream: StudentService().streamStudentProfile(uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              final dummy = StudentModel(
                uid: uid,
                username: '',
                studentName: 'Siswa',
                email: '',
                photoUrl: '',
                currentLevel: 1,
                levelProgress: 0.1,
              );

              final levels = LevelModel.getDefaultLevels(dummy.currentLevel);

              return SafeArea(
                child: Column(
                  children: [
                    _profile(context, dummy),
                    Expanded(child: _levelMap(context, dummy, levels)),
                  ],
                ),
              );
            }

            final student = snapshot.data!;
            final levels = LevelModel.getDefaultLevels(student.currentLevel);

            return SafeArea(
              child: Column(
                children: [
                  _profile(context, student),
                  Expanded(child: _levelMap(context, student, levels)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // BACKGROUND BIRU
  Widget _background({required Widget child}) {
    return Container(color: const Color(0xFFB0DAFD), child: child);
  }

  // 🧑‍🎓 PROFILE SECTION (dengan nama studentName & bar 5 level)
  Widget _profile(BuildContext context, StudentModel student) {
    final displayName = student.studentName.isNotEmpty
        ? student.studentName
        : (FirebaseAuth.instance.currentUser?.displayName ?? "Siswa");

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF00BCD4)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.3),
            backgroundImage: student.photoUrl.isNotEmpty
                ? NetworkImage(student.photoUrl)
                : null,
            child: student.photoUrl.isEmpty
                ? const Text("😊", style: TextStyle(fontSize: 32))
                : null,
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $displayName ✨",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                AppSpacing.vSm,
                Text(
                  "Level ${student.currentLevel} dari 5 🎮",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                AppSpacing.vSm,
                _levelBar(student.currentLevel, 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bar 5 kotak, yang keisi = currentLevel (misal level 3 → 3 kotak nyala)
  Widget _levelBar(int currentLevel, int maxLevel) {
    return Row(
      children: List.generate(maxLevel, (index) {
        final lv = index + 1;
        final bool isFilled = lv <= currentLevel;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == maxLevel - 1 ? 0 : 4),
            height: 8,
            decoration: BoxDecoration(
              color: isFilled ? const Color(0xFFFFD54F) : Colors.white24,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }

  // 🌍 LEVEL MAP
  Widget _levelMap(
    BuildContext context,
    StudentModel student,
    List<LevelModel> levels,
  ) {
    _scrollToLevel1IfNeeded(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    "Peta Petualangan Membaca 📚",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              top: 56,
              child: SingleChildScrollView(
                controller: _mapScrollController,
                child: SizedBox(
                  height: 2200,
                  child: Stack(
                    children: [
                      _decorations(),

                      Positioned(
                        top: 290,
                        left: 30,
                        child: _levelIsland(context, levels[4]),
                      ),
                      Positioned(top: 230, left: -20, child: _path(true)),

                      Positioned(
                        top: 520,
                        right: 0,
                        child: _levelIsland(context, levels[3]),
                      ),
                      Positioned(top: 450, right: -70, child: _path(false)),

                      Positioned(
                        top: 650,
                        left: 25,
                        child: _levelIsland(context, levels[2]),
                      ),
                      Positioned(top: 600, left: -40, child: _path(true)),

                      Positioned(top: 800, right: -40, child: _path(false)),

                      Positioned(
                        top: 870,
                        right: 30,
                        child: _levelIsland(context, levels[1]),
                      ),

                      Positioned(
                        top: 1000,
                        left: 10,
                        child: _startButton(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ dekorasi
  Widget _decorations() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(left: 50, top: 80, child: _star(Colors.yellow, 12)),
          Positioned(left: 120, top: 150, child: _star(Colors.pink, 8)),
          Positioned(left: 200, top: 100, child: _star(Colors.purple, 10)),
          Positioned(right: 60, top: 120, child: _star(Colors.yellow, 9)),
          Positioned(right: 100, top: 200, child: _star(Colors.blue, 7)),
        ],
      ),
    );
  }

  Widget _star(Color c, double s) => Icon(Icons.star, color: c, size: s);

  // 🪜 path
  Widget _path(bool ladder) {
    return IgnorePointer(
      child: SizedBox(
        width: 450,
        height: 450,
        child: Image.asset(
          ladder ? 'assets/img/tangga.png' : 'assets/img/lengkung.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // 🟢 Level Island (dengan gembok kalau belum kebuka)
  Widget _levelIsland(BuildContext context, LevelModel level) {
    Color color;
    String emoji;

    switch (level.levelNumber) {
      case 2:
        color = const Color(0xFF9C27B0);
        emoji = "📖";
        break;
      case 3:
        color = const Color(0xFF2196F3);
        emoji = "🚀";
        break;
      case 4:
        color = const Color(0xFF4CAF50);
        emoji = "🌈";
        break;
      case 5:
        color = const Color(0xFFE91E63);
        emoji = "🏆";
        break;
      default:
        color = Colors.grey;
        emoji = "⭐";
    }

    // ➜ pastikan LevelModel punya field isUnlocked
    final bool isUnlocked = level.isUnlocked;

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.pushNamed(
                context,
                AppRoutes.playLevel,
                arguments: level.levelNumber,
              );
            }
          : null,
      child: Column(
        children: [
          Text(
            "Level ${level.levelNumber}",
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulau
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (isUnlocked ? color : Colors.grey).withOpacity(0.9),
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.5),
                      isUnlocked ? color : Colors.grey,
                    ],
                    center: const Alignment(-0.6, -0.6),
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 30)),
                ),
              ),

              // Overlay gelap + icon gembok
              if (!isUnlocked)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 30),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 🟩 Start Button
  Widget _startButton(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Mulai di sini 🚀",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.playLevel1),
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4CAF50),
            ),
            child: const Center(
              child: Text("🎯", style: TextStyle(fontSize: 36)),
            ),
          ),
        ),
      ],
    );
  }
}
