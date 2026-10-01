import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../features/auth/auth_service.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/admin_home_screen.dart';
import '../features/home/home_screen.dart';
import 'routes.dart';
import 'theme.dart';

class KumarBroomsApp extends StatelessWidget {
  const KumarBroomsApp({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: _navigatorKey,
      initialRoute: _initialRoute,
      onGenerateRoute: _routeFor,
    );
  }

  static final _navigatorKey = GlobalKey<NavigatorState>();

  String get _initialRoute {
    final user = authService.user;
    if (user == null) return AppRoutes.login;
    return user.isAdmin ? AppRoutes.adminDashboard : AppRoutes.userDashboard;
  }

  Route<dynamic> _routeFor(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.login;
    Widget page;
    if (routeName == AppRoutes.register) {
      page = RegisterScreen(authService: authService);
    } else if (routeName == AppRoutes.adminDashboard &&
        authService.user?.isAdmin == true) {
      page = AdminHomeScreen(authService: authService);
    } else if (routeName == AppRoutes.userDashboard &&
        authService.isAuthenticated) {
      page = HomeScreen(authService: authService);
    } else if (routeName == AppRoutes.login && authService.isAuthenticated) {
      page = authService.user!.isAdmin
          ? AdminHomeScreen(authService: authService)
          : HomeScreen(authService: authService);
    } else {
      page = LoginScreen(authService: authService);
    }
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
