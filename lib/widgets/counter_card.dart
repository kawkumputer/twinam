import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/counter.dart';

class CounterCard extends StatefulWidget {
  final Counter counter;
  final VoidCallback onTap;
  final VoidCallback onQuickTap;
  final VoidCallback? onLongPress;

  const CounterCard({
    super.key,
    required this.counter,
    required this.onTap,
    required this.onQuickTap,
    this.onLongPress,
  });

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  Widget _buildQuickTapButton(Color color, {bool small = false}) {
    final size = small ? 30.0 : 38.0;
    final iconSize = small ? 16.0 : 20.0;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _tapController.forward().then((_) => _tapController.reverse());
        widget.onQuickTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(small ? 8 : 10),
        ),
        child: Icon(
          Icons.add_rounded,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counter = widget.counter;
    final color = Color(counter.colorValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _tapAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _tapAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(counter.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      counter.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${counter.value}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                    ),
                    const Spacer(),
                    if (counter.goal != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: counter.progress,
                                minHeight: 6,
                                backgroundColor: color.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  counter.goalReached ? const Color(0xFF66BB6A) : color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickTapButton(color, small: true),
                        ],
                      ),
                    ],
                    if (counter.goal == null) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildQuickTapButton(color),
                      ),
                    ],
                  ],
                ),
              ),
              if (counter.goal != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: counter.goalReached
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF66BB6A),
                            size: 16,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF80DEEA).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(counter.progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFF80DEEA),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
