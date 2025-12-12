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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Pesan Siswa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getTeacherChatList(teacherId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!.docs;

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Belum ada pesan",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pesan dari siswa akan muncul di sini",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final data = rooms[i].data() as Map<String, dynamic>;

              final studentId = data['studentId'] ?? '';
              final studentName = data['studentName'] ?? 'Siswa';
              final bool isReadByTeacher = data['isReadByTeacher'] ?? true;
              final lastMessage = data['lastMessage'] ?? '';
              final Timestamp? ts = data['lastTimestamp'];
              final DateTime? lastTime = ts?.toDate();

              return _buildChatCard(
                context: context,
                studentName: studentName,
                studentId: studentId,
                lastMessage: lastMessage,
                lastTime: lastTime,
                isReadByTeacher: isReadByTeacher,
                index: i,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatCard({
    required BuildContext context,
    required String studentName,
    required String studentId,
    required String lastMessage,
    required DateTime? lastTime,
    required bool isReadByTeacher,
    required int index,
  }) {
    // Generate warna avatar berdasarkan index
    final avatarColors = [
      [const Color(0xFFFFD54F), const Color(0xFFFFB74D)], // Orange
      [const Color(0xFF81C784), const Color(0xFF66BB6A)], // Green
      [const Color(0xFF64B5F6), const Color(0xFF42A5F5)], // Blue
      [const Color(0xFFFFB74D), const Color(0xFFFF9800)], // Deep Orange
      [const Color(0xFFBA68C8), const Color(0xFFAB47BC)], // Purple
    ];
    final colorPair = avatarColors[index % avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onChatTap(context, studentId),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar dengan gradient
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colorPair,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorPair[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(studentName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Konten chat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              studentName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isReadByTeacher
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(lastTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: isReadByTeacher
                                  ? Colors.grey[500]
                                  : const Color(0xFF4CAF50),
                              fontWeight: isReadByTeacher
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage.isEmpty
                                  ? 'Belum ada pesan'
                                  : lastMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: isReadByTeacher
                                    ? Colors.grey[600]
                                    : const Color(0xFF2D3748),
                                fontWeight: isReadByTeacher
                                    ? FontWeight.w400
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isReadByTeacher) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Baru',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      // Hari ini
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      // Kemarin
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      // Minggu ini
      final days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      return days[time.weekday % 7];
    } else {
      // Lebih dari seminggu
      return "${time.day}/${time.month}";
    }
  }

  Future<void> _onChatTap(BuildContext context, String studentId) async {
    // Update isReadByTeacher
    final roomRef = FirebaseFirestore.instance
        .collection('story_rooms')
        .doc("${teacherId}_$studentId");

    final roomDoc = await roomRef.get();
    if (roomDoc.exists) {
      await roomRef.update({'isReadByTeacher': true});
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            teacherId: teacherId,
            studentId: studentId,
            isTeacherView: true,
          ),
        ),
      );
    }
  }
}
