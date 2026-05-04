# FuzzyBoard 🤖

**FuzzyBoard** is a full-featured, responsive workflow-automation dashboard built entirely with Flutter. It runs seamlessly on smartphone, tablet, laptop, and web — one codebase, every screen size.

The project is designed as a self-contained showcase of Flutter best practices: a rich component library, reactive state management, adaptive layouts, animated UI, gamification, and a growing set of developer-focused tools.

---

## ✨ Feature Overview

| Feature | Description |
|---|---|
| 📊 **Dashboard** | Welcome banner, live stat cards, task-status pie chart, workflow-run line chart, and a leaderboard |
| 🗂️ **Task Management** | Create, edit, delete and run tasks with priorities, statuses, tags, and a full execution history |
| 🔄 **Workflow Visual Builder** | Drag-and-drop infinite canvas — add, connect, and configure trigger/action/condition/delay/script nodes |
| 🔌 **Plugin System** | Manage installed plugins, toggle activation, configure per-plugin settings, and browse the plugin README |
| 🛍️ **Plugin Marketplace** | Discover community plugins by category, install with one tap |
| 🗄️ **SQL Visual Builder** | Build SQL queries point-and-click — FROM table, SELECT columns, WHERE clauses, ORDER BY, LIMIT; live preview |
| 🌙 **Lua Expression Builder** | Compose boolean Lua expressions visually with nested AND/OR/NOT groups; generates a runnable Lua script live |
| 📝 **CMS** | Content types, entries, media library, pages, and category management |
| ⚙️ **Settings** | Toggle Light / Dark / System theme, pick any accent color, manage engine options (avatar, motion, logging, auto-save) |
| 👾 **Dev Mode** | Live event log, JSON state inspector, simulated test runner, and XP/level gamification stats |
| 🎤 **Voice Commands** | Simulated voice-command panel with a scrollable command reference |
| 🎮 **Gamification** | XP, levels, streaks, and tasks-completed counter — all persisted across sessions |
| 🤖 **Avatar Mascot** | Animated 3D-style emoji that reacts to in-app events |
| 🔐 **Auth Flow** | Role-based auth skeleton (admin / user) with a login screen and redirect guards |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.22

### Install & Run

```bash
flutter pub get
flutter run -d chrome          # Web
flutter run -d macos           # Desktop (macOS)
flutter run                    # Default connected device
```

### Build

```bash
flutter build web              # Web (PWA-ready)
flutter build apk              # Android
flutter build ios              # iOS
flutter build macos            # macOS
```

### Tests

```bash
flutter test
```

---

## 🏗️ Architecture

FuzzyBoard follows a **Provider + GoRouter** architecture:

```
User action
  → Widget calls Provider method
    → Provider mutates state & calls notifyListeners()
      → Dependent widgets rebuild
```

| Layer | Location | Purpose |
|---|---|---|
| **Models** | `lib/models/` | Plain Dart data classes (Task, Workflow, Plugin, …) |
| **Providers** | `lib/core/providers/` | State containers (AppProvider, ThemeProvider, GamificationProvider, …) |
| **Routing** | `lib/core/routing/` | `GoRouter` config with auth redirect guards |
| **Shell** | `lib/shared/widgets/` | `AppSidebar`, `AppBottomNav`, `_AppHeader` — responsive nav chrome |
| **Features** | `lib/features/` | One folder per page/feature, self-contained StatefulWidgets |
| **Design System** | `lib/shared/widgets/` + `lib/core/theme/` | Tokens, typography, and shared UI atoms |

### Key Providers

| Provider | Responsibility |
|---|---|
| `AppProvider` | Tasks, workflows, plugins, chat, voice commands, event bus, logs |
| `ThemeProvider` | Theme mode + accent color; persisted in SharedPreferences |
| `GamificationProvider` | XP / level / streak / tasks-completed; persisted in SharedPreferences |
| `UserProvider` | Auth roles (admin / user) |
| `CmsProvider` | CMS content types, entries, media, pages, categories |

---

## 🎨 Design System

All visual tokens live in **`lib/core/theme/`**:

| File | Purpose |
|---|---|
| `app_colors.dart` | Brand and semantic color constants |
| `app_typography.dart` | Text styles — swap the Google Font in one place |
| `app_theme.dart` | `ThemeData` factory; change the seed color to re-skin the whole app |

Shared UI atoms live in **`lib/shared/widgets/`**:

| Widget | Description |
|---|---|
| `AppButton` | Unified button — `primary`, `secondary`, `outline`, `ghost`, `danger` variants with bounce animation |
| `AppInput` / `AppSelect` | Styled text field and dropdown |
| `AppCard` / `StatCard` | Card with optional header, actions, and footer |
| `AppSidebar` / `AppBottomNav` | Responsive navigation (sidebar on tablet+, bottom nav on mobile) |
| `BounceOnTap` | Spring-scale press animation wrapper |
| `TutorialBanner` | Collapsible step-by-step guide banner |
| `AvatarWidget` | 3D-style emoji mascot with event-driven animations |

### Changing the Accent Color

Open `lib/core/theme/app_colors.dart` and update `brandPrimary`:

```dart
static const Color brandPrimary = Color(0xFF6C63FF); // ← swap any hex here
```

Or use the **Settings page** at runtime to pick any color with the color picker.

### Changing the Font

Open `lib/core/theme/app_typography.dart` and swap the font family:

```dart
// Replace with any GoogleFonts family:
static TextTheme get textTheme => GoogleFonts.poppinsTextTheme(...);
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root MaterialApp.router + MultiProvider
├── core/
│   ├── theme/                   # Design-system tokens
│   ├── providers/               # All ChangeNotifier providers
│   └── routing/                 # go_router config + auth guards
├── shared/
│   ├── widgets/                 # Shared UI components
│   └── layout/                  # Responsive-layout utilities
├── models/                      # Task, Workflow, Plugin, CMS data models
├── data/                        # Seed / demo data builders
├── adapters/                    # Abstract adapter interfaces (Task, Workflow, Plugin, …)
└── features/
    ├── dashboard/               # Stats, charts, welcome banner
    ├── tasks/                   # Task CRUD + run history
    ├── workflows/               # Workflow list + infinite canvas editor
    ├── plugins/                 # Plugin manager
    ├── marketplace/             # Plugin discovery
    ├── sql_builder/             # Visual SQL query builder
    ├── lua_builder/             # Visual Lua boolean-expression builder
    ├── cms/                     # CMS (types, entries, media, pages, categories)
    ├── settings/                # Theme + engine settings
    └── dev_mode/                # Logs, state inspector, test runner
```

---

## 🧩 Extending FuzzyBoard

### Adding a New Page

1. Create `lib/features/<name>/<name>_page.dart`
2. Add a `GoRoute` to `lib/core/routing/app_router.dart`
3. Add a `_NavItem` entry to `lib/shared/widgets/sidebar.dart`

### Adding a New Plugin

Seed data lives in `lib/data/seed_data.dart`. Add a new `Plugin(...)` entry in `buildSeedPlugins()`. The plugin appears automatically in the Plugin Manager and Marketplace.

### Implementing Real Adapters

Abstract adapter interfaces are in `lib/adapters/adapters.dart`. Replace the in-memory stubs (`example/adapters/in_memory_adapter.dart`) with real network or database implementations.

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `go_router` | Declarative URL-based routing with shell routes and auth guards |
| `provider` | Lightweight reactive state management |
| `fl_chart` | Pie and line charts on the dashboard |
| `flutter_animate` | Declarative widget animations |
| `google_fonts` | Typography (Inter by default) |
| `flutter_colorpicker` | Runtime accent-color picker in Settings |
| `shared_preferences` | Persist theme, gamification, and settings across sessions |
| `uuid` | Unique IDs for all model instances |

---

## License

MIT

