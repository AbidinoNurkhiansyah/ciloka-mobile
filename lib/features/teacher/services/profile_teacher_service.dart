import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_teacher_model.dart';

class ProfileTeacherService {
  final _teacherCollection = FirebaseFirestore.instance.collection('teachers');

  Stream<TeacherModel?> streamTeacherProfile(String uid) {
    return _teacherCollection.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return null;
      }

      final teacher = TeacherModel.fromFirestore(data, snapshot.id);
      return teacher;
    });
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _teacherCollection.doc(uid).update(data);
  }
}
