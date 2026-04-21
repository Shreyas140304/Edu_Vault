import 'package:flutter/material.dart';
import 'package:eduvault/constants/app_colors.dart';

class StageCard extends StatelessWidget {
  final String stage;
  final int documentCount;
  final int completionPercentage;
  final int missingCount;
  final VoidCallback onTap;

  const StageCard({
    Key? key,
    required this.stage,
    required this.documentCount,
    required this.completionPercentage,
    required this.missingCount,
    required this.onTap,
  }) : super(key: key);

  Color _getCompletionColor() {
    if (completionPercentage == 100) return AppColors.success;
    if (completionPercentage >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _getStatusText() {
    if (completionPercentage == 100) return 'Complete';
    if (missingCount == 0) return 'Complete';
    return '$missingCount missing';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getStageIcon(), color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$documentCount documents uploaded',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCompletionColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getCompletionColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation(_getCompletionColor()),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completionPercentage% Complete',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStageIcon() {
    switch (stage) {
      case 'Class 10':
        return Icons.school;
      case 'Class 12':
        return Icons.school;
      case 'Graduation':
        return Icons.business_center;
      case 'Post Graduation':
        return Icons.auto_stories;
      case 'Entrance Exams':
        return Icons.assignment;
      default:
        return Icons.folder;
    }
  }
}
