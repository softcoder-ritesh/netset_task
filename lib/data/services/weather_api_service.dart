import 'package:dio/dio.dart';

class WeatherApiService {
  final Dio dio = Dio();
  final String apiKey = "971f58c5291c2289e772cfc4ce609ef3";
  final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    try {
      final response = await dio.get(
        "$baseUrl?q=$city&appid=$apiKey&units=metric",
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch weather");
    }
  }

  Future<Map<String, dynamic>> fetchWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await dio.get(
        "$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric",
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch weather");
    }
  }
}
