import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';

const double _sidebarWidth = 240;
const double _railWidth = 72;

/// Which top-level navigation tab is currently active.
enum AppHeaderTab { data, pages }

// Sealed-like base for sidebar list entries
abstract class _SidebarEntry {
  const _SidebarEntry();
}

/// A standard navigation tile entry.
class _NavItem extends _SidebarEntry {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final bool isSubItem;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.isSubItem = false,
  });
}

/// A collapsible section header in the sidebar.
class _SectionHeader extends _SidebarEntry {
  final String label;
  final IconData icon;

  /// The route prefix used to determine whether the section is "active"
  /// (auto-expanded).
  final String routePrefix;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.routePrefix,
  });
}

// ── Data tab nav items ────────────────────────────────────────────────────────
const _dataNavItems = <_SidebarEntry>[
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
    label: 'Dev Mode',
    icon: Icons.bug_report_outlined,
    activeIcon: Icons.bug_report,
    route: '/dev',
  ),
  _NavItem(
    label: 'Config Graph',
    icon: Icons.device_hub_outlined,
    activeIcon: Icons.device_hub,
    route: '/config',
  ),
  _NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    route: '/settings',
  ),
];

// ── Pages tab nav items ───────────────────────────────────────────────────────
const _pagesNavItems = <_SidebarEntry>[
  _NavItem(
    label: 'Page Builder',
    icon: Icons.dashboard_customize_outlined,
    activeIcon: Icons.dashboard_customize,
    route: '/builder',
  ),
  _SectionHeader(label: 'CMS', icon: Icons.web_outlined, routePrefix: '/cms'),
  _NavItem(
    label: 'Overview',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    route: '/cms',
    isSubItem: true,
  ),
  _NavItem(
    label: 'Content Types',
    icon: Icons.schema_outlined,
    activeIcon: Icons.schema,
    route: '/cms/types',
    isSubItem: true,
  ),
  _NavItem(
    label: 'Entries',
    icon: Icons.article_outlined,
    activeIcon: Icons.article,
    route: '/cms/entries',
    isSubItem: true,
  ),
  _NavItem(
    label: 'Media',
    icon: Icons.photo_library_outlined,
    activeIcon: Icons.photo_library,
    route: '/cms/media',
    isSubItem: true,
  ),
  _NavItem(
    label: 'Pages',
    icon: Icons.pages_outlined,
    activeIcon: Icons.pages,
    route: '/cms/pages',
    isSubItem: true,
  ),
  _NavItem(
    label: 'Categories',
    icon: Icons.label_outlined,
    activeIcon: Icons.label,
    route: '/cms/categories',
    isSubItem: true,
  ),
];

/// Desktop / tablet sidebar
class AppSidebar extends StatefulWidget {
  final bool collapsed;
  final AppHeaderTab tab;

  const AppSidebar({
    super.key,
    this.collapsed = false,
    this.tab = AppHeaderTab.data,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  // Tracks which section headers are expanded. Keyed by routePrefix.
  final Map<String, bool> sectionExpanded = {};

  bool isSectionExpanded(String routePrefix, String loc) {
    // Auto-expand if user is on a sub-route; otherwise use stored state.
    if (sectionExpanded.containsKey(routePrefix)) return sectionExpanded[routePrefix]!;
    return loc.startsWith(routePrefix);
  }

  List<_SidebarEntry> get navItems =>
      widget.tab == AppHeaderTab.pages ? _pagesNavItems : _dataNavItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final loc = GoRouterState.of(context).uri.toString();
    final devMode = context.watch<AppProvider>().devMode;
    final themeProvider = context.watch<ThemeProvider>();

    final sidebarColor = isDark ? const Color(0xFF16162A) : Colors.white;

    // Build visible items based on section-expansion state.
    final visibleItems = <_SidebarEntry>[];
    for (final entry in navItems) {
      if (entry is _SectionHeader) {
        visibleItems.add(entry);
        // Add sub-items only when section is expanded
        if (!widget.collapsed && isSectionExpanded(entry.routePrefix, loc)) {
          final headerIdx = navItems.indexOf(entry);
          for (int j = headerIdx + 1; j < navItems.length; j++) {
            final next = navItems[j];
            if (next is _SectionHeader) break;
            if (next is _NavItem && next.isSubItem) visibleItems.add(next);
          }
        }
      } else if (entry is _NavItem && !entry.isSubItem) {
        visibleItems.add(entry);
      }
    }

    return Container(
      width: widget.collapsed ? _railWidth : _sidebarWidth,
      color: sidebarColor,
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: visibleItems.length,
              itemBuilder: (context, i) {
                final entry = visibleItems[i];
                if (entry is _SectionHeader) {
                  final expanded = !widget.collapsed && isSectionExpanded(entry.routePrefix, loc);
                  final sectionActive = loc.startsWith(entry.routePrefix);
                  if (widget.collapsed) {
                    // In collapsed mode show icon only
                    return Tooltip(
                      message: entry.label,
                      preferBelow: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Icon(entry.icon,
                            size: 22,
                            color: sectionActive ? cs.primary : cs.onSurface.withOpacity(0.5)),
                      ),
                    );
                  }
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => sectionExpanded[entry.routePrefix] = !expanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(children: [
                        Icon(entry.icon, size: 18,
                            color: sectionActive ? cs.primary : cs.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(entry.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: sectionActive ? cs.primary : cs.onSurface.withOpacity(0.5),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5))),
                        Icon(expanded ? Icons.expand_less : Icons.expand_more,
                            size: 16, color: cs.onSurface.withOpacity(0.4)),
                      ]),
                    ),
                  );
                }
                // It's a _NavItem
                final item = entry as _NavItem;
                final isActive = loc == item.route ||
                    (item.route != '/' && loc.startsWith(item.route));
                return _NavTile(
                  item: item,
                  isActive: isActive,
                  collapsed: widget.collapsed,
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
                  collapsed: widget.collapsed,
                  active: devMode,
                  onTap: () => context.read<AppProvider>().toggleDevMode(),
                ),
                const SizedBox(height: 4),
                _SidebarAction(
                  icon: themeProvider.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  label: 'Toggle Theme',
                  collapsed: widget.collapsed,
                  onTap: () => themeProvider.setThemeMode(
                    themeProvider.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  ),
                ),
                const SizedBox(height: 4),
                _SidebarAction(
                  icon: Icons.logout_outlined,
                  label: 'Logout',
                  collapsed: widget.collapsed,
                  onTap: () => context.read<AuthProvider>().logout(),
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
          contentPadding: EdgeInsets.only(
            left: collapsed ? 16 : (item.isSubItem ? 28 : 12),
            right: 12,
          ),
          leading: Icon(
            isActive ? item.activeIcon : item.icon,
            size: item.isSubItem ? 18 : 22,
            color: isActive ? cs.primary : cs.onSurface.withOpacity(0.6),
          ),
          title: collapsed
              ? null
              : Text(item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: item.isSubItem ? 13 : null,
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
  final AppHeaderTab tab;

  const AppBottomNav({super.key, this.tab = AppHeaderTab.data});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final sourceItems = tab == AppHeaderTab.pages ? _pagesNavItems : _dataNavItems;
    final mobileItems = sourceItems
        .whereType<_NavItem>()
        .where((i) => !i.isSubItem)
        .take(5)
        .toList();

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
