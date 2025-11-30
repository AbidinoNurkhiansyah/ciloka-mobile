import 'package:flutter/material.dart';

class LevelModel {
  final int levelNumber;
  final bool isUnlocked;
  final String levelName;
  final Color levelColor;
  final String iconPath;

  LevelModel({
    required this.levelNumber,
    required this.isUnlocked,
    required this.levelName,
    required this.levelColor,
    required this.iconPath,
  });

  static List<LevelModel> getDefaultLevels(int currentLevel) {
    return [
      LevelModel(
        levelNumber: 1,
        isUnlocked: true,
        levelName: 'Level 1',
        levelColor: const Color(0xFF4CAF50), // Green
        iconPath: '',
      ),
      LevelModel(
        levelNumber: 2,
        isUnlocked: currentLevel >= 2,
        levelName: 'Level 2',
        levelColor: const Color.fromARGB(255, 39, 176, 108), // Purple
        iconPath: '',
      ),
      LevelModel(
        levelNumber: 3,
        isUnlocked: currentLevel >= 3,
        levelName: 'Level 3',
        levelColor: const Color(0xFF2196F3), // Blue
        iconPath: '',
      ),
      LevelModel(
        levelNumber: 4,
        isUnlocked: currentLevel >= 4,
        levelName: 'Level 4',
        levelColor: const Color(0xFF4CAF50), // Green
        iconPath: '',
      ),
      LevelModel(
        levelNumber: 5,
        isUnlocked: currentLevel >= 5,
        levelName: 'Level 5',
        levelColor: const Color(0xFFE91E63), // Pink
        iconPath: '',
      ),
    ];
  }
}
