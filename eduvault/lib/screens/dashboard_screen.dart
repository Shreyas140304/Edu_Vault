import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduvault/constants/app_colors.dart';
import 'package:eduvault/constants/app_constants.dart';
import 'package:eduvault/providers/index.dart';
import 'package:eduvault/widgets/stage_card.dart';
import 'package:eduvault/widgets/exam_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserProfile();
      context.read<DocumentProvider>().loadDocuments();
      context.read<EntranceExamProvider>().loadEntranceExams();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('EduVault'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).pushNamed('/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Summary
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final profile = userProvider.userProfile;
              return profile != null
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primary,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.fullName ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${profile.schoolName} • ${profile.board}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Stages', icon: Icon(Icons.school)),
              Tab(text: 'Exams', icon: Icon(Icons.assignment)),
              Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            ],
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStagesTab(),
                _buildExamsTab(),
                _buildOverviewTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/upload-document');
        },
        icon: const Icon(Icons.add),
        label: const Text('Upload Document'),
      ),
    );
  }

  Widget _buildStagesTab() {
    return Consumer<DocumentProvider>(
      builder: (context, documentProvider, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: AppConstants.educationStages.length,
          itemBuilder: (context, index) {
            final stage = AppConstants.educationStages[index];
            final documents = documentProvider.getDocumentsByStage(stage);
            final completion = documentProvider.getStageCompletionPercentage(
              stage,
            );
            final missing = documentProvider.getMissingDocumentsForStage(stage);

            return StageCard(
              stage: stage,
              documentCount: documents.length,
              completionPercentage: completion,
              missingCount: missing.length,
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed('/stage-details', arguments: stage);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildExamsTab() {
    return Consumer<EntranceExamProvider>(
      builder: (context, examProvider, _) {
        final exams = examProvider.activeExams;

        if (exams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  'No entrance exams added yet',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/add-exam');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exam'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            return ExamCard(
              exam: exams[index],
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed('/exam-details', arguments: exams[index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Progress',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Consumer2<DocumentProvider, EntranceExamProvider>(
            builder: (context, docProvider, examProvider, _) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Documents',
                    docProvider.documents.length.toString(),
                    Icons.description,
                  ),
                  _buildStatCard(
                    'Active Exams',
                    examProvider.activeExams.length.toString(),
                    Icons.assignment,
                  ),
                  _buildStatCard(
                    'Approaching Deadlines',
                    examProvider
                        .getExamsWithApproachingDeadlines()
                        .length
                        .toString(),
                    Icons.alarm,
                  ),
                  _buildStatCard(
                    'Completed Stages',
                    '${_getCompletedStages(docProvider).length}/${AppConstants.educationStages.length}',
                    Icons.check_circle,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Documents',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Consumer<DocumentProvider>(
            builder: (context, docProvider, _) {
              final recent = docProvider.documents.length > 5
                  ? docProvider.documents
                        .sublist(docProvider.documents.length - 5)
                        .reversed
                        .toList()
                  : docProvider.documents.reversed.toList();

              return recent.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No documents uploaded yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        final doc = recent[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.description,
                              color: AppColors.primary,
                            ),
                            title: Text(doc.fileName ?? 'Document'),
                            subtitle: Text(
                              '${doc.stage} • ${doc.category}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              doc.getFormattedDate(),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        );
                      },
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  List<String> _getCompletedStages(DocumentProvider provider) {
    return AppConstants.educationStages
        .where((stage) => provider.getStageCompletionPercentage(stage) == 100)
        .toList();
  }
}
