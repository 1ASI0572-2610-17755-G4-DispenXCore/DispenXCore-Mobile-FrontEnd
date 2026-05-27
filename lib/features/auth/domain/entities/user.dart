enum Role { user, admin }
 
enum AccountStatus { active, inactive }
 
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final Role role;
  final AccountStatus status;
 
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.status,
  });
 
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: (json['role'] as String).toUpperCase() == 'ADMIN' ? Role.admin : Role.user,
      status: (json['status'] as String).toUpperCase() == 'ACTIVE'
          ? AccountStatus.active
          : AccountStatus.inactive,
    );
  }
}
 