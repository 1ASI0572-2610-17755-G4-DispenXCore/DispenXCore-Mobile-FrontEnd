import 'package:dispenxcore_frontend/app/router/app_router.dart';
import 'package:dispenxcore_frontend/core/di/injector.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/login_user.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/register_user.dart';
import 'package:flutter/material.dart';
 
void main() {
  WidgetsFlutterBinding.ensureInitialized();
 
  final appRouter = AppRouter(
    loginUser: injector<LoginUser>(),
    registerUser: injector<RegisterUser>(),
  );
 
  runApp(MyApp(appRouter: appRouter));
}
 
class MyApp extends StatelessWidget {
  final AppRouter appRouter;
 
  const MyApp({super.key, required this.appRouter});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: appRouter.generateRoute,
      initialRoute: '/login',
    );
  }
}