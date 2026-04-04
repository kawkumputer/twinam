import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Production Ad Unit IDs - Halal-compliant ads
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID (Android)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4086972652140089/5330932502'; // Production ID (iOS)
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID (Android)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4086972652140089/6031768525'; // Production ID (iOS)
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID (Android)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4086972652140089/2433306423'; // Production ID (iOS)
    }
    return '';
  }

  Future<void> initialize() async {
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
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('[AdMob] Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('[AdMob] Banner ad failed to load: $error');
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
          print('[AdMob] Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('[AdMob] Interstitial ad failed to load: $error');
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
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          print('[AdMob] Interstitial ad dismissed after $trigger');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('[AdMob] Interstitial ad failed to show: $error');
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      print('[AdMob] Interstitial ad shown on $trigger');
    } else {
      print('[AdMob] Interstitial ad not ready for $trigger');
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
          print('[AdMob] Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('[AdMob] Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      print('[AdMob] Rewarded ad not ready');
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
        print('[AdMob] Rewarded ad failed to show: $error');
        ad.dispose();
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('[AdMob] User earned reward: ${reward.amount} ${reward.type}');
        rewarded = true;
      },
    );

    return rewarded;
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
