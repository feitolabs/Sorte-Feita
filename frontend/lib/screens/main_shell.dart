import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../widgets/app_navbar.dart';
import '../core/ads/ad_service.dart';
import 'home_screen.dart';
import 'catalog_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'wheel_screen.dart';
import 'name_draw_screen.dart';
import 'teams_screen.dart';
import 'number_draw_screen.dart';
import 'decision_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    // Transição natural: volta ao Início (frequency cap no AdService).
    if (index == 0 && _currentIndex != 0) adService.maybeShowInterstitial();
    setState(() => _currentIndex = index);
  }

  void _showQuickCreateDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.nevoa,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Criar novo sorteio',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.petroleo,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickOption(
                icon: Icons.pie_chart_rounded,
                title: 'Nova Roleta',
                subtitle: 'Personalize nomes, pesos e gire para decidir',
                color: AppColors.petroleo,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WheelScreen()));
                },
              ),
              _buildQuickOption(
                icon: Icons.format_list_bulleted_rounded,
                title: 'Sorteio de Nomes',
                subtitle: 'Lista com ganhadores e suplentes',
                color: AppColors.azulRio,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NameDrawScreen()));
                },
              ),
              _buildQuickOption(
                icon: Icons.tag_rounded,
                title: 'Sorteio de Números',
                subtitle: 'Intervalo, quantidade e exclusões',
                color: AppColors.petroleo,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NumberDrawScreen()));
                },
              ),
              _buildQuickOption(
                icon: Icons.groups_rounded,
                title: 'Dividir Equipes',
                subtitle: 'Grupos equilibrados e capitães',
                color: AppColors.azulRio,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamsScreen()));
                },
              ),
              _buildQuickOption(
                icon: Icons.check_circle_outline_rounded,
                title: 'Sim ou Não',
                subtitle: 'Decisão aleatória instantânea',
                color: AppColors.azulRioClaro,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DecisionScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderLight),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.petroleo,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondaryLight),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onOpenCatalog: () => setState(() => _currentIndex = 1),
        onOpenHistory: () => setState(() => _currentIndex = 2),
      ),
      const CatalogScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppNavbar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        onQuickCreate: _showQuickCreateDialog,
      ),
    );
  }
}
