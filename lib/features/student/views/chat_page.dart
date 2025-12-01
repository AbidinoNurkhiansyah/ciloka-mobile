// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/colors.dart';
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
      body: StreamBuilder(
        stream: vm.messages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada pesan"));
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index].data() as Map<String, dynamic>;
              final isImage = msg['type'] == 'image';
              final senderId = msg['senderId'] ?? '';

              final content = msg['content'] ?? '';
              final imageUrl = msg['imageUrl'];
              final timestamp = (msg['timestamp'] as Timestamp?)?.toDate();

              // cek apakah pesan dari guru atau siswa
              final isTeacher = senderId == widget.teacherId;

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
                        isTeacher ? "Guru" : "Kamu",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isTeacher ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Isi pesan (text atau image)
                      isImage
                          ? Image.network(imageUrl)
                          : Text(
                              content,
                              style: TextStyle(
                                color: isTeacher ? Colors.black : Colors.white,
                              ),
                            ),

                      const SizedBox(height: 4),

                      // Jam pesan
                      if (timestamp != null)
                        Text(
                          "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: 11,
                            color: isTeacher ? Colors.black54 : Colors.white70,
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
    );
  }
}
