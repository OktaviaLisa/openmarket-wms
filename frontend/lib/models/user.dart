class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isActive;
  final String role;
  final List<String> roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isActive,
    this.role = 'user',
    this.roles = const ['user'],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isStaff: json['is_staff'] ?? false,
      isActive: json['is_active'] ?? true,
      role: json['role'] ?? 'user',
      roles: List<String>.from(json['roles'] ?? ['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'is_active': isActive,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
  
  bool get isAdmin => isStaff || role == 'admin';
  bool get isClient => !isStaff && isActive && role == 'user';
  bool get isVendor => !isStaff && isActive && role == 'user';
  bool get hasWarehouseRoles => roles.any((role) => 
    ['warehouse_management', 'operator_gudang', 'checker', 'qc', 'picker'].contains(role));
}