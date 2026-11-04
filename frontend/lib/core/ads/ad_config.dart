import 'package:flutter/foundation.dart';

/// Configuração de publicidade. Nenhum ID real fica no código: em produção
/// eles são injetados no build via `--dart-define` (ver README).
/// Os valores padrão são os IDs de TESTE públicos do Google AdMob.
class AdConfig {
  AdConfig._();

  /// Liga/desliga totalmente a publicidade (modo sem anúncios para testes).
  static const bool adsEnabled =
      bool.fromEnvironment('ADS_ENABLED', defaultValue: true);

  static const String _bannerAndroid = String.fromEnvironment(
      'ADMOB_BANNER_ANDROID',
      defaultValue: 'ca-app-pub-3940256099942544/6300978111');
  static const String _bannerIos = String.fromEnvironment('ADMOB_BANNER_IOS',
      defaultValue: 'ca-app-pub-3940256099942544/2934735716');
  static const String _interstitialAndroid = String.fromEnvironment(
      'ADMOB_INTERSTITIAL_ANDROID',
      defaultValue: 'ca-app-pub-3940256099942544/1033173712');
  static const String _interstitialIos = String.fromEnvironment(
      'ADMOB_INTERSTITIAL_IOS',
      defaultValue: 'ca-app-pub-3940256099942544/4411468910');

  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get bannerUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS ? _bannerIos : _bannerAndroid;

  static String get interstitialUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? _interstitialIos
          : _interstitialAndroid;

  // Frequency cap do intersticial (spec 13.3) — configurável no build.
  static const int interstitialMinActivities =
      int.fromEnvironment('AD_MIN_ACTIVITIES', defaultValue: 3);
  static const int interstitialMinIntervalSeconds =
      int.fromEnvironment('AD_MIN_INTERVAL_SECONDS', defaultValue: 300);
}
