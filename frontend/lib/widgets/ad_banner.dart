import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ads/ad_config.dart';
import '../core/ads/ad_service.dart';
import '../core/storage/local_storage_service.dart';
import 'ad_banner_placeholder.dart';

/// Banner adaptativo identificado como publicidade. Falha de forma isolada:
/// se não carregar, não ocupa espaço nem afeta a ferramenta.
class AdBanner extends StatefulWidget {
  final String placement;
  const AdBanner({super.key, required this.placement});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    adService.addListener(_onChange);
    localStorageService.addListener(_onChange);
  }

  void _onChange() {
    if (!mounted) return;
    if (!adService.adsAllowed) {
      _ad?.dispose();
      _ad = null;
      _loaded = false;
    }
    setState(() {});
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    if (_requested || !adService.ready) return;
    _requested = true;
    final width = MediaQuery.sizeOf(context).width.truncate() - 40;
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    _ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, e) {
          ad.dispose();
          _ad = null;
          debugPrint('[ads] banner failed: ${e.code}');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    adService.removeListener(_onChange);
    localStorageService.removeListener(_onChange);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!adService.adsAllowed) {
      // Em debug fora de mobile (desktop/web) mostra o espaço reservado.
      return kDebugMode && !AdConfig.isMobile && !localStorageService.adsRemoved
          ? const AdBannerPlaceholder()
          : const SizedBox.shrink();
    }
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Publicidade',
            child: SizedBox(
              width: _ad!.size.width.toDouble(),
              height: _ad!.size.height.toDouble(),
              child: AdWidget(ad: _ad!),
            ),
          ),
          const SizedBox(height: 2),
          const Text('Publicidade',
              style: TextStyle(fontSize: 10, color: Colors.black45)),
        ],
      ),
    );
  }
}
