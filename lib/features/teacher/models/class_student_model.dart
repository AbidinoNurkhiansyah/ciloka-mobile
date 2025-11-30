import 'package:cloud_firestore/cloud_firestore.dart';

class ClassStudentModel {
  final String id;
  final String photoUrl;
  final String studentName;
  final String nis;
  final String parentName;

  ClassStudentModel({
    required this.id,
    required this.photoUrl,
    required this.studentName,
    required this.nis,
    required this.parentName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'studentName': studentName,
      'nis': nis,
      'parentName': parentName,
    };
  }

  factory ClassStudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassStudentModel(
      id: doc.id,
      photoUrl: (data['photoUrl'] as String?) ?? '',
      studentName: (data['studentName'] as String?) ?? '',
      nis: (data['nis'] as String?) ?? '',
      parentName: (data['parentName'] as String?) ?? '',
    );
  }
}
