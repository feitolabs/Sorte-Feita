import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorte_feita/core/storage/local_storage_service.dart';
import 'package:sorte_feita/screens/number_draw_screen.dart';
import 'package:sorte_feita/screens/pairs_screen.dart';
import 'package:sorte_feita/screens/tasks_screen.dart';

Future<void> open(WidgetTester t, Widget w) async {
  SharedPreferences.setMockInitialValues({});
  await localStorageService.init();
  t.view.physicalSize = const Size(900, 2400);
  t.view.devicePixelRatio = 2.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  testWidgets('number draw: invalid inputs show a message, never crash', (t) async {
    await open(t, const NumberDrawScreen());
    final fields = find.byType(TextField);
    // min, max, count are the first three fields
    await t.enterText(fields.at(0), '0');
    await t.enterText(fields.at(1), '999999999');
    await t.tap(find.textContaining('Sortear').first);
    await t.pump();
    expect(find.textContaining('no máximo 1.000.000'), findsOneWidget);

    ScaffoldMessenger.of(t.element(find.byType(Scaffold).first)).clearSnackBars();
    await t.pump();
    await t.enterText(fields.at(1), '10');
    await t.enterText(fields.at(2), '0');
    await t.tap(find.textContaining('Sortear').first);
    await t.pump();
    expect(find.textContaining('entre 1 e 1000'), findsOneWidget);

    ScaffoldMessenger.of(t.element(find.byType(Scaffold).first)).clearSnackBars();
    await t.pump();
    await t.enterText(fields.at(2), '');
    await t.tap(find.textContaining('Sortear').first);
    await t.pump();
    expect(find.textContaining('inteiros'), findsOneWidget);
    expect(tester(t), isNull);
  });

  testWidgets('number draw: valid draw stores history and shows result', (t) async {
    await open(t, const NumberDrawScreen());
    final fields = find.byType(TextField);
    await t.enterText(fields.at(0), '5');
    await t.enterText(fields.at(1), '5');
    await t.tap(find.textContaining('Sortear').first);
    await t.pumpAndSettle();
    expect(find.text('Resultado'), findsWidgets);
    expect(localStorageService.history.first.type, 'number_draw');
  });

  testWidgets('pairs screen renders and generates without exceptions', (t) async {
    await open(t, const PairsScreen());
    await t.tap(find.textContaining('Formar').first);
    await t.pumpAndSettle();
    expect(tester(t), isNull);
  });

  testWidgets('tasks screen assigns every task exactly once', (t) async {
    await open(t, const TasksScreen());
    await t.tap(find.textContaining('Distribuir').first);
    await t.pumpAndSettle();
    for (final task in ['Lavar a louça', 'Tirar o lixo', 'Varrer a sala', 'Comprar o pão']) {
      expect(find.textContaining(task), findsOneWidget);
    }
  });
}

Object? tester(WidgetTester t) => t.takeException();
