import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/counter.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class CreateCounterScreen extends StatefulWidget {
  final String? editCounterId;
  const CreateCounterScreen({super.key, this.editCounterId});

  @override
  State<CreateCounterScreen> createState() => _CreateCounterScreenState();
}

class _CreateCounterScreenState extends State<CreateCounterScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final _stepController = TextEditingController();
  String _selectedEmoji = '🔢';
  int _selectedColorIndex = 0;
  GoalDirection _goalDirection = GoalDirection.reach;
  ResetFrequency _resetFrequency = ResetFrequency.daily;
  bool _isEditing = false;
  Counter? _existingCounter;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  String _previewName = '';

  @override
  void initState() {
    super.initState();
    _stepController.text = '1';
    _nameController.addListener(() {
      setState(() => _previewName = _nameController.text);
    });
    _goalController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.editCounterId != null && !_isEditing) {
      _isEditing = true;
      final provider = context.read<CounterProvider>();
      _existingCounter = provider.getCounter(widget.editCounterId!);
      if (_existingCounter != null) {
        _nameController.text = _existingCounter!.name;
        _selectedEmoji = _existingCounter!.emoji;
        _selectedColorIndex = AppTheme.counterColors.indexWhere(
          (c) => c.toARGB32() == _existingCounter!.colorValue,
        );
        if (_selectedColorIndex == -1) _selectedColorIndex = 0;
        _goalDirection = _existingCounter!.goalDirection;
        _resetFrequency = _existingCounter!.resetFrequency;
        _stepController.text = _existingCounter!.step.toString();
        _reminderEnabled = _existingCounter!.reminderEnabled;
        _reminderTime = TimeOfDay(hour: _existingCounter!.reminderHour, minute: _existingCounter!.reminderMinute);
        if (_existingCounter!.goal != null) {
          _goalController.text = _existingCounter!.goal.toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.translate('editCounter') : l10n.translate('newCounter'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live preview card
            _buildPreviewCard(context),
            const SizedBox(height: 28),

            // Emoji selector
            _buildSectionTitle(context, l10n.translate('icon')),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppTheme.counterEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = AppTheme.counterEmojis[index];
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.counterColors[_selectedColorIndex].withValues(alpha: 0.15)
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(
                                color: AppTheme.counterColors[_selectedColorIndex],
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Name
            _buildSectionTitle(context, l10n.translate('counterName')),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.translate('counterNameHint'),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 28),

            // Color
            _buildSectionTitle(context, l10n.translate('color')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(AppTheme.counterColors.length, (index) {
                final color = AppTheme.counterColors[index];
                final isSelected = index == _selectedColorIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            // Goal
            _buildSectionTitle(context, l10n.translate('goal')),
            const SizedBox(height: 12),
            TextField(
              controller: _goalController,
              decoration: InputDecoration(
                hintText: l10n.translate('goalHint'),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildChip(
                    context,
                    l10n.translate('reachGoal'),
                    _goalDirection == GoalDirection.reach,
                    () => setState(() => _goalDirection = GoalDirection.reach),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChip(
                    context,
                    l10n.translate('stayBelow'),
                    _goalDirection == GoalDirection.stayBelow,
                    () => setState(() => _goalDirection = GoalDirection.stayBelow),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Step
            _buildSectionTitle(context, l10n.translate('step')),
            const SizedBox(height: 12),
            TextField(
              controller: _stepController,
              decoration: InputDecoration(
                hintText: l10n.translate('stepHint'),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 28),

            // Reset frequency
            _buildSectionTitle(context, l10n.translate('resetFrequency')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildChip(
                  context,
                  l10n.translate('daily'),
                  _resetFrequency == ResetFrequency.daily,
                  () => setState(() => _resetFrequency = ResetFrequency.daily),
                ),
                _buildChip(
                  context,
                  l10n.translate('weekly'),
                  _resetFrequency == ResetFrequency.weekly,
                  () => setState(() => _resetFrequency = ResetFrequency.weekly),
                ),
                _buildChip(
                  context,
                  l10n.translate('monthly'),
                  _resetFrequency == ResetFrequency.monthly,
                  () => setState(() => _resetFrequency = ResetFrequency.monthly),
                ),
                _buildChip(
                  context,
                  l10n.translate('never'),
                  _resetFrequency == ResetFrequency.never,
                  () => setState(() => _resetFrequency = ResetFrequency.never),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Reminder
            _buildSectionTitle(context, l10n.translate('reminder')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_rounded,
                              color: AppTheme.counterColors[_selectedColorIndex],
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                l10n.translate('reminderEnabled'),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _reminderEnabled,
                        onChanged: (val) => setState(() => _reminderEnabled = val),
                        activeTrackColor: AppTheme.counterColors[_selectedColorIndex],
                      ),
                    ],
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                        );
                        if (picked != null) {
                          setState(() => _reminderTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.translate('reminderTime'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _reminderTime.format(context),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.counterColors[_selectedColorIndex],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onSave,
                child: Text(l10n.translate('save')),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final color = AppTheme.counterColors[_selectedColorIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _previewName.isEmpty ? '...' : _previewName;
    final goalText = _goalController.text.trim();
    final goal = goalText.isEmpty ? null : int.tryParse(goalText);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(_selectedEmoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          // Name + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '0',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                    ),
                    if (goal != null) ...[
                      Text(
                        ' / $goal',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Color indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.add_rounded, color: color, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final color = AppTheme.counterColors[_selectedColorIndex];
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final provider = context.read<CounterProvider>();
    final settings = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final goalText = _goalController.text.trim();
    final stepText = _stepController.text.trim();
    final goal = goalText.isEmpty ? null : int.tryParse(goalText);
    final step = stepText.isEmpty ? 1 : (int.tryParse(stepText) ?? 1);
    final notifService = NotificationService();

    String counterId;

    if (_isEditing && _existingCounter != null) {
      _existingCounter!.name = name;
      _existingCounter!.emoji = _selectedEmoji;
      _existingCounter!.colorValue = AppTheme.counterColors[_selectedColorIndex].toARGB32();
      _existingCounter!.goal = goal;
      _existingCounter!.goalDirection = _goalDirection;
      _existingCounter!.resetFrequency = _resetFrequency;
      _existingCounter!.step = step;
      _existingCounter!.reminderEnabled = _reminderEnabled;
      _existingCounter!.reminderHour = _reminderTime.hour;
      _existingCounter!.reminderMinute = _reminderTime.minute;
      provider.updateCounter(_existingCounter!);
      counterId = _existingCounter!.id;
    } else {
      counterId = const Uuid().v4();
      final counter = Counter(
        id: counterId,
        name: name,
        emoji: _selectedEmoji,
        colorValue: AppTheme.counterColors[_selectedColorIndex].toARGB32(),
        goal: goal,
        goalDirection: _goalDirection,
        resetFrequency: _resetFrequency,
        step: step,
        reminderEnabled: _reminderEnabled,
        reminderHour: _reminderTime.hour,
        reminderMinute: _reminderTime.minute,
      );
      provider.addCounter(counter);
    }

    // Schedule or cancel notification
    final notifId = notifService.notificationIdFromCounterId(counterId);
    if (_reminderEnabled) {
      await notifService.requestPermission();
      final userName = settings.userName;
      final notifBody = userName.isNotEmpty
          ? '$userName${l10n.translate('reminderBodyPersonal')}'
          : l10n.translate('reminderBody');
      await notifService.scheduleDailyReminder(
        id: notifId,
        title: '$_selectedEmoji $name',
        body: notifBody,
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await notifService.cancelReminder(notifId);
    }

    if (mounted) Navigator.of(context).pop();
  }
}
