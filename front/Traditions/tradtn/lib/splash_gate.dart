import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'theme/theme_controller.dart';
import 'widgets/app_scaffold.dart';

class SplashGate extends StatelessWidget {
  const SplashGate({super.key, required this.themeController});

  final ThemeController themeController;

  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logged') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: load(),
      builder: (c, s) {
        if (!s.hasData) {
          return const AppScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (s.data!) {
          return HomePage(themeController: themeController);
        }

        return AuthPage(themeController: themeController);
      },
    );
  }
}

