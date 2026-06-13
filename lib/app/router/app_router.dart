import 'package:dispenxcore_frontend/app/pages/main_page.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/login_user.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/register_user.dart';
import 'package:dispenxcore_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:dispenxcore_frontend/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
 
class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';

  final LoginUser loginUser;
  final RegisterUser registerUser;

  AppRouter({
    required this.loginUser,
    required this.registerUser,
  });

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => LoginPage(loginUser: loginUser),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => RegisterPage(registerUser: registerUser),
        );

      case main:
        return MaterialPageRoute(
          builder: (_) => const MainPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}