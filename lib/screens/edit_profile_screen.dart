import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/platform_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _departmentController = TextEditingController(text: widget.user.department);
    _positionController = TextEditingController(text: widget.user.position);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated user object
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text.trim(),
        email: widget.user.email,
        role: widget.user.role,
        department: _departmentController.text.trim(),
        position: _positionController.text.trim(),
      );

      // Update user in database
      await _databaseService.updateUser(updatedUser);
      
      // Update current user in auth service
      await _authService.updateCurrentUser(updatedUser);

      if (mounted) {
        PlatformHelper.showSnackBar(
          context, 
          'Profil berhasil diperbarui',
        );
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        PlatformHelper.showErrorDialog(
          context,
          'Gagal memperbarui profil',
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
        title: const Text('Edit Profil'),
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
                    // Profile header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              _nameController.text.isNotEmpty
                                  ? _nameController.text.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: AppTheme.inputDecoration(
                        'Nama',
                        hint: 'Masukkan nama lengkap',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan nama';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field (disabled)
                    TextFormField(
                      initialValue: widget.user.email,
                      decoration: AppTheme.inputDecoration(
                        'Email',
                        hint: 'Email tidak dapat diubah',
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Department field
                    TextFormField(
                      controller: _departmentController,
                      decoration: AppTheme.inputDecoration(
                        'Departemen',
                        hint: 'Masukkan departemen',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan departemen';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Position field
                    TextFormField(
                      controller: _positionController,
                      decoration: AppTheme.inputDecoration(
                        'Jabatan',
                        hint: 'Masukkan jabatan',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan jabatan';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: AppTheme.primaryButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Simpan Perubahan'),
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
