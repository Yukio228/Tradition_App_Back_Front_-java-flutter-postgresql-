import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tradition.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.7:8080';

  // ---------- GET ----------
  static Future<List<Tradition>> getTraditions() async {
    final res = await http.get(Uri.parse('$baseUrl/traditions'));
    final List data = json.decode(res.body);
    return data.map((e) => Tradition.fromJson(e)).toList();
  }

  // ---------- ADD (ADMIN) ----------
  static Future<void> addTradition({
    required String title,
    required String description,
    required String meaning,
    required String category,
    required String imageUrl,
    required String youtubeUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    await http.post(
      Uri.parse('$baseUrl/traditions'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Email': email,
      },
      body: json.encode({
        'title': title,
        'description': description,
        'meaning': meaning,
        'category': category,
        'imageUrl': imageUrl,
        'youtubeUrl': youtubeUrl,
      }),
    );
  }

  // ---------- DELETE (ADMIN) ----------
  static Future<void> deleteTradition(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    await http.delete(
      Uri.parse('$baseUrl/traditions/$id'),
      headers: {
        'X-User-Email': email,
      },
    );
  }

  // ---------- UPDATE (ADMIN) ----------
  static Future<void> updateTradition({
    required int id,
    required String title,
    required String description,
    required String meaning,
    required String category,
    required String imageUrl,
    required String youtubeUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    await http.put(
      Uri.parse('$baseUrl/traditions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Email': email,
      },
      body: json.encode({
        'title': title,
        'description': description,
        'meaning': meaning,
        'category': category,
        'imageUrl': imageUrl,
        'youtubeUrl': youtubeUrl,
      }),
    );
  }

  // ---------- LOGIN ----------
  static Future<String?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(res.body);

    if (data['status'] == 'ok') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged', true);
      await prefs.setString('role', data['role'] ?? 'USER');
      await prefs.setString('email', email);
      return null;
    }

    return data['error'] ?? 'Ошибка входа';
  }

  // ---------- REGISTER ----------
  static Future<String?> register(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = json.decode(res.body);

    if (data['status'] == 'ok') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged', true);
      await prefs.setString('role', 'USER');
      await prefs.setString('email', email);
      return null;
    }

    return data['error'] ?? 'Ошибка регистрации';
  }
}
