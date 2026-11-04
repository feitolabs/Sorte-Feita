import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../storage/local_storage_service.dart';
import 'ad_config.dart';

/// Adaptador de publicidade (AdMob / Android e iOS).
///
/// Regras (spec §13): falha isolada, consentimento (UMP) antes de carregar
/// o SDK, nunca durante o giro/resultado, frequency cap centralizado e
/// nenhum dado de participantes enviado à rede. Eventos registram só
/// placement/format.
class AdService extends ChangeNotifier {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;
  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;
  int _activitiesSinceAd = 0;
  DateTime? _lastInterstitial;
  final DateTime _sessionStart = DateTime.now();
  bool _blocked = false; // bloqueio absoluto (roleta girando / resultado)

  /// Anúncios só aparecem em mobile, habilitados e se o usuário não removeu.
  bool get adsAllowed =>
      AdConfig.adsEnabled &&
      AdConfig.isMobile &&
      !localStorageService.adsRemoved;

  /// SDK pronto e consentimento resolvido.
  bool get ready => adsAllowed && _initialized && _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  Future<void> init() async {
    if (_initialized || !adsAllowed) return;
    try {
      final completer = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          } catch (e) {
            debugPrint('[ads] consent form: $e');
          }
          if (!completer.isCompleted) completer.complete();
        },
        (error) {
          debugPrint('[ads] consent error: ${error.message}');
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future
          .timeout(const Duration(seconds: 20), onTimeout: () {});
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      _privacyOptionsRequired = await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
      if (_canRequestAds) {
        await MobileAds.instance.initialize();
        _initialized = true;
        _loadInterstitial();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[ads] init failed (isolated): $e');
    }
  }

  /// Reabre o formulário de opções de privacidade de anúncios.
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (e) {
      debugPrint('[ads] privacy options: $e');
    }
  }

  /// Chamado quando o usuário remove os anúncios (compra) — descarta tudo.
  void onAdsRemoved() {
    _interstitial?.dispose();
    _interstitial = null;
    notifyListeners();
  }

  /// Bloqueio absoluto durante giro/seleção/resultado (spec 13.2).
  void setBlocked(bool value) => _blocked = value;

  /// Registra uma atividade concluída (para o frequency cap).
  void recordActivityCompleted() => _activitiesSinceAd++;

  void _log(String event, String placement, String format) =>
      debugPrint('[ads] $event placement=$placement format=$format');

  void _loadInterstitial() {
    if (!ready || _interstitial != null || _interstitialLoading) return;
    _interstitialLoading = true;
    _log('ad_request', 'transition', 'interstitial');
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitial = ad;
          _log('ad_loaded', 'transition', 'interstitial');
        },
        onAdFailedToLoad: (e) {
          _interstitialLoading = false;
          debugPrint('[ads] interstitial failed: ${e.code}');
        },
      ),
    );
  }

  /// Chamar somente em transições naturais (ex.: voltar ao Início), nunca
  /// na primeira abertura, durante giro, edição ou antes do resultado.
  void maybeShowInterstitial() {
    if (!ready || _blocked || _interstitial == null) {
      _loadInterstitial();
      return;
    }
    final now = DateTime.now();
    final sinceStart = now.difference(_sessionStart).inSeconds;
    final sinceLast = _lastInterstitial == null
        ? sinceStart
        : now.difference(_lastInterstitial!).inSeconds;
    if (_activitiesSinceAd < AdConfig.interstitialMinActivities ||
        sinceLast < AdConfig.interstitialMinIntervalSeconds) {
      return;
    }
    final ad = _interstitial!;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        a.dispose();
        _loadInterstitial();
      },
      onAdImpression: (_) =>
          _log('ad_impression', 'transition', 'interstitial'),
    );
    try {
      ad.show();
      _lastInterstitial = now;
      _activitiesSinceAd = 0;
    } catch (e) {
      debugPrint('[ads] show failed (isolated): $e');
    }
  }
}

final AdService adService = AdService.instance;
