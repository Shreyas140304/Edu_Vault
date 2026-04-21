import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/constants/app_colors.dart';
import 'package:eduvault/constants/app_constants.dart';
import 'package:eduvault/providers/document_provider.dart';
import 'package:eduvault/providers/entrance_exam_provider.dart';
import 'package:eduvault/providers/institution_provider.dart';
import 'package:eduvault/models/entrance_exam_model.dart';

class StageDetailsScreen extends StatelessWidget {
  final String stage;

  const StageDetailsScreen({super.key, required this.stage});

  Future<void> _deleteDocument(
    BuildContext context,
    DocumentProvider provider,
    String documentId,
  ) async {
    final success = await provider.deleteDocument(documentId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Document deleted successfully'
              : (provider.error ?? 'Failed to delete document'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final institutionProvider = context.watch<InstitutionProvider>();
    final stageRequirements = institutionProvider.getStageRequirements(stage);
    final requiredDocuments = stageRequirements.isEmpty
        ? (AppConstants.requiredDocuments[stage] ?? const [])
        : stageRequirements;
    final sourceLabel = institutionProvider.getStageRequirementSource(stage);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('$stage Documents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/upload-document');
        },
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, provider, _) {
          final uploadedDocuments = provider.getDocumentsByStage(stage);
          final uploadedCategories = uploadedDocuments
              .map((doc) => doc.category)
              .whereType<String>()
              .toSet();
          final completion = provider.getStageCompletionPercentage(stage);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircularProgressIndicator(
                        value: completion / 100,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$completion% complete',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${uploadedDocuments.length} uploaded',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Required Documents',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (sourceLabel != null && sourceLabel.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    'Source: $sourceLabel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                const SizedBox(height: 8),
              if (requiredDocuments.isEmpty)
                const Card(
                  child: ListTile(
                    title: Text(
                      'No predefined required documents for this stage',
                    ),
                  ),
                )
              else
                ...requiredDocuments.map((requiredDoc) {
                  final isUploaded = uploadedCategories.contains(requiredDoc);
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isUploaded
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isUploaded
                            ? AppColors.success
                            : AppColors.textHint,
                      ),
                      title: Text(requiredDoc),
                      subtitle: Text(isUploaded ? 'Uploaded' : 'Missing'),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              Text(
                'Uploaded Documents',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (uploadedDocuments.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No documents uploaded for $stage yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ...uploadedDocuments.map((document) {
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.description,
                        color: AppColors.primary,
                      ),
                      title: Text(document.fileName ?? 'Document'),
                      subtitle: Text(
                        '${document.category ?? 'Uncategorized'} • ${document.getFormattedDate()}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: provider.isLoading || document.id == null
                            ? null
                            : () => _deleteDocument(
                                context,
                                provider,
                                document.id!,
                              ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class ExamDetailsScreen extends StatelessWidget {
  final EntranceExam? exam;

  const ExamDetailsScreen({super.key, this.exam});

  List<String> _extractTimelineFromNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) {
      return const [];
    }

    return notes
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('- '))
        .map((line) => line.substring(2))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = context.watch<EntranceExamProvider>();
    final selected = exam ?? examProvider.selectedExam;

    if (selected == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam Details')),
        body: const Center(child: Text('No exam selected')),
      );
    }

    final timeline = _extractTimelineFromNotes(selected.notes);
    final requiredDocs = selected.requiredDocuments ?? const <String>[];
    final syncStatus = selected.id == null
        ? null
        : examProvider.getSyncStatus(selected.id!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('${selected.examName ?? 'Exam'} Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.examName ?? 'Exam',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deadline: ${selected.getFormattedDeadline()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (selected.officialPortal != null &&
                      selected.officialPortal!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Official portal: ${selected.officialPortal}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (syncStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        syncStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: examProvider.isLoading || selected.id == null
                        ? null
                        : () async {
                            final ok = await examProvider
                                .syncExamFromOfficialSource(selected.id!);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Exam synced successfully'
                                      : (examProvider.error ??
                                            'Sync failed, please try again'),
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.sync),
                    label: Text(
                      examProvider.isLoading ? 'Syncing...' : 'Sync Now',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Required Documents',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (requiredDocs.isEmpty)
            const Card(
              child: ListTile(title: Text('No required documents mapped yet')),
            )
          else
            ...requiredDocs.map(
              (doc) => Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(doc),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Timeline', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (timeline.isEmpty)
            const Card(
              child: ListTile(
                title: Text('Timeline not available yet. Tap Sync Now.'),
              ),
            )
          else
            ...timeline.map(
              (item) => Card(
                child: ListTile(
                  leading: const Icon(Icons.timeline),
                  title: Text(item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
