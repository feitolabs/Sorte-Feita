import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/storage/local_storage_service.dart';
import '../core/ads/ad_service.dart';
import '../core/billing/billing_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Privacidade & LGPD',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.petroleo,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Armazenamento Local First',
                style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo),
              ),
              const SizedBox(height: 6),
              Text(
                'Todas as suas listas de participantes, opções de roleta e resultados ficam armazenados exclusivamente no seu dispositivo (LocalStorage). Nenhum nome ou dado pessoal é transmitido para servidores ou compartilhado com redes de publicidade.',
                style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textPrimaryLight, height: 1.4),
              ),
              const SizedBox(height: 14),
              Text(
                'Transparência e Controle',
                style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo),
              ),
              const SizedBox(height: 6),
              Text(
                'Publicidade: usamos o Google AdMob para exibir anúncios. Nenhum nome, lista ou resultado é enviado à rede de anúncios. Em regiões que exigem, pedimos seu consentimento e você pode alterá-lo em Ajustes > Preferências de anúncios. Anúncios nunca aparecem durante o giro nem alteram resultados.\n\nVocê tem controle total sobre seus dados. A qualquer momento, é possível apagar individualmente ou limpar completamente seu histórico nas abas do aplicativo.',
                style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textPrimaryLight, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.petroleo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icone/png/sorte-feita-icone-96.png',
              width: 72,
              height: 72,
              errorBuilder: (_, __, ___) => const Icon(Icons.pie_chart_rounded, size: 64, color: AppColors.azulRio),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'sorte ',
                  style: GoogleFonts.bricolageGrotesque(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.petroleo),
                ),
                Text(
                  'feita',
                  style: GoogleFonts.bricolageGrotesque(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.azulRio),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Versão 1.0.0',
              style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),
            Text(
              'Roletas, sorteios e equipes. Tudo grátis, sem cadastro.',
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textPrimaryLight, height: 1.4),
            ),
            const SizedBox(height: 18),
            Text(
              'UM APP FEITO LABS',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: AppColors.petroleo,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.petroleo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  TextStyle get _tileTitle => GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo);

  Widget _buildAdsSection(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([billingService, adService, localStorageService]),
      builder: (context, _) {
        final removed = localStorageService.adsRemoved;
        final msg = billingService.message;
        final canBuy = !removed && billingService.available && !billingService.busy;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PUBLICIDADE',
              style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                side: BorderSide(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.block_rounded, color: AppColors.petroleo),
                    title: Text(removed ? 'Anúncios removidos' : 'Remover anúncios', style: _tileTitle),
                    subtitle: Text(
                      removed
                          ? 'Obrigado por apoiar o Sorte Feita!'
                          : billingService.available
                              ? 'Pagamento único de ${billingService.price}. Todas as ferramentas continuam grátis e os resultados nunca mudam.'
                              : 'Indisponível no momento. O app segue grátis com anúncios discretos.',
                      style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                    trailing: removed
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.azulRio)
                        : billingService.busy
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondaryLight),
                    onTap: canBuy ? () => billingService.buyRemoveAds() : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restore_rounded, color: AppColors.petroleo),
                    title: Text('Restaurar compra', style: _tileTitle),
                    onTap: billingService.available && !billingService.busy ? () => billingService.restore() : null,
                  ),
                  if (adService.privacyOptionsRequired && !removed) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.tune_rounded, color: AppColors.petroleo),
                      title: Text('Preferências de anúncios', style: _tileTitle),
                      subtitle: Text('Gerenciar consentimento de publicidade', style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondaryLight)),
                      onTap: () => adService.showPrivacyOptions(),
                    ),
                  ],
                ],
              ),
            ),
            if (msg != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(msg, style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.petroleo)),
              ),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: localStorageService,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PREFERÊNCIAS',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Switches Card
                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          activeTrackColor: AppColors.petroleo,
                          title: Text(
                            'Sons do sorteio',
                            style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo),
                          ),
                          subtitle: Text('Efeitos sonoros ao girar e sortear', style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondaryLight)),
                          value: localStorageService.soundEnabled,
                          onChanged: (val) => localStorageService.setSoundEnabled(val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          activeTrackColor: AppColors.petroleo,
                          title: Text(
                            'Vibração (Haptic)',
                            style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo),
                          ),
                          subtitle: Text('Vibrar ao concluir o sorteio', style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondaryLight)),
                          value: localStorageService.hapticEnabled,
                          onChanged: (val) => localStorageService.setHapticEnabled(val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          activeTrackColor: AppColors.petroleo,
                          title: Text(
                            'Reduzir movimento',
                            style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo),
                          ),
                          subtitle: Text('Substitui animações longas por giros rápidos', style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondaryLight)),
                          value: localStorageService.reduceMotion,
                          onChanged: (val) => localStorageService.setReduceMotion(val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildAdsSection(context),

                  Text(
                    'INFORMAÇÕES E TERMOS',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.shield_outlined, color: AppColors.petroleo),
                          title: Text(
                            'Privacidade & LGPD',
                            style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondaryLight),
                          onTap: () => _showPrivacyDialog(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline_rounded, color: AppColors.petroleo),
                          title: Text(
                            'Sobre o Sorte Feita',
                            style: GoogleFonts.bricolageGrotesque(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.petroleo),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondaryLight),
                          onTap: () => _showAboutDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
