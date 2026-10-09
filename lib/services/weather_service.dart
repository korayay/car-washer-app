import 'dart:math';

enum WeatherCondition {
  sunny,
  cloudy,
  rainy,
  stormy,
  snowy,
}

class WeatherData {
  final double temperature;
  final WeatherCondition condition;
  final String description;
  final DateTime time;
  final bool willRainSoon; // Önümüzdeki 2 saat içinde yağmur
  final double humidity;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.time,
    required this.willRainSoon,
    required this.humidity,
  });
}

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  // Cache mekanizması - 5 dakika boyunca aynı veriyi döndür
  WeatherData? _cachedWeather;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Mock weather data
  Future<WeatherData> getCurrentWeather() async {
    // Cache kontrolü
    if (_cachedWeather != null && _lastFetchTime != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
      if (timeSinceLastFetch < _cacheDuration) {
        return _cachedWeather!;
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    
    final random = Random();
    final conditions = WeatherCondition.values;
    final condition = conditions[random.nextInt(conditions.length)];
    
    final weatherData = WeatherData(
      temperature: 15 + random.nextDouble() * 20, // 15-35°C
      condition: condition,
      description: _getDescription(condition),
      time: DateTime.now(),
      willRainSoon: condition == WeatherCondition.rainy || 
                   condition == WeatherCondition.stormy ||
                   random.nextBool(), // %50 chance
      humidity: 40 + random.nextDouble() * 50, // 40-90%
    );

    // Cache'e kaydet
    _cachedWeather = weatherData;
    _lastFetchTime = DateTime.now();
    
    return weatherData;
  }

  Future<List<WeatherData>> getHourlyForecast({int hours = 24}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final List<WeatherData> forecast = [];
    final random = Random();
    
    for (int i = 0; i < hours; i++) {
      final conditions = WeatherCondition.values;
      final condition = conditions[random.nextInt(conditions.length)];
      
      forecast.add(WeatherData(
        temperature: 15 + random.nextDouble() * 20,
        condition: condition,
        description: _getDescription(condition),
        time: DateTime.now().add(Duration(hours: i)),
        willRainSoon: condition == WeatherCondition.rainy || 
                     condition == WeatherCondition.stormy,
        humidity: 40 + random.nextDouble() * 50,
      ));
    }
    
    return forecast;
  }

  String _getDescription(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return 'Güneşli';
      case WeatherCondition.cloudy:
        return 'Bulutlu';
      case WeatherCondition.rainy:
        return 'Yağmurlu';
      case WeatherCondition.stormy:
        return 'Fırtınalı';
      case WeatherCondition.snowy:
        return 'Karlı';
    }
  }

  String getCarWashRecommendation(WeatherData weather) {
    if (weather.willRainSoon) {
      return 'Yakında yağmur yağacak! Arabanı yıkatmak için son şans 🌧️';
    }
    
    switch (weather.condition) {
      case WeatherCondition.sunny:
        return 'Harika bir gün! Arabanı yıkatmak için mükemmel hava ☀️';
      case WeatherCondition.cloudy:
        return 'Bulutlu ama yıkama için ideal bir hava 🌤️';
      case WeatherCondition.rainy:
        return 'Yağmur yağıyor, daha sonra yıkat 🌧️';
      case WeatherCondition.stormy:
        return 'Fırtına var, güvenlik için yıkamayı ertele ⛈️';
      case WeatherCondition.snowy:
        return 'Kar yağıyor, yıkama önerilmez ❄️';
    }
  }

  bool isGoodTimeForWash(WeatherData weather) {
    return !weather.willRainSoon && 
           weather.condition != WeatherCondition.rainy &&
           weather.condition != WeatherCondition.stormy;
  }
}

extension WeatherConditionExtension on WeatherCondition {
  String get emoji {
    switch (this) {
      case WeatherCondition.sunny:
        return '☀️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.stormy:
        return '⛈️';
      case WeatherCondition.snowy:
        return '❄️';
    }
  }
} 