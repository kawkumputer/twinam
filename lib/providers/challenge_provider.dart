import 'package:flutter/foundation.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';

class ChallengeProvider extends ChangeNotifier {
  List<Challenge> _challenges = [];
  bool _loading = false;
  String? _error;

  List<Challenge> get challenges => _challenges;
  bool get loading => _loading;
  String? get error => _error;

  List<Challenge> get pending =>
      _challenges.where((c) => c.isPending).toList();
  List<Challenge> get active =>
      _challenges.where((c) => c.isActive).toList();
  List<Challenge> get completed =>
      _challenges.where((c) => c.isCompleted).toList();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _challenges = await ChallengeService.loadMyChallenges();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createChallenge({
    required String title,
    String? description,
    required String challengeType,
    required int targetValue,
    required int durationDays,
    required String opponentId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await ChallengeService.createChallenge(
        title: title,
        description: description,
        challengeType: challengeType,
        targetValue: targetValue,
        durationDays: durationDays,
        opponentId: opponentId,
      );
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> respond(String challengeId, bool accept) async {
    try {
      await ChallengeService.respondToChallenge(challengeId, accept);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProgress(String challengeId, int value) async {
    try {
      await ChallengeService.updateProgress(challengeId, value);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> delete(String challengeId) async {
    try {
      await ChallengeService.deleteChallenge(challengeId);
      _challenges.removeWhere((c) => c.id == challengeId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateInfo(
      String challengeId, String title, String? description) async {
    try {
      await ChallengeService.updateChallengeInfo(
          challengeId, title, description);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
