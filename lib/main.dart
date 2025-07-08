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
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const WeatherHome(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      cardColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BCD4),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      cardColor: const Color(0xFF2A2A3A),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [const Color(0xFF1E1E2E), const Color(0xFF2A2A3A)]
              : [const Color(0xFF87CEEB), const Color(0xFFF5F7FA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        size: 48,
                        color: isDark ? Colors.amber : Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Weather Forecast',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get real-time weather information',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Search Section
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: 'Enter city name',
                            hintText: 'e.g., London, New York, Tokyo',
                            prefixIcon: const Icon(Icons.location_city),
                            suffixIcon: _controller.text.isNotEmpty 
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() => _controller.clear()),
                                )
                              : null,
                          ),
                          onChanged: (value) => setState(() {}),
                          onSubmitted: (value) => getWeather(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _controller.text.isNotEmpty ? getWeather : null,
                                icon: const Icon(Icons.search),
                                label: const Text('Search Weather'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.teal : Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: getWeatherByLocation,
                                icon: const Icon(Icons.my_location),
                                label: const Text('My Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.amber : Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Loading, Error, or Results
                if (isLoading) 
                  _buildLoadingCard(isDark)
                else if (errorMessage != null)
                  _buildErrorCard(errorMessage!, isDark)
                else if (weatherData != null)
                  _buildWeatherCard(weatherData!, isDark)
                else
                  _buildWelcomeCard(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.teal : Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Fetching weather data...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, bool isDark) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.red.shade50,
              Colors.red.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.explore,
              size: 64,
              color: isDark ? Colors.teal : Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Weather Forecast!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a city name above or use your current location to get started with real-time weather information.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic> data, bool isDark) {
    final String cityName = data['name'];
    final String countryCode = data['sys']['country'];
    final double temp = data['main']['temp'].toDouble();
    final double feelsLike = data['main']['feels_like'].toDouble();
    final String description = data['weather'][0]['description'];
    final String iconCode = data['weather'][0]['icon'];
    final int humidity = data['main']['humidity'];
    final double windSpeed = data['wind']['speed'].toDouble();
    final int pressure = data['main']['pressure'];
    final int visibility = data['visibility'];
    final int sunrise = data['sys']['sunrise'];
    final int sunset = data['sys']['sunset'];

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF2A2A3A), const Color(0xFF1E1E2E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Location Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: isDark ? Colors.teal : Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$cityName, $countryCode',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Weather Icon and Temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.teal.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        "http://openweathermap.org/img/wn/$iconCode@2x.png",
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _getWeatherIcon(iconCode),
                          size: 80,
                          color: isDark ? Colors.teal : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${temp.toStringAsFixed(1)}°C",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        "Feels like ${feelsLike.toStringAsFixed(1)}°C",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                _capitalize(description),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Weather Details Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildWeatherDetail(
                          Icons.water_drop,
                          'Humidity',
                          '$humidity%',
                          isDark,
                        ),
                        _buildWeatherDetail(
                          Icons.air,
                          'Wind Speed',
                          '${windSpeed.toStringAsFixed(1)} m/s',
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildWeatherDetail(
                          Icons.compress,
                          'Pressure',
                          '$pressure hPa',
                          isDark,
                        ),
                        _buildWeatherDetail(
                          Icons.visibility,
                          'Visibility',
                          '${(visibility / 1000).toStringAsFixed(1)} km',
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildWeatherDetail(
                          Icons.wb_sunny,
                          'Sunrise',
                          _formatTime(sunrise),
                          isDark,
                        ),
                        _buildWeatherDetail(
                          Icons.brightness_3,
                          'Sunset',
                          _formatTime(sunset),
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: isDark ? Colors.teal : Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode.substring(0, 2)) {
      case '01': return Icons.wb_sunny;
      case '02': return Icons.wb_cloudy;
      case '03': case '04': return Icons.cloud;
      case '09': case '10': return Icons.grain;
      case '11': return Icons.thunderstorm;
      case '13': return Icons.ac_unit;
      case '50': return Icons.foggy;
      default: return Icons.wb_sunny;
    }
  }

  String _formatTime(int timestamp) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
