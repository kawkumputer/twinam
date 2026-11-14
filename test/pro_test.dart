import 'package:flutter_test/flutter_test.dart';
import 'package:twinam/config/features.dart';
import 'package:twinam/services/purchase_service.dart';
import 'package:twinam/widgets/pro_sheet.dart';

class _FakeStorage implements PurchaseStorage {
  @override
  bool proPurchased;
  @override
  String? storeCountry;

  _FakeStorage({this.proPurchased = false});

  @override
  Future<void> setProPurchased(bool value) async => proPurchased = value;
  @override
  Future<void> setStoreCountry(String value) async => storeCountry = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('counter limit', () {
    test('free user can create up to the limit', () {
      for (var n = 0; n < kFreeCounterLimit; n++) {
        expect(canCreateCounter(isPro: false, counterCount: n), isTrue);
      }
    });

    test('free user is blocked at the limit and above', () {
      expect(canCreateCounter(isPro: false, counterCount: kFreeCounterLimit), isFalse);
      expect(canCreateCounter(isPro: false, counterCount: kFreeCounterLimit + 4), isFalse);
    });

    test('Pro user has no limit', () {
      expect(canCreateCounter(isPro: true, counterCount: 50), isTrue);
    });
  });

  group('PurchaseService', () {
    test('restores a saved purchase at startup, even without a store', () async {
      final service = PurchaseService(_FakeStorage(proPurchased: true));
      await service.init();
      expect(service.isPro, isTrue);
      expect(service.canBuy, isFalse); // no store in tests
    });

    test('starts free when nothing was bought', () async {
      final service = PurchaseService(_FakeStorage());
      await service.init();
      expect(service.isPro, isFalse);
    });

    test('debugSet switches Pro on and off', () {
      final service = PurchaseService(_FakeStorage());
      service.debugSet(purchased: true);
      expect(service.isPro, isTrue);
      service.debugSet(purchased: false);
      expect(service.isPro, isFalse);
    });
  });
}
