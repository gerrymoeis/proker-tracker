import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/task_model.dart';
import '../utils/app_utils.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isLast;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.isLast = false,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'not_started':
        return AppTheme.grayColor;
      case 'in_progress':
        return AppTheme.orangeColor;
      case 'completed':
        return AppTheme.successColor;
      default:
        return AppTheme.grayColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && task.status != 'completed';
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              Container(
                margin: const EdgeInsets.only(top: 2, right: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status),
                  shape: BoxShape.circle,
                ),
                width: 16,
                height: 16,
              ),
              
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.status == 'completed'
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == 'completed'
                            ? AppTheme.textSecondaryColor
                            : AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppUtils.truncateText(task.description, 100),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                        decoration: task.status == 'completed'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isOverdue
                              ? AppTheme.errorColor
                              : AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${AppUtils.formatDate(task.dueDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isOverdue
                                ? AppTheme.errorColor
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
