import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/constants.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  // Obtener token almacenado
  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  // Guardar token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  // Eliminar token
  static Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // Headers con autenticación
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http
          .delete(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Manejar respuesta HTTP
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final message = data['message'] as String? ?? 'Error desconocido';
      throw Exception(message);
    }
  }
}
