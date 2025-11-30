import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:ciloka_app/features/student/services/chat_service.dart';

import '../../teacher/services/upload_image_service.dart';

class ChatRoomViewmodel extends ChangeNotifier {
  final ChatService _chatService;
  final UploadImageService _uploadImageService;

  String? teacherId;
  String? studentId;

  ChatRoomViewmodel(this._chatService, this._uploadImageService);

  // state
  bool _isSending = false;
  bool get isSending => _isSending;

  Stream<QuerySnapshot>? messages;
  Future<void> init(String teacherId, String studentId) async {
    this.teacherId = teacherId;
    this.studentId = studentId;

    await _chatService.initRoom(teacherId, studentId);

    messages = _chatService.getMessages(teacherId, studentId);

    notifyListeners();
  }

  Future<void> sendTextMessage({
    required String text,
    required String senderId,
  }) async {
    if (teacherId == null || studentId == null) return;

    _isSending = true;
    notifyListeners();
    await _chatService.sendMessage(
      teacherId: teacherId!,
      studentId: studentId!,
      senderId: senderId,
      text: text,
    );

    _isSending = false;
    notifyListeners();
  }

  Future<void> sendImageMessage({
    required String senderId,
    required File imageFile,
  }) async {
    if (teacherId == null || studentId == null) return;

    _isSending = true;
    notifyListeners();

    try {
      final imageUrl = await _uploadImageService.uploadImgMessageToCloudinary(
        imageFile,
      );

      await _chatService.sendMessage(
        teacherId: teacherId!,
        studentId: studentId!,
        senderId: senderId,
        imageUrl: imageUrl,
      );
    } catch (e) {
      debugPrint('Error sending image: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
