import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class AppNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickCreate;

  const AppNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onQuickCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              iconPath: currentIndex == 0
                  ? 'assets/interface/navegacao/inicio-ativo.svg'
                  : 'assets/interface/navegacao/inicio.svg',
              fallbackIcon: Icons.home_rounded,
              label: 'Início',
            ),
            _buildNavItem(
              index: 1,
              iconPath: currentIndex == 1
                  ? 'assets/interface/navegacao/ferramentas-ativo.svg'
                  : 'assets/interface/navegacao/ferramentas.svg',
              fallbackIcon: Icons.grid_view_rounded,
              label: 'Ferramentas',
            ),
            // Floating Center Action Button (+) in Brasa
            GestureDetector(
              onTap: onQuickCreate,
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.brasa,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3DF26B21),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            _buildNavItem(
              index: 2,
              iconPath: 'assets/interface/navegacao/historico.svg',
              fallbackIcon: Icons.history_rounded,
              label: 'Histórico',
            ),
            _buildNavItem(
              index: 3,
              iconPath: 'assets/interface/navegacao/ajustes.svg',
              fallbackIcon: Icons.tune_rounded,
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required IconData fallbackIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.petroleo : AppColors.textSecondaryLight;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                placeholderBuilder: (_) => Icon(fallbackIcon, size: 24, color: color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

