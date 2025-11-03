/// Entries Provider
/// 
/// Manages journal entries state using Provider pattern.
/// Provides methods for CRUD operations on entries.

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/models.dart';
import '../services/graphql_queries.dart';

class EntriesProvider with ChangeNotifier {
  List<Entry> _entries = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Entry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get entriesCount => _entries.length;

  /// Fetch all entries for the current user
  Future<void> fetchEntries(GraphQLClient client) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(GraphQLQueries.myEntries),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _error = result.exception.toString();
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (result.data != null && result.data!['myEntries'] != null) {
        final List<dynamic> entriesData = result.data!['myEntries'];
        _entries = entriesData.map((json) => Entry.fromJson(json)).toList();

        // Sort by most recent first
        _entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new entry
  Future<bool> createEntry(
    GraphQLClient client, {
    required String title,
    required String content,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.createEntry),
        variables: {
          'title': title,
          'content': content,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        _error = result.exception.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (result.data != null && result.data!['createEntry'] != null) {
        final newEntry = Entry.fromJson(result.data!['createEntry']);
        
        // Add to the beginning of the list
        _entries.insert(0, newEntry);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to create entry';
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

  /// Update an existing entry
  Future<bool> updateEntry(
    GraphQLClient client, {
    required String id,
    String? title,
    String? content,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateEntry),
        variables: {
          'id': id,
          if (title != null) 'title': title,
          if (content != null) 'content': content,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        _error = result.exception.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (result.data != null && result.data!['updateEntry'] != null) {
        final updatedEntry = Entry.fromJson(result.data!['updateEntry']);
        
        // Find and replace the entry in the list
        final index = _entries.indexWhere((e) => e.id == id);
        if (index != -1) {
          _entries[index] = updatedEntry;
          // Re-sort to move updated entry to top
          _entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to update entry';
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

  /// Delete an entry
  Future<bool> deleteEntry(
    GraphQLClient client, {
    required String id,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.deleteEntry),
        variables: {
          'id': id,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        _error = result.exception.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (result.data != null && result.data!['deleteEntry'] != null) {
        // Remove from the list
        _entries.removeWhere((e) => e.id == id);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to delete entry';
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

  /// Get a single entry by ID
  Entry? getEntryById(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all entries (on logout)
  void clear() {
    _entries = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

