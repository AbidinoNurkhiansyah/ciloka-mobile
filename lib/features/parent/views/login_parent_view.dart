import '../../../core/utils/global_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/static/firebase_auth_status.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/custom_textfield_widget.dart';
import '../../../widgets/gradient_stroke_text_widget.dart';
import '../viewmodels/auth_parent_viewmodel.dart';

class LoginParentView extends StatefulWidget {
  const LoginParentView({super.key});

  @override
  _LoginParentViewState createState() => _LoginParentViewState();
}

class _LoginParentViewState extends State<LoginParentView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _nisController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthParentViewmodel>();
    final isLoading = authVM.status == FirebaseAuthStatus.authenticating;
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: Image.asset('assets/img/logo_ciloka.webp'),
                      ),
                      AppSpacing.vSm,
                      GradientStrokeTextWidget(
                        text: 'Hallo Para Wali',
                        gradient: const LinearGradient(
                          colors: [Color(0xff78CAEF), Color(0xff462F75)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        fillColor: Theme.of(context).colorScheme.onSurface,
                        style: Theme.of(context).textTheme.displaySmall!
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      AppSpacing.vSm,
                      GradientStrokeTextWidget(
                        text: 'Silahkan Isi Data Anak Anda',
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
                              controller: _parentNameController,
                              label: 'Nama Orang Tua',
                              hint: 'Masukkan Nama Orangtua',
                              prefixIcon: Icons.person,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Wajib diisi";
                                }
                                return null;
                              },
                            ),

                            customTextField(
                              controller: _nisController,
                              label: 'NIS',
                              hint: 'Masukkan NIS Anak',
                              prefixIcon: Icons.numbers,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Wajib diisi";
                                }
                                return null;
                              },
                            ),
                            AppSpacing.vLg,
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          final succes = await context
                                              .read<AuthParentViewmodel>()
                                              .loginParent(
                                                _parentNameController.text
                                                    .trim(),
                                                _nisController.text.trim(),
                                                context: context,
                                              );

                                          if (!succes) {
                                            _nisController.clear();
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  "Masuk",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _parentNameController.dispose();
    _nisController.dispose();
    super.dispose();
  }
}
