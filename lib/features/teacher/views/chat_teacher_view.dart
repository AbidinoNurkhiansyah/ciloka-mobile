import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/global_navigator.dart';

class ChatTeacherView extends StatelessWidget {
  const ChatTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: AppSpacing.sm),
          child: IconButton(
            onPressed: () {
              GlobalNavigator.pushReplacementNamed(AppRoutes.mainTeacher);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              // Ganti dengan URL gambar avatar guru/sekolah
              // Placeholder avatar
              backgroundImage: NetworkImage(
                'https://placehold.co/100x100/A0D2FF/333333?text=SR',
              ),
            ),
            AppSpacing.hMd,
            Text(
              'Story Room',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Bagian list chat
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                // Pesan dari Guru (Kiri)
                _MessageBubble(
                  isMe: false,
                  isTeacher: true,
                  message: 'Anak - anak kalian sudah sampai level berapa?',
                  // Ganti dengan URL avatar guru
                  avatarUrl:
                      'https://placehold.co/100x100/F0A0A0/FFFFFF?text=T',
                ),
                SizedBox(height: 12),

                // Pesan dari Murid (Kanan)
                _MessageBubble(
                  isMe: true,
                  isTeacher: false,
                  message: 'Saya level 7',
                  // Ganti dengan URL avatar murid
                  avatarUrl:
                      'https://placehold.co/100x100/FFE0E9/333333?text=M',
                ),
                SizedBox(height: 12),

                // Pesan dari Murid dengan Gambar (Kanan)
                _MessageBubble(
                  isMe: true,
                  isTeacher: false,
                  message: 'Saya berangkat sekolah jam 06.35',
                  // Ganti dengan URL avatar murid
                  avatarUrl:
                      'https://placehold.co/100x100/FFE0E9/333333?text=M',
                  // Ganti dengan URL gambar yang dikirim
                  imageUrl:
                      'https://placehold.co/600x600/CCCCCC/FFFFFF?text=Foto+Sekolah',
                ),
              ],
            ),
          ),
          // 2. Bagian input text di bawah
          _InputBar(),
        ],
      ),
    );
  }
}

// WIDGET UNTUK INPUT BAR DI BAWAH (VERSI STATEFUL)
class _InputBar extends StatefulWidget {
  const _InputBar();

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showSendButton = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan pilihan lampiran (Kamera & Mic)
  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Kamera'),
                onTap: () {
                  // TODO: Implementasi ambil gambar dari kamera
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic_none_outlined),
                title: const Text('Voice Note'),
                onTap: () {
                  // TODO: Implementasi rekam suara
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: const Color(0xFFD6EEFF), // Warna sama dengan background
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          // --- MODIFIKASI DI SINI ---
          // Menambahkan border biru sesuai permintaan
          border: Border.all(
            color: const Color(0xFF4DB6FF), // Warna biru #4DB6FF
            width: 2.0, // Atur ketebalan border
          ),
          // --- BATAS MODIFIKASI ---
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Text Field
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Pesan',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            // Tombol dinamis (+) atau (Kirim)
            _showSendButton
                ?
                  // Tombol KIRIM (warna biru #4DB6FF)
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: const Color(
                      0xFF4DB6FF,
                    ), // Warna biru sesuai permintaan
                    onPressed: () {
                      // TODO: Implementasi kirim pesan
                      _controller.clear();
                    },
                  )
                :
                  // Tombol PLUS (+)
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.grey,
                    ), // Tetap abu-abu
                    onPressed: () {
                      _showAttachmentOptions(context);
                    },
                  ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// WIDGET UNTUK GELEMBUNG CHAT (CHAT BUBBLE)
class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final bool isTeacher;
  final String message;
  final String avatarUrl;
  final String? imageUrl;

  const _MessageBubble({
    required this.isMe,
    required this.isTeacher,
    required this.message,
    required this.avatarUrl,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan perataan
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    // Tentukan warna bubble
    final bubbleColor = isMe
        ? const Color(0xFFFFE0E9) // Pink untuk murid
        : const Color(0xFFD0F2C0); // Hijau untuk guru
    // Tentukan avatar
    final avatar = CircleAvatar(backgroundImage: NetworkImage(avatarUrl));
    // Tentukan border radius
    final borderRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(5), // Sudut dekat avatar
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(5), // Sudut dekat avatar
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Label "Teacher"
        if (isTeacher)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(left: 50, bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0A0A0), // Warna banner teacher
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Teacher ⭐',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        Row(
          // Urutan: [Avatar, Bubble] atau [Bubble, Avatar]
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[avatar, const SizedBox(width: 8)],

            // Bubble Konten
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: borderRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tampilkan gambar jika ada
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          // Error handling untuk gambar
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    if (imageUrl != null) const SizedBox(height: 8),
                    // Teks Pesan
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isMe) ...[const SizedBox(width: 8), avatar],
          ],
        ),
      ],
    );
  }
}
