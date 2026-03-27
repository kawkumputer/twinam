# Twin'Am

> *Your daily digital companion*

A beautiful, universal tap counter app built with Flutter. Count anything — water glasses, workouts, habits, prayers, and more. *Twin* (jumeau) + *Am* (mon, en Pulaar) — your personal twin that tracks your daily life.

## Features

### Core
- **Multi-counter dashboard** — manage multiple counters in a clean grid
- **Tap to count** — satisfying animations, haptic feedback, confetti on goal completion
- **Goals & progress** — set daily goals (reach or stay below), track progress visually
- **Auto-reset** — daily, weekly, monthly, or never
- **Statistics** — bar charts (week/month), totals, averages, best scores
- **Long-press actions** — edit, stats, reset, delete from dashboard
- **Quick-tap** — +1 directly from dashboard cards
- **Drag reorder** — persistent counter ordering
- **Share** — share counter stats via any app
- **Live preview** — see your counter card while creating/editing

### Engagement & Retention
- **🏆 17 Achievements** — unlock badges for milestones (First Tap, Century, Streak 30, Night Owl, etc.)
- **🔥 Streak tracking** — consecutive days goal reached, displayed on tap + stats screens
- **💡 Daily motivation** — rotating motivational quotes on dashboard (changes daily)
- **👋 Personalized greetings** — time-based greeting (Good morning/afternoon/evening)
- **📊 User profile** — total taps, days active, goals completed stats
- **🔔 Daily reminders** — per-counter notification at chosen time
- **🎉 Celebration popups** — animated dialog when new achievement unlocked

### Design
- **Dark mode** — elegant dark & light themes (Material 3)
- **Bilingual** — French & English
- **Animated rolling counter** — smooth digit animation on tap screen
- **Smooth page transitions** — slide + fade between screens
- **Pulsing empty state** — animated icon when no counters yet
- **Local storage** — Hive-based, no account needed, works offline

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter |
| State management | Provider |
| Local storage | Hive (JSON serialization) |
| Charts | fl_chart |
| Notifications | flutter_local_notifications + timezone |
| Sharing | share_plus |
| Typography | Google Fonts (Poppins) |
| Routing | Named routes (onGenerateRoute) |
| i18n | Custom map-based localization |

## Getting Started

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
  main.dart                    # Entry point, Hive + notifications init
  app.dart                     # MaterialApp, routing, providers
  theme/
    app_theme.dart             # Light & dark themes, colors, emojis
  l10n/
    app_localizations.dart     # Localization manager
    app_en.dart                # English strings (120+ keys)
    app_fr.dart                # French strings (120+ keys)
  models/
    counter.dart               # Counter & CounterEntry models
    achievement.dart           # Achievement model (17 types)
  services/
    storage_service.dart       # Hive storage abstraction
    notification_service.dart  # Local notifications scheduling
  providers/
    counter_provider.dart      # Counter state management
    settings_provider.dart     # Theme & locale state
    achievement_provider.dart  # Achievement tracking & unlock logic
  screens/
    dashboard_screen.dart      # Counter grid, greeting, motivation
    counter_screen.dart        # Tap screen with animations
    create_counter_screen.dart # Create/edit form + live preview
    stats_screen.dart          # Charts & statistics
    settings_screen.dart       # Dark mode, language, user profile
    achievements_screen.dart   # Trophy room with achievement grid
  widgets/
    counter_card.dart          # Dashboard card widget
    animated_counter.dart      # Rolling digit counter animation
```

## Monetization Plan

- **Free**: 3 counters, 7-day history, basic achievements, ads
- **Premium** (1.99€/mo or 9.99€/yr): unlimited counters, full history, all achievements, themes, widgets, no ads
