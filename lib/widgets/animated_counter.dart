import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: value, end: value),
      duration: duration,
      builder: (context, val, child) {
        return _AnimatedCounterValue(
          value: value,
          style: style,
          duration: duration,
        );
      },
    );
  }
}

class _AnimatedCounterValue extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const _AnimatedCounterValue({
    required this.value,
    this.style,
    required this.duration,
  });

  @override
  State<_AnimatedCounterValue> createState() => _AnimatedCounterValueState();
}

class _AnimatedCounterValueState extends State<_AnimatedCounterValue>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _currentValue = widget.value;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedCounterValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _currentValue;
      _currentValue = widget.value;
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
    final digits = _currentValue.toString().split('');
    final prevDigits = _previousValue.toString().split('');

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(digits.length, (index) {
            final digit = digits[index];
            final hasPrev = index < prevDigits.length;
            final prevDigit = hasPrev ? prevDigits[index] : null;
            final isChanged = prevDigit != digit;

            if (!isChanged || _animation.isCompleted) {
              return Text(digit, style: widget.style);
            }

            return ClipRect(
              child: SizedBox(
                width: _getDigitWidth(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Old digit sliding out
                    if (prevDigit != null)
                      Transform.translate(
                        offset: Offset(0, -40 * _animation.value),
                        child: Opacity(
                          opacity: (1 - _animation.value).clamp(0.0, 1.0),
                          child: Text(prevDigit, style: widget.style),
                        ),
                      ),
                    // New digit sliding in
                    Transform.translate(
                      offset: Offset(0, 40 * (1 - _animation.value)),
                      child: Opacity(
                        opacity: _animation.value.clamp(0.0, 1.0),
                        child: Text(digit, style: widget.style),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _getDigitWidth(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.displayLarge!;
    final textPainter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width + 2;
  }
}
