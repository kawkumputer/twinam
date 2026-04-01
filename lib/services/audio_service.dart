import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Play celebration sound when goal is reached
  Future<void> playCelebration() async {
    try {
      // Use system sound for celebration
      await SystemSound.play(SystemSoundType.click);
      debugPrint('[Audio] Celebration sound played');
    } catch (e) {
      debugPrint('[Audio] Error playing celebration: $e');
    }
  }

  // Play success sound for task completion
  Future<void> playSuccess() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      debugPrint('[Audio] Success sound played');
    } catch (e) {
      debugPrint('[Audio] Error playing success: $e');
    }
  }

  // Play alert sound for overdue tasks
  Future<void> playAlert() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      debugPrint('[Audio] Alert sound played');
    } catch (e) {
      debugPrint('[Audio] Error playing alert: $e');
    }
  }
}
