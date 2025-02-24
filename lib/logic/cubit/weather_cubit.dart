import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netset_weather_task/logic/cubit/weather_state.dart';
import '../../data/models/weather_model.dart';
import '../../data/repositories/weather_repository.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherCubit({required this.weatherRepository}) : super(WeatherInitial());

  void fetchWeatherByCity(String city) async {
    emit(WeatherLoading());
    try {
      final weather = await weatherRepository.getWeatherByCity(city);
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError("Could not fetch weather"));
    }
  }

  void fetchWeatherByLocation(double lat, double lon) async {
    emit(WeatherLoading());
    try {
      final weather = await weatherRepository.getWeatherByLocation(lat, lon);
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError("Could not fetch weather"));
    }
  }

  void loadCachedWeather() async {
    final cachedWeather = await weatherRepository.getCachedWeather();
    if (cachedWeather != null) {
      emit(WeatherLoaded(cachedWeather));
    } else {
      emit(WeatherInitial());
    }
  }
}
