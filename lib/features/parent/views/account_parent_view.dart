import '../../../core/routes/app_routes.dart';
import '../../../core/utils/global_navigator.dart';
import '../../../widgets/gradient_stroke_text_widget.dart';
import '../viewmodels/navigation_parent_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountParentView extends StatelessWidget {
  const AccountParentView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFADE1FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            GradientStrokeTextWidget(
              text: 'AKUN (WALI)',
              gradient: const LinearGradient(
                colors: [Color(0xff78CAEF), Color(0xff462F75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              fillColor: colorScheme.onSurface,
              style: Theme.of(
                context,
              ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Menu Container
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8E0FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem('Preferensi', Icons.settings),
                          const Divider(height: 1, color: Colors.white),
                          _buildMenuItem('Profile', Icons.person),
                          const Divider(height: 1, color: Colors.white),
                          _buildMenuItem('Notifikasi', Icons.notifications),
                          const Divider(height: 1, color: Colors.white),
                          _buildMenuItem('Pengaturan Privasi', Icons.lock),
                          const Divider(height: 1, color: Colors.white),
                          _buildMenuItem('Pusat Bantuan', Icons.help),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Logout Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: const Center(
                            child: Text(
                              'KELUAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Text(
            "Konfirmasi Keluar",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Apakah Anda yakin ingin keluar?",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontFamily: 'Nunito'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: Text(
                "Tidak",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Reset navigation index
                Provider.of<NavigationParentViewmodel>(
                  context,
                  listen: false,
                ).setIndexBottomNavbar(0);

                GlobalNavigator.pushReplacementNamed(AppRoutes.loginParent);
              },
              child: Text(
                'Ya',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(String title, IconData icon) {
    return InkWell(
      onTap: () {
        // Navigate to respective page
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B46C1),
                fontFamily: 'Nunito',
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFFffffff), size: 24),
          ],
        ),
      ),
    );
  }
}
