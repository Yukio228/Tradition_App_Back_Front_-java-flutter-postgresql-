import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_page.dart';
import 'add_tradition_page.dart';
import '../services/api_service.dart';
import 'tradition_detail_page.dart';
import '../services/favorites_service.dart';
import 'edit_tradition_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search = '';
  bool showFavorites = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'USER';

    setState(() {
      isAdmin = role.toUpperCase() == 'ADMIN';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Традиции Казахстана'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            color: showFavorites ? Colors.red : null,
            onPressed: () {
              setState(() {
                showFavorites = !showFavorites;
              });
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTraditionPage(),
                  ),
                );
                setState(() {});
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                    (_) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Поиск
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Поиск традиции...',
              ),
              onChanged: (v) => setState(() => search = v.toLowerCase()),
            ),
          ),

          Expanded(
            child: FutureBuilder(
              future: ApiService.getTraditions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Ошибка: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Нет данных'));
                }

                var list = snapshot.data!;

                if (search.isNotEmpty) {
                  list = list
                      .where(
                        (t) => t.title.toLowerCase().contains(search),
                  )
                      .toList();
                }

                return FutureBuilder<Set<int>>(
                  future: FavoritesService.getFavorites(),
                  builder: (context, favSnap) {
                    final favs = favSnap.data ?? {};

                    if (showFavorites) {
                      list =
                          list.where((t) => favs.contains(t.id)).toList();
                    }

                    if (list.isEmpty) {
                      return const Center(child: Text('Ничего не найдено'));
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final t = list[index];
                        final isFav = favs.contains(t.id);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(t.title),
                            subtitle: Text(
                              t.description.isNotEmpty
                                  ? t.description
                                  : 'Без описания',
                            ),
                            leading: IconButton(
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFav ? Colors.red : null,
                              ),
                              onPressed: () async {
                                await FavoritesService.toggle(t.id);
                                setState(() {});
                              },
                            ),
                            trailing: isAdmin
                                ? IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () async {
                                await ApiService.deleteTradition(t.id);
                                setState(() {});
                              },
                            )
                                : const Icon(Icons.arrow_forward_ios,
                                size: 16),
                            onTap: () async {
                              if (isAdmin) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditTraditionPage(tradition: t),
                                  ),
                                );
                                setState(() {});
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TraditionDetailPage(tradition: t),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
