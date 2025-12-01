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
    return StreamBuilder(
      stream: ChatService(
        FirebaseFirestore.instance,
        UploadImageService(),
      ).getTeacherChatList(teacherId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final rooms = snapshot.data!.docs;

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, i) {
            final data = rooms[i].data() as Map<String, dynamic>;
            final studentId = (data['participants'] as List).firstWhere(
              (p) => p != teacherId,
            );

            return ListTile(
              title: Text("Student: $studentId"), // nanti ambil nama asli
              subtitle: Text(data['lastMessage'] ?? ''),
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
    );
  }
}
