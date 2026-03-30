import 'package:flutter/material.dart';

enum TwinState { happy, neutral, sad }

class TwinAvatarWidget extends StatefulWidget {
  final TwinState state;
  final double size;
  final String message;
  final VoidCallback? onTap;

  const TwinAvatarWidget({
    super.key,
    required this.state,
    this.size = 90,
    this.message = '',
    this.onTap,
  });

  static TwinState fromScore(double score) {
    if (score >= 0.8) return TwinState.happy;
    if (score >= 0.4) return TwinState.neutral;
    return TwinState.sad;
  }

  static String messageForState(TwinState state) {
    switch (state) {
      case TwinState.happy:
        return "I'm proud of you! 🌟";
      case TwinState.neutral:
        return "Keep going, you've got this 💪";
      case TwinState.sad:
        return "You can do better. Come on! 🔥";
    }
  }

  static String assetForState(TwinState state) {
    switch (state) {
      case TwinState.happy:
        return 'assets/happy-avatar.jpeg';
      case TwinState.neutral:
        return 'assets/neutral-avatar.jpeg';
      case TwinState.sad:
        return 'assets/sad-avatar.jpeg';
    }
  }

  static Color colorForState(TwinState state) {
    switch (state) {
      case TwinState.happy:
        return const Color(0xFF4CAF50);
      case TwinState.neutral:
        return const Color(0xFF2196F3);
      case TwinState.sad:
        return const Color(0xFFFF7043);
    }
  }

  @override
  State<TwinAvatarWidget> createState() => _TwinAvatarWidgetState();
}

class _TwinAvatarWidgetState extends State<TwinAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(TwinAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = TwinAvatarWidget.colorForState(widget.state);
    final asset = TwinAvatarWidget.assetForState(widget.state);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: widget.size + 16,
                  height: widget.size + 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: _glowAnimation.value),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      asset,
                      width: widget.size + 16,
                      height: widget.size + 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (widget.message.isNotEmpty) ...[
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    key: ValueKey(widget.state),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
