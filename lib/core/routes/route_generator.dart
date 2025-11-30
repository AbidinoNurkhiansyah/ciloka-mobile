import 'package:flutter/material.dart';

// --- IMPORT FILE HALAMAN ---
import '../../core/views/error_view.dart';
import '../../features/student/views/play_level_view.dart';
import '../../features/parent/views/login_parent_view.dart';
import '../../features/parent/views/main_parent_view.dart';
import '../../features/select_role_screen.dart';
import '../../features/splash_screen.dart';
import '../../features/student/views/login_student_view.dart';
import '../../features/student/views/main_student_view.dart';
import '../../features/teacher/views/add_student_teacher_screen.dart';
import '../../features/teacher/views/chat_teacher_view.dart';
import '../../features/teacher/views/class_student_list_view.dart';
import '../../features/teacher/views/class_teacher_view.dart';
import '../../features/teacher/views/login_teacher_view.dart';
import '../../features/teacher/views/main_teacher_view.dart';
import '../../features/teacher/views/register_teacher_view.dart';
import 'package:ciloka_app/features/student/views/chat_page.dart';
import 'app_routes.dart';

// --- IMPORT 3 GAME LU (PASTIIN PATH & NAMA FILENYA BENER) ---
import '../../features/student/games/latihan_berhitung/latihan_berhitung_view.dart';
import '../../features/student/games/latihan_menulis/latihan_menulis_view.dart';
import '../../features/student/games/latihan_mengeja/latihan_mengeja_view.dart'; // <-- Ganti nama file ini kalo beda

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.selectRole:
        return MaterialPageRoute(builder: (_) => const SelectRoleScreen());

      // Teacher Routes Generator
      case AppRoutes.loginTeacher:
        return MaterialPageRoute(builder: (_) => const LoginTeacherView());
      case AppRoutes.registerTeacher:
        return MaterialPageRoute(builder: (_) => const RegisterTeacherView());
      case AppRoutes.mainTeacher:
        return MaterialPageRoute(builder: (_) => const MainTeacherView());
      case AppRoutes.chatTeacher:
        return MaterialPageRoute(builder: (_) => const ChatTeacherView());
      case AppRoutes.classDataTeacher:
        return MaterialPageRoute(
          builder: (_) => const ClassStudentListView(),
          settings: settings,
        );
      case AppRoutes.classTeacher:
        return MaterialPageRoute(builder: (_) => const ClassTeacherView());
      case AppRoutes.addStudentTeacher:
        return MaterialPageRoute(
          builder: (_) => const AddStudentTeacherScreen(),
          settings: settings,
        );

      // Parent Routes Generator
      case AppRoutes.loginParent:
        return MaterialPageRoute(builder: (_) => const LoginParentView());
      case AppRoutes.mainParent:
        return MaterialPageRoute(builder: (_) => const MainParentView());

      // student routes generator
      case AppRoutes.loginStudent:
        return MaterialPageRoute(builder: (_) => const LoginStudentView());
      case AppRoutes.mainStudent:
        return MaterialPageRoute(builder: (_) => const MainStudentView());
      case AppRoutes.chatStudent:
        return MaterialPageRoute(
          builder: (_) =>
              const ChatPage(teacherId: 'teacherId', studentId: 'studentId'),
        );

      // --- RUTE LEVEL ---
      case AppRoutes.playLevel1:
        return MaterialPageRoute(
          builder: (_) => const PlayLevelView(levelNumber: 1),
        );
      case AppRoutes.playLevel:
        if (settings.arguments is int) {
          final levelNumber = settings.arguments as int; // Ambil nomor level
          return MaterialPageRoute(
            builder: (_) => PlayLevelView(levelNumber: levelNumber),
          );
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());

      // --- RUTE GAME ---
      case AppRoutes.gameLatihanBerhitung:
        if (settings.arguments is int) {
          final levelNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => LatihanBerhitungView(levelNumber: levelNumber),
          );
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());

      case AppRoutes.gameLatihanMenulis:
        if (settings.arguments is int) {
          final levelNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => LatihanMenulisView(levelNumber: levelNumber),
          );
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());

      case AppRoutes.gameLatihanMengeja:
        if (settings.arguments is int) {
          final levelNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => PengejaanView(levelNumber: levelNumber),
          );
        }
        return MaterialPageRoute(builder: (_) => const ErrorView());
      // --- BATAS RUTE GAME ---

      default:
        // Ganti error default jelek pake ErrorView yang bagus
        return MaterialPageRoute(builder: (_) => const ErrorView());
    }
  }
}
