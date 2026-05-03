import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A dismissible onboarding banner that explains a feature.
/// Pass [title], [emoji], and a list of [steps] describing how to use the feature.
class TutorialBanner extends StatefulWidget {
  final String title;
  final String emoji;
  final List<String> steps;

  const TutorialBanner({
    super.key,
    required this.title,
    required this.emoji,
    required this.steps,
  });

  @override
  State<TutorialBanner> createState() => _TutorialBannerState();
}

class _TutorialBannerState extends State<TutorialBanner> {
  bool visible = true;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Animate(
      effects: const [FadeEffect(duration: Duration(milliseconds: 300))],
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => visible = false),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close,
                        size: 16, color: cs.onSurface.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...widget.steps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(top: 1, right: 8),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: cs.primary),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(e.value,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.8))),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => visible = false),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Got it!'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
