import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';
import '../core/storage/local_storage_service.dart';
import '../models/history_entry.dart';

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _opt1Controller = TextEditingController(text: 'Sim');
  final TextEditingController _opt2Controller = TextEditingController(text: 'Não');

  String? _result;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _opt1Controller.dispose();
    _opt2Controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _decide() {
    final opt1 = _opt1Controller.text.trim().isEmpty ? 'Sim' : _opt1Controller.text.trim();
    final opt2 = _opt2Controller.text.trim().isEmpty ? 'Não' : _opt2Controller.text.trim();

    if (localStorageService.hapticEnabled) {
      HapticFeedback.heavyImpact();
    }

    final chosen = CryptoRandom.randInt(0, 1) == 0 ? opt1 : opt2;

    setState(() {
      _result = chosen;
    });

    _animController.reset();
    _animController.forward();

    localStorageService.addHistoryEntry(HistoryEntry(
      type: 'decision',
      title: _questionController.text.trim().isEmpty ? 'Sim ou Não' : _questionController.text.trim(),
      summary: 'Decisão: $chosen',
      configSnapshot: {'opt1': opt1, 'opt2': opt2},
      result: chosen,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sim ou Não'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'PERGUNTA (OPCIONAL)',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(hintText: 'Ex: Devo pedir pizza hoje?'),
              ),
              const SizedBox(height: 20),

              // Options
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _opt1Controller,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.petroleo),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _opt2Controller,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.petroleo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Decision Orb / Result
              GestureDetector(
                onTap: _decide,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.petroleo,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x290E3B43),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _result == null
                      ? Text(
                          'Toque para\ndecidir',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.areia,
                          ),
                        )
                      : ScaleTransition(
                          scale: _scaleAnimation,
                          child: Text(
                            _result!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: _result == 'Sim' ? AppColors.brasa : Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brasa,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _decide,
                  child: Text(
                    'Decidir agora',
                    style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.petroleo, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Share.share('Decisão Sorte Feita: "$_result" para "${_questionController.text}"');
                  },
                  icon: const Icon(Icons.upload_rounded, size: 18, color: AppColors.petroleo),
                  label: Text('Compartilhar', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700, color: AppColors.petroleo)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

