import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
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

  // ---------- PROFILE ----------
  static Future<UserProfile?> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      if (email.isEmpty) return null;

      final res = await http.get(
        Uri.parse('$baseUrl/api/profile/me'),
        headers: {'X-User-Email': email},
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = json.decode(res.body);
        final profile = UserProfile.fromJson(data);
        return UserProfile(
          email: profile.email,
          role: profile.role,
          username: profile.username,
          avatarUrl: _buildAvatarUrl(profile.avatarUrl),
          themePreference: profile.themePreference,
        );
      }
    } catch (_) {
      // Ignore backend errors; local UI should still work.
    }

    return null;
  }

  static Future<String?> updateProfile({
    String? username,
    String? themePreference,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      if (email.isEmpty) return 'Not authenticated';

      final body = <String, String>{};
      if (username != null) body['username'] = username;
      if (themePreference != null) {
        body['themePreference'] = themePreference.toUpperCase();
      }

      final res = await http.put(
        Uri.parse('$baseUrl/api/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Email': email,
        },
        body: json.encode(body),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return null;
      }

      if (res.statusCode == 409) {
        return 'Username already taken';
      }

      if (res.body.isNotEmpty) {
        final data = json.decode(res.body);
        return data['message'] ?? 'Update failed';
      }
    } catch (_) {
      return 'Network error';
    }

    return 'Update failed';
  }

  static Future<String?> fetchThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      if (email.isEmpty) return null;

      final res = await http.get(
        Uri.parse('$baseUrl/api/profile/me'),
        headers: {'X-User-Email': email},
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = json.decode(res.body);
        return data['themePreference'] as String?;
      }
    } catch (_) {
      // Ignore backend errors; local theme still applies.
    }

    return null;
  }

  static Future<void> updateThemePreference(String preference) async {
    try {
      await updateProfile(themePreference: preference);
    } catch (_) {
      // Ignore backend errors; will retry on next change.
    }
  }

  static Future<String?> uploadAvatar(File file) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      if (email.isEmpty) return 'Not authenticated';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/profile/me/avatar'),
      );
      request.headers['X-User-Email'] = email;
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final url = data['avatarUrl'] ?? '';
        return _buildAvatarUrl(url);
      }

      if (response.body.isNotEmpty) {
        final data = json.decode(response.body);
        return data['message'] ?? 'Upload failed';
      }
    } catch (_) {
      return 'Upload failed';
    }

    return 'Upload failed';
  }

  static Future<String?> validateImageUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.isAbsolute) {
      return 'Invalid image URL';
    }

    try {
      http.Response res = await http.head(uri);
      if (res.statusCode == 405 || res.statusCode == 403) {
        res = await http.get(uri, headers: {'Range': 'bytes=0-0'});
      }

      if (res.statusCode < 200 || res.statusCode >= 400) {
        return 'Image URL not reachable (HTTP ${res.statusCode})';
      }

      final contentType = res.headers['content-type'];
      if (contentType != null && contentType.isNotEmpty) {
        if (!contentType.startsWith('image/')) {
          return 'URL is not an image';
        }
      }
    } catch (_) {
      return 'Image URL not reachable';
    }

    return null;
  }

  static String _buildAvatarUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '$baseUrl$url';
  }
}
