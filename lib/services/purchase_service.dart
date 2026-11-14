import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

/// Where the purchase state is kept on the device.
/// Implemented by StorageService (Hive); tests pass a fake.
abstract class PurchaseStorage {
  bool get proPurchased;
  Future<void> setProPurchased(bool value);
  String? get storeCountry;
  Future<void> setStoreCountry(String value);
}

/// One-time in-app purchase "Twin'Am Pro" (non-consumable).
///
/// Same pattern as Learn Pulaar / Pulaar Arabe:
/// - Free: up to [kFreeCounterLimit] counters, last 7 days of stats.
/// - Pro: unlimited counters, full stats (month view + activity map).
class PurchaseService extends ChangeNotifier {
  PurchaseService(this._storage, {InAppPurchase? store}) : _store = store;

  /// Product id, identical in App Store Connect and Google Play.
  static const productId = 'com.twinam.twinam.pro';

  final PurchaseStorage _storage;
  final InAppPurchase? _store;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  bool purchased = false;
  bool busy = false;
  bool storeAvailable = false;
  String? price;
  String? country;
  String? error;

  bool get isPro => purchased;
  bool get canBuy => storeAvailable && _product != null && !busy;

  /// For tests: force the state without going through the stores.
  void debugSet({bool? purchased}) {
    this.purchased = purchased ?? this.purchased;
    notifyListeners();
  }

  Future<void> init() async {
    purchased = _storage.proPurchased;
    country = _storage.storeCountry;
    if (kIsWeb) {
      notifyListeners();
      return;
    }
    try {
      final iap = _store ?? InAppPurchase.instance;
      storeAvailable = await iap.isAvailable();
      _sub = iap.purchaseStream.listen(
        _onPurchases,
        onError: (Object e) => _fail('$e'),
      );
      if (storeAvailable) {
        unawaited(_loadStoreInfo(iap));
      }
    } catch (e) {
      storeAvailable = false;
      debugPrint('IAP init: $e');
    }
    notifyListeners();
  }

  Future<void> _loadStoreInfo(InAppPurchase iap) async {
    try {
      final code = await InAppPurchasePlatform.instance.countryCode();
      if (code.isNotEmpty) {
        country = code;
        await _storage.setStoreCountry(code);
      }
    } catch (e) {
      debugPrint('IAP country: $e');
    }
    try {
      final r = await iap.queryProductDetails({productId});
      if (r.productDetails.isNotEmpty) {
        _product = r.productDetails.first;
        price = _product!.price;
      }
    } catch (e) {
      debugPrint('IAP products: $e');
    }
    notifyListeners();
    // Silent restore: finds a purchase made on another device.
    // (iOS: no automatic restore, it would ask for the Apple ID password.)
    if (!purchased && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await iap.restorePurchases();
      } catch (_) {}
    }
  }

  Future<void> buy() async {
    final p = _product;
    if (p == null) return;
    error = null;
    busy = true;
    notifyListeners();
    try {
      await (_store ?? InAppPurchase.instance).buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: p),
      );
    } catch (e) {
      _fail('$e');
    }
  }

  Future<void> restore() async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      await (_store ?? InAppPurchase.instance).restorePurchases();
      // If nothing comes back, give control back after a delay.
      Future<void>.delayed(const Duration(seconds: 6), () {
        if (busy) {
          busy = false;
          notifyListeners();
        }
      });
    } catch (e) {
      _fail('$e');
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final d in list) {
      if (d.productID != productId) continue;
      switch (d.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          purchased = true;
          await _storage.setProPurchased(true);
          busy = false;
        case PurchaseStatus.error:
          _fail(d.error?.message ?? 'error');
        case PurchaseStatus.canceled:
          busy = false;
        case PurchaseStatus.pending:
          busy = true;
      }
      if (d.pendingCompletePurchase) {
        try {
          await (_store ?? InAppPurchase.instance).completePurchase(d);
        } catch (_) {}
      }
    }
    notifyListeners();
  }

  void _fail(String message) {
    busy = false;
    error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
