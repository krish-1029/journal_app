/// Home Screen
/// 
/// Displays a list of the user's journal entries.
/// Provides options to create, edit, or delete entries.

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/entries_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';
import '../../widgets/entries_layout.dart';
import '../../widgets/entry_list_item.dart';
import '../../widgets/entry_editor.dart';
import '../../widgets/new_entry_creator.dart';
import '../entry/create_entry_screen.dart';
import '../entry/entry_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For mobile bottom navigation
  Entry? _selectedEntry; // For desktop split-view
  bool _isCreatingNewEntry = false; // For desktop new entry mode

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

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _navigateToCreateEntry() {
    final isMobile = Responsive.isMobile(context);
    
    if (isMobile) {
      // Mobile: Navigate to separate screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateEntryScreen()),
      );
    } else {
      // Desktop: Open in split view
      setState(() {
        _isCreatingNewEntry = true;
        _selectedEntry = null;
      });
    }
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
    final isMobile = Responsive.isMobile(context);

    // On mobile: show tab-based navigation with bottom bar
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_selectedIndex == 0 ? 'My Journal' : 'Profile'),
          actions: [
            // Theme toggle button
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: themeProvider.isDark ? 'Light Mode' : 'Dark Mode',
                );
              },
            ),
          ],
        ),
        body: _selectedIndex == 0
            ? RefreshIndicator(
                onRefresh: _fetchEntries,
                child: entriesProvider.isLoading && entriesProvider.entries.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : entriesProvider.entries.isEmpty
                        ? _buildEmptyState()
                        : EntriesLayout(
                            entries: entriesProvider.entries,
                            onEntryTap: _navigateToEntryDetail,
                          ),
              )
            : const ProfileScreen(showAppBar: false), // No AppBar when embedded
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'Entries',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton.extended(
                onPressed: _navigateToCreateEntry,
                icon: const Icon(Icons.add),
                label: const Text('New Entry'),
              )
            : null,
      );
    }

    // On desktop: show split-view with master-detail
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        actions: [
          // User name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                authProvider.currentUser?.name ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          // Theme toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: themeProvider.isDark ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          // Profile button
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _navigateToProfile,
            tooltip: 'Profile',
          ),
        ],
      ),
      body: entriesProvider.isLoading && entriesProvider.entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : entriesProvider.entries.isEmpty
              ? _buildEmptyState()
              : _buildDesktopSplitView(entriesProvider.entries),
    );
  }

  Widget _buildDesktopSplitView(List<Entry> entries) {
    return Row(
      children: [
        // LEFT PANEL: Master - Entries List
        SizedBox(
          width: 400,
          child: Column(
            children: [
              // New Entry Button
              Container(
                height: 80,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToCreateEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('New Entry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 3, // Add shadow
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),

              // Entries List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchEntries,
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return EntryListItem(
                        entry: entry,
                        isSelected: _selectedEntry?.id == entry.id && !_isCreatingNewEntry,
                        onTap: () {
                          setState(() {
                            _isCreatingNewEntry = false;
                            _selectedEntry = entry;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Divider
        const VerticalDivider(width: 1, thickness: 1),

        // RIGHT PANEL: Detail - Entry Editor or New Entry Creator
        Expanded(
          child: _isCreatingNewEntry
              ? NewEntryCreator(
                  onEntrySaved: (Entry newEntry) {
                    setState(() {
                      _isCreatingNewEntry = false;
                      _selectedEntry = newEntry;
                    });
                  },
                  onCancel: () {
                    setState(() {
                      _isCreatingNewEntry = false;
                    });
                  },
                )
              : _selectedEntry != null
                  ? EntryEditor(
                      key: ValueKey(_selectedEntry!.id),
                      entry: _selectedEntry!,
                      onDeleted: () {
                        setState(() {
                          _selectedEntry = null;
                        });
                      },
                    )
                  : _buildEmptyDetailState(),
        ),
      ],
    );
  }

  Widget _buildEmptyDetailState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Select an entry to view and edit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Or create a new entry to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
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
}

