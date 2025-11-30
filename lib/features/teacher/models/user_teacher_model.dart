class TeacherModel {
  final String uid;
  final String username;
  final String email;
  final String photoUrl;

  TeacherModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
  });

  factory TeacherModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return TeacherModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {'username': username, 'email': email, 'photoUrl': photoUrl};
  }
}
