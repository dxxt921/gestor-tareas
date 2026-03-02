import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../application/usecases/auth_usecases.dart';

class AuthProvider with ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final CheckAuthUseCase checkAuthUseCase;
  final LogoutUseCase logoutUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.checkAuthUseCase,
    required this.logoutUseCase,
  });

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await checkAuthUseCase.execute();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      {required String nombre,
      required String email,
      required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await registerUseCase.execute(nombre, email, password);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _user = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await loginUseCase.execute(email, password);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _user = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await logoutUseCase.execute();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
