import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/random/crypto_random.dart';

/// Naipes: símbolo, nome em português e se é vermelho.
enum Suit {
  espadas('♠︎', 'Espadas', false),
  copas('♥︎', 'Copas', true),
  ouros('♦︎', 'Ouros', true),
  paus('♣︎', 'Paus', false);

  final String symbol;
  final String label;
  final bool red;
  const Suit(this.symbol, this.label, this.red);
}

class PlayingCard {
  /// 'A', '2'..'10', 'J', 'Q', 'K' ou 'JOKER'.
  final String rank;
  final Suit? suit;

  const PlayingCard(this.rank, this.suit);

  bool get isJoker => suit == null;

  String get name {
    if (isJoker) return 'Coringa';
    const names = {'A': 'Ás', 'J': 'Valete', 'Q': 'Dama', 'K': 'Rei'};
    return '${names[rank] ?? rank} de ${suit!.label}';
  }
}

/// Baralho completo: 52 cartas + 2 coringas.
List<PlayingCard> buildDeck({bool jokers = true}) {
  const ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
  return [
    for (final s in Suit.values)
      for (final r in ranks) PlayingCard(r, s),
    if (jokers) ...const [PlayingCard('JOKER', null), PlayingCard('JOKER', null)],
  ];
}

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late List<PlayingCard> _deck;
  PlayingCard? _drawnCard;
  final List<PlayingCard> _history = [];

  @override
  void initState() {
    super.initState();
    _deck = buildDeck();
  }

  void _drawCard() {
    if (_deck.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O baralho acabou! Embaralhe de novo.')),
      );
      return;
    }

    final idx = CryptoRandom.randInt(0, _deck.length - 1);
    setState(() {
      _drawnCard = _deck.removeAt(idx);
      _history.insert(0, _drawnCard!);
    });
  }

  void _reset() {
    setState(() {
      _deck = buildDeck();
      _drawnCard = null;
      _history.clear();
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Embaralhar de novo',
            onPressed: _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: _CardFace(
                  key: ValueKey(_drawnCard == null ? 'back' : '${_history.length}'),
                  card: _drawnCard,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _drawnCard?.name ?? 'Toque em "Tirar carta"',
                textAlign: TextAlign.center,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.petroleo,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cartas no baralho: ${_deck.length}',
                style: GoogleFonts.hankenGrotesk(fontSize: 14, color: AppColors.textSecondaryLight),
              ),
              if (_history.length > 1) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 28,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _history.length - 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final c = _history[i + 1];
                      return Center(
                        child: Text(
                          c.isJoker ? 'C★' : '${c.rank}${c.suit!.symbol}',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: c.isJoker || c.suit!.red ? AppColors.brasa : AppColors.petroleo,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brasa,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _drawCard,
                  child: Text(
                    'Tirar carta',
                    style: GoogleFonts.bricolageGrotesque(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desenho da carta: frente (valor + naipe nos cantos e naipe grande no centro)
/// ou verso (quando ainda não saiu nenhuma carta).
class _CardFace extends StatelessWidget {
  final PlayingCard? card;
  const _CardFace({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final c = card;
    return Semantics(
      label: c == null ? 'Baralho virado para baixo' : c.name,
      child: Container(
        width: 220,
        height: 310,
        decoration: BoxDecoration(
          color: c == null ? AppColors.petroleo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.petroleo, width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: c == null ? _back() : _front(c),
      ),
    );
  }

  Widget _back() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.nevoa, width: 2),
          color: AppColors.azulRio,
        ),
        child: const Center(
          child: Icon(Icons.casino_rounded, size: 72, color: AppColors.areia),
        ),
      ),
    );
  }

  Widget _front(PlayingCard c) {
    if (c.isJoker) {
      return Stack(
        children: [
          Positioned(top: 12, left: 14, child: _corner('★', 'C', AppColors.brasa)),
          const Center(child: Icon(Icons.star_rounded, size: 110, color: AppColors.brasa)),
          Positioned(
            bottom: 12,
            right: 14,
            child: Transform.rotate(angle: 3.14159, child: _corner('★', 'C', AppColors.brasa)),
          ),
        ],
      );
    }
    final color = c.suit!.red ? AppColors.brasa : AppColors.petroleo;
    return Stack(
      children: [
        Positioned(top: 12, left: 14, child: _corner(c.suit!.symbol, c.rank, color)),
        Center(
          child: Text(
            c.suit!.symbol,
            style: TextStyle(fontSize: 120, color: color, height: 1),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 14,
          child: Transform.rotate(angle: 3.14159, child: _corner(c.suit!.symbol, c.rank, color)),
        ),
      ],
    );
  }

  Widget _corner(String symbol, String rank, Color color) {
    return Column(
      children: [
        Text(
          rank,
          style: GoogleFonts.bricolageGrotesque(fontSize: 30, fontWeight: FontWeight.w800, color: color, height: 1),
        ),
        Text(symbol, style: TextStyle(fontSize: 26, color: color, height: 1.1)),
      ],
    );
  }
}
