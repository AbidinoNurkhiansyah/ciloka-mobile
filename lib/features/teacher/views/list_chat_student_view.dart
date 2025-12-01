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

              final bool isReadByTeacher = data['isReadByTeacher'] ?? true;

              final lastMessage = data['lastMessage'] ?? '';
              final Timestamp? ts = data['lastTimestamp'];
              final DateTime? lastTime = ts?.toDate();

              return ListTile(
                title: Text("Student $studentName"),
                subtitle: Text(
                  lastMessage,
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lastTime != null
                          ? "${lastTime.hour}:${lastTime.minute.toString().padLeft(2, '0')}"
                          : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (!isReadByTeacher)
                      const Icon(Icons.circle, color: Colors.red, size: 10),
                  ],
                ),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('story_rooms')
                      .doc("${teacherId}_${studentId}")
                      .set({'isReadByTeacher': true}, SetOptions(merge: true));
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
