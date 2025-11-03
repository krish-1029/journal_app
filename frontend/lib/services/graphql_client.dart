/// GraphQL Client Service
/// 
/// Configures and provides the GraphQL client for the entire app.
/// Handles authentication headers and connects to the backend API.

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class GraphQLClientService {
  /// Create a GraphQL client with authentication
  /// 
  /// This method creates a new GraphQL client instance with the JWT token
  /// from secure storage included in the authorization header.
  static Future<GraphQLClient> getClient() async {
    // Create HTTP Link to the API
    final HttpLink httpLink = HttpLink(
      ApiConfig.baseUrl,
    );

    // Create Auth Link to add the token to requests
    // IMPORTANT: The getToken closure fetches the token FRESH on each request
    // This ensures we always use the latest token (after login/logout)
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final token = await AuthService.getToken();
        if (token != null) {
          return 'Bearer $token';
        }
        return null;
      },
    );

    // Combine auth and http links
    final Link link = authLink.concat(httpLink);

    // Return configured GraphQL client
    return GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: InMemoryStore(), // Cache for query results
      ),
    );
  }

  /// Create a ValueNotifier for the GraphQL client
  /// 
  /// This is used with GraphQLProvider to provide the client to the widget tree.
  /// The ValueNotifier allows the client to be updated when auth state changes.
  static Future<ValueNotifier<GraphQLClient>> getClientNotifier() async {
    final client = await getClient();
    return ValueNotifier(client);
  }

  /// Update the client when auth state changes
  /// 
  /// Call this after login/logout to update the client with new token
  static Future<void> updateClient(
      ValueNotifier<GraphQLClient> clientNotifier) async {
    final newClient = await getClient();
    clientNotifier.value = newClient;
  }
}

