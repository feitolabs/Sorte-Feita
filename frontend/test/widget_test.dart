import 'package:flutter_test/flutter_test.dart';
import 'package:sorte_feita/core/random/crypto_random.dart';
import 'package:sorte_feita/models/wheel_model.dart';
import 'package:sorte_feita/main.dart';

void main() {
  test('CryptoRandom randInt stays within range', () {
    for (int i = 0; i < 50; i++) {
      final val = CryptoRandom.randInt(5, 15);
      expect(val >= 5 && val <= 15, isTrue);
    }
  });

  test('CryptoRandom shuffle preserves elements', () {
    final list = ['A', 'B', 'C', 'D'];
    final shuffled = CryptoRandom.shuffle(list);
    expect(shuffled.length, equals(list.length));
    expect(shuffled.toSet(), equals(list.toSet()));
  });

  test('CryptoRandom weighted choice selects valid indices', () {
    final weights = [1.0, 2.0, 3.0];
    for (int i = 0; i < 30; i++) {
      final idx = CryptoRandom.weightedChoice(weights);
      expect(idx >= 0 && idx < weights.length, isTrue);
    }
  });

  test('WheelModel default food wheel has valid options', () {
    final wheel = WheelModel.defaultFoodWheel();
    expect(wheel.options.length, equals(6));
    expect(wheel.name, equals('O que comer hoje'));
  });

  testWidgets('SorteFeitaApp builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SorteFeitaApp());
    expect(find.byType(SorteFeitaApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
