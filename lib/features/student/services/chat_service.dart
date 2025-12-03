import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:ciloka_app/features/teacher/services/upload_image_service.dart';

class ChatService {
  final FirebaseFirestore _firestore;
  final UploadImageService _imageService;
  final _uuid = const Uuid();

  ChatService(this._firestore, this._imageService);

  Future<void> initRoom(
    String teacherId,
    String studentId,
    String studentName,
  ) async {
    final roomId = getRoomId(teacherId, studentId);
    final doc = await _firestore.collection('story_rooms').doc(roomId).get();

    if (!doc.exists) {
      await _firestore.collection('story_rooms').doc(roomId).set({
        'teacherId': teacherId,
        'studentId': studentId,
        'studentName': studentName,
        'participants': [teacherId, studentId],
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // 🔹 Get chat room ID
  String getRoomId(String teacherId, String studentId) {
    return '${teacherId}_$studentId';
  }

  Stream<QuerySnapshot> getTeacherChatList(String teacherId) {
    return _firestore
        .collection('story_rooms')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getChatRoom(String teacherId, String studentId) {
    final roomId = getRoomId(teacherId, studentId);
    return _firestore.collection('story_rooms').doc(roomId).snapshots();
  }

  // 🔹 Send message (text / image)
  Future<void> sendMessage({
    required String teacherId,
    required String studentId,
    required String senderId,
    required String senderName,
    String? text,
    String? imageUrl,
  }) async {
    final roomId = getRoomId(teacherId, studentId);
    final messageId = _uuid.v4();

    final messageData = {
      'senderId': senderId,
      'type': imageUrl != null ? 'image' : 'text',
      'content': text ?? '',
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // simpan ke sub-collection messages
    await _firestore
        .collection('story_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);

    // update dokumen room
    await _firestore.collection('story_rooms').doc(roomId).set({
      'lastMessage': text ?? '[Image]',
      'lastTimestamp': FieldValue.serverTimestamp(),

      'isReadByTeacher': senderId == teacherId,
      'isReadByStudent': senderId == studentId,
    }, SetOptions(merge: true));
  }

  // 🔹 Get messages stream
  Stream<QuerySnapshot> getMessages(String teacherId, String studentId) {
    final roomId = getRoomId(teacherId, studentId);
    return _firestore
        .collection('story_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteChatMessage(
    String teacherId,
    String studentId,
    String messageId,
    String? imageUrl,
  ) async {
    final roomId = getRoomId(teacherId, studentId);

    await _firestore
        .collection('story_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .delete();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _imageService.deleteFromCloudinary(imageUrl);
    }
  }
}
