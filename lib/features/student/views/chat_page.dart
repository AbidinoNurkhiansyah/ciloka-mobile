// ignore_for_file: public_member_api_docs, sort_constructors_first
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
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return Text("Messages Loaded");
        },
      ),
    );
  }
}
