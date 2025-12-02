// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/static/firebase_auth_status.dart';
import '../../../core/utils/colors.dart';
import '../viewmodels/auth_student_viewmodel.dart';
import '../viewmodels/chat_room_viewmodel.dart';

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

    final authVm = context.read<AuthStudentViewmodel>();
    final studentId = authVm.studentId ?? authVm.authUid!;
    final studentName = authVm.studentName ?? "Anak Hebat";

    final chatVm = context.read<ChatRoomViewmodel>();
    chatVm.init(widget.teacherId, studentId, studentName);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatRoomViewmodel>();

    return Scaffold(
      // Background full layar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF3E0), // pastel orange
              Color(0xFFE1F5FE), // pastel biru
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header lucu
              _buildCuteHeader(context),

              const SizedBox(height: 8),

              // Card utama isi chat
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          _buildDayLabel(),

                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: vm.messages,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        "Ups, ada kendala jaringan.\nCoba cek internet dulu ya 😊",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return _buildEmptyState();
                                }

                                final messages = snapshot.data!.docs.reversed
                                    .toList();
                                final authStudentVm = context
                                    .read<AuthStudentViewmodel>();

                                final String currentUserId =
                                    authStudentVm.status ==
                                        FirebaseAuthStatus.authenticated
                                    ? authStudentVm.authUid! // siswa login
                                    : widget.teacherId; // guru login

                                return ListView.builder(
                                  reverse: true,
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    6,
                                    10,
                                    14,
                                  ),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final msg =
                                        messages[index].data()
                                            as Map<String, dynamic>;

                                    final isImage = msg['type'] == 'image';
                                    final senderId = msg['senderId'] ?? '';
                                    final senderName =
                                        msg['senderName'] ?? 'Guru';
                                    final isMe = senderId == currentUserId;

                                    final content = msg['content'] ?? '';
                                    final imageUrl = msg['imageUrl'];
                                    final timestamp =
                                        (msg['timestamp'] as Timestamp?)
                                            ?.toDate();

                                    return _buildMessageBubble(
                                      context: context,
                                      isMe: isMe,
                                      senderName: senderName,
                                      isImage: isImage,
                                      content: content,
                                      imageUrl: imageUrl,
                                      timestamp: timestamp,
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          _buildInputArea(vm),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ================== HEADER ==================

  Widget _buildCuteHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFFB74D)],
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  color: Colors.black.withOpacity(0.15),
                ),
              ],
            ),
            child: const Center(
              child: Text("👩‍🏫", style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Ruang Bincang Ceria",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF424242),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Tanya apa saja ke gurumu ya ✨",
                  style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Hari ini 🧸",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
        ),
      ),
    );
  }

  // ================== EMPTY STATE ==================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 4),
            Text(
              "🎈 Halo, Anak Hebat!",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xFF424242),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Belum ada obrolan.\nKirim pesan pertama ke gurumu yuk! 📝",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
            ),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // ================== BUBBLE CHAT ==================

  Widget _buildMessageBubble({
    required BuildContext context,
    required bool isMe,
    required String senderName,
    required bool isImage,
    required String content,
    required String? imageUrl,
    required DateTime? timestamp,
  }) {
    final bubbleColor = isMe
        ? const Color(0xFFFFF59D) // kuning lembut untuk anak
        : chatGreen; // hijau untuk guru
    final textColor = isMe ? Colors.brown[900]! : Colors.white;
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isMe ? 20 : 6),
      bottomRight: Radius.circular(isMe ? 6 : 20),
    );

    final label = isMe
        ? "🧒 Kamu"
        : "👩‍🏫 ${senderName.isEmpty ? 'Guru' : senderName}";

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                offset: const Offset(0, 2),
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nama + role
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: textColor.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 4),

              // Isi pesan
              if (isImage && imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ] else ...[
                Text(
                  content,
                  style: TextStyle(fontSize: 14, height: 1.3, color: textColor),
                ),
              ],

              const SizedBox(height: 4),

              // Jam kecil
              if (timestamp != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: textColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== INPUT AREA ==================

  Widget _buildInputArea(ChatRoomViewmodel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, -2),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol gambar
          _buildRoundIconButton(
            icon: Icons.image_rounded,
            tooltip: "Kirim gambar lucu 📷",
            background: const Color(0xFFE1F5FE),
            iconColor: const Color(0xFF0288D1),
            onTap: () async {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
              );

              final authVm = context.read<AuthStudentViewmodel>();
              final studentName = authVm.studentName ?? "Anak Hebat";

              if (picked != null) {
                await vm.sendImageMessage(
                  senderId: authVm.authUid!,
                  senderName: studentName,
                  imageFile: File(picked.path),
                );
              }
            },
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: TextFormField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _onSendPressed(vm),
                decoration: const InputDecoration(
                  hintText: "Tulis pesan manis di sini... ✨",
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF424242)),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Tombol kirim
          _buildRoundIconButton(
            icon: Icons.send_rounded,
            tooltip: "Kirim pesan 🚀",
            background: chatGreen,
            iconColor: Colors.white,
            onTap: () => _onSendPressed(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? background,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: background ?? const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: iconColor ?? Colors.grey[700]),
        ),
      ),
    );
  }

  // ================== LOGIC KIRIM PESAN ==================

  Future<void> _onSendPressed(ChatRoomViewmodel vm) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    String senderId;
    String senderName;

    final authStudentVm = context.read<AuthStudentViewmodel>();

    if (authStudentVm.status == FirebaseAuthStatus.authenticated) {
      // Siswa login
      senderId = authStudentVm.authUid!;
      senderName = authStudentVm.studentName ?? "Anak Hebat";
    } else {
      // Guru login
      senderId = widget.teacherId;
      senderName = "Guru";
    }

    await vm.sendTextMessage(
      text: text,
      senderId: senderId,
      senderName: senderName,
    );
    _controller.clear();
  }
}
