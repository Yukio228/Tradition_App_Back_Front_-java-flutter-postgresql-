import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';

class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (s.data!) {
          return const HomePage(); // 🔥 ВСЕГДА HomePage
        }

        return const AuthPage();
      },
    );
  }
}
