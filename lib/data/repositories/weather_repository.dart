import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService apiService;
  WeatherRepository({required this.apiService});

  Future<WeatherModel> getWeatherByCity(String city) async {
    final response = await apiService.fetchWeatherByCity(city);
    final weather = WeatherModel.fromJson(response);
    await _cacheWeatherData(weather);
    return weather;
  }

  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    final response = await apiService.fetchWeatherByCoordinates(lat, lon);
    final weather = WeatherModel.fromJson(response);
    await _cacheWeatherData(weather);
    return weather;
  }

  Future<void> _cacheWeatherData(WeatherModel weather) async {
    final box = await Hive.openBox('weatherCache');
    box.put('cachedWeather', weather.toJson());

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lastCity', weather.city);
  }

  Future<WeatherModel?> getCachedWeather() async {
    final box = await Hive.openBox('weatherCache');
    final data = box.get('cachedWeather');

    if (data != null) {
      return WeatherModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
}
