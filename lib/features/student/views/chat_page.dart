// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/colors.dart';
import '../viewmodels/auth_student_viewmodel.dart';
import '../viewmodels/chat_room_viewmodel.dart'; // Import warna dari satu level di atas

// Halaman Chat
class ChatPage extends StatefulWidget {
  final String teacherId;
  final String studentId;
  const ChatPage({super.key, required this.teacherId, required this.studentId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    final chatVm = context.read<ChatRoomViewmodel>();
    chatVm.init(widget.teacherId, widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatRoomViewmodel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruang Bincang'),
        // Menggunakan chatGreen dari util/colors.dart
        backgroundColor: chatGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: vm.messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Belum ada Obrolan",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          "Ayo mulai berkomunikasi dengan gurumu!",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isImage = msg['type'] == 'image';
                    final senderId = msg['senderId'] ?? '';
                    final senderName = msg['senderName'] ?? '';

                    final content = msg['content'] ?? '';
                    final imageUrl = msg['imageUrl'];
                    final timestamp = (msg['timestamp'] as Timestamp?)
                        ?.toDate();

                    // cek apakah pesan dari guru atau siswa

                    final isTeacher = senderId == widget.teacherId;
                    debugPrint('senderName: $senderName');
                    return Align(
                      alignment: isTeacher
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isTeacher ? Colors.grey[300] : chatGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: isTeacher
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            // Nama pengirim
                            Text(
                              senderName,

                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isTeacher ? Colors.black : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Isi pesan
                            isImage
                                ? Image.network(imageUrl)
                                : Text(
                                    content,
                                    style: TextStyle(
                                      color: isTeacher
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),

                            const SizedBox(height: 4),

                            // Jam
                            if (timestamp != null)
                              Text(
                                "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isTeacher
                                      ? Colors.black54
                                      : Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // 🔹 Input + tombol kirim
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.grey[200],
              child: Row(
                children: [
                  // Tombol pilih gambar
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.blue),
                    onPressed: () async {
                      final picked = await _picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      final authVm = context.read<AuthStudentViewmodel>();
                      final studentName = authVm.studentName ?? "Anda";
                      if (picked != null) {
                        await vm.sendImageMessage(
                          senderId: widget.studentId,
                          senderName:
                              studentName, // 🔥 ganti dengan nama siswa asli
                          imageFile: File(picked.path),
                        );
                      }
                    },
                  ),

                  // Input text
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Tulis pesan...",
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),

                  // Tombol kirim
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () async {
                      final text = _controller.text.trim();
                      final authVm = context.read<AuthStudentViewmodel>();
                      final studentName = authVm.studentName ?? "Anda";
                      if (text.isNotEmpty) {
                        await vm.sendTextMessage(
                          text: text,
                          senderId: widget.studentId,
                          senderName: studentName,
                        );
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
