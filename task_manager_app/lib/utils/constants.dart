class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000';
  static const String authEndpoint = '/auth';
  static const String tasksEndpoint = '/tasks';

  // OpenWeather API Configuration
  static const String weatherApiKey =
      'c322e932ddaa76e37076ab401e2bdeb8'; // Obtener gratis en https://openweathermap.org/api
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';

  // Timeout
  static const Duration requestTimeout = Duration(seconds: 30);
}
