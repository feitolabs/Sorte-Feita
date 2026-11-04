import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _stage = 1; // 1: Feito Labs Apresenta, 2: Sorte Feita
  Timer? _timer1;
  Timer? _timer2;

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  @override
  void dispose() {
    _timer1?.cancel();
    _timer2?.cancel();
    super.dispose();
  }

  void _startSplashSequence() {
    // Stage 1 for 1.4 seconds
    _timer1 = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _stage = 2);
      }
    });

    // Stage 2 for 1.6 seconds, then navigate to Home
    _timer2 = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == 1) {
      // Splash 1: Feito Labs Apresenta (Dark Petrol)
      return Scaffold(
        backgroundColor: AppColors.petroleo,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/abertura/png/abertura-1-feito-labs-apresenta.png',
                  width: 240,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.azulRio,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.bolt, color: Colors.white, size: 50),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'feito labs',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'APRESENTA',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4.0,
                    color: AppColors.nevoaClaro,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 140,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    // Splash 2: Sorte Feita (Areia)
    return Scaffold(
      backgroundColor: AppColors.areia,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/icone/png/sorte-feita-icone-192.png',
                  width: 130,
                  height: 130,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.petroleo,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.pie_chart, color: AppColors.brasa, size: 64),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'sorte ',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.petroleo,
                      ),
                    ),
                    Text(
                      'feita',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.azulRio,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Roletas, sorteios e equipes. Tudo grátis, sem cadastro.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      'UM APP',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: AppColors.petroleo,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'feito labs',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.petroleo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
