import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart'; // Import warna dari satu level di atas

// Konten Halaman Kelas (Index 1)
class ClassPageContent extends StatelessWidget {
  final VoidCallback onChatTap;

  const ClassPageContent({super.key, required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 1. HEADER (Welcome Banner)
        _buildWelcomeBanner(),
        const SizedBox(height: 20),

        // 2. CHAT BUTTON
        GestureDetector(
          onTap: onChatTap, // Panggil callback saat di-tap
          child: _buildChatButton(),
        ),
        const SizedBox(height: 20),

        // 3. INFORMATION CARDS (Grid)
        _buildInfoGrid(),
        const SizedBox(height: 100), // Tambahan ruang di bawah
      ],
    );
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerBlue, // Biru cerah/tosca
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white, // Warna outline putih
          width: 2.5, // Ketebalan outline
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Profile Picture/Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.asset(
                'assets/img/placeholderprofilekelas.png',
                fit: BoxFit.cover,
                width: 56,
                height: 56,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 40, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hallo!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Selamat Datang di kelas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Riski Ramadhan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: chatGreen, // Hijau cerah
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white, // Warna outline putih
          width: 2.5, // Ketebalan outline
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Avatar
          Image.asset(
            'assets/img/bincangprofile.png', // Ikon avatar chat
            width: 36,
            height: 36,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.chat_bubble, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Ayo Berbincang!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Arrow Icon
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Menonaktifkan scroll GridView
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.355,
      children: <Widget>[
        // Kartu 1: Kelas
        _buildInfoCard(
          backgroundColor: classPink,
          imagePath: 'assets/img/kelasbook.png',
          title: 'Kelas 4 A',
          subtitle: 'SDN 1 TELAGASARI',
        ),
        // Kartu 2: Wali Kelas
        _buildInfoCard(
          backgroundColor: teacherPurple,
          imagePath: 'assets/img/profilwalas.png',
          title: 'Wali kelas',
          subtitle: 'Ahmad Ilahi.spd',
          isTeacherCard: true,
        ),
        // Kartu 3: Level (Rocket)
        _buildInfoCard(
          backgroundColor: levelCyan,
          imagePath: 'assets/img/roket.png',
          title: '5', // Hanya angka level
          isLevelCard: true,
        ),
        // Kartu 4: Points/Stars
        _buildInfoCard(
          backgroundColor: pointYellow,
          imagePath: 'assets/img/bintanglead.png',
          title: '50', // Hanya jumlah poin
          isStarCard: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required Color backgroundColor,
    required String imagePath,
    required String title,
    String? subtitle,
    bool isTeacherCard = false,
    bool isLevelCard = false,
    bool isStarCard = false,
  }) {
    // Penentuan warna teks
    final Color textColor = Colors.white;

    // 1. Define the Image/Icon Widget
    final imageWidget = Image.asset(
      imagePath,
      width: 30, // Ukuran Ikon disesuaikan agar cocok dengan tinggi 121
      height: 30,
      // Hanya terapkan color filter untuk bintang, karena yang lain diasumsikan PNG berwarna
      color: isStarCard ? const Color(0xFFFFC107) : null,
      // Placeholder fallback if image not found
      errorBuilder: (context, error, stackTrace) {
        IconData icon;
        if (isTeacherCard)
          icon = Icons.person_pin;
        else if (isLevelCard)
          icon = Icons.rocket_launch;
        else if (isStarCard)
          icon = Icons.star;
        else
          icon = Icons.menu_book;

        return Icon(
          icon,
          size: 30,
          color: isStarCard ? const Color(0xFFFFC107) : Colors.white,
        );
      },
    );

    // 2. Define the Text Content Widget (Column)
    Widget textContent;

    if (isTeacherCard) {
      // Wali Kelas Layout
      textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Wali Kelas',
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle ?? '', // Ahmad Ilahi.spd
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      );
    } else if (isLevelCard) {
      // Level Layout
      textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Level',
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
          ),
          Text(
            title, // Level 5
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    } else if (isStarCard) {
      // Points/Stars Layout
      textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Poin', // Tambahkan label Poin
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
          ),
          Text(
            title, // 50
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    } else {
      // Default Case (Kelas Card)
      textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title, // Kelas 4 A
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            subtitle ?? '', // SDN 1 TELAGASARI
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      );
    }

    // 3. Card Wrapper
    final cardContentRow = Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Logo/Image di kiri
          imageWidget,
          const SizedBox(width: 12),
          // Text di kanan (menggunakan Expanded untuk mengisi sisa ruang)
          Expanded(child: textContent),
        ],
      ),
    );

    // Card Wrapper Container
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white, // Warna outline putih
          width: 2.5, // Ketebalan outline
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: cardContentRow,
    );
  }
}
