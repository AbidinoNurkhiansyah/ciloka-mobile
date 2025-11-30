import 'package:flutter/material.dart';

import '../models/level_model.dart';
import '../models/user_student_model.dart';

class LevelMapViewModel extends ChangeNotifier {
  StudentModel? _student;
  List<LevelModel> _levels = [];

  StudentModel? get student => _student;
  List<LevelModel> get levels => _levels;

  void updateStudent(StudentModel? student) {
    _student = student;
    if (student != null) {
      _levels = LevelModel.getDefaultLevels(student.currentLevel);
    }
    notifyListeners();
  }

  void updateLevelProgress(double progress) {
    if (_student != null) {
      _student = StudentModel(
        uid: _student!.uid,
        username: _student!.username,
        email: _student!.email,
        photoUrl: _student!.photoUrl,
        currentLevel: _student!.currentLevel,
        levelProgress: progress,
      );
      notifyListeners();
    }
  }
}
