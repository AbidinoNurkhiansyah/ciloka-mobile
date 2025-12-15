import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/routes/app_routes.dart';
import 'teacher/viewmodels/auth_teacher_viewmodel.dart';
import 'student/viewmodels/auth_student_viewmodel.dart';
import 'parent/viewmodels/auth_parent_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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

    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('user_role');
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (userRole == 'teacher') {
        // Load session teacher
        if (mounted) {
          final authTeacherVm = context.read<AuthTeacherViewmodel>();
          await authTeacherVm.loadTeacherSession();
          Navigator.pushReplacementNamed(context, AppRoutes.mainTeacher);
        }
      } else if (userRole == 'student') {
        // Load session student (jika perlu)
        if (mounted) {
          final authStudentVm = context.read<AuthStudentViewmodel>();
          await authStudentVm.loadStudentProfile(); // Reload data student
          Navigator.pushReplacementNamed(context, AppRoutes.mainStudent);
        }
      } else if (userRole == 'parent') {
        // Load session parent
        if (mounted) {
          final authParentVm = context.read<AuthParentViewmodel>();
          await authParentVm.loadParentSession();
          Navigator.pushReplacementNamed(context, AppRoutes.mainParent);
        }
      } else {
        // Fallback jika user ada tapi role tidak jelas (biasanya student lama)
        Navigator.pushReplacementNamed(context, AppRoutes.mainStudent);
      }
    } else {
      // Belum login
      Navigator.pushReplacementNamed(context, AppRoutes.selectRole);
    }
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
              child: SizedBox(
                height: 300,
                width: 300,
                child: Image.asset('assets/img/logo_ciloka.webp', height: 150),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
