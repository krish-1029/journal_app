/// GraphQL Queries and Mutations
/// 
/// This file contains all GraphQL operations (queries and mutations) for the app.
/// These match the schema defined in the backend API.

class GraphQLQueries {
  // ==================== AUTH MUTATIONS ====================

  /// Register a new user
  static const String register = r'''
    mutation Register($email: String!, $password: String!, $name: String!) {
      register(email: $email, password: $password, name: $name) {
        token
        user {
          id
          email
          name
          createdAt
        }
      }
    }
  ''';

  /// Login with email and password
  static const String login = r'''
    mutation Login($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        token
        user {
          id
          email
          name
          createdAt
        }
      }
    }
  ''';

  // ==================== USER QUERIES ====================

  /// Get current user profile
  static const String me = r'''
    query Me {
      me {
        id
        email
        name
        createdAt
      }
    }
  ''';

  // ==================== ENTRY QUERIES ====================

  /// Get all entries for the current user
  static const String myEntries = r'''
    query MyEntries {
      myEntries {
        id
        userId
        title
        content
        createdAt
        updatedAt
      }
    }
  ''';

  // ==================== ENTRY MUTATIONS ====================

  /// Create a new journal entry
  static const String createEntry = r'''
    mutation CreateEntry($title: String!, $content: String!) {
      createEntry(title: $title, content: $content) {
        id
        userId
        title
        content
        createdAt
        updatedAt
      }
    }
  ''';

  /// Update an existing journal entry
  static const String updateEntry = r'''
    mutation UpdateEntry($id: ID!, $title: String, $content: String) {
      updateEntry(id: $id, title: $title, content: $content) {
        id
        userId
        title
        content
        createdAt
        updatedAt
      }
    }
  ''';

  /// Delete a journal entry
  static const String deleteEntry = r'''
    mutation DeleteEntry($id: ID!) {
      deleteEntry(id: $id) {
        id
      }
    }
  ''';
}

