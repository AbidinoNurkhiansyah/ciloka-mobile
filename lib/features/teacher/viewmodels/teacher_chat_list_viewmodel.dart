import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../student/services/chat_service.dart';

class TeacherChatListViewmodel extends ChangeNotifier {
  final ChatService _chatService;

  TeacherChatListViewmodel(this._chatService);

  Stream<QuerySnapshot> getChatList(String teacherId) {
    return _chatService.getTeacherChatList(teacherId);
  }
}
