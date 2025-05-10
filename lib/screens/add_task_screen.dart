import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_theme.dart';
import '../models/proker_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/platform_helper.dart';

class AddTaskScreen extends StatefulWidget {
  final Proker proker;

  const AddTaskScreen({super.key, required this.proker});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String _status = 'not_started';
  User? _assignee;
  List<User> _availableUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all users
      final users = await _databaseService.getAllUsers();
      setState(() {
        _availableUsers = users;
        // Default assignee is the current user
        _authService.getCurrentUser().then((currentUser) {
          if (currentUser != null) {
            setState(() {
              _assignee = users.firstWhere(
                (user) => user.id == currentUser.id,
                orElse: () => currentUser,
              );
            });
          }
        });
      });
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: widget.proker.endDate.isAfter(DateTime.now())
          ? widget.proker.endDate
          : DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_assignee == null) {
      PlatformHelper.showSnackBar(
        context,
        'Silakan pilih penanggung jawab tugas',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          PlatformHelper.showSnackBar(
            context,
            'Pengguna belum terautentikasi',
          );
        }
        return;
      }

      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        status: _status,
        prokerId: widget.proker.id,
        assigneeId: _assignee!.id,
        creatorId: currentUser.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.insertTask(newTask);

      if (mounted) {
        PlatformHelper.showSnackBar(
          context,
          'Tugas berhasil ditambahkan',
        );
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      print('Error saving task: $e');
      if (mounted) {
        PlatformHelper.showErrorDialog(
          context,
          'Gagal menambahkan tugas',
          'Terjadi kesalahan: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program info
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Program: ${widget.proker.title}',
                              style: AppTheme.subheadingStyle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rentang: ${DateFormat.yMMMd().format(widget.proker.startDate)} - ${DateFormat.yMMMd().format(widget.proker.endDate)}',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: AppTheme.inputDecoration(
                        'Judul Tugas',
                        hint: 'Masukkan judul tugas',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan judul tugas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppTheme.inputDecoration(
                        'Deskripsi',
                        hint: 'Masukkan deskripsi tugas',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan deskripsi tugas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Due date
                    InkWell(
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: AppTheme.inputDecoration('Tenggat Waktu'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat.yMMMd().format(_dueDate),
                              style: AppTheme.bodyStyle,
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Assignee dropdown
                    DropdownButtonFormField<User>(
                      decoration: AppTheme.inputDecoration('Penanggung Jawab'),
                      value: _assignee,
                      items: _availableUsers.map((User user) {
                        return DropdownMenuItem<User>(
                          value: user,
                          child: Text('${user.name} (${user.position})'),
                        );
                      }).toList(),
                      onChanged: (User? newValue) {
                        setState(() {
                          _assignee = newValue;
                        });
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),

                    // Status dropdown
                    DropdownButtonFormField<String>(
                      decoration: AppTheme.inputDecoration('Status'),
                      value: _status,
                      items: const [
                        DropdownMenuItem(
                          value: 'not_started',
                          child: Text('Belum Dimulai'),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('Sedang Berjalan'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Selesai'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTask,
                        style: AppTheme.primaryButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Simpan Tugas'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
