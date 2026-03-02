class Weather {
  final String city;
  final double temperature;
  final String description;
  final String icon;
  final double feelsLike;
  final int humidity;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'] as String,
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
