import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Space-themed Duolingo-style gamification state.
/// Tracks XP, level, streak, and total tasks completed.
class GamificationProvider extends ChangeNotifier {
  int xp = 0;
  int level = 1;
  int streak = 0;
  int tasksCompleted = 0;
  DateTime? lastActivityDate;

  static const int xpPerLevel = 100;
  static const int xpPerTask = 20;
  static const int xpPerWorkflow = 30;
  static const int xpPerPlugin = 15;

  GamificationProvider() {
    loadState();
  }

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    xp = prefs.getInt('gam_xp') ?? 0;
    level = prefs.getInt('gam_level') ?? 1;
    streak = prefs.getInt('gam_streak') ?? 0;
    tasksCompleted = prefs.getInt('gam_tasks') ?? 0;
    final ms = prefs.getInt('gam_last_activity');
    if (ms != null) {
      lastActivityDate = DateTime.fromMillisecondsSinceEpoch(ms);
      _maybeResetStreak();
    }
    notifyListeners();
  }

  void _maybeResetStreak() {
    if (lastActivityDate == null) return;
    final today = DateTime.now();
    final diff = today.difference(lastActivityDate!).inDays;
    if (diff > 1) {
      streak = 0;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gam_xp', xp);
    await prefs.setInt('gam_level', level);
    await prefs.setInt('gam_streak', streak);
    await prefs.setInt('gam_tasks', tasksCompleted);
    if (lastActivityDate != null) {
      await prefs.setInt('gam_last_activity', lastActivityDate!.millisecondsSinceEpoch);
    }
  }

  void _awardXp(int amount) {
    xp += amount;
    while (xp >= xpPerLevel) {
      xp -= xpPerLevel;
      level++;
    }
    _updateActivity();
    notifyListeners();
    _save();
  }

  void _updateActivity() {
    final today = DateTime.now();
    if (lastActivityDate == null) {
      streak = 1;
    } else {
      final diff = today.difference(lastActivityDate!).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
      // diff == 0 → same day, streak unchanged
    }
    lastActivityDate = today;
  }

  void onTaskCompleted() {
    tasksCompleted++;
    _awardXp(xpPerTask);
  }

  void onWorkflowRun() {
    _awardXp(xpPerWorkflow);
  }

  void onPluginInstalled() {
    _awardXp(xpPerPlugin);
  }

  double get levelProgress => xp / xpPerLevel;

  String get levelTitle {
    if (level < 3) return '🚀 Space Cadet';
    if (level < 6) return '🛸 Explorer';
    if (level < 10) return '⭐ Star Pilot';
    if (level < 15) return '🌟 Galaxy Commander';
    return '☄️ Universe Legend';
  }

  String get streakLabel {
    if (streak == 0) return 'No streak yet';
    if (streak == 1) return '1 day streak';
    return '$streak day streak 🔥';
  }
}
