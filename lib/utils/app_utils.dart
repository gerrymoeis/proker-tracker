import 'package:intl/intl.dart';

class AppUtils {
  // Format date to display format (e.g., "Jan 15, 2025")
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  // Format date with time (e.g., "Jan 15, 2025 14:30")
  static String formatDateWithTime(DateTime date) {
    return DateFormat.yMMMd().add_Hm().format(date);
  }

  // Get relative time (e.g., "2 days ago", "in 3 days")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ${difference.isNegative ? "ago" : "from now"}';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ${difference.isNegative ? "ago" : "from now"}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days from now';
    } else if (difference.inDays < 0) {
      return '${-difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours from now';
    } else if (difference.inHours < 0) {
      return '${-difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes from now';
    } else if (difference.inMinutes < 0) {
      return '${-difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Calculate progress percentage
  static double calculateProgress(List<String> taskStatuses) {
    if (taskStatuses.isEmpty) return 0.0;
    
    int completedTasks = taskStatuses.where((status) => status == 'completed').length;
    return completedTasks / taskStatuses.length;
  }

  // Get status color based on progress and due date
  static String getStatusIndicator(double progress, DateTime dueDate) {
    final now = DateTime.now();
    final daysLeft = dueDate.difference(now).inDays;

    if (progress >= 1.0) {
      return 'completed';
    } else if (daysLeft < 0) {
      return 'overdue';
    } else if (daysLeft < 3) {
      return 'at_risk';
    } else if (progress > 0) {
      return 'in_progress';
    } else {
      return 'not_started';
    }
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
