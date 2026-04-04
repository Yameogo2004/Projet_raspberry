import 'package:flutter/material.dart';

import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/common/access_denied_screen.dart';
import '../../presentation/screens/common/help_screen.dart';
import '../../presentation/screens/common/no_internet_screen.dart';
import '../../presentation/screens/common/not_found_screen.dart';
import '../../presentation/screens/common/notifications_screen.dart';
import '../../presentation/screens/common/profile_screen.dart';
import '../../presentation/screens/common/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import 'route_guard.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _buildRoute(
          const SplashScreen(),
          settings,
        );

      case RouteNames.login:
        return _buildRoute(
          const LoginScreen(),
          settings,
        );

      case RouteNames.register:
        return _buildRoute(
          const RegisterScreen(),
          settings,
        );

      case RouteNames.forgotPassword:
        return _buildRoute(
          const ForgotPasswordScreen(),
          settings,
        );

      case RouteNames.home:
        return RouteGuard.protect(
          settings,
          const _TemporaryHomeScreen(),
        );

      case RouteNames.dashboard:
        return RouteGuard.protectAdmin(
          settings,
          const AdminDashboardScreen(),
        );

      case RouteNames.profile:
        return RouteGuard.protect(
          settings,
          const ProfileScreen(),
        );

      case RouteNames.settings:
        return RouteGuard.protect(
          settings,
          const SettingsScreen(),
        );

      case RouteNames.notifications:
        return RouteGuard.protect(
          settings,
          const NotificationsScreen(),
        );

      case RouteNames.help:
        return RouteGuard.protect(
          settings,
          const HelpScreen(),
        );

      case RouteNames.noInternet:
        return _buildRoute(
          const NoInternetScreen(),
          settings,
        );

      case RouteNames.accessDenied:
        return _buildRoute(
          const AccessDeniedScreen(),
          settings,
        );

      case RouteNames.notFound:
        return _buildRoute(
          const NotFoundScreen(),
          settings,
        );

      default:
        return _buildRoute(
          const NotFoundScreen(),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}

class _TemporaryHomeScreen extends StatelessWidget {
  const _TemporaryHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: const Center(
        child: Text(
          'Home screen à venir',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}