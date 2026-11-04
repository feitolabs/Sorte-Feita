import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';
import '../core/storage/local_storage_service.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String? _letter;
  final Set<String> _excluded = {};

  void _drawLetter() {
    final available = alphabet.split('').where((c) => !_excluded.contains(c)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas as letras foram sorteadas ou excluídas!')),
      );
      return;
    }

    if (localStorageService.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    final chosen = available[CryptoRandom.randInt(0, available.length - 1)];
    setState(() {
      _letter = chosen;
      _excluded.add(chosen);
    });
  }

  void _reset() {
    setState(() {
      _letter = null;
      _excluded.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorteio de Letras'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Reiniciar alfabeto', onPressed: _reset),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.petroleo,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(color: Color(0x240E3B43), blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _letter ?? '?',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 96,
                    fontWeight: FontWeight.w800,
                    color: _letter != null ? AppColors.brasa : Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Letras restantes: ${26 - _excluded.length}',
                style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSecondaryLight),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.brasa, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _drawLetter,
                  child: Text('Sortear letra', style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
