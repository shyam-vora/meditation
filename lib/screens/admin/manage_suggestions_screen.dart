import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'dart:io';
import '../../models/suggestion_model.dart';
import '../../database/app_database.dart';
import 'suggestion_form_screen.dart';

class ManageSuggestionsScreen extends StatefulWidget {
  const ManageSuggestionsScreen({super.key});

  @override
  State<ManageSuggestionsScreen> createState() =>
      _ManageSuggestionsScreenState();
}

class _ManageSuggestionsScreenState extends State<ManageSuggestionsScreen> {
  List<Suggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final suggestions = await AppDatabase.instance.getAllSuggestions();
    setState(() {
      _suggestions = suggestions;
    });
  }

  Future<void> _navigateToForm([Suggestion? suggestion]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuggestionFormScreen(suggestion: suggestion),
      ),
    );

    if (result == true) {
      _loadSuggestions();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Suggestions Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first suggestion',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _navigateToForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add Suggestion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: Text(
          'Manage Suggestions',
          style: TextStyle(
            color: TColor.primaryTextW,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.primaryTextW),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: _suggestions.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _navigateToForm(),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Suggestions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add and manage meditation suggestions for your users',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.format_list_bulleted,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_suggestions.length} Suggestions',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _suggestions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Column(
                          children: [
                            if (suggestion.imagePath != null)
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  image: DecorationImage(
                                    image:
                                        FileImage(File(suggestion.imagePath!)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ListTile(
                              title: Text(
                                suggestion.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: suggestion.type == 'mandatory'
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      suggestion.type.toUpperCase(),
                                      style: TextStyle(
                                        color: suggestion.type == 'mandatory'
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(suggestion.description),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _navigateToForm(suggestion),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await AppDatabase.instance
                                          .deleteSuggestion(suggestion.id!);
                                      _loadSuggestions();
                                    },
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
