/// Home Screen
/// 
/// Displays a list of the user's journal entries.
/// Provides options to create, edit, or delete entries.

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/entries_provider.dart';
import '../../models/models.dart';
import '../entry/create_entry_screen.dart';
import '../entry/entry_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch entries when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEntries();
    });
  }

  Future<void> _fetchEntries() async {
    final entriesProvider =
        Provider.of<EntriesProvider>(context, listen: false);
    final graphQLClient = GraphQLProvider.of(context).value;
    await entriesProvider.fetchEntries(graphQLClient);
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entriesProvider =
        Provider.of<EntriesProvider>(context, listen: false);

    // Clear entries
    entriesProvider.clear();

    // Logout
    await authProvider.logout();

    // AuthWrapper will automatically navigate to login
  }

  void _navigateToCreateEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateEntryScreen()),
    );
  }

  void _navigateToEntryDetail(Entry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryDetailScreen(entry: entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final entriesProvider = Provider.of<EntriesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        actions: [
          // User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                authProvider.currentUser?.name ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEntries,
        child: entriesProvider.isLoading && entriesProvider.entries.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : entriesProvider.entries.isEmpty
                ? _buildEmptyState()
                : _buildEntriesList(entriesProvider.entries),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateEntry,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first entry',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<Entry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _EntryCard(
          entry: entry,
          onTap: () => _navigateToEntryDetail(entry),
        );
      },
    );
  }
}

/// Card widget for displaying an entry in the list
class _EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback onTap;

  const _EntryCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                entry.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content preview
              Text(
                entry.contentPreview,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(entry.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (entry.isRecentlyUpdated) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

