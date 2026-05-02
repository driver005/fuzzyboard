import 'package:flutter/material.dart';

class ScreenDef {
  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final WidgetBuilder builder;

  const ScreenDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    required this.builder,
  });
}

class ScreenRegistryProvider extends ChangeNotifier {
  final List<ScreenDef> screens = [];

  ScreenRegistryProvider() {
    _seedBuiltIns();
  }

  void _seedBuiltIns() {
    screens.addAll([
      ScreenDef(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, route: '/', builder: (_) => const Placeholder()),
      ScreenDef(id: 'tasks', label: 'Tasks', icon: Icons.task_outlined, activeIcon: Icons.task, route: '/tasks', builder: (_) => const Placeholder()),
      ScreenDef(id: 'workflows', label: 'Workflows', icon: Icons.account_tree_outlined, activeIcon: Icons.account_tree, route: '/workflows', builder: (_) => const Placeholder()),
      ScreenDef(id: 'plugins', label: 'Plugins', icon: Icons.extension_outlined, activeIcon: Icons.extension, route: '/plugins', builder: (_) => const Placeholder()),
      ScreenDef(id: 'marketplace', label: 'Marketplace', icon: Icons.store_outlined, activeIcon: Icons.store, route: '/marketplace', builder: (_) => const Placeholder()),
      ScreenDef(id: 'sql', label: 'SQL Builder', icon: Icons.table_chart_outlined, activeIcon: Icons.table_chart, route: '/sql', builder: (_) => const Placeholder()),
      ScreenDef(id: 'lua', label: 'Lua Builder', icon: Icons.code_outlined, activeIcon: Icons.code, route: '/lua', builder: (_) => const Placeholder()),
      ScreenDef(id: 'search', label: 'Search', icon: Icons.search_outlined, activeIcon: Icons.search, route: '/search', builder: (_) => const Placeholder()),
      ScreenDef(id: 'chat', label: 'AI Chat', icon: Icons.chat_outlined, activeIcon: Icons.chat, route: '/chat', builder: (_) => const Placeholder()),
      ScreenDef(id: 'voice', label: 'Voice', icon: Icons.mic_outlined, activeIcon: Icons.mic, route: '/voice', builder: (_) => const Placeholder()),
      ScreenDef(id: 'builder', label: 'Page Builder', icon: Icons.dashboard_customize_outlined, activeIcon: Icons.dashboard_customize, route: '/builder', builder: (_) => const Placeholder()),
      ScreenDef(id: 'dev', label: 'Dev Mode', icon: Icons.bug_report_outlined, activeIcon: Icons.bug_report, route: '/dev', builder: (_) => const Placeholder()),
      ScreenDef(id: 'settings', label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings, route: '/settings', builder: (_) => const Placeholder()),
    ]);
  }

  void register(ScreenDef screen) {
    screens.add(screen);
    notifyListeners();
  }

  void unregister(String id) {
    screens.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
