import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../utils/constants.dart';
import '../network/api_client.dart';

class ApiAuthRepository implements IAuthRepository {
  @override
  Future<User> register(String nombre, String email, String password) async {
    final response = await ApiService.post(
      '${AppConstants.authEndpoint}/register',
      {
        'nombre': nombre,
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await ApiService.saveToken(token);
      await _saveUserData(user);

      return user;
    } else {
      throw Exception(response['message'] ?? 'Error al registrar');
    }
  }

  @override
  Future<User> login(String email, String password) async {
    final response = await ApiService.post(
      '${AppConstants.authEndpoint}/login',
      {
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await ApiService.saveToken(token);
      await _saveUserData(user);

      return user;
    } else {
      throw Exception(response['message'] ?? 'Error al iniciar sesión');
    }
  }

  @override
  Future<void> logout() async {
    await ApiService.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.remove(AppConstants.userEmailKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(AppConstants.userIdKey);
    final nombre = prefs.getString(AppConstants.userNameKey);
    final email = prefs.getString(AppConstants.userEmailKey);

    if (id != null && nombre != null && email != null) {
      return User(id: id, nombre: nombre, email: email);
    }
    return null;
  }

  @override
  Future<String?> getToken() async {
    return await ApiService.getToken();
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.userIdKey, user.id);
    await prefs.setString(AppConstants.userNameKey, user.nombre);
    await prefs.setString(AppConstants.userEmailKey, user.email);
  }
}
