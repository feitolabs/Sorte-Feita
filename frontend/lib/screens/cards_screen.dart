import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  static const List<String> defaultDeck = [
    'Ás de Copas', 'Rei de Espadas', 'Dama de Ouros', 'Valete de Paus',
    '10 de Copas', '7 de Ouros', 'Ás de Espadas', 'Coringa'
  ];

  late List<String> _deck;
  String? _drawnCard;

  @override
  void initState() {
    super.initState();
    _deck = List.from(defaultDeck);
  }

  void _drawCard() {
    if (_deck.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O baralho acabou! Reinicie as cartas.')),
      );
      return;
    }

    final idx = CryptoRandom.randInt(0, _deck.length - 1);
    setState(() {
      _drawnCard = _deck.removeAt(idx);
    });
  }

  void _reset() {
    setState(() {
      _deck = List.from(defaultDeck);
      _drawnCard = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Embaralhar de novo', onPressed: _reset),
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
                width: 220,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.petroleo, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.style_rounded, size: 56, color: AppColors.azulRio),
                    const SizedBox(height: 16),
                    Text(
                      _drawnCard ?? 'Toque para tirar uma carta',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.petroleo,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cartas no baralho: ${_deck.length}',
                style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSecondaryLight),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.brasa, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _drawCard,
                  child: Text('Tirar carta', style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

