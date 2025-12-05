import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  void dispose() {
    _mapScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final defaultStudent = StudentModel(
      uid: uid ?? '',
      username: '',
      studentName: 'Siswa',
      email: '',
      photoUrl: '',
      currentLevel: 1,
      levelProgress: 0.1,
    );

    if (uid == null) {
      final levels = LevelModel.getDefaultLevels(1);

      return Scaffold(
        body: SafeArea(
          child: _background(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _levelMap(context, defaultStudent, levels),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _profile(context, defaultStudent),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: _background(
          child: StreamBuilder<StudentModel?>(
            stream: StudentService().streamStudentProfile(uid),
            builder: (context, snapshot) {
              final student = snapshot.data ?? defaultStudent;
              final levels = LevelModel.getDefaultLevels(student.currentLevel);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: _levelMap(context, student, levels)),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _profile(context, student),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BACKGROUND
  // ---------------------------------------------------------------------------
  Widget _background({required Widget child}) {
    return Container(color: const Color(0xFFB0DAFD), child: child);
  }

  // ---------------------------------------------------------------------------
  // PROFILE HEADER
  // ---------------------------------------------------------------------------
  Widget _profile(BuildContext context, StudentModel student) {
    final displayName = student.studentName.isNotEmpty
        ? student.studentName
        : (FirebaseAuth.instance.currentUser?.displayName ?? "Siswa");

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ), // ⬅ tidak dorong ke bawah
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF00BCD4)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.3),
            backgroundImage: student.photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(student.photoUrl)
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

  Widget _levelBar(int currentLevel, int maxLevel) {
    return Row(
      children: List.generate(maxLevel, (index) {
        final lv = index + 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == maxLevel - 1 ? 0 : 4),
            height: 8,
            decoration: BoxDecoration(
              color: lv <= currentLevel
                  ? const Color(0xFFFFD54F)
                  : Colors.white24,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // LEVEL MAP
  // ---------------------------------------------------------------------------
  Widget _levelMap(
    BuildContext context,
    StudentModel student,
    List<LevelModel> levels,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mapScrollController.hasClients) {
        _mapScrollController.jumpTo(
          _mapScrollController.position.maxScrollExtent,
        );
      }
    });

    final positions = [135, 350, 500, 720, 850];
    final double autoHeight = positions.reduce((a, b) => a > b ? a : b) + 160;

    return SingleChildScrollView(
      controller: _mapScrollController,
      child: SizedBox(
        height: autoHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(top: 110, left: -45, child: _path(true)),
            Positioned(
              top: 135,
              left: 16,
              child: _levelIsland(context, levels[4]),
            ),
            Positioned(top: 300, right: -70, child: _path(false)),
            Positioned(
              top: 350,
              right: 16,
              child: _levelIsland(context, levels[3]),
            ),
            Positioned(top: 465, left: -45, child: _path(true)),
            Positioned(
              top: 500,
              left: 16,
              child: _levelIsland(context, levels[2]),
            ),
            Positioned(top: 660, left: -16, child: _path(false)),
            Positioned(
              top: 720,
              right: 16,
              child: _levelIsland(context, levels[1]),
            ),
            Positioned(top: 850, left: 10, child: _startButton(context)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PATH IMAGE
  // ---------------------------------------------------------------------------
  Widget _path(bool ladder) {
    return SizedBox(
      width: 450,
      height: 450,
      child: Image.asset(
        ladder ? 'assets/img/tangga.png' : 'assets/img/lengkung.png',
        fit: BoxFit.contain,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ISLAND LEVEL
  // ---------------------------------------------------------------------------
  Widget _levelIsland(BuildContext context, LevelModel level) {
    final colors = {
      1: Colors.grey,
      2: const Color(0xFF9C27B0),
      3: const Color(0xFF2196F3),
      4: const Color(0xFF4CAF50),
      5: const Color(0xFFE91E63),
    };

    final emojis = {1: "⭐", 2: "📖", 3: "🚀", 4: "🌈", 5: "🏆"};

    final bool isUnlocked = level.isUnlocked;

    return GestureDetector(
      onTap: isUnlocked
          ? () => Navigator.pushNamed(
              context,
              AppRoutes.playLevel,
              arguments: level.levelNumber,
            )
          : null,
      child: Column(
        children: [
          Text(
            "Level ${level.levelNumber}",
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (isUnlocked ? colors[level.levelNumber] : Colors.grey)
                      ?.withOpacity(0.9),
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.5),
                      isUnlocked ? colors[level.levelNumber]! : Colors.grey,
                    ],
                    center: const Alignment(-0.6, -0.6),
                  ),
                ),
                child: Center(
                  child: Text(
                    emojis[level.levelNumber]!,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),

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

  // ---------------------------------------------------------------------------
  // START BUTTON
  // ---------------------------------------------------------------------------
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
