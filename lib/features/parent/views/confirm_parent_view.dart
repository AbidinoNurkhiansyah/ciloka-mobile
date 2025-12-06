import '../../../core/utils/global_navigator.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

class ConfirmParentView extends StatelessWidget {
  final String childName;
  final String nis;
  final String? className;
  final String? schoolName;
  final String? photoUrl;

  const ConfirmParentView({
    super.key,
    required this.childName,
    required this.nis,
    this.className,
    this.schoolName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE8F4FD), // Light blue background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 20),
                // Logo CILOKA
                SizedBox(
                  height: 150,
                  child: Image.asset('assets/img/logo_ciloka.webp'),
                ),
                SizedBox(height: 12),
                // "Apakah Sudah Benar" text
                Text(
                  'Apakah Sudah Benar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff462F75), // Dark blue
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 32),
                // Profile Picture with Frame
                Stack(
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.none,
                  children: [
                    // Purple rounded square frame
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Color(0xffE8D5FF), // Light purple
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xff462F75), // Dark blue
                              width: 8,
                            ),
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: photoUrl != null && photoUrl!.isNotEmpty
                                ? Image.network(
                                    photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar();
                                    },
                                  )
                                : _buildDefaultAvatar(),
                          ),
                        ),
                      ),
                    ),
                    // Cartoon character with magnifying glass
                    Positioned(
                      right: -50,
                      top: 0,
                      child: SizedBox(
                        width: 160,
                        height: 180,
                        child: Image.asset(
                          'assets/img/icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback icon if asset doesn't exist
                            return Icon(
                              Icons.search,
                              size: 140,
                              color: Color(0xff78CAEF),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                // Child Name
                Text(
                  childName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff462F75), // Dark blue
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 8),
                // Class and School Info or NIS
                if (className != null && schoolName != null)
                  Text(
                    'Kelas $className $schoolName',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff462F75), // Dark blue
                      fontFamily: 'Nunito',
                    ),
                  )
                else
                  Text(
                    'NIS: $nis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff462F75), // Dark blue
                      fontFamily: 'Nunito',
                    ),
                  ),
                SizedBox(height: 48),
                // LANJUT Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      GlobalNavigator.pushReplacementNamed(
                        AppRoutes.mainParent,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff78CAEF), // Bright blue
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "LANJUT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // KEMBALI Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      GlobalNavigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "KEMBALI",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffE8F4FD),
      ),
      child: Icon(Icons.person, size: 100, color: Color(0xff78CAEF)),
    );
  }
}
