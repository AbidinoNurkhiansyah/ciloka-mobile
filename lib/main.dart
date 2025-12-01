import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/error/error_notifier.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/global_navigator.dart';
import 'core/utils/global_snackbar.dart';
import 'features/parent/services/auth_parent_service.dart';
import 'features/parent/viewmodels/auth_parent_viewmodel.dart';
import 'features/parent/viewmodels/navigation_parent_viewmodel.dart';
import 'features/student/services/auth_student_service.dart';
import 'features/student/services/chat_service.dart';
import 'features/student/viewmodels/auth_student_viewmodel.dart';
import 'features/student/viewmodels/chat_room_viewmodel.dart';
import 'features/student/viewmodels/navigation_student_viewmodel.dart';
import 'features/teacher/services/class_teacher_service.dart';
import 'features/teacher/services/firebase_auth_service.dart';
import 'features/teacher/services/student_class_service.dart';
import 'features/teacher/services/upload_image_service.dart';
import 'features/teacher/viewmodels/auth_teacher_viewmodel.dart';
import 'features/teacher/viewmodels/class_viewmodel.dart';
import 'features/teacher/viewmodels/navigation_teacher_viewmodel.dart';
import 'features/teacher/viewmodels/student_list_viewmodel.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    ErrorNotifier.global.handleError(details.exception);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorNotifier.global.handleError(error);
    return true;
  };
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => firebaseAuth),
        Provider(create: (context) => firebaseFirestore),
        Provider<FirebaseAuthService>(
          create: (context) =>
              FirebaseAuthService(context.read<FirebaseAuth>()),
        ),
        ChangeNotifierProvider(create: (_) => ErrorNotifier()),
        ChangeNotifierProxyProvider<FirebaseAuthService, AuthTeacherViewmodel>(
          create: (context) =>
              AuthTeacherViewmodel(context.read<FirebaseAuthService>()),
          update: (_, authService, previous) =>
              previous!..updateAuthService(authService),
        ),

        Provider<ClassTeacherService>(create: (_) => ClassTeacherService()),

        ChangeNotifierProxyProvider<ClassTeacherService, ClassViewModel>(
          create: (context) =>
              ClassViewModel(context.read<ClassTeacherService>()),
          update: (_, firestoreService, previous) =>
              previous!..updateService(firestoreService),
        ),

        Provider(create: (_) => StudentClassService()),
        Provider(create: (_) => UploadImageService()),
        ChangeNotifierProxyProvider2<
          StudentClassService,
          UploadImageService,
          StudentListViewmodel
        >(
          create: (context) => StudentListViewmodel(
            context.read<StudentClassService>(),
            context.read<UploadImageService>(),
          ),
          update: (_, studentService, imageService, previous) =>
              previous!..updateService(studentService),
        ),

        ChangeNotifierProvider(create: (_) => NavigationTeacherViewmodel()),

        // parent provider
        Provider(create: (_) => AuthParentService()),
        ChangeNotifierProxyProvider<AuthParentService, AuthParentViewmodel>(
          create: (context) =>
              AuthParentViewmodel(context.read<AuthParentService>()),
          update: (_, firestoreService, previous) =>
              previous!..updateService(firestoreService),
        ),

        ChangeNotifierProvider(create: (_) => NavigationParentViewmodel()),
        // studentProvider
        Provider(create: (_) => AuthStudentService()),
        ChangeNotifierProxyProvider<AuthStudentService, AuthStudentViewmodel>(
          create: (context) =>
              AuthStudentViewmodel(context.read<AuthStudentService>()),
          update: (_, firestoreService, previous) =>
              previous!..updateService(firestoreService),
        ),

        // Service Provider
        Provider<ChatService>(
          create: (context) => ChatService(
            FirebaseFirestore.instance,
            context.read<UploadImageService>(),
          ),
        ),
        Provider<UploadImageService>(create: (_) => UploadImageService()),
        ChangeNotifierProvider<ChatRoomViewmodel>(
          create: (context) => ChatRoomViewmodel(
            context.read<ChatService>(),
            context.read<UploadImageService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => NavigationStudentViewModel()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ciloka App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: GlobalNavigator.navigatorKey,
      scaffoldMessengerKey: GlobalSnackBar.messengerKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
