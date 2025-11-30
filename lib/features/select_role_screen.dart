import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/global_navigator.dart';
import '../widgets/card_role_widget.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0,
          duration: Duration(milliseconds: 1200),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    child: Image.asset('assets/img/logo_ciloka.webp'),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: AppSpacing.md),
                    child: Column(
                      children: [
                        Text(
                          'Ayo Pilih Peranmu!',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        AppSpacing.vSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CardRoleWidget(
                              imagePath: 'assets/img/img_teacher_role.webp',
                              onTap: () {
                                GlobalNavigator.pushNamed(
                                  AppRoutes.loginTeacher,
                                );
                              },
                            ),
                            AppSpacing.hSm,
                            CardRoleWidget(
                              imagePath: 'assets/img/img_parent_role.webp',
                              onTap: () {
                                GlobalNavigator.pushNamed(
                                  AppRoutes.loginParent,
                                );
                              },
                            ),
                          ],
                        ),
                        CardRoleWidget(
                          imagePath: 'assets/img/img_student_role.webp',
                          onTap: () {
                            GlobalNavigator.pushNamed(AppRoutes.loginStudent);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
