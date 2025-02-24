import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../logic/cubit/weather_cubit.dart';
import '../../logic/cubit/weather_state.dart';
import '../widgets/weather_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _recentSearches = [];
  final List<String> _popularCities = [
    "Katihar",
    "Mumbai",
    "Chandigarh",
    "Gaya",
    "Patna",
    "Nagpur",
    "Kolkata",
    "Bengaluru"
  ];
  late Box _searchBox;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _searchBox = await Hive.openBox('searchBox');
    setState(() {
      _recentSearches =
          _searchBox.get('recentSearches', defaultValue: []).cast<String>();
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _fetchWeather(String city) {
    if (city.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<WeatherCubit>().fetchWeatherByCity(city);
    _cityController.text = city;
    _saveSearch(city);
  }

  void _saveSearch(String city) {
    if (!_recentSearches.contains(city)) {
      if (_recentSearches.length >= 5) {
        _recentSearches.removeAt(0);
      }
      _recentSearches.add(city);
      _searchBox.put('recentSearches', _recentSearches);
      setState(() {});
    }
  }

  void _clearRecentSearches() {
    _searchBox.delete('recentSearches');
    setState(() {
      _recentSearches.clear();
    });
  }

  Future<void> _fetchWeatherByLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    context
        .read<WeatherCubit>()
        .fetchWeatherByLocation(position.latitude, position.longitude);
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Check Weather",
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            focusNode: _searchFocusNode,
            controller: _cityController,
            onSubmitted: _fetchWeather,
            decoration: InputDecoration(
              hintText: "Search city",
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white24,
              prefixIcon: Icon(Icons.search, color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () => _fetchWeather(_cityController.text),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),

          /// Recent Searches
          if (_recentSearches.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Searches",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _clearRecentSearches,
                      child: Text("Clear",
                          style: TextStyle(color: Colors.white70)),
                    )
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _recentSearches.map((city) {
                    return GestureDetector(
                      onTap: () => _fetchWeather(city),
                      child: Chip(
                        label:
                            Text(city, style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.blue.shade700,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          SizedBox(height: 10),

          Text(
            "Popular Cities",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _popularCities.map((city) {
              return GestureDetector(
                onTap: () => _fetchWeather(city),
                child: Chip(
                  label: Text(city, style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blue.shade700,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _fetchWeatherByLocation,
            icon: Icon(Icons.location_on, color: Colors.white),
            label: Text("Use Current Location"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade300,
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorUI(String message, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.redAccent, size: 80),
        SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _fetchWeather(_cityController.text),
          icon: Icon(Icons.refresh, color: Colors.white),
          label: Text("Try Again"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                SizedBox(height: 30),
                _buildHeader(),
                SizedBox(height: 20),
                BlocBuilder<WeatherCubit, WeatherState>(
                  builder: (context, state) {
                    if (state is WeatherLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is WeatherLoaded) {
                      return FadeInUp(
                        duration: Duration(milliseconds: 500),
                        child: WeatherCard(weather: state.weather),
                      );
                    } else if (state is WeatherError) {
                      if (state.message.contains("not found")) {
                        return _buildErrorUI(
                          "City not found. Please check the name and try again.",
                          Icons.location_off,
                        );
                      } else if (state.message.contains("No Internet")) {
                        return _buildErrorUI(
                          "Internet connection lost. Please check your network.",
                          Icons.wifi_off,
                        );
                      } else {
                        return _buildErrorUI(
                          "Something went wrong. Please try again later.",
                          Icons.error_outline,
                        );
                      }
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          child: Icon(Icons.cloud,
                              size: 100, color: Colors.blueGrey),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Search for a city's weather",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Try searching for: ${_popularCities.join(', ')} and more",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
