/// Authentication Provider
/// 
/// Manages authentication state using Provider pattern.
/// Tracks the current user and provides methods for login/logout/register.

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/graphql_queries.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize auth state on app start
  /// 
  /// Checks if user has a stored token and fetches user data
  Future<void> initialize(GraphQLClient client) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user has a token
      final hasToken = await AuthService.isAuthenticated();

      if (hasToken) {
        // Fetch user data from API
        final QueryResult result = await client.query(
          QueryOptions(
            document: gql(GraphQLQueries.me),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        );

        if (result.hasException) {
          // Token might be expired, clear it
          await AuthService.deleteToken();
          _currentUser = null;
        } else if (result.data != null && result.data!['me'] != null) {
          _currentUser = User.fromJson(result.data!['me']);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<bool> register(
    GraphQLClient client, {
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.register),
        variables: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        _error = result.exception.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (result.data != null && result.data!['register'] != null) {
        final data = result.data!['register'];

        // Save token
        await AuthService.saveToken(data['token']);

        // Set current user
        _currentUser = User.fromJson(data['user']);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login(
    GraphQLClient client, {
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.login),
        variables: {
          'email': email,
          'password': password,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        _error = result.exception.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (result.data != null && result.data!['login'] != null) {
        final data = result.data!['login'];

        // Save token
        await AuthService.saveToken(data['token']);

        // Set current user
        _currentUser = User.fromJson(data['user']);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change the current user's password
  Future<bool> changePassword({
    required GraphQLClient client,
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.changePassword),
          variables: {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          },
        ),
      );

      if (result.hasException) {
        _error = result.exception?.graphqlErrors.isNotEmpty == true
            ? result.exception!.graphqlErrors.first.message
            : 'Failed to change password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = result.data?['changePassword'] == true;
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    await AuthService.deleteToken();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

