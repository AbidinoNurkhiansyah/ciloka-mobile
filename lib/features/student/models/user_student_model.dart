class StudentModel {
  final String uid;
  final String username;
  final String email;
  final String photoUrl;
  final int currentLevel;
  final double levelProgress; // 0.0 to 1.0

  StudentModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
    this.currentLevel = 1,
    this.levelProgress = 0.0,
  });

  factory StudentModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return StudentModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      currentLevel: data['currentLevel'] ?? 1,
      levelProgress: (data['levelProgress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'currentLevel': currentLevel,
      'levelProgress': levelProgress,
    };
  }
}
