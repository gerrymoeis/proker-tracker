import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/proker_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/app_utils.dart';
import '../widgets/proker_card.dart';
import 'add_proker_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'proker_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  User? _currentUser;
  List<Proker> _prokers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndProkers();
  }

  Future<void> _loadUserAndProkers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current user
      final user = await _authService.getCurrentUser();
      if (user == null) {
        // Handle not logged in case
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false,
          );
        }
        return;
      }

      // Load prokers
      final prokers = await _databaseService.getAllProkers();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _prokers = prokers;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddProker() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddProkerScreen(),
      ),
    );

    if (result == true) {
      _loadUserAndProkers();
    }
  }

  void _navigateToProkerDetail(Proker proker) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProkerDetailScreen(prokerId: proker.id),
      ),
    ).then((_) => _loadUserAndProkers());
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Dasbor'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserAndProkers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    _buildStatusSection(),
                    const SizedBox(height: 24),
                    _buildRecentProkersSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProker,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              radius: 30,
              child: Text(
                _currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang kembali,',
                    style: AppTheme.captionStyle,
                  ),
                  Text(
                    _currentUser?.name ?? 'User',
                    style: AppTheme.subheadingStyle,
                  ),
                  Text(
                    _currentUser?.role ?? 'Member',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    final totalProkers = _prokers.length;
    final completedProkers = _prokers.where((p) => p.status == 'completed').length;
    final inProgressProkers = _prokers.where((p) => p.status == 'in_progress').length;
    final notStartedProkers = _prokers.where((p) => p.status == 'not_started').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status Program', style: AppTheme.subheadingStyle),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatusCard(
              'Total',
              totalProkers.toString(),
              Icons.assignment,
              AppTheme.primaryColor,
            ),
            _buildStatusCard(
              'Selesai',
              completedProkers.toString(),
              Icons.check_circle,
              AppTheme.successColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatusCard(
              'Sedang Berjalan',
              inProgressProkers.toString(),
              Icons.pending_actions,
              AppTheme.orangeColor,
            ),
            _buildStatusCard(
              'Belum Dimulai',
              notStartedProkers.toString(),
              Icons.schedule,
              AppTheme.grayColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProkersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Program Terbaru', style: AppTheme.subheadingStyle),
            TextButton(
              onPressed: () {
                // View all prokers
              },
              child: Text(
                'Lihat Semua',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _prokers.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: AppTheme.grayColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada program',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _navigateToAddProker,
                        style: AppTheme.primaryButtonStyle,
                        child: const Text('Tambah Program'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _prokers.length > 5 ? 5 : _prokers.length,
                itemBuilder: (context, index) {
                  final proker = _prokers[index];
                  return ProkerCard(
                    proker: proker,
                    onTap: () => _navigateToProkerDetail(proker),
                  );
                },
              ),
      ],
    );
  }
}
