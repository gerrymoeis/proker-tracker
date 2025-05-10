import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/platform_helper.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLogin = true;
  bool _isLoading = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    User? user;

    try {
      if (_isLogin) {
        // Login
        user = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Register
        user = await _authService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _departmentController.text.trim(),
          _positionController.text.trim(),
        );
      }

      if (user != null) {
        // Navigate to dashboard on success
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          PlatformHelper.showSnackBar(
            context,
            _isLogin
                ? 'Email atau kata sandi tidak valid'
                : 'Email sudah terdaftar atau pendaftaran gagal',
            isError: true,
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        PlatformHelper.showErrorDialog(
          context,
          'Kesalahan Autentikasi',
          'Terjadi kesalahan saat ${_isLogin ? 'masuk' : 'mendaftar'}: $e',
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    _isLogin ? 'Selamat Datang Kembali' : 'Buat Akun',
                    style: AppTheme.headingStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    _isLogin
                        ? 'Masuk untuk melanjutkan'
                        : 'Daftar untuk memulai',
                    style: AppTheme.captionStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Name field (only for register)
                  if (!_isLogin) ...[  
                    TextFormField(
                      controller: _nameController,
                      decoration: AppTheme.inputDecoration(
                        'Nama Lengkap',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan nama Anda';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Department field
                    TextFormField(
                      controller: _departmentController,
                      decoration: AppTheme.inputDecoration(
                        'Departemen',
                        prefixIcon: const Icon(Icons.business_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan departemen Anda';
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
                        prefixIcon: const Icon(Icons.work_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan jabatan Anda';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: AppTheme.inputDecoration(
                      'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan masukkan email Anda';
                      }
                      if (!value.contains('@')) {
                        return 'Silakan masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: AppTheme.inputDecoration(
                      'Kata Sandi',
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan masukkan kata sandi Anda';
                      }
                      if (!_isLogin && value.length < 6) {
                        return 'Kata sandi harus minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: AppTheme.primaryButtonStyle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isLogin ? 'Masuk' : 'Daftar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Toggle button
                  TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(
                      _isLogin
                          ? 'Belum punya akun? Daftar'
                          : 'Sudah punya akun? Masuk',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
