class User {
  final String id;
  final String name;
  final String email;
  final String role; // e.g., 'admin', 'member'
  final String? profileImageUrl;
  final String department;
  final String position;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
    required this.department,
    required this.position,
  });

  // Convert User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'department': department,
      'position': position,
    };
  }

  // Create a User object from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      profileImageUrl: map['profileImageUrl'],
      department: map['department'],
      position: map['position'],
    );
  }
}
