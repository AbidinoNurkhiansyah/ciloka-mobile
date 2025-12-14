import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/static/firebase_auth_status.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../widgets/custom_textfield_widget.dart';
import '../../../widgets/gradient_stroke_text_widget.dart';
import '../viewmodels/auth_teacher_viewmodel.dart';

class RegisterTeacherView extends StatefulWidget {
  const RegisterTeacherView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterTeacherViewState createState() => _RegisterTeacherViewState();
}

class _RegisterTeacherViewState extends State<RegisterTeacherView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Kata sandi harus mengandung huruf besar';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Kata sandi harus mengandung huruf kecil';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Kata sandi harus mengandung angka';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Kata sandi harus mengandung karakter spesial (!@#\$%^&*)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vM = context.watch<AuthTeacherViewmodel>();
    final isLoading = vM.status == FirebaseAuthStatus.authenticating;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            GlobalNavigator.pushReplacementNamed(AppRoutes.selectRole);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Image.asset('assets/img/logo_ciloka.webp'),
                    ),
                    AppSpacing.vSm,
                    GradientStrokeTextWidget(
                      text: 'Hallo Para Guru',
                      gradient: const LinearGradient(
                        colors: [Color(0xff78CAEF), Color(0xff462F75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      fillColor: Theme.of(context).colorScheme.onSurface,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.vSm,
                    GradientStrokeTextWidget(
                      text: 'Silahkan Masuk ke AKun Anda',
                      gradient: const LinearGradient(
                        colors: [Color(0xff78CAEF), Color(0xff462F75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      strokeWidth: 10,
                      fillColor: Color(0xffE8F446),
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    AppSpacing.vLg,
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          customTextField(
                            controller: userNameController,
                            label: 'Nama Lengkap',
                            hint: 'Masukkan Nama Lengkap anda',
                            prefixIcon: Icons.person,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Nama Lengkap Tidak boleh kosong";
                              }
                              return null;
                            },
                          ),
                          customTextField(
                            controller: emailController,
                            label: 'Email',
                            hint: 'Masukkan Email anda',
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email Tidak boleh kosong";
                              }
                              if (!RegExp(r'[@":{}|<>]').hasMatch(value)) {
                                return 'Email harus mengandung @gmail.com';
                              }
                              return null;
                            },
                          ),
                          customTextField(
                            controller: passwordController,
                            label: 'Kata Sandi',
                            hint: 'Masukkan Kata Sandi anda',
                            obscureText: !isPasswordVisible,
                            prefixIcon: Icons.lock,
                            keyboardType: TextInputType.text,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            validator: validatePassword,
                          ),

                          SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context
                                        .read<AuthTeacherViewmodel>()
                                        .register(
                                          userNameController.text.trim(),
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                          context: context,
                                        ),
                              child: Text(
                                "Daftar",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),
                          AppSpacing.vSm,

                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Text(
                                    'atau masuk dengan',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          AppSpacing.vSm,
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                              ),
                              onPressed: () {
                                // if (_formKey.currentState!.validate()) {
                                //   _tapToLogin();
                                // }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.google,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                  AppSpacing.hSm,
                                  Text(
                                    "Google",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(AppSpacing.md),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Sudah punya akun? ",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  TextSpan(
                                    text: 'Masuk',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.loginTeacher,
                                        );
                                      },
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
