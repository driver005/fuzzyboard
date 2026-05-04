import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../extensions/extension_manifest.dart';
import '../../extensions/extension_registry.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/config/config_graph_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/tasks/tasks_page.dart';
import '../../features/workflows/workflows_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/dev_mode/dev_mode_page.dart';
import '../../features/plugins/plugins_page.dart';
import '../../features/marketplace/marketplace_page.dart';
import '../../features/sql_builder/sql_builder_page.dart';
import '../../features/lua_builder/lua_builder_page.dart';
import '../../features/search/search_page.dart';
import '../../features/chat/chat_page.dart';
import '../../features/voice/voice_mode_page.dart';
import '../../features/page_builder/page_builder_page.dart';
import '../../features/cms/cms_overview_page.dart';
import '../../features/cms/content_types_page.dart';
import '../../features/cms/content_entries_page.dart';
import '../../features/cms/media_library_page.dart';
import '../../features/cms/pages_manager_page.dart';
import '../../features/cms/categories_page.dart';
import '../../shared/widgets/sidebar.dart';
import '../../shared/layout/responsive_layout.dart';
import '../../shared/widgets/avatar_widget.dart';

GoRouter createRouter(AuthProvider auth, ExtensionRegistry extensions) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.uri.toString();
      final onAuthPage = loc == '/login' || loc == '/signup';

      // While the AuthProvider is restoring session from SharedPreferences,
      // keep the user on an auth page (or redirect to login). Once loading
      // completes, the GoRouter will re-evaluate via refreshListenable.
      if (auth.isLoading) {
        return onAuthPage ? null : '/login';
      }

      if (!auth.isAuthenticated && !onAuthPage) return '/login';
      if (auth.isAuthenticated && onAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/tasks', builder: (_, __) => const TasksPage()),
          GoRoute(path: '/workflows', builder: (_, __) => const WorkflowsPage()),
          GoRoute(path: '/plugins', builder: (_, __) => const PluginsPage()),
          GoRoute(path: '/marketplace', builder: (_, __) => const MarketplacePage()),
          GoRoute(path: '/sql', builder: (_, __) => const SqlBuilderPage()),
          GoRoute(path: '/lua', builder: (_, __) => const LuaBuilderPage()),
          GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
          GoRoute(path: '/chat', builder: (_, __) => const ChatPage()),
          GoRoute(path: '/voice', builder: (_, __) => const VoiceModePage()),
          GoRoute(path: '/builder', builder: (_, __) => const PageBuilderPage()),
          GoRoute(path: '/cms', builder: (_, __) => const CmsOverviewPage()),
          GoRoute(path: '/cms/types', builder: (_, __) => const ContentTypesPage()),
          GoRoute(path: '/cms/entries', builder: (_, __) => const ContentEntriesPage()),
          GoRoute(path: '/cms/media', builder: (_, __) => const MediaLibraryPage()),
          GoRoute(path: '/cms/pages', builder: (_, __) => const PagesManagerPage()),
          GoRoute(path: '/cms/categories', builder: (_, __) => const CategoriesPage()),
          GoRoute(path: '/dev', builder: (_, __) => const DevModePage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/config', builder: (_, __) => const ConfigGraphPage()),
          // Extension-contributed routes are appended here.
          ...extensions.extraRoutes,
        ],
      ),
    ],
  );
}

/// Determine the active header tab based on the current route.
/// Extension-contributed routes are checked via their [ExtensionTab] affinity.
AppHeaderTab _tabFromRoute(String loc, ExtensionRegistry extensions) {
  if (loc.startsWith('/cms') || loc == '/builder') {
    return AppHeaderTab.pages;
  }
  // Check extension routes
  for (final manifest in extensions.manifests.values) {
    for (final r in manifest.routes) {
      if (loc == r.path || (r.path != '/' && loc.startsWith(r.path))) {
        return r.tab == ExtensionTab.pages
            ? AppHeaderTab.pages
            : AppHeaderTab.data;
      }
    }
  }
  return AppHeaderTab.data;
}

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final desktop = isDesktop(context);
    final themeProvider = context.watch<ThemeProvider>();
    final extensions = context.watch<ExtensionRegistry>();
    final loc = GoRouterState.of(context).uri.toString();
    final currentTab = _tabFromRoute(loc, extensions);

    return Scaffold(
      appBar: _AppHeader(currentTab: currentTab),
      body: Row(
        children: [
          if (!mobile)
            AppSidebar(
              collapsed: !desktop || themeProvider.compactSidebar,
              tab: currentTab,
            ),
          if (!mobile)
            const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: mobile ? AppBottomNav(tab: currentTab) : null,
    );
  }
}

/// Persistent top header bar with logo and Data/Pages tab switcher.
class _AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final AppHeaderTab currentTab;

  const _AppHeader({required this.currentTab});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = cs.brightness == Brightness.dark;
    final mobile = isMobile(context);
    final showAvatar = context.watch<AppProvider>().showAvatar;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16162A) : Colors.white,
        border: Border(
          bottom: BorderSide(color: cs.outline.withOpacity(0.15)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo mark
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.blur_on, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              if (!mobile)
                Text(
                  'FuzzyBoard',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              const SizedBox(width: 20),
              // Data tab button
              _HeaderTabBtn(
                label: 'Data',
                icon: Icons.storage_outlined,
                selected: currentTab == AppHeaderTab.data,
                onTap: () {
                  if (currentTab != AppHeaderTab.data) context.go('/');
                },
              ),
              const SizedBox(width: 4),
              // Pages tab button
              _HeaderTabBtn(
                label: 'Pages',
                icon: Icons.web_outlined,
                selected: currentTab == AppHeaderTab.pages,
                onTap: () {
                  if (currentTab != AppHeaderTab.pages) context.go('/cms');
                },
              ),
              const Spacer(),
              // Avatar (AI mascot) — always visible when enabled
              if (showAvatar) ...[
                const AvatarWidget(size: 34),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A single tab button in the top header bar.
class _HeaderTabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _HeaderTabBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? cs.primary.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? cs.primary
                  : cs.onSurface.withOpacity(0.55),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? cs.primary
                    : cs.onSurface.withOpacity(0.7),
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
