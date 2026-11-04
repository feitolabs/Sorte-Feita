import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  static const List<String> challengesList = [
    'Imite um animal sem fazer sons até alguém adivinhar!',
    'Conte uma piada rápida em menos de 30 segundos.',
    'Cante o refrão de uma música inventando a letra na hora!',
    'Fale 5 palavras que comecem com a letra "S" sem gaguejar.',
    'Faça uma mímica de um filme famoso!',
    'Desenhe um objeto com os olhos fechados.',
    'Diga o alfabeto de trás para frente até a letra T.',
    'Elogie a pessoa à sua direita com 3 palavras criativas.',
  ];

  String _current = challengesList[0];

  void _nextChallenge() {
    final idx = CryptoRandom.randInt(0, challengesList.length - 1);
    setState(() {
      _current = challengesList[idx];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desafios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderLight, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.star_rounded, size: 48, color: AppColors.brasa),
                    const SizedBox(height: 16),
                    Text(
                      _current,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.petroleo,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.brasa, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _nextChallenge,
                  child: Text('Próximo desafio', style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

