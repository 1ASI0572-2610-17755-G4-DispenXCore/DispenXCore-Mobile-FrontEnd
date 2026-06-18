enum Role { user, admin }

enum AccountStatus { active, inactive }

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final Role role;
  final AccountStatus status;
  final String? photoUrl;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.status,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRole = (json['role'] as String? ?? 'USER').toUpperCase();
    final rawStatus = (json['status'] as String? ?? 'ACTIVE').toUpperCase();

    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: rawRole == 'ADMIN' ? Role.admin : Role.user,
      status: rawStatus == 'ACTIVE' ? AccountStatus.active : AccountStatus.inactive,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
