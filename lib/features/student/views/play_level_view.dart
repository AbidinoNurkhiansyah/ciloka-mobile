import 'package:flutter/material.dart';
import 'package:ciloka_app/core/routes/app_routes.dart';

class PlayLevelView extends StatefulWidget {
  final int levelNumber;

  const PlayLevelView({super.key, required this.levelNumber});

  @override
  State<PlayLevelView> createState() => _PlayLevelViewState();
}

class _PlayLevelViewState extends State<PlayLevelView>
    with TickerProviderStateMixin {
  late AnimationController _birdController;
  late AnimationController _buttonController;
  late AnimationController _characterController;
  late Animation<double> _birdAnimation;
  late Animation<double> _buttonPulseAnimation;
  late Animation<Offset> _characterSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Bird floating animation
    _birdController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _birdAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _birdController, curve: Curves.easeInOut),
    );

    // Button pulse animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    // Character entrance animation
    _characterController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _characterSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _characterController,
            curve: Curves.elasticOut,
          ),
        );

    _characterController.forward();
  }

  @override
  void dispose() {
    _birdController.dispose();
    _buttonController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB0DAFD),
      body: Stack(
        children: [
          // 2. Decorative Background Shapes (Bubbles/Circles) - NEW
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: 40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. Floating Stars/Sparkles
          ...List.generate(5, (index) {
            return _buildFloatingStar(index * 0.2, index * 100.0, index * 50.0);
          }),

          // 4. Character with entrance animation - LARGER SIZE
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25, // Adjusted top
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _characterSlideAnimation,
              child: FadeTransition(
                opacity: _characterController,
                child: Image.asset(
                  'assets/img/level/orang.png',
                  height: 400, // Increased size significantly from 250
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 400,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person,
                        size: 300,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 5. Pulsing START Button with glow
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1, // Adjusted bottom
            left: 50,
            right: 50,
            child: AnimatedBuilder(
              animation: _buttonPulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonPulseAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2ACCF0).withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ACCF0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        debugPrint('Mulai Level ${widget.levelNumber}!');
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.gameLatihanMenulis,
                          arguments: widget.levelNumber,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'MULAI',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: const Icon(
                                  Icons.play_circle_filled_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 6. Bird & Speech Bubble with floating animation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: _birdAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _birdAnimation.value),
                    child: Stack(
                      children: [
                        // Bird
                        Positioned(
                          top: 20,
                          left: 0,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Image.asset(
                                  'assets/img/level/burung_level.png',
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.shade700,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.flutter_dash,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        // Speech Bubble with bounce
                        Positioned(
                          top: 80,
                          left: 90,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: _buildSpeechBubble(
                                  context,
                                  'Ayo Mulai Level ${widget.levelNumber}! 🎯',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 7. Level Badge (Top Right)
          Positioned(
            top: 50,
            right: 16,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Level ${widget.levelNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 8. Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2ACCF0),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Floating stars/sparkles
  Widget _buildFloatingStar(double delay, double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 1000 + (delay * 1000).toInt()),
        curve: Curves.easeOut,
        builder: (context, opacity, child) {
          return Opacity(
            opacity: opacity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: 0.5 + (scale * 0.5),
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.yellow.shade300.withValues(alpha: 0.7),
                    size: 30,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Enhanced speech bubble
  Widget _buildSpeechBubble(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.blue.shade50]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF2ACCF0).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF007B9E),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
