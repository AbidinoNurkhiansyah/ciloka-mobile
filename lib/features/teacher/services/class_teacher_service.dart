import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/class_teacher_model.dart';

class ClassTeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _teachers => _firestore.collection('teachers');

  Future<void> setUser(
    String uid,
    String? username,
    String email, {
    String? photoUrl,
  }) async {
    await _teachers.doc(uid).set({
      'username': username?.trim().toLowerCase(),
      'email': email,
      'registeredAt': Timestamp.now(),
      'photoUrl': photoUrl,
    }, SetOptions(merge: true));
  }

  Future<void> addClass({
    required String className,
    required String grade,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final teacherId = user.uid;

    final newClassRef = _teachers.doc(teacherId).collection('classes').doc();

    final newClass = ClassTeacherModel(
      id: newClassRef.id,
      grade: grade,
      className: className,
      createdAt: DateTime.now(),
    );

    await newClassRef.set(newClass.toMap());
  }

  Stream<List<ClassTeacherModel>> getTeacherClasses() {
    final teacherId = _auth.currentUser?.uid;
    if (teacherId == null) return const Stream.empty();

    return _teachers
        .doc(teacherId)
        .collection('classes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ClassTeacherModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
