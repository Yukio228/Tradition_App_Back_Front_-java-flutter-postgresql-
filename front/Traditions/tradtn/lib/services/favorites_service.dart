import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorites';

  static Future<Set<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.map(int.parse).toSet() ?? {};
  }

  static Future<void> toggle(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFavorites();

    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }

    await prefs.setStringList(
      _key,
      current.map((e) => e.toString()).toList(),
    );
  }

  static Future<bool> isFavorite(int id) async {
    final favs = await getFavorites();
    return favs.contains(id);
  }
}
