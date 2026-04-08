import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/banner_ad_widget.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final todoCount = taskProvider.todoTasks.length;
    final inProgressCount = taskProvider.inProgressTasks.length;
    final doneCount = taskProvider.doneTasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('tasks'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          if (doneCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: l10n.translate('clearCompleted'),
              onPressed: () => _showClearCompletedDialog(context, taskProvider, l10n),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(l10n.translate('todo'), overflow: TextOverflow.ellipsis)),
                  if (todoCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$todoCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(l10n.translate('inProgress'), overflow: TextOverflow.ellipsis)),
                  if (inProgressCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$inProgressCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(l10n.translate('done'), overflow: TextOverflow.ellipsis)),
                  if (doneCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$doneCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TaskList(tasks: taskProvider.todoTasks),
          _TaskList(tasks: taskProvider.inProgressTasks),
          _TaskList(tasks: taskProvider.doneTasks),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/create-task'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.translate('newTask'), style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF2196F3),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  void _showClearCompletedDialog(BuildContext context, TaskProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.translate('clearCompletedConfirm')),
        content: Text(l10n.translate('clearCompletedMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              provider.clearCompletedTasks();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.translate('completedTasksCleared'))),
              );
            },
            child: Text(l10n.translate('clearCompleted'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;

  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.translate('noTasksHere'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _TaskCard(task: tasks[index]),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    // Start shake animation if task is overdue
    if (widget.task.isOverdue) {
      _shakeController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(settings.locale);
    final priorityColor = _getPriorityColor(widget.task.priority);
    final statusColor = _getStatusColor(widget.task.status);
    final isOverdue = widget.task.isOverdue;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: isOverdue 
            ? Offset(_shakeAnimation.value * (widget.task.hashCode % 2 == 0 ? 1 : -1), 0) 
            : Offset.zero,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue
                ? const Color(0xFFFF7043).withValues(alpha: 0.3)
                : priorityColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed('/edit-task', arguments: widget.task.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Priority indicator
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  decoration: widget.task.status == TaskStatus.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          if (widget.task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.task.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(widget.task.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Deadline and actions
                Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
                      size: 16,
                      color: isOverdue
                          ? const Color(0xFFFF7043)
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDeadline(widget.task.deadline, isOverdue, l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isOverdue
                                ? const Color(0xFFFF7043)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    
                    // Quick actions
                    if (widget.task.status != TaskStatus.done)
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        color: const Color(0xFF4CAF50),
                        onPressed: () {
                          Provider.of<TaskProvider>(context, listen: false)
                              .markTaskAsDone(widget.task.id);
                        },
                        tooltip: 'Mark as done',
                      ),
                    if (widget.task.status == TaskStatus.todo)
                      IconButton(
                        icon: const Icon(Icons.play_circle_rounded, size: 20),
                        color: const Color(0xFFFF9800),
                        onPressed: () {
                          Provider.of<TaskProvider>(context, listen: false)
                              .markTaskAsInProgress(widget.task.id);
                        },
                        tooltip: 'Start',
                      ),
                    if (widget.task.status == TaskStatus.done)
                      IconButton(
                        icon: const Icon(Icons.restart_alt_rounded, size: 20),
                        color: const Color(0xFF2196F3),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Provider.of<TaskProvider>(context, listen: false)
                              .markTaskAsTodo(widget.task.id);
                        },
                        tooltip: 'Reopen',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFFF7043);
      case TaskPriority.medium:
        return const Color(0xFFFF9800);
      case TaskPriority.low:
        return const Color(0xFF4CAF50);
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const Color(0xFF2196F3);
      case TaskStatus.inProgress:
        return const Color(0xFFFF9800);
      case TaskStatus.done:
        return const Color(0xFF4CAF50);
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN PROGRESS';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  String _formatDeadline(DateTime deadline, bool isOverdue, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);

    if (isOverdue) {
      final overdueBy = now.difference(deadline);
      if (overdueBy.inMinutes < 60) {
        return '${l10n.translate('overdueBy')} ${overdueBy.inMinutes}${l10n.translate('minuteAbbr')}';
      }
      if (overdueBy.inHours < 24) {
        return '${l10n.translate('overdueBy')} ${overdueBy.inHours}h';
      }
      return '${l10n.translate('overdueBy')} ${overdueBy.inDays}${l10n.translate('dayAbbr')}';
    }

    final time = DateFormat.Hm().format(deadline);
    if (deadlineDay.isAtSameMomentAs(today)) {
      return '${l10n.translate('todayAt')} ${l10n.translate('at')} $time';
    }
    if (deadlineDay.isAtSameMomentAs(tomorrow)) {
      return '${l10n.translate('tomorrowAt')} ${l10n.translate('at')} $time';
    }
    final diff = deadline.difference(now);
    if (diff.inDays < 7) {
      return '${DateFormat.E().format(deadline)} ${l10n.translate('at')} $time';
    }
    return DateFormat('MMM d, HH:mm').format(deadline);
  }
}
