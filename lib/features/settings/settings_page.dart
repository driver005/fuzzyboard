import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _ThemeSection(),
          SizedBox(height: 20),
          _AppearanceSection(),
          SizedBox(height: 20),
          _EngineSection(),
          SizedBox(height: 20),
          _AboutSection(),
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final presetColors = [
      AppColors.brandPrimary,
      AppColors.brandSecondary,
      const Color(0xFF0EA5E9),
      const Color(0xFFF97316),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
    ];

    return AppCard(
      title: '🎨 Theme',
      subtitle: 'Customize the look and feel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode selector
          Text('Color Mode',
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode)),
              ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.auto_mode)),
            ],
            selected: {themeProvider.themeMode},
            onSelectionChanged: (s) =>
                themeProvider.setThemeMode(s.first),
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          // Seed color
          Text('Accent Color',
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...presetColors.map((c) => _ColorSwatch(
                    color: c,
                    selected: themeProvider.seedColor == c,
                    onTap: () => themeProvider.setSeedColor(c),
                  )),
              _CustomColorButton(
                current: themeProvider.seedColor,
                onPick: (c) => themeProvider.setSeedColor(c),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch(
      {required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

class _CustomColorButton extends StatelessWidget {
  final Color current;
  final ValueChanged<Color> onPick;

  const _CustomColorButton({required this.current, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: Theme.of(context).colorScheme.outline, width: 1.5),
          gradient: const SweepGradient(
            colors: [
              Colors.red,
              Colors.yellow,
              Colors.green,
              Colors.cyan,
              Colors.blue,
              Colors.purple,
              Colors.red,
            ],
          ),
        ),
        child: const Icon(Icons.colorize, size: 18, color: Colors.white),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    Color picked = current;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: picked,
            onColorChanged: (c) => picked = c,
            enableAlpha: false,
            labelTypes: const [ColorLabelType.hex],
          ),
        ),
        actions: [
          AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.ghost,
              onPressed: () => Navigator.of(ctx).pop()),
          AppButton(
              label: 'Apply',
              onPressed: () {
                onPick(picked);
                Navigator.of(ctx).pop();
              }),
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    return AppCard(
      title: '✨ Appearance',
      subtitle: 'Visual preferences',
      child: Column(
        children: [
          _ToggleSetting(
              title: 'Show avatar mascot',
              subtitle: 'Display the floating avatar on desktop',
              value: app.showAvatar,
              onChanged: (v) => app.setShowAvatar(v)),
          _ToggleSetting(
              title: 'Reduced motion',
              subtitle: 'Minimize animations throughout the app',
              value: app.reducedMotion,
              onChanged: (v) => app.setReducedMotion(v)),
          _ToggleSetting(
              title: 'Compact sidebar',
              subtitle: 'Use icon-only sidebar on medium screens',
              value: themeProvider.compactSidebar,
              onChanged: (v) => themeProvider.setCompactSidebar(v)),
        ],
      ),
    );
  }
}

class _EngineSection extends StatelessWidget {
  const _EngineSection();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return AppCard(
      title: '⚙️ Engine',
      subtitle: 'Workflow engine settings',
      child: Column(
        children: [
          _ToggleSetting(
              title: 'Developer Mode',
              subtitle: 'Enable advanced dev tools and logs',
              value: app.devMode,
              onChanged: (_) => app.toggleDevMode()),
          _ToggleSetting(
              title: 'Auto-save workflows',
              subtitle: 'Automatically save on every change',
              value: app.autoSave,
              onChanged: (v) => app.setAutoSave(v)),
          _ToggleSetting(
              title: 'Verbose logging',
              subtitle: 'Log detailed execution traces',
              value: app.verboseLogging,
              onChanged: (v) => app.setVerboseLogging(v)),
        ],
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.bodyMedium),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5))),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppCard(
      title: 'ℹ️ About FuzzyBoard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow('Version', '1.0.0'),
          _InfoRow('Engine', 'FuzzyFlow v0.9'),
          _InfoRow('Flutter', '3.27+'),
          const SizedBox(height: 12),
          Text(
            'FuzzyBoard is an open workflow engine dashboard built with Flutter.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5))),
          ),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
