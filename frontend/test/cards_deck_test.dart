import 'package:flutter_test/flutter_test.dart';
import 'package:sorte_feita/screens/cards_screen.dart';

void main() {
  test('baralho completo tem 52 cartas + 2 coringas, sem repetição', () {
    final deck = buildDeck();
    expect(deck.length, 54);
    expect(deck.where((c) => c.isJoker).length, 2);
    final names = deck.where((c) => !c.isJoker).map((c) => c.name).toSet();
    expect(names.length, 52);
    expect(buildDeck(jokers: false).length, 52);
  });

  test('nomes em português', () {
    expect(const PlayingCard('A', Suit.copas).name, 'Ás de Copas');
    expect(const PlayingCard('K', Suit.espadas).name, 'Rei de Espadas');
    expect(const PlayingCard('10', Suit.ouros).name, '10 de Ouros');
  });
}
