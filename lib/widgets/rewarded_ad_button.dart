import 'package:flutter/material.dart';
import '../services/admob_service.dart';

class RewardedAdButton extends StatefulWidget {
  final Function(int xpReward) onRewardEarned;
  final String buttonText;
  
  const RewardedAdButton({
    super.key,
    required this.onRewardEarned,
    this.buttonText = 'Watch Ad for +50 XP',
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _isLoading = false;

  Future<void> _watchAd() async {
    setState(() {
      _isLoading = true;
    });

    final rewarded = await AdMobService().showRewardedAd();
    
    if (rewarded && mounted) {
      widget.onRewardEarned(50);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Text('🎉 +50 XP earned!'),
            ],
          ),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = AdMobService().isRewardedAdReady;
    
    return ElevatedButton.icon(
      onPressed: (isReady && !_isLoading) ? _watchAd : null,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.play_circle_outline_rounded),
      label: Text(
        _isLoading ? 'Loading...' : widget.buttonText,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFB74D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
