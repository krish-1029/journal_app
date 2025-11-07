/// Entries Layout Widget
/// 
/// Handles responsive display of journal entries:
/// - Mobile: Single column list
/// - Tablet: 2-column grid
/// - Desktop: 3-column grid

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/responsive.dart';
import 'entry_card.dart';

class EntriesLayout extends StatelessWidget {
  final List<Entry> entries;
  final Function(Entry) onEntryTap;

  const EntriesLayout({
    super.key,
    required this.entries,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildList(context),
      tablet: _buildGrid(context, 2),
      desktop: _buildGrid(context, 3),
    );
  }

  /// Build single-column list for mobile
  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EntryCard(
            entry: entry,
            onTap: () => onEntryTap(entry),
          ),
        );
      },
    );
  }

  /// Build multi-column grid for tablet/desktop
  Widget _buildGrid(BuildContext context, int columns) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8, // Wider cards = shorter height
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return EntryCard(
          entry: entry,
          onTap: () => onEntryTap(entry),
        );
      },
    );
  }
}

