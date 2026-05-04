# FuzzyBoard 🤖

A **responsive** workflow engine dashboard built with Flutter. Runs on smartphone, tablet, laptop, and web.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🗂️ **Task Management** | Define, track and manage tasks with priorities, statuses, and tags |
| 🔄 **Workflow Visual Builder** | Drag-and-drop canvas to create workflow graphs with nodes and connections |
| 🔌 **Plugin System** | Manage installed plugins, toggle activation, and view metadata |
| 🛍️ **Plugin Marketplace** | Discover and install community plugins by category |
| 🗄️ **SQL Visual Builder** | Build SQL queries visually – SELECT, WHERE, ORDER BY, LIMIT |
| 🌙 **Lua Expression Builder** | Compose simple boolean Lua expressions visually with AND/OR/NOT groups |
| ⚙️ **Settings** | Toggle theme mode (Light / Dark / System), change accent color, and tweak engine settings |
| 👾 **Dev Mode** | View logs, inspect app state as JSON, and run simulated tests |
| 🎨 **Design System** | Centralized `AppButton`, `AppInput`, `AppCard` widgets – swap once, re-skin everywhere |
| 🤖 **Avatar Mascot** | A 3D-style emoji avatar that reacts to app events with animations |
| 📊 **Dashboard** | Welcome banner, stat cards, task status pie chart, workflow runs line chart |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.27

### Install & Run

```bash
flutter pub get
flutter run -d chrome          # Web
flutter run -d macos           # Desktop (macOS)
flutter run                    # Default device
```

### Build

```bash
flutter build web              # Web
flutter build apk              # Android
flutter build ios              # iOS
```

### Tests

```bash
flutter test
```

---

## 🎨 Theming & Design System

The entire visual identity is controlled from **`lib/core/theme/`**:

| File | Purpose |
|---|---|
| `app_colors.dart` | All brand and semantic colors |
| `app_typography.dart` | All text styles (swap Google Font here) |
| `app_theme.dart` | `ThemeData` factory – change seed color or any token here |

Shared UI components live in **`lib/shared/widgets/`**:

| Widget | Description |
|---|---|
| `AppButton` | Unified button with `primary`, `secondary`, `outline`, `ghost`, `danger` variants |
| `AppInput` / `AppSelect` | Unified text field and dropdown |
| `AppCard` / `StatCard` | Card with optional header, footer, and actions |
| `AppSidebar` / `AppBottomNav` | Responsive navigation |
| `AvatarWidget` | 3D-style emoji mascot with event reactions |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root MaterialApp.router
├── core/
│   ├── theme/                   # ← Design system tokens
│   ├── providers/               # ThemeProvider + AppProvider
│   └── routing/                 # go_router config
├── shared/
│   ├── widgets/                 # Shared UI components
│   └── layout/                  # ResponsiveLayout utilities
├── models/                      # Task, Workflow, Plugin data models
└── features/
    ├── dashboard/               # Dashboard with stats & charts
    ├── tasks/                   # Task CRUD with status lanes
    ├── workflows/               # Workflow list + visual canvas
    ├── settings/                # Theme + engine settings
    ├── dev_mode/                # Logs, state inspector, test runner
    ├── plugins/                 # Installed plugins manager
    ├── marketplace/             # Plugin discovery
    ├── sql_builder/             # Visual SQL query builder
    └── lua_builder/             # Visual Lua boolean expression builder
```

---

## 🧩 Adding a New Page

1. Create `lib/features/<name>/<name>_page.dart`
2. Add a `GoRoute` to `lib/core/routing/app_router.dart`
3. Add a `_NavItem` entry to `lib/shared/widgets/sidebar.dart`

## 🎨 Changing the Accent Color

Open `lib/core/theme/app_colors.dart` and update `brandPrimary`:

```dart
static const Color brandPrimary = Color(0xFF6C63FF); // ← change this
```

Or use the **Settings page** at runtime to pick any color.

## 🔤 Changing the Font

Open `lib/core/theme/app_typography.dart` and swap the font family:

```dart
// Replace GoogleFonts.interTextTheme with any other Google Font:
static TextTheme get textTheme => GoogleFonts.poppinsTextTheme(...);
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `go_router` | Declarative routing |
| `provider` | State management |
| `fl_chart` | Dashboard charts |
| `flutter_animate` | Page/widget animations |
| `google_fonts` | Typography |
| `flutter_colorpicker` | Theme color picker |
| `shared_preferences` | Persist theme settings |
| `uuid` | Unique IDs for models |

---

## License

MIT
