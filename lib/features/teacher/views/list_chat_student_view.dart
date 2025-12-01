import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../student/services/chat_service.dart';
import '../../student/views/chat_page.dart';
import '../services/upload_image_service.dart';

class TeacherChatListPage extends StatelessWidget {
  final String teacherId;

  const TeacherChatListPage({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService(
      FirebaseFirestore.instance,
      UploadImageService(),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Chat Siswa')),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getTeacherChatList(teacherId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!.docs;

          if (rooms.isEmpty) {
            return const Center(child: Text("Belum ada chat"));
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final data = rooms[i].data() as Map<String, dynamic>;

              // Ambil studentId dari field dokumen
              final studentId = data['studentId'] ?? '';
              final studentName = data['studentName'] ?? '';
              final lastMessage = data['lastMessage'] ?? '';

              return ListTile(
                title: Text(
                  "Student $studentName",
                ), // nanti bisa ambil nama asli dari koleksi students
                subtitle: Text(lastMessage),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatPage(teacherId: teacherId, studentId: studentId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
