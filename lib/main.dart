import 'package:flutter/material.dart';
import 'services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Weather Forecast',
      theme: ThemeData.dark(),
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? errorMessage;

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> getWeather() async {
    final city = _controller.text.trim();
    if (city.isEmpty) {
      setState(() {
        errorMessage = "⚠️ Please enter a city name.";
        weatherData = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final data = await WeatherService.fetchWeather(city);

    setState(() {
      isLoading = false;
      if (data != null && data["cod"] == 200) {
        weatherData = data;
        errorMessage = null;
      } else {
        weatherData = null;
        errorMessage = "❌ City \"$city\" not found. Try again.";
      }
    });
  }

  Future<void> getWeatherByLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = "❌ Location services are disabled.";
          isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = "❌ Location permission denied.";
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage =
              "❌ Location permission permanently denied. Enable it in settings.";
          isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final data = await WeatherService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        isLoading = false;
        if (data != null && data['cod'] == 200) {
          weatherData = data;
          errorMessage = null;
          _controller.clear();
        } else {
          weatherData = null;
          errorMessage = "❌ Unable to fetch weather for your location.";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "❌ Failed to get location: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City Weather App'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter city name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: getWeather,
                icon: const Icon(Icons.search),
                label: const Text('Get Weather'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: getWeatherByLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use My Location'),
              ),
              const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator(),
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (weatherData == null && errorMessage == null && !isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "🔍 Enter a city above or use your location.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              if (weatherData != null) weatherResultCard(weatherData!),
            ],
          ),
        ),
      ),
    );
  }

  Widget weatherResultCard(Map<String, dynamic> data) {
    final String cityName = data['name'];
    final double temp = data['main']['temp'].toDouble();
    final String description = data['weather'][0]['description'];
    final String iconCode = data['weather'][0]['icon'];
    final int humidity = data['main']['humidity'];
    final double windSpeed = data['wind']['speed'].toDouble();

    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              cityName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Image.network("http://openweathermap.org/img/wn/$iconCode@2x.png"),
            Text(
              "${temp.toStringAsFixed(1)} °C",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              _capitalize(description),
              style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.water_drop),
                    Text('Humidity: $humidity%')
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.air),
                    Text('Wind: ${windSpeed.toStringAsFixed(1)} m/s')
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
