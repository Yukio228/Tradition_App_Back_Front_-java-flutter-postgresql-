import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_text_field.dart';
import '../widgets/tradition_card.dart';
import 'add_tradition_page.dart';
import 'auth_page.dart';
import 'edit_tradition_page.dart';
import 'profile_page.dart';
import 'tradition_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => AuthPage(themeController: widget.themeController),
      ),
      (_) => false,
    );
  }

  void _openSettings() {
    showAppBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Light theme'),
            value: Theme.of(context).brightness == Brightness.light,
            onChanged: (value) {
              widget.themeController
                  .setMode(value ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTraditionPage(),
                  ),
                );
                setState(() {});
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Traditions',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover culture, rituals, and stories.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: showFavorites
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: showFavorites
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  onPressed: () {
                    setState(() => showFavorites = !showFavorites);
                  },
                  tooltip: 'Favorites',
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: Icons.tune_rounded,
                  onPressed: _openSettings,
                  tooltip: 'Settings',
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: Icons.person_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfilePage(themeController: widget.themeController),
                      ),
                    );
                  },
                  tooltip: 'Profile',
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: Icons.logout_rounded,
                  onPressed: _logout,
                  tooltip: 'Log out',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppTextField(
              controller: searchController,
              hintText: 'Search traditions...',
              prefixIcon: Icons.search_rounded,
              onChanged: (value) => setState(() => search = value.toLowerCase()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: FutureBuilder(
              future: ApiService.getTraditions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppSkeletonList();
                }

                if (snapshot.hasError) {
                  return const AppEmptyState(
                    title: 'Something went wrong',
                    subtitle: 'Please try again later.',
                    icon: Icons.error_outline_rounded,
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const AppEmptyState(
                    title: 'No traditions yet',
                    subtitle: 'Add the first tradition to get started.',
                    icon: Icons.auto_awesome_rounded,
                  );
                }

                var list = snapshot.data!;

                if (search.isNotEmpty) {
                  list = list
                      .where((t) => t.title.toLowerCase().contains(search))
                      .toList();
                }

                return FutureBuilder<Set<int>>(
                  future: FavoritesService.getFavorites(),
                  builder: (context, favSnap) {
                    final favs = favSnap.data ?? {};

                    if (showFavorites) {
                      list = list.where((t) => favs.contains(t.id)).toList();
                    }

                    if (list.isEmpty) {
                      return const AppEmptyState(
                        title: 'No matches found',
                        subtitle: 'Try a different search or filter.',
                        icon: Icons.search_off_rounded,
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final t = list[index];
                        final isFav = favs.contains(t.id);

                        return TraditionCard(
                          tradition: t,
                          isFavorite: isFav,
                          isAdmin: isAdmin,
                          onFavoriteToggle: () async {
                            await FavoritesService.toggle(t.id);
                            setState(() {});
                          },
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
                          onDelete: isAdmin
                              ? () async {
                                  await ApiService.deleteTradition(t.id);
                                  setState(() {});
                                }
                              : null,
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
