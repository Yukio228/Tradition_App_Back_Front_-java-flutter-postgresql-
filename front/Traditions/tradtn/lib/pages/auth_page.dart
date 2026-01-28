import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool hidePassword = true;
  bool loading = false;

  final email = TextEditingController();
  final password = TextEditingController();

  String? error;

  late AnimationController _controller;
  late Animation<double> _animation;

  bool get isEmailValid =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.text.trim());

  bool get isPasswordValid => password.text.length >= 6;

  bool get canSubmit => isEmailValid && isPasswordValid && !loading;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!canSubmit) return;

    setState(() {
      loading = true;
      error = null;
    });

    String? res;

    if (isLogin) {
      res = await ApiService.login(
        email.text.trim(),
        password.text,
      );
    } else {
      res = await ApiService.register(
        email.text.trim(),
        password.text,
      );
    }

    if (!mounted) return;

    if (res != null) {
      setState(() {
        error = res;
        loading = false;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? 'USER';

      // 🔔 ВСПЛЫВАЮЩЕЕ УВЕДОМЛЕНИЕ О РОЛИ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            role == 'ADMIN'
                ? '👑 Вы вошли как Администратор'
                : '👤 Вы вошли как Пользователь',
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // маленькая пауза, чтобы SnackBar успел появиться
      await Future.delayed(const Duration(milliseconds: 300));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A3DD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  isLogin ? 'Вход' : 'Регистрация',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                ScaleTransition(
                  scale: _animation,
                  child: FadeTransition(
                    opacity: _animation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: email,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              suffixIcon: Icon(
                                isEmailValid
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: isEmailValid
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: password,
                            obscureText: hidePassword,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Пароль (минимум 6)',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          if (error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: canSubmit ? submit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF00A3DD),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Text(
                                isLogin
                                    ? 'Войти'
                                    : 'Создать аккаунт',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _controller.reset();
                    _controller.forward();
                    setState(() {
                      isLogin = !isLogin;
                      error = null;
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'Нет аккаунта? Создайте'
                        : 'Уже есть аккаунт? Войти',
                    style: const TextStyle(
                      color: Color(0xFFFFC72C),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
