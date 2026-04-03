import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/counter_provider.dart';
import '../providers/achievement_provider.dart';
import '../services/widget_service.dart';

class WidgetSettingsScreen extends StatelessWidget {
  const WidgetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final counterProvider = context.watch<CounterProvider>();
    final achievementProvider = context.watch<AchievementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('widgetSettings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Text(
            l10n.translate('homeScreenWidgets'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('widgetSettingsDesc'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 32),

          // Counter Widget Card
          _buildWidgetCard(
            context,
            icon: '📊',
            title: l10n.translate('counterWidget'),
            description: l10n.translate('counterWidgetDesc'),
            onUpdate: () => _updateCounterWidget(context, counterProvider, achievementProvider),
            onPreview: () => _showWidgetPreview(context, 'counter'),
            l10n: l10n,
          ),

          const SizedBox(height: 16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2196F3).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.translate('howToAddWidget'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionStep('1', l10n.translate('widgetStep1')),
                const SizedBox(height: 8),
                _buildInstructionStep('2', l10n.translate('widgetStep2')),
                const SizedBox(height: 8),
                _buildInstructionStep('3', l10n.translate('widgetStep3')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required VoidCallback onUpdate,
    required VoidCallback onPreview,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onUpdate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.translate('updateWidget')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility, size: 18),
                  label: Text(l10n.translate('preview')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  void _updateCounterWidget(
    BuildContext context,
    CounterProvider counterProvider,
    AchievementProvider achievementProvider,
  ) {
    // Calculate score
    double score = 0.0;
    int totalWithGoals = 0;
    
    for (final counter in counterProvider.counters) {
      if (counter.goal != null) {
        totalWithGoals++;
        if (counter.goalReached) score += 1.0;
      }
    }
    
    if (totalWithGoals > 0) {
      score = score / totalWithGoals;
    }

    // Update widget
    WidgetService().updateCounterWidget(
      counters: counterProvider.counters,
      score: score,
      level: achievementProvider.level,
      levelTitle: achievementProvider.levelTitle,
    );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Widget updated! 🎉'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showWidgetPreview(BuildContext context, String widgetType) {
    final settings = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('widgetPreview')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D2D3A), Color(0xFF1A1A24)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Twin'Am",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB74D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Lvl 1',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.translate('todaysProgress'),
                    style: TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: Color(0xFF37474F),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '65%',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This is how your widget will look on your home screen!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close')),
          ),
        ],
      ),
    );
  }
}
