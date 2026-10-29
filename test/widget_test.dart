// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mini_pokedex/animation_settings.dart';
import 'package:mini_pokedex/screens/animation_lab_screen.dart';

void main() {
  testWidgets('Animation Lab presents and toggles animation examples', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _AnimationLabTestApp());

    expect(find.text('Animation Lab'), findsOneWidget);
    expect(find.text('AnimatedContainer'), findsOneWidget);
    expect(find.text('AnimatedOpacity'), findsOneWidget);

    await tester.tap(find.text('Ubah ukuran & warna'));
    await tester.pump();
    await tester.tap(find.text('Sembunyikan Pokémon'));
    await tester.pump();

    final settings = tester
        .state<_AnimationLabTestAppState>(find.byType(_AnimationLabTestApp))
        .settings;
    expect(settings.containerExpanded, isTrue);
    expect(settings.pokemonVisible, isFalse);

    await tester.scrollUntilVisible(
      find.text('AnimatedCrossFade'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('AnimatedCrossFade'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('AnimationController & Hero'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('AnimationController & Hero'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Toggle Detail Pokémon'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('Jeda'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Jeda'));
    await tester.pump();
    expect(settings.controller.isAnimating, isFalse);

    await tester.scrollUntilVisible(
      find.text('Toggle Detail Pokémon'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Toggle Detail Pokémon'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Detail disembunyikan'), findsOneWidget);
    expect(settings.detailsVisible, isFalse);
  });
}

class _AnimationLabTestApp extends StatefulWidget {
  const _AnimationLabTestApp();

  @override
  State<_AnimationLabTestApp> createState() => _AnimationLabTestAppState();
}

class _AnimationLabTestAppState extends State<_AnimationLabTestApp>
    with SingleTickerProviderStateMixin {
  late final AnimationSettings settings = AnimationSettings(vsync: this);

  @override
  void dispose() {
    settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimationSettingsScope(
        settings: settings,
        child: const AnimationLabScreen(),
      ),
    );
  }
}
