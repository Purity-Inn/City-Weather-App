# 🌤️ City Weather App

A beautiful Flutter application that provides real-time weather information for cities worldwide. Get current weather conditions, forecasts, and location-based weather data with an intuitive and modern interface.

## 🌐 Live Demo

**🚀 [Try the Live Web App](https://purity-inn.github.io/City-Weather-App/)**

*Access the app directly in your browser - no installation required!*

## ✨ Features

- 🔍 **City Search**: Search for weather information by city name
- 📍 **Location-based Weather**: Get weather for your current location using GPS
- 🌡️ **Detailed Weather Info**: Temperature, humidity, pressure, wind speed, and visibility
- 🌅 **Sunrise/Sunset Times**: Know when the sun rises and sets
- 🌪️ **Weather Conditions**: Clear descriptions with weather condition details
- 📱 **Cross-platform**: Runs on Android, iOS, Web, Windows, macOS, and Linux
- 🌙 **Dark Theme**: Beautiful dark theme for comfortable viewing

## 📱 Screenshots

*Screenshots coming soon...*

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.8.1 or higher)
- [Dart](https://dart.dev/get-dart) (included with Flutter)
- A code editor (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Purity-Inn/City-Weather-App.git
   cd City-Weather-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### 🔑 API Configuration

This app uses the OpenWeatherMap API. The API key is already included for demo purposes, but for production use, you should:

1. Get your own API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Replace the API key in `lib/services/weather_service.dart`

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Main app entry point
└── services/
    └── weather_service.dart  # Weather API service
```

## 🔧 Dependencies

- **[http](https://pub.dev/packages/http)**: For making API requests to OpenWeatherMap
- **[geolocator](https://pub.dev/packages/geolocator)**: For getting device location
- **[cupertino_icons](https://pub.dev/packages/cupertino_icons)**: iOS-style icons

## 🎯 How to Use

1. **Search by City**: Enter a city name in the search field and tap "Get Weather"
2. **Use Current Location**: Tap the location button to get weather for your current position
3. **View Details**: The app displays comprehensive weather information including:
   - Current temperature
   - Weather description
   - Humidity and pressure
   - Wind speed and direction
   - Visibility
   - Sunrise and sunset times

## 🌍 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔧 Building for Different Platforms

### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

### Windows
```bash
flutter build windows
```

### macOS
```bash
flutter build macos
```

### Linux
```bash
flutter build linux
```

## 🚀 Deployment

This app is deployed and accessible on multiple platforms:

### 🌐 Web Application
- **Live Demo**: [https://purity-inn.github.io/City-Weather-App/](https://purity-inn.github.io/City-Weather-App/)
- **Platform**: GitHub Pages
- **Status**: ✅ Live and running

### 📱 Mobile Applications
- **Android APK**: Available for download (built with `flutter build apk`)
- **iOS**: Can be built on macOS with `flutter build ios`

### 💻 Desktop Applications
- **Windows**: Can be built with `flutter build windows`
- **macOS**: Can be built on macOS with `flutter build macos`
- **Linux**: Can be built with `flutter build linux`

### 🔄 Continuous Deployment
The web version is automatically deployed to GitHub Pages from the `gh-pages` branch whenever updates are pushed.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenWeatherMap](https://openweathermap.org/) for providing the weather API
- [Flutter](https://flutter.dev/) for the amazing cross-platform framework
- The Flutter community for their excellent packages and resources

## 📞 Support

If you have any questions or run into issues, please open an issue on GitHub or contact the maintainers.

---

Made with ❤️ using Flutter
