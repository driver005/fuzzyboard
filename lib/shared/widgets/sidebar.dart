import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/theme_provider.dart';

const double _sidebarWidth = 240;
const double _railWidth = 72;

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

const _navItems = [
  _NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    route: '/',
  ),
  _NavItem(
    label: 'Tasks',
    icon: Icons.task_outlined,
    activeIcon: Icons.task,
    route: '/tasks',
  ),
  _NavItem(
    label: 'Workflows',
    icon: Icons.account_tree_outlined,
    activeIcon: Icons.account_tree,
    route: '/workflows',
  ),
  _NavItem(
    label: 'Plugins',
    icon: Icons.extension_outlined,
    activeIcon: Icons.extension,
    route: '/plugins',
  ),
  _NavItem(
    label: 'Marketplace',
    icon: Icons.store_outlined,
    activeIcon: Icons.store,
    route: '/marketplace',
  ),
  _NavItem(
    label: 'SQL Builder',
    icon: Icons.table_chart_outlined,
    activeIcon: Icons.table_chart,
    route: '/sql',
  ),
  _NavItem(
    label: 'Lua Builder',
    icon: Icons.code_outlined,
    activeIcon: Icons.code,
    route: '/lua',
  ),
  _NavItem(
    label: 'Search',
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    route: '/search',
  ),
  _NavItem(
    label: 'AI Chat',
    icon: Icons.chat_outlined,
    activeIcon: Icons.chat,
    route: '/chat',
  ),
  _NavItem(
    label: 'Voice',
    icon: Icons.mic_outlined,
    activeIcon: Icons.mic,
    route: '/voice',
  ),
  _NavItem(
    label: 'Page Builder',
    icon: Icons.dashboard_customize_outlined,
    activeIcon: Icons.dashboard_customize,
    route: '/builder',
  ),
  _NavItem(
    label: 'CMS',
    icon: Icons.web_outlined,
    activeIcon: Icons.web,
    route: '/cms',
  ),
  _NavItem(
    label: 'Content Types',
    icon: Icons.schema_outlined,
    activeIcon: Icons.schema,
    route: '/cms/types',
  ),
  _NavItem(
    label: 'Entries',
    icon: Icons.article_outlined,
    activeIcon: Icons.article,
    route: '/cms/entries',
  ),
  _NavItem(
    label: 'Media',
    icon: Icons.photo_library_outlined,
    activeIcon: Icons.photo_library,
    route: '/cms/media',
  ),
  _NavItem(
    label: 'Pages',
    icon: Icons.pages_outlined,
    activeIcon: Icons.pages,
    route: '/cms/pages',
  ),
  _NavItem(
    label: 'Categories',
    icon: Icons.label_outlined,
    activeIcon: Icons.label,
    route: '/cms/categories',
  ),
  _NavItem(
    label: 'Dev Mode',
    icon: Icons.bug_report_outlined,
    activeIcon: Icons.bug_report,
    route: '/dev',
  ),
  _NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    route: '/settings',
  ),
];

/// Desktop / tablet sidebar
class AppSidebar extends StatelessWidget {
  final bool collapsed;
  const AppSidebar({super.key, this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final loc = GoRouterState.of(context).uri.toString();
    final devMode = context.watch<AppProvider>().devMode;
    final themeProvider = context.watch<ThemeProvider>();

    final sidebarColor =
        isDark ? const Color(0xFF16162A) : Colors.white;

    return Container(
      width: collapsed ? _railWidth : _sidebarWidth,
      color: sidebarColor,
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.blur_on, color: Colors.white, size: 20),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FuzzyBoard',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('Workflow Engine',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final isActive = loc == item.route ||
                    (item.route != '/' && loc.startsWith(item.route));
                return _NavTile(
                  item: item,
                  isActive: isActive,
                  collapsed: collapsed,
                  onTap: () => context.go(item.route),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Dev mode toggle & theme
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _SidebarAction(
                  icon: devMode ? Icons.bug_report : Icons.bug_report_outlined,
                  label: 'Dev Mode',
                  collapsed: collapsed,
                  active: devMode,
                  onTap: () => context.read<AppProvider>().toggleDevMode(),
                ),
                const SizedBox(height: 4),
                _SidebarAction(
                  icon: themeProvider.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  label: 'Toggle Theme',
                  collapsed: collapsed,
                  onTap: () => themeProvider.setThemeMode(
                    themeProvider.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Tooltip(
      message: collapsed ? item.label : '',
      preferBelow: false,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: isActive
            ? BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: ListTile(
          dense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: collapsed ? 16 : 12, vertical: 0),
          leading: Icon(
            isActive ? item.activeIcon : item.icon,
            size: 22,
            color: isActive ? cs.primary : cs.onSurface.withOpacity(0.6),
          ),
          title: collapsed
              ? null
              : Text(item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isActive ? cs.primary : cs.onSurface.withOpacity(0.8),
                  )),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _SidebarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool collapsed;
  final bool active;
  final VoidCallback onTap;

  const _SidebarAction({
    required this.icon,
    required this.label,
    required this.collapsed,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: collapsed ? label : '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: active
              ? BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: active ? cs.primary : cs.onSurface.withOpacity(0.5)),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: active
                            ? cs.primary
                            : cs.onSurface.withOpacity(0.6))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation bar for mobile
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final mobileItems = _navItems.take(5).toList();
    int currentIndex = mobileItems.indexWhere(
      (item) =>
          loc == item.route ||
          (item.route != '/' && loc.startsWith(item.route)),
    );
    if (currentIndex < 0) currentIndex = 0;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => context.go(mobileItems[i].route),
      destinations: mobileItems
          .map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
              ))
          .toList(),
    );
  }
}
