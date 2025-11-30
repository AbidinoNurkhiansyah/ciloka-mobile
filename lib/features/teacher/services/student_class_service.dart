import 'package:ciloka_app/features/teacher/models/class_student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _teachers => _firestore.collection('teachers');

  Future<bool> isNisExist(String classId, String nis) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final teacherId = user.uid;

    final existing = await _teachers
        .doc(teacherId)
        .collection('classes')
        .doc(classId)
        .collection('students')
        .where('nis', isEqualTo: nis)
        .limit(1)
        .get();

    return existing.docs.isNotEmpty;
  }

  Future<void> addStudentClass({
    required String classId,
    required String photoUrl,
    required String studentName,
    required String nis,
    required String parentName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final teacherId = user.uid;

    final existing = await _teachers
        .doc(teacherId)
        .collection('classes')
        .doc(classId)
        .collection('students')
        .where('nis', isEqualTo: nis)
        .get();

    if (existing.docs.isNotEmpty) {
      throw ('Siswa dengan NIS ini sudah terdaftar di kelas');
    }

    final newClassDataRef = _teachers
        .doc(teacherId)
        .collection('classes')
        .doc(classId)
        .collection('students')
        .doc();

    final newClassData = ClassStudentModel(
      id: newClassDataRef.id,
      photoUrl: photoUrl,
      studentName: studentName,
      nis: nis,
      parentName: parentName,
    );

    await newClassDataRef.set(newClassData.toMap());
    await _firestore.collection('student_index').doc(nis).set({
      'nis': nis,
      'studentName': studentName,
      'teacherId': teacherId,
      'classId': classId,
      'studentId': newClassDataRef.id,
    });
  }

  Stream<List<ClassStudentModel>> getStudentsByClass(String classId) {
    final teacherId = _auth.currentUser?.uid;
    if (teacherId == null || classId.isEmpty) {
      return const Stream.empty();
    }
    return _teachers
        .doc(teacherId)
        .collection('classes')
        .doc(classId)
        .collection('students')
        .orderBy('studentName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ClassStudentModel.fromFirestore(doc))
              .toList(),
        );
  }
}
