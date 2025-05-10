import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/proker_model.dart';
import '../models/task_model.dart';
import 'database_service.dart';

class MockDataService {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  /// Initialize the app with mock data for testing
  Future<void> initializeMockData() async {
    try {
      // Check if data already exists
      final users = await _databaseService.getAllUsers();
      if (users.isNotEmpty) {
        // Data already exists, no need to initialize
        return;
      }

      // Create mock users
      final List<User> mockUsers = [
        User(
          id: _uuid.v4(),
          name: 'John Doe',
          email: 'john@example.com',
          role: 'admin',
          department: 'Executive Board',
          position: 'Chairman',
        ),
        User(
          id: _uuid.v4(),
          name: 'Jane Smith',
          email: 'jane@example.com',
          role: 'member',
          department: 'Public Relations',
          position: 'Coordinator',
        ),
        User(
          id: _uuid.v4(),
          name: 'Mike Johnson',
          email: 'mike@example.com',
          role: 'member',
          department: 'Academic Affairs',
          position: 'Officer',
        ),
      ];

      // Insert users
      for (var user in mockUsers) {
        await _databaseService.insertUser(user);
      }

      // Create mock prokers
      final now = DateTime.now();
      final List<Proker> mockProkers = [
        Proker(
          id: _uuid.v4(),
          title: 'Annual Student Conference',
          description: 'A conference bringing together student leaders from various universities to discuss common challenges and share best practices.',
          startDate: now.add(const Duration(days: 30)),
          endDate: now.add(const Duration(days: 32)),
          status: 'in_progress',
          creatorId: mockUsers[0].id,
          department: 'Academic Affairs',
        ),
        Proker(
          id: _uuid.v4(),
          title: 'Community Service Week',
          description: 'A week-long program of community service activities involving students from all departments.',
          startDate: now.add(const Duration(days: 15)),
          endDate: now.add(const Duration(days: 22)),
          status: 'not_started',
          creatorId: mockUsers[1].id,
          department: 'Social Affairs',
        ),
        Proker(
          id: _uuid.v4(),
          title: 'Leadership Training Workshop',
          description: 'A workshop designed to develop leadership skills among student organization members.',
          startDate: now.subtract(const Duration(days: 10)),
          endDate: now.subtract(const Duration(days: 8)),
          status: 'completed',
          creatorId: mockUsers[0].id,
          department: 'Human Resources',
        ),
      ];

      // Insert prokers
      for (var proker in mockProkers) {
        await _databaseService.insertProker(proker);
      }

      // Create mock tasks
      final List<Task> mockTasks = [
        Task(
          id: _uuid.v4(),
          title: 'Book conference venue',
          description: 'Contact university facilities to book the main auditorium for the conference.',
          dueDate: now.add(const Duration(days: 10)),
          status: 'completed',
          prokerId: mockProkers[0].id,
          assigneeId: mockUsers[1].id,
          creatorId: mockUsers[0].id,
        ),
        Task(
          id: _uuid.v4(),
          title: 'Send invitations to speakers',
          description: 'Draft and send invitation emails to all potential speakers.',
          dueDate: now.add(const Duration(days: 15)),
          status: 'in_progress',
          prokerId: mockProkers[0].id,
          assigneeId: mockUsers[2].id,
          creatorId: mockUsers[0].id,
        ),
        Task(
          id: _uuid.v4(),
          title: 'Prepare volunteer schedule',
          description: 'Create a schedule for volunteers for the community service week.',
          dueDate: now.add(const Duration(days: 5)),
          status: 'not_started',
          prokerId: mockProkers[1].id,
          assigneeId: mockUsers[1].id,
          creatorId: mockUsers[1].id,
        ),
        Task(
          id: _uuid.v4(),
          title: 'Collect feedback from participants',
          description: 'Create and distribute feedback forms to all workshop participants.',
          dueDate: now.subtract(const Duration(days: 5)),
          status: 'completed',
          prokerId: mockProkers[2].id,
          assigneeId: mockUsers[2].id,
          creatorId: mockUsers[0].id,
        ),
      ];

      // Insert tasks
      for (var task in mockTasks) {
        await _databaseService.insertTask(task);
      }

      print('Mock data initialized successfully');
    } catch (e) {
      print('Error initializing mock data: $e');
    }
  }
}
