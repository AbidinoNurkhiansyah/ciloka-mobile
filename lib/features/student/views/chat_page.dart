// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/colors.dart';
import '../viewmodels/auth_student_viewmodel.dart';
import '../viewmodels/chat_room_viewmodel.dart';

class ChatPage extends StatefulWidget {
  final String teacherId;
  final String studentId;
  final bool isTeacherView; // true jika dibuka oleh teacher, false jika student

  const ChatPage({
    super.key,
    required this.teacherId,
    required this.studentId,
    this.isTeacherView = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final authVm = context.read<AuthStudentViewmodel>();
    final studentName = authVm.studentName ?? "Siswa";

    final chatVm = context.read<ChatRoomViewmodel>();
    // Inisialisasi room
    chatVm.init(widget.teacherId, widget.studentId, studentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatRoomViewmodel>();

    return Scaffold(
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
              _buildCuteHeader(context),
              const SizedBox(height: 8),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                          color: Colors.black.withValues(alpha: 0.08),
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
                                    child: CircularProgressIndicator(),
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

                                // Data tidak direverse -> Urutan Ascending (Lama -> Baru)
                                final messages = snapshot.data!.docs;

                                // Auto Scroll ke Bawah jika data baru masuk
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (_scrollController.hasClients) {
                                    _scrollController.jumpTo(
                                      _scrollController
                                          .position
                                          .maxScrollExtent,
                                    );
                                  }
                                });

                                return ListView.builder(
                                  controller: _scrollController,
                                  reverse: false, // Top-to-Bottom
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    14,
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
                                        msg['senderName'] ??
                                        ''; // Default empty string agar tidak muncul (Guru)
                                    final content = msg['content'] ?? '';
                                    final imageUrl = msg['imageUrl'];
                                    final timestamp =
                                        (msg['timestamp'] as Timestamp?)
                                            ?.toDate();

                                    // Logic Determine isMe
                                    bool isMe;
                                    if (widget.isTeacherView) {
                                      isMe =
                                          senderId.trim() ==
                                          widget.teacherId.trim();
                                    } else {
                                      isMe =
                                          senderId.trim() ==
                                          widget.studentId.trim();
                                    }

                                    return _buildMessageBubble(
                                      context: context,
                                      isMe: isMe,
                                      senderId: senderId,
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

  Widget _buildCuteHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
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
                  color: Colors.black.withValues(alpha: 0.15),
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

  Widget _buildMessageBubble({
    required BuildContext context,
    required bool isMe,
    required String senderId,
    required String senderName,
    required bool isImage,
    required String content,
    required String? imageUrl,
    required DateTime? timestamp,
  }) {
    // Logika Warna
    final bool isMessageFromTeacher = senderId == widget.teacherId;

    final bubbleColor = isMessageFromTeacher
        ? chatGreen
        : const Color(0xFFFFF59D);

    final textColor = isMessageFromTeacher ? Colors.white : Colors.brown[900]!;

    final align = isMe ? Alignment.topRight : Alignment.topLeft;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isMe ? 20 : 6),
      bottomRight: Radius.circular(isMe ? 6 : 20),
    );

    // Label Logic
    String label;
    String roleLabel = "";
    if (isMessageFromTeacher) {
      // Pesan Guru
      roleLabel = isMe ? "Anda (Guru)" : "Guru";
    } else {
      // Pesan Siswa
      roleLabel = isMe
          ? "Anda (Siswa)"
          : "Siswa ${senderName.isEmpty ? '' : '($senderName)'}".trim();
    }

    label = roleLabel;

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
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: textColor.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 4),
              if (isImage && imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  content,
                  style: TextStyle(fontSize: 14, height: 1.3, color: textColor),
                ),
              ],
              const SizedBox(height: 4),
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
                      color: textColor.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor.withValues(alpha: 0.7),
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

  Widget _buildInputArea(ChatRoomViewmodel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, -2),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRoundIconButton(
            icon: Icons.image_rounded,
            tooltip: "Kirim gambar lucu 📷",
            background: const Color(0xFFE1F5FE),
            iconColor: const Color(0xFF0288D1),
            onTap: () async {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null) {
                String senderId;
                String senderName;
                if (widget.isTeacherView) {
                  senderId = widget.teacherId;
                  senderName = "Guru";
                } else {
                  final authVm = context.read<AuthStudentViewmodel>();
                  senderId = authVm.getConsistentStudentId() ?? '';
                  senderName = authVm.studentName ?? "Anak Hebat";
                }
                if (senderId.isNotEmpty) {
                  await vm.sendImageMessage(
                    senderId: senderId,
                    senderName: senderName,
                    imageFile: File(picked.path),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
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
          const SizedBox(width: 8),
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

  Future<void> _onSendPressed(ChatRoomViewmodel vm) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    String senderId;
    String senderName;
    final authStudentVm = context.read<AuthStudentViewmodel>();

    if (widget.isTeacherView) {
      senderId = widget.teacherId;
      senderName = "Guru";
    } else {
      final consistentStudentId = authStudentVm.getConsistentStudentId();
      if (consistentStudentId == null) return;
      senderId = consistentStudentId;
      senderName = authStudentVm.studentName ?? "Anak Hebat";
    }

    await vm.sendTextMessage(
      text: text,
      senderId: senderId,
      senderName: senderName,
    );
    _controller.clear();
  }
}
