import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/logger_service.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isClient => _user?.isClient ?? false;
  bool get isVendor => _user?.isVendor ?? false;
  bool get hasWarehouseRoles => _user?.hasWarehouseRoles ?? false;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.login(username, password);
      if (success) {
        await _loadUserInfo();
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password, 
                       String firstName, String lastName) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _authService.register(username, email, password, firstName, lastName);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        await _loadUserInfo();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo != null) {
        _user = User(
          id: userInfo['user_id'] ?? 0,
          username: userInfo['username'] ?? 'Unknown',
          email: userInfo['email'] ?? '',
          firstName: userInfo['first_name'] ?? '',
          lastName: userInfo['last_name'] ?? '',
          isStaff: userInfo['is_staff'] ?? false,
          isActive: true,
          role: userInfo['role'] ?? 'user',
          roles: List<String>.from(userInfo['roles'] ?? ['user']),
        );
        AppLogger.info('User loaded: ${_user!.username}, isStaff: ${_user!.isStaff}');
      }
    } catch (e) {
      AppLogger.info('Error loading user info: $e');
      // Create basic user from token if available
      final token = await _authService.getToken();
      if (token != null) {
        _user = User(
          id: 1,
          username: 'User',
          email: '',
          firstName: '',
          lastName: '',
          isStaff: false,
          isActive: true,
        );
      }
    }
  }
}