import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  /// Master switch to enable/disable all ads.
  /// Set to true when ready to monetize (500-1000 active users).
  static const bool adsEnabled = false;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Production Ad Unit IDs - Halal-compliant ads
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4086972652140089/9656987068'; // Production ID (Android)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4086972652140089/5330932502'; // Production ID (iOS)
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4086972652140089/1447324559'; // Production ID (Android)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4086972652140089/6031768525'; // Production ID (iOS)
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4086972652140089/6996931064'; // Production ID (Android)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4086972652140089/2433306423'; // Production ID (iOS)
    }
    return '';
  }

  Future<void> initialize() async {
    if (!adsEnabled) {
      debugPrint('[AdMob] Ads disabled — skipping initialization');
      return;
    }
    await MobileAds.instance.initialize();
    
    // Configure for halal-compliant ads (family-friendly, no sensitive content)
    final requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      maxAdContentRating: MaxAdContentRating.g, // General audiences only
    );
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);
    
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  // Banner Ad
  BannerAd? createBannerAd() {
    if (!adsEnabled) return null;
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[AdMob] Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdMob] Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
    return _bannerAd;
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  // Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('[AdMob] Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAdIfReady() {
    // Removed - ads will now show only on goal reached or screen exit
  }

  void showInterstitialAdOnGoalReached() {
    _showInterstitialAd('goal reached');
  }

  void showInterstitialAdOnScreenExit() {
    _showInterstitialAd('screen exit');
  }

  void _showInterstitialAd(String trigger) {
    if (!adsEnabled) return;
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          debugPrint('[AdMob] Interstitial ad dismissed after $trigger');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('[AdMob] Interstitial ad failed to show: $error');
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      debugPrint('[AdMob] Interstitial ad shown on $trigger');
    } else {
      debugPrint('[AdMob] Interstitial ad not ready for $trigger');
      _loadInterstitialAd();
    }
  }

  // Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('[AdMob] Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (!adsEnabled) return false;
    if (_rewardedAd == null) {
      debugPrint('[AdMob] Rewarded ad not ready');
      _loadRewardedAd();
      return false;
    }

    bool rewarded = false;
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] Rewarded ad failed to show: $error');
        ad.dispose();
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdMob] User earned reward: ${reward.amount} ${reward.type}');
        rewarded = true;
      },
    );

    return rewarded;
  }

  bool get isRewardedAdReady => adsEnabled && _rewardedAd != null;

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
