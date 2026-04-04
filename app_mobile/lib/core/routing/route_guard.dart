import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../presentation/screens/common/access_denied_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';

class RouteGuard {
  RouteGuard._();

  static Route<dynamic> protect(RouteSettings settings, Widget page) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) {
        return Consumer<AuthProvider>(
          builder: (_, authProvider, __) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!authProvider.isLoggedIn) {
              return const LoginScreen();
            }

            return page;
          },
        );
      },
    );
  }

  static Route<dynamic> protectAdmin(RouteSettings settings, Widget page) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) {
        return Consumer<AuthProvider>(
          builder: (_, authProvider, __) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!authProvider.isLoggedIn) {
              return const LoginScreen();
            }

            if (!authProvider.isAdmin) {
              return const AccessDeniedScreen();
            }

            return page;
          },
        );
      },
    );
  }
}