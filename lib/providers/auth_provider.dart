import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/twin_user.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  TwinUser? _currentUser;
  String? _error;
  bool _loading = false;
  bool _pendingEmailConfirmation = false;
  String? _pendingEmail;

  AuthStatus get status => _status;
  TwinUser? get currentUser => _currentUser;
  String? get error => _error;
  bool get loading => _loading;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get pendingEmailConfirmation => _pendingEmailConfirmation;
  String? get pendingEmail => _pendingEmail;

  AuthProvider() {
    _init();
    SupabaseService.authStateChanges.listen((data) {
      if (data.session != null) {
        _loadCurrentUser();
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
  }

  Future<void> _init() async {
    if (SupabaseService.isLoggedIn) {
      await _loadCurrentUser();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentProfile();
      _status = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    _loading = true;
    _error = null;
    _pendingEmailConfirmation = false;
    notifyListeners();
    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString() == 'EMAIL_CONFIRMATION_REQUIRED') {
        _pendingEmailConfirmation = true;
        _pendingEmail = email;
        _loading = false;
        notifyListeners();
        return false;
      }
      _error = _parseError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String email,
    required String token,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.verifyOtp(email: email, token: token);
      _status = AuthStatus.authenticated;
      _pendingEmailConfirmation = false;
      _pendingEmail = null;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> deleteAccount() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.deleteAccount();
      try {
        if (Hive.isBoxOpen('counters')) await Hive.box<String>('counters').clear();
        if (Hive.isBoxOpen('settings')) await Hive.box<dynamic>('settings').clear();
        if (Hive.isBoxOpen('tasks')) await Hive.box<String>('tasks').clear();
      } catch (_) {}
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(Object e) {
    if (e is AuthException) {
      switch (e.code) {
        case 'over_email_send_rate_limit':
          return 'Trop d\'emails envoyés. Attends quelques minutes avant de réessayer.';
        case 'user_already_exists':
        case 'email_exists':
          return 'Un compte existe déjà avec cet email.';
        case 'invalid_credentials':
          return 'Email ou mot de passe incorrect.';
        case 'weak_password':
          return 'Mot de passe trop faible (min. 6 caractères).';
        case 'otp_expired':
        case 'token_expired':
          return 'Code expiré. Recommence l\'inscription.';
        case 'otp_disabled':
          return 'Vérification OTP non disponible.';
        default:
          return e.message;
      }
    }
    return e.toString();
  }
}
