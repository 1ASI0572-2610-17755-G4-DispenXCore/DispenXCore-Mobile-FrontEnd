import 'package:dispenxcore_frontend/app/pages/main_page.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/login_user.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/register_user.dart';
import 'package:dispenxcore_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:dispenxcore_frontend/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';

import '../../features/alerts/domain/usecases/get_active_alerts.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
 
class AppRouter {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetActiveAlerts getActiveAlerts;
 
  AppRouter({
    required this.loginUser,
    required this.registerUser,
    required this.getActiveAlerts,
  });
 
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':

      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginPage(loginUser: loginUser),
        );
 
      case '/register':
        return MaterialPageRoute(
          builder: (_) => RegisterPage(registerUser: registerUser),
        );

      case '/main':
        return MaterialPageRoute(
          builder: (_) => MainPage(getActiveAlerts: getActiveAlerts),
        );

      case '/alerts':
        return MaterialPageRoute(
          builder: (_) => AlertsPage(getActiveAlerts: getActiveAlerts),
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