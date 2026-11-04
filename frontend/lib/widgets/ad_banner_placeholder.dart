import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class AdBannerPlaceholder extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry margin;

  const AdBannerPlaceholder({
    super.key,
    this.height = 68,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.nevoa.withOpacity(0.6),
          width: 1.2,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'ESPAÇO DE ANÚNCIO',
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: AppColors.petroleo.withOpacity(0.5),
        ),
      ),
    );
  }
}

