/// Authentication Service
/// 
/// Manages JWT tokens using flutter_secure_storage.
/// Provides methods to save, retrieve, and delete the authentication token.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Secure storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Storage key for the JWT token
  static const String _tokenKey = 'jwt_token';

  /// Save the JWT token securely
  /// 
  /// On iOS: Stored in Keychain
  /// On Android: Stored in EncryptedSharedPreferences
  /// On Web: Stored in browser's secure storage
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve the stored JWT token
  /// 
  /// Returns null if no token is stored
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the stored JWT token (logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if user is authenticated (has a token)
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored data (complete logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Get authorization header for API requests
  /// 
  /// Returns the header map ready to be used in HTTP/GraphQL requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      return {};
    }
    return {
      'Authorization': 'Bearer $token',
    };
  }
}

