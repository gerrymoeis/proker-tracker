import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/proker_model.dart';
import '../utils/app_utils.dart';

class ProkerCard extends StatelessWidget {
  final Proker proker;
  final VoidCallback onTap;

  const ProkerCard({
    super.key,
    required this.proker,
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

  String _getStatusText(String status) {
    switch (status) {
      case 'not_started':
        return 'Not Started';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = proker.endDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && proker.status != 'completed';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      proker.title,
                      style: AppTheme.subheadingStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(proker.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(proker.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(proker.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppUtils.truncateText(proker.description ?? '', 100),
                style: AppTheme.bodyStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${AppUtils.formatDate(proker.startDate)} - ${AppUtils.formatDate(proker.endDate)}',
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
                  Text(
                    isOverdue
                        ? 'Overdue by ${-daysLeft} days'
                        : daysLeft == 0
                            ? 'Due today'
                            : '${daysLeft} days left',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOverdue
                          ? AppTheme.errorColor
                          : daysLeft <= 3
                              ? AppTheme.warningColor
                              : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
