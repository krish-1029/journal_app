/// API Configuration
/// 
/// This file contains the API endpoint configuration for different platforms.
/// Flutter can run on multiple platforms (Web, iOS, Android, Desktop), and each
/// might need different URLs to access the API.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Base URL for the GraphQL API
  /// 
  /// Platform-specific URLs:
  /// - Web: localhost works directly
  /// - iOS Simulator: localhost works
  /// - Android Emulator: Use 10.0.2.2 (special address for host machine)
  /// - Physical devices: Use your computer's local IP (e.g., 192.168.1.100)
  static String get baseUrl {
    if (kIsWeb) {
      // Web platform (Chrome, Firefox, etc.)
      return 'http://localhost:8080/api/graphql';
    } else if (Platform.isAndroid) {
      // Android emulator
      // For physical device, change to your computer's IP:
      // return 'http://192.168.1.100:8080/api/graphql';
      return 'http://10.0.2.2:8080/api/graphql';
    } else {
      // iOS simulator or macOS desktop
      return 'http://localhost:8080/api/graphql';
    }
  }

  /// WebSocket URL for GraphQL subscriptions (if needed in the future)
  static String get wsUrl {
    if (kIsWeb) {
      return 'ws://localhost:8080/api/graphql';
    } else if (Platform.isAndroid) {
      return 'ws://10.0.2.2:8080/api/graphql';
    } else {
      return 'ws://localhost:8080/api/graphql';
    }
  }

  /// Timeout duration for API requests
  static const Duration timeout = Duration(seconds: 30);

  /// API version (if your API supports versioning)
  static const String apiVersion = 'v1';
}

