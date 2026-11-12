import 'package:flutter_test/flutter_test.dart';
import 'package:sorte_feita/screens/pairs_screen.dart';

List<String> people(int n) => List.generate(n, (i) => 'P$i');
List<int> sizes(int n, int g) =>
    groupParticipants(people(n), g).map((x) => x.length).toList();

void main() {
  test('duplas: sobra de 1 vira trio', () {
    expect(sizes(2, 2), [2]);
    expect(sizes(5, 2), [2, 3]);
    expect(sizes(6, 2), [2, 2, 2]);
  });

  test('trios: sobras nunca geram grupo maior que 3', () {
    expect(sizes(8, 3), [3, 3, 2]);
    expect(sizes(7, 3), [3, 2, 2]);
    expect(sizes(9, 3), [3, 3, 3]);
    expect(sizes(4, 3), [2, 2]);
  });

  test('todos os participantes entram uma vez', () {
    for (final g in [2, 3]) {
      for (var n = g; n <= 30; n++) {
        final flat = groupParticipants(people(n), g).expand((x) => x).toList();
        expect(flat.length, n);
        expect(flat.toSet().length, n);
      }
    }
  });
}
