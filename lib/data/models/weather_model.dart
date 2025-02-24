class WeatherModel {
  final String city;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String icon;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "temperature": temperature,
      "humidity": humidity,
      "windSpeed": windSpeed,
      "icon": icon,
    };
  }
}
