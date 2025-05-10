import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_theme.dart';
import '../models/proker_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/app_utils.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class ProkerDetailScreen extends StatefulWidget {
  final String prokerId;

  const ProkerDetailScreen({super.key, required this.prokerId});

  @override
  State<ProkerDetailScreen> createState() => _ProkerDetailScreenState();
}

class _ProkerDetailScreenState extends State<ProkerDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  Proker? _proker;
  User? _creator;
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProkerData();
  }

  Future<void> _loadProkerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load proker details
      final proker = await _databaseService.getProker(widget.prokerId);
      if (proker == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Program tidak ditemukan')),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // Load creator details
      final creator = await _databaseService.getUser(proker.creatorId);

      // Load tasks
      final tasks = await _databaseService.getTasksByProker(proker.id);

      setState(() {
        _proker = proker;
        _creator = creator;
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading proker data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
    if (_proker != null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddTaskScreen(proker: _proker!),
        ),
      );
      
      // Reload data if task was added
      if (result == true) {
        _loadProkerData();
      }
    }
  }

  Future<void> _editProker() async {
    // This would typically navigate to an EditProker screen
    // For simplicity, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur edit program akan segera hadir')),
    );
  }

  Future<void> _deleteProker() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Program'),
        content: const Text('Apakah Anda yakin ingin menghapus program ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && _proker != null) {
      try {
        // Delete all tasks associated with this proker
        for (var task in _tasks) {
          await _databaseService.deleteTask(task.id);
        }

        // Delete the proker
        await _databaseService.deleteProker(_proker!.id);

        if (mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      } catch (e) {
        print('Error deleting proker: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus program: $e')),
          );
        }
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'not_started':
        return 'Belum Dimulai';
      case 'in_progress':
        return 'Sedang Berjalan';
      case 'completed':
        return 'Selesai';
      default:
        return 'Tidak Diketahui';
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Program'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProker,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProker,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _proker == null
              ? const Center(child: Text('Program not found'))
              : RefreshIndicator(
                  onRefresh: _loadProkerData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProkerHeader(),
                        const SizedBox(height: 24),
                        _buildProkerDetails(),
                        const SizedBox(height: 24),
                        _buildTasksSection(),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildProkerHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _proker!.title,
                    style: AppTheme.headingStyle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_proker!.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(_proker!.status)),
                  ),
                  child: Text(
                    _getStatusText(_proker!.status),
                    style: TextStyle(
                      color: _getStatusColor(_proker!.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _proker!.description ?? '',
              style: AppTheme.bodyStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProkerDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(
              'Rentang Tanggal',
              '${DateFormat.yMMMd().format(_proker!.startDate)} - ${DateFormat.yMMMd().format(_proker!.endDate)}',
              Icons.date_range,
            ),
            const Divider(),
            _buildDetailItem(
              'Departemen',
              _proker!.department ?? 'Tidak ditentukan',
              Icons.business,
            ),
            const Divider(),
            _buildDetailItem(
              'Dibuat Oleh',
              _creator?.name ?? 'Tidak diketahui',
              Icons.person,
            ),
            const Divider(),
            _buildDetailItem(
              'Dibuat Pada',
              DateFormat.yMMMd().format(_proker!.createdAt),
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tugas', style: AppTheme.subheadingStyle),
            Text(
              '${_tasks.where((t) => t.status == "completed").length}/${_tasks.length} selesai',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _tasks.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 64,
                        color: AppTheme.grayColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada tugas',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addTask,
                        style: AppTheme.primaryButtonStyle,
                        child: const Text('Tambah Tugas'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  final isLast = index == _tasks.length - 1;
                  return TaskCard(
                    task: task,
                    isLast: isLast,
                    onTap: () {
                      // Navigate to task detail screen
                    },
                  );
                },
              ),
      ],
    );
  }
}
