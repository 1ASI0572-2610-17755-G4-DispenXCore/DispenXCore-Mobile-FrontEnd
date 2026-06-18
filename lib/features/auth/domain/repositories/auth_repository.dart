import '../entities/session.dart';

abstract class AuthRepository {
  Future<Session> login(String email, String password);

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
}
 