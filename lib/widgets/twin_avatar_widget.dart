import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../l10n/app_localizations.dart';

enum TwinState { happy, neutral, sad }

class TwinAvatarWidget extends StatefulWidget {
  final TwinState state;
  final double size;
  final String message;
  final VoidCallback? onTap;
  final bool enableMicroBehaviors;

  const TwinAvatarWidget({
    super.key,
    required this.state,
    this.size = 90,
    this.message = '',
    this.onTap,
    this.enableMicroBehaviors = true,
  });

  static TwinState fromScore(double score) {
    if (score >= 0.8) return TwinState.happy;
    if (score >= 0.4) return TwinState.neutral;
    return TwinState.sad;
  }

  static String messageForState(TwinState state, [String locale = 'en']) {
    final l10n = AppLocalizations(locale);
    switch (state) {
      case TwinState.happy:
        return l10n.translate('twinHappyMessage');
      case TwinState.neutral:
        return l10n.translate('twinNeutralMessage');
      case TwinState.sad:
        return l10n.translate('twinSadMessage');
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

  static String videoForState(TwinState state) {
    switch (state) {
      case TwinState.happy:
        return 'assets/idle-happy.mp4';
      case TwinState.neutral:
        return 'assets/idle-neutre.mp4';
      case TwinState.sad:
        return 'assets/idle-sad.mp4';
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
    with TickerProviderStateMixin {
  // Video controller
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  // Animation controllers
  late AnimationController _breathingController;
  late AnimationController _idleController;
  late AnimationController _blinkController;
  late AnimationController _welcomeController;
  
  // Animations
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _idleSwayAnimation;
  late Animation<double> _welcomeScaleAnimation;
  late Animation<double> _welcomeRotationAnimation;
  
  // Timers
  Timer? _blinkTimer;
  Timer? _idleTimer;
  
  // State
  bool _showWelcome = true;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Breathing animation (continuous, subtle)
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    
    // Idle sway animation (subtle side-to-side movement)
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);
    
    _idleSwayAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
    
    // Blink animation (quick)
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Welcome animation (on app open)
    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _welcomeScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: Curves.elasticOut,
      ),
    );
    
    _welcomeRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: Curves.easeOut,
      ),
    );
    
    _initVideo();
    if (widget.enableMicroBehaviors) {
      _startMicroBehaviors();
      _playWelcomeAnimation();
    }
  }

  Future<void> _initVideo() async {
    final path = TwinAvatarWidget.videoForState(widget.state);
    final controller = VideoPlayerController.asset(path);
    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(0);
    controller.play();
    if (mounted) {
      setState(() {
        _videoController?.dispose();
        _videoController = controller;
        _videoInitialized = true;
      });
    } else {
      controller.dispose();
    }
  }
  
  void _startMicroBehaviors() {
    // Random blinking (every 2-5 seconds)
    _scheduleNextBlink();
    
    // Random idle movements are handled by the continuous idle controller
  }
  
  void _scheduleNextBlink() {
    final delay = 2000 + _random.nextInt(3000); // 2-5 seconds
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted && widget.enableMicroBehaviors) {
        _performBlink();
      }
    });
  }
  
  void _performBlink() async {
    if (!mounted) return;
    await _blinkController.forward();
    await _blinkController.reverse();
    if (mounted) {
      _scheduleNextBlink();
    }
  }
  
  void _playWelcomeAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      await _welcomeController.forward();
      setState(() => _showWelcome = false);
    }
  }

  @override
  void didUpdateWidget(TwinAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _videoInitialized = false;
      _initVideo();
      _breathingController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _breathingController.dispose();
    _idleController.dispose();
    _blinkController.dispose();
    _welcomeController.dispose();
    _blinkTimer?.cancel();
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = TwinAvatarWidget.colorForState(widget.state);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingController,
          _idleController,
          _blinkController,
          _welcomeController,
        ]),
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Welcome animation wrapper
              Transform.scale(
                scale: _showWelcome ? _welcomeScaleAnimation.value : 1.0,
                child: Transform.rotate(
                  angle: _showWelcome ? _welcomeRotationAnimation.value : 0.0,
                  child: Transform.translate(
                    // Idle sway (subtle side-to-side)
                    offset: widget.enableMicroBehaviors 
                      ? Offset(_idleSwayAnimation.value, 0) 
                      : Offset.zero,
                    child: Transform.scale(
                      // Breathing animation
                      scale: widget.enableMicroBehaviors 
                        ? _breathingAnimation.value 
                        : 1.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: widget.size + 16,
                            height: widget.size + 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(
                                    alpha: widget.enableMicroBehaviors 
                                      ? _glowAnimation.value 
                                      : 0.25,
                                  ),
                                  blurRadius: 24,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          // Avatar with blink effect
                          ClipOval(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: widget.size + 16,
                              height: widget.size + 16,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (_videoInitialized && _videoController != null)
                                    SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: _videoController!.value.size.width,
                                          height: _videoController!.value.size.height,
                                          child: VideoPlayer(_videoController!),
                                        ),
                                      ),
                                    )
                                  else
                                    Image.asset(
                                      TwinAvatarWidget.assetForState(widget.state),
                                      fit: BoxFit.cover,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.message.isNotEmpty) ...[
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
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
