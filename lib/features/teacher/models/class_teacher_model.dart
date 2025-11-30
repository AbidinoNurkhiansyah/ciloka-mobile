class ClassTeacherModel {
  final String id;
  final String grade;
  final String className;
  final DateTime createdAt;

  ClassTeacherModel({
    required this.id,
    required this.grade,
    required this.className,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grade': grade,
      'className': className,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassTeacherModel.fromMap(Map<String, dynamic> map) {
    return ClassTeacherModel(
      id: map['id'] ?? '',
      grade: map['grade'] ?? '',
      className: map['className'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
