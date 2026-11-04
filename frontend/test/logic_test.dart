import 'package:flutter_test/flutter_test.dart';
import 'package:sorte_feita/core/logic/grouping.dart';
import 'package:sorte_feita/core/random/crypto_random.dart';

List<String> names(int n) => List.generate(n, (i) => 'p$i');

void main() {
  group('buildGroups', () {
    test('never loses or duplicates anyone, never makes groups of 4+', () {
      for (final size in [2, 3]) {
        for (var n = size; n <= 40; n++) {
          final g = buildGroups(names(n), size);
          expect(g.expand((e) => e).toSet().length, n, reason: 'size $size n $n');
          expect(g.expand((e) => e).length, n);
          for (final grp in g) {
            expect(grp.length, inInclusiveRange(2, 3), reason: 'size $size n $n');
          }
        }
      }
    });
    test('pairs with 7 -> 2 pairs + 1 trio', () {
      final g = buildGroups(names(7), 2).map((e) => e.length).toList()..sort();
      expect(g, [2, 2, 3]);
    });
    test('trios with 7 -> 1 trio + 2 pairs', () {
      final g = buildGroups(names(7), 3).map((e) => e.length).toList()..sort();
      expect(g, [2, 2, 3]);
    });
  });

  group('CryptoRandom', () {
    test('sampleWithoutReplacement returns unique elements', () {
      final r = CryptoRandom.sampleWithoutReplacement(List.generate(50, (i) => i), 50);
      expect(r.toSet().length, 50);
    });
    test('shuffle is a permutation', () {
      final l = List.generate(30, (i) => i);
      expect(CryptoRandom.shuffle(l)..sort(), l);
    });
    test('randInt stays in range and covers all values', () {
      final seen = <int>{};
      for (var i = 0; i < 2000; i++) {
        final v = CryptoRandom.randInt(-3, 3);
        expect(v, inInclusiveRange(-3, 3));
        seen.add(v);
      }
      expect(seen.length, 7);
    });
    test('weightedChoice rejects invalid weights', () {
      expect(() => CryptoRandom.weightedChoice([1, 0]), throwsArgumentError);
      expect(() => CryptoRandom.weightedChoice([]), throwsArgumentError);
    });
    test('weightedChoice follows weights roughly', () {
      var hits = 0;
      for (var i = 0; i < 6000; i++) {
        if (CryptoRandom.weightedChoice([1, 2]) == 1) hits++;
      }
      expect(hits / 6000, closeTo(2 / 3, 0.05));
    });
  });
}
