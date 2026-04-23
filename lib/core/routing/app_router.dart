import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/tasks/tasks_page.dart';
import '../../features/workflows/workflows_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/dev_mode/dev_mode_page.dart';
import '../../features/plugins/plugins_page.dart';
import '../../features/marketplace/marketplace_page.dart';
import '../../features/sql_builder/sql_builder_page.dart';
import '../../features/lua_builder/lua_builder_page.dart';
import '../../shared/widgets/sidebar.dart';
import '../../shared/layout/responsive_layout.dart';
import '../../shared/widgets/avatar_widget.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
        GoRoute(path: '/dev', builder: (_, __) => const DevModePage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final desktop = isDesktop(context);

    return Scaffold(
      body: Row(
        children: [
          if (!mobile)
            AppSidebar(collapsed: !desktop),
          if (!mobile)
            const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: mobile ? const AppBottomNav() : null,
      floatingActionButton: mobile
          ? null
          : const Padding(
              padding: EdgeInsets.only(bottom: 12, right: 12),
              child: AvatarWidget(size: 56),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
