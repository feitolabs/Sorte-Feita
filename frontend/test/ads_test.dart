import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorte_feita/core/ads/ad_service.dart';
import 'package:sorte_feita/core/ads/ad_config.dart';
import 'package:sorte_feita/core/storage/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SDK is never ready before init/consent resolution', () {
    expect(adService.ready, isFalse);
  });

  test('interstitial request is a safe no-op when ads are not ready', () {
    adService.recordActivityCompleted();
    expect(() => adService.maybeShowInterstitial(), returnsNormally);
  });

  test('frequency cap defaults follow the spec', () {
    expect(AdConfig.interstitialMinActivities, 3);
    expect(AdConfig.interstitialMinIntervalSeconds, greaterThanOrEqualTo(180));
  });

  test('adsRemoved persists locally', () async {
    SharedPreferences.setMockInitialValues({});
    await localStorageService.init();
    expect(localStorageService.adsRemoved, isFalse);
    await localStorageService.setAdsRemoved(true);
    expect(localStorageService.adsRemoved, isTrue);
    await localStorageService.init();
    expect(localStorageService.adsRemoved, isTrue);
  });
}
