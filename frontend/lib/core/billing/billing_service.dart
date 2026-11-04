import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../ads/ad_service.dart';
import '../storage/local_storage_service.dart';

/// Google Play Billing (via in_app_purchase).
///
/// Único produto: compra única NÃO consumível que apenas remove os anúncios.
/// Nunca bloqueia ferramentas, altera resultados ou probabilidades.
/// O ID do produto deve ser criado no Play Console (ver README).
class BillingService extends ChangeNotifier {
  BillingService._();
  static final BillingService instance = BillingService._();

  static const String removeAdsProductId =
      String.fromEnvironment('IAP_REMOVE_ADS_ID', defaultValue: 'remove_ads');

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;
  bool _available = false;
  bool _busy = false;
  String? _message;

  bool get available => _available && _product != null;
  bool get busy => _busy;
  String? get message => _message;
  String get price => _product?.price ?? '';

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      _available = await _iap.isAvailable();
      if (!_available) return;
      _sub ??= _iap.purchaseStream.listen(_onPurchases,
          onError: (e) => debugPrint('[billing] stream error: $e'));
      final res = await _iap.queryProductDetails({removeAdsProductId});
      if (res.productDetails.isNotEmpty) _product = res.productDetails.first;
      notifyListeners();
      // Reinstalação/novo aparelho: recupera a compra silenciosamente.
      if (!localStorageService.adsRemoved) {
        await _iap.restorePurchases();
      }
    } catch (e) {
      debugPrint('[billing] init failed (isolated): $e');
    }
  }

  Future<void> buyRemoveAds() async {
    if (_product == null || _busy) return;
    _setBusy(true, null);
    try {
      final started = await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: _product!));
      if (!started) _setBusy(false, 'Não foi possível iniciar a compra.');
    } catch (e) {
      _setBusy(false, 'Não foi possível iniciar a compra.');
    }
  }

  Future<void> restore() async {
    if (!_available || _busy) return;
    _setBusy(true, null);
    try {
      await _iap.restorePurchases();
      // Se nada for restaurado, libera o estado ocupado após um tempo.
      Future.delayed(const Duration(seconds: 6), () {
        if (_busy) _setBusy(false, 'Nenhuma compra encontrada para restaurar.');
      });
    } catch (e) {
      _setBusy(false, 'Não foi possível restaurar as compras.');
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.productID != removeAdsProductId) continue;
      switch (p.status) {
        case PurchaseStatus.pending:
          _setBusy(true, null);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await localStorageService.setAdsRemoved(true);
          adService.onAdsRemoved();
          _setBusy(false, 'Anúncios removidos. Obrigado pelo apoio!');
          break;
        case PurchaseStatus.error:
          // Já possui o item: recupera em vez de falhar.
          if (p.error?.message.toLowerCase().contains('owned') ?? false) {
            await _iap.restorePurchases();
          }
          _setBusy(false, 'A compra não foi concluída.');
          break;
        case PurchaseStatus.canceled:
          _setBusy(false, null);
          break;
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  void _setBusy(bool busy, String? msg) {
    _busy = busy;
    _message = msg;
    notifyListeners();
  }
}

final BillingService billingService = BillingService.instance;
