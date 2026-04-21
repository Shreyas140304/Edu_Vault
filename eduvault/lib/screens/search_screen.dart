import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/constants/app_colors.dart';
import 'package:eduvault/constants/app_constants.dart';
import 'package:eduvault/l10n/app_localizations.dart';
import 'package:eduvault/models/document_model.dart';
import 'package:eduvault/providers/index.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _selectedStage;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().loadDocuments();
      context.read<EntranceExamProvider>().loadEntranceExams();
      context.read<InstitutionProvider>().loadDirectory();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _query = value;
      });
    });
  }

  List<String> _getAvailableCategories(List<Document> docs) {
    final categories = docs
        .map((doc) => doc.category)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = context.watch<DocumentProvider>();
    final examProvider = context.watch<EntranceExamProvider>();
    final institutionProvider = context.watch<InstitutionProvider>();
    final categoryOptions = _getAvailableCategories(documentProvider.documents);
    if (_selectedCategory != null &&
        !categoryOptions.contains(_selectedCategory)) {
      _selectedCategory = null;
    }

    final documentResults = documentProvider.searchDocumentsWithFilters(
      query: _query,
      stage: _selectedStage,
      category: _selectedCategory,
    );

    final normalizedQuery = _query.trim().toLowerCase();
    final examResults = examProvider.exams.where((exam) {
      if (normalizedQuery.isEmpty) return false;
      return (exam.examName?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (exam.notes?.toLowerCase().contains(normalizedQuery) ?? false) ||
          (exam.officialPortal?.toLowerCase().contains(normalizedQuery) ??
              false);
    }).toList();

    final institutionResults = normalizedQuery.isEmpty
        ? const []
        : institutionProvider.searchAll(_query, limit: 10);

    final totalCount =
        documentResults.length + examResults.length + institutionResults.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('search'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _queryController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: context.tr('search_hint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _queryController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _queryController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedStage,
                    decoration: const InputDecoration(
                      labelText: 'Stage',
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Stages'),
                      ),
                      ...AppConstants.educationStages.map(
                        (stage) =>
                            DropdownMenuItem(value: stage, child: Text(stage)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStage = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categoryOptions.map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalCount result${totalCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    _queryController.clear();
                    setState(() {
                      _query = '';
                      _selectedStage = null;
                      _selectedCategory = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr('reset')),
                ),
              ],
            ),
          ),
          Expanded(
            child: totalCount == 0
                ? Center(
                    child: Text(
                      context.tr('no_matches_found'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (documentResults.isNotEmpty) ...[
                        Text(
                          context.tr('documents'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...documentResults.map((doc) {
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.description_outlined,
                                color: AppColors.primary,
                              ),
                              title: Text(doc.fileName ?? 'Document'),
                              subtitle: Text(
                                '${doc.stage ?? 'Unknown stage'} • ${doc.category ?? 'Uncategorized'}',
                              ),
                              trailing: Text(
                                doc.getFormattedDate(),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                      if (examResults.isNotEmpty) ...[
                        Text(
                          context.tr('exams'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...examResults.map((exam) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.assignment_outlined),
                              title: Text(exam.examName ?? 'Exam'),
                              subtitle: Text(
                                exam.officialPortal ??
                                    exam.getFormattedDeadline(),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                      if (institutionResults.isNotEmpty) ...[
                        Text(
                          context.tr('institutions'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...institutionResults.map((entry) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.account_balance_outlined,
                              ),
                              title: Text(entry.name),
                              subtitle: Text(
                                '${entry.type.toUpperCase()} • ${entry.state ?? 'Unknown'}',
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
