import 'package:cached_network_image/cached_network_image.dart';
import 'package:ciloka_app/core/theme/app_spacing.dart';
import 'package:ciloka_app/features/student/models/level_model.dart';
import 'package:ciloka_app/features/student/models/user_student_model.dart';
import 'package:ciloka_app/features/student/services/student_service.dart';
import 'package:ciloka_app/features/student/viewmodels/auth_student_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ciloka_app/core/routes/app_routes.dart';

class HomeStudentView extends StatefulWidget {
  const HomeStudentView({super.key});

  @override
  State<HomeStudentView> createState() => _HomeStudentViewState();
}

class _HomeStudentViewState extends State<HomeStudentView>
    with TickerProviderStateMixin {
  final ScrollController _mapScrollController = ScrollController();
  AnimationController? _profileAnimController;
  AnimationController? _bounceController;
  Animation<double>? _profileSlideAnimation;
  Animation<double>? _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Profile card slide-in animation
    _profileAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _profileSlideAnimation = CurvedAnimation(
      parent: _profileAnimController!,
      curve: Curves.easeOutBack,
    );

    // Bounce animation for level islands
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bounceController!, curve: Curves.easeInOut),
    );

    _profileAnimController!.forward();
  }

  @override
  void dispose() {
    _mapScrollController.dispose();
    _profileAnimController?.dispose();
    _bounceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStudentViewmodel>(
      builder: (context, authVm, _) {
        final uid = authVm.authUid;
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
                  final levels = LevelModel.getDefaultLevels(
                    student.currentLevel,
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: _levelMap(context, student, levels),
                      ),
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
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BACKGROUND
  // ---------------------------------------------------------------------------
  Widget _background({required Widget child}) {
    return Container(color: const Color(0xFFB0DAFD), child: child);
  }

  // ---------------------------------------------------------------------------
  // PROFILE HEADER (with slide-in animation)
  // ---------------------------------------------------------------------------
  Widget _profile(BuildContext context, StudentModel student) {
    final displayName = student.studentName.isNotEmpty
        ? student.studentName
        : "Siswa";

    final profileContent = _buildProfileContent(context, student, displayName);

    // If animation not ready, show without animation
    if (_profileSlideAnimation == null) {
      return profileContent;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_profileSlideAnimation!),
      child: FadeTransition(
        opacity: _profileSlideAnimation!,
        child: profileContent,
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    StudentModel student,
    String displayName,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF00BCD4)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated avatar with pulse effect
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.95, end: 1.05),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    backgroundImage: student.photoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(student.photoUrl)
                        : null,
                    child: student.photoUrl.isEmpty
                        ? const Text("😊", style: TextStyle(fontSize: 32))
                        : null,
                  ),
                ),
              );
            },
            onEnd: () {
              if (mounted) setState(() {});
            },
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
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                AppSpacing.vSm,
                Text(
                  "Level ${student.currentLevel} dari 5",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
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
        final isActive = lv <= currentLevel;

        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: isActive ? 1 : 0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Container(
                margin: EdgeInsets.only(right: index == maxLevel - 1 ? 0 : 4),
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? Color.lerp(
                          Colors.white24,
                          const Color(0xFFFFD54F),
                          value,
                        )
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isActive && value > 0.5
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFFFFD54F,
                            ).withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              );
            },
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

    final positions = [135, 350, 500, 705, 850];
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
              child: _levelIsland(context, levels[4], 0, student.currentLevel),
            ),
            Positioned(top: 300, right: -70, child: _path(false)),
            Positioned(
              top: 350,
              right: 16,
              child: _levelIsland(context, levels[3], 1, student.currentLevel),
            ),
            Positioned(top: 465, left: -45, child: _path(true)),
            Positioned(
              top: 500,
              left: 16,
              child: _levelIsland(context, levels[2], 2, student.currentLevel),
            ),
            Positioned(top: 660, left: -16, child: _path(false)),
            Positioned(
              top: 705,
              right: 16,
              child: _levelIsland(context, levels[1], 3, student.currentLevel),
            ),
            Positioned(
              top: 850,
              left: 10,
              child: _startButton(context, student.currentLevel),
            ),
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
  // ISLAND LEVEL (with animations!)
  // ---------------------------------------------------------------------------
  Widget _levelIsland(
    BuildContext context,
    LevelModel level,
    int index,
    int currentStudentLevel,
  ) {
    // Colors and emojis map are removed/unused if we fully switch to assets,
    // but kept just in case you want fallback or glow colors.
    final colors = {
      1: Colors.grey,
      2: const Color(0xFF9C27B0),
      3: const Color(0xFF2196F3),
      4: const Color(0xFF4CAF50),
      5: const Color(0xFFE91E63),
    };

    final bool isUnlocked = level.isUnlocked;
    final bool isCurrentLevel = level.levelNumber == currentStudentLevel;

    // If animation not ready yet, return without bounce
    if (_bounceAnimation == null) {
      return _buildIslandContent(
        context,
        level,
        index,
        colors,
        isUnlocked,
        isCurrentLevel,
        0,
      );
    }

    return AnimatedBuilder(
      animation: _bounceAnimation!,
      builder: (context, child) {
        return _buildIslandContent(
          context,
          level,
          index,
          colors,
          isUnlocked,
          isCurrentLevel,
          _bounceAnimation!.value,
        );
      },
    );
  }

  Widget _buildIslandContent(
    BuildContext context,
    LevelModel level,
    int index,
    Map<int, Color> colors,
    bool isUnlocked,
    bool isCurrentLevel,
    double bounceValue,
  ) {
    return Transform.translate(
      offset: isUnlocked
          ? Offset(0, bounceValue * (1 + index * 0.3))
          : Offset.zero,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 600 + (index * 200)),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: isUnlocked
                  ? () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.playLevel,
                        arguments: level.levelNumber,
                      );
                    }
                  : null,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      // Island Image
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Main Island Asset
                          Image.asset(
                            level.levelNumber <= 5
                                ? 'assets/img/games/level${level.levelNumber}.png'
                                : 'assets/img/games/level3.png', // Fallback for > 5
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            colorBlendMode: isUnlocked
                                ? null
                                : BlendMode.modulate,
                            color: isUnlocked
                                ? null
                                : Colors.grey.withValues(alpha: 0.7),
                          ),

                          // Lock Overlay if locked
                          if (!isUnlocked)
                            Container(
                              width: 150,
                              height: 150,
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Level Label (Below Island)
                      SafeArea(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "Level ${level.levelNumber}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Character Marker (If Current Level)
                  if (isCurrentLevel)
                    Positioned(
                      top: -10, // Adjust to stand ON the island
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 10),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              value > 5 ? 10 - value : value,
                            ), // Bobbing effect
                            child: Image.asset(
                              'assets/img/games/char.png',

                              height: 90, // Adjust based on asset aspect ratio
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                        onEnd: () {
                          if (mounted) setState(() {});
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // START BUTTON (with pulse animation)
  // ---------------------------------------------------------------------------
  Widget _startButton(BuildContext context, int currentLevel) {
    final bool isCurrentLevel = currentLevel == 1;

    // If animation not ready yet, return without bounce
    if (_bounceAnimation == null) {
      return _buildStartButtonContent(context, isCurrentLevel, 0);
    }

    return AnimatedBuilder(
      animation: _bounceAnimation!,
      builder: (context, child) {
        return _buildStartButtonContent(
          context,
          isCurrentLevel,
          _bounceAnimation!.value,
        );
      },
    );
  }

  Widget _buildStartButtonContent(
    BuildContext context,
    bool isCurrentLevel,
    double bounceValue,
  ) {
    return Transform.translate(
      offset: Offset(0, bounceValue * 1.3), // Bounce effect like other islands
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Pulsing start button with character
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: 1.1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  builder: (context, pulseScale, child) {
                    return Transform.scale(
                      scale: pulseScale,
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.playLevel1),
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Level 1 Island Image
                              Center(
                                child: Image.asset(
                                  'assets/img/games/level1.png',
                                ),
                              ),

                              // Character (if current level is 1)
                              if (isCurrentLevel)
                                Positioned(
                                  top: -5,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 10),
                                    duration: const Duration(
                                      milliseconds: 1500,
                                    ),
                                    curve: Curves.easeInOut,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          value > 5 ? 10 - value : value,
                                        ),
                                        child: Image.asset(
                                          'assets/img/games/char.png',
                                          height: 70,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                    onEnd: () {
                                      if (mounted) setState(() {});
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
