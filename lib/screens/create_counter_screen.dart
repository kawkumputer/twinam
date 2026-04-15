import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/counter.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/banner_ad_widget.dart';
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
  List<int> _reminderDays = []; // 1=Mon…7=Sun, empty=every day
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    _stepController.text = '1';
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
        _reminderDays = List<int>.from(_existingCounter!.reminderDays);
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
              onChanged: (_) { if (_nameError) setState(() => _nameError = false); },
              decoration: InputDecoration(
                hintText: l10n.translate('counterNameHint'),
                errorText: _nameError ? l10n.translate('fieldRequired') : null,
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
                    _buildDaySelector(context, l10n, settings.locale),
                    const SizedBox(height: 8),
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
      bottomNavigationBar: const BannerAdWidget(),
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

  Widget _buildDaySelector(BuildContext context, AppLocalizations l10n, String locale) {
    const dayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    const arAbbr  = ['\u0646', '\u062b', '\u0631', '\u062e', '\u062c', '\u0633', '\u062d'];
    final color = AppTheme.counterColors[_selectedColorIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _reminderDays.isEmpty ? l10n.translate('everyDay') : l10n.translate('specificDays'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final weekday = i + 1;
            final isSelected = _reminderDays.contains(weekday);
            final label = locale == 'ar'
                ? arAbbr[i]
                : l10n.translate(dayKeys[i]).substring(0, 1).toUpperCase();
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _reminderDays.remove(weekday);
                  } else {
                    _reminderDays.add(weekday);
                    _reminderDays.sort();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? color : Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: isSelected ? null : Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }

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
      _existingCounter!.reminderDays = List<int>.from(_reminderDays);
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
        reminderDays: List<int>.from(_reminderDays),
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
      await notifService.scheduleWeeklyReminders(
        baseId: notifId,
        title: '$_selectedEmoji $name',
        body: notifBody,
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
        days: _reminderDays,
        payload: 'counter:$counterId',
      );
    } else {
      await notifService.cancelWeeklyReminders(notifId);
    }

    if (mounted) Navigator.of(context).pop();
  }
}
