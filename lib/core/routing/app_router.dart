import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/theme_provider.dart';
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
    final themeProvider = context.watch<ThemeProvider>();
    final app = context.watch<AppProvider>();

    return Scaffold(
      body: Row(
        children: [
          if (!mobile)
            AppSidebar(collapsed: !desktop || themeProvider.compactSidebar),
          if (!mobile)
            const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: mobile ? const AppBottomNav() : null,
      floatingActionButton: mobile || !app.showAvatar
          ? null
          : const Padding(
              padding: EdgeInsets.only(bottom: 12, right: 12),
              child: AvatarWidget(size: 56),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
