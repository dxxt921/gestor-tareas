import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/entities/weather.dart';
import '../utils/constants.dart';

class WeatherService {
  // Obtener clima por ciudad
  static Future<Weather> getWeatherByCity(String city) async {
    try {
      final url = Uri.parse(
        '${AppConstants.weatherBaseUrl}/weather?q=$city&appid=${AppConstants.weatherApiKey}&units=metric&lang=es',
      );

      final response = await http.get(url).timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Weather.fromJson(data);
      } else {
        throw Exception('Ciudad no encontrada');
      }
    } catch (e) {
      throw Exception('Error al obtener clima: $e');
    }
  }

  // Obtener clima por coordenadas
  static Future<Weather> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse(
        '${AppConstants.weatherBaseUrl}/weather?lat=$lat&lon=$lon&appid=${AppConstants.weatherApiKey}&units=metric&lang=es',
      );

      final response = await http.get(url).timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Weather.fromJson(data);
      } else {
        throw Exception('No se pudo obtener el clima');
      }
    } catch (e) {
      throw Exception('Error al obtener clima: $e');
    }
  }
}
