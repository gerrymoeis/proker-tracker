import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_theme.dart';
import '../models/proker_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AddProkerScreen extends StatefulWidget {
  const AddProkerScreen({super.key});

  @override
  State<AddProkerScreen> createState() => _AddProkerScreenState();
}

class _AddProkerScreenState extends State<AddProkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _status = 'not_started';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveProker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengguna belum terautentikasi')),
          );
        }
        return;
      }

      final newProker = Proker(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        creatorId: currentUser.id,
        department: _departmentController.text.trim(),
      );

      await _databaseService.insertProker(newProker);

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      print('Error saving proker: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan program: $e')),
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
        title: const Text('Tambah Program Kerja'),
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
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: AppTheme.inputDecoration(
                        'Judul Program',
                        hint: 'Masukkan judul program kerja',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan judul program';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description field (optional)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppTheme.inputDecoration(
                        'Deskripsi (Opsional)',
                        hint: 'Masukkan deskripsi program kerja',
                      ),
                      maxLines: 3,
                      // No validator as it's optional
                    ),
                    const SizedBox(height: 16),

                    // Department field (required)
                    TextFormField(
                      controller: _departmentController,
                      decoration: AppTheme.inputDecoration(
                        'Departemen',
                        hint: 'Masukkan nama departemen',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan departemen';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date range
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: AppTheme.inputDecoration('Tanggal Mulai'),
                              child: Text(
                                DateFormat.yMMMd().format(_startDate),
                                style: AppTheme.bodyStyle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: AppTheme.inputDecoration('Tanggal Selesai'),
                              child: Text(
                                DateFormat.yMMMd().format(_endDate),
                                style: AppTheme.bodyStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                        onPressed: _saveProker,
                        style: AppTheme.primaryButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Simpan Program'),
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
