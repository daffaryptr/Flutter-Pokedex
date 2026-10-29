import 'package:flutter/material.dart';

class AnimationSettings extends ChangeNotifier {
  AnimationSettings({required TickerProvider vsync}) {
    controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  late final AnimationController controller;
  bool containerExpanded = false;
  bool pokemonVisible = true;
  bool detailsVisible = true;

  void toggleContainer() {
    containerExpanded = !containerExpanded;
    notifyListeners();
  }

  void togglePokemonVisibility() {
    pokemonVisible = !pokemonVisible;
    notifyListeners();
  }

  void toggleDetails() {
    detailsVisible = !detailsVisible;
    notifyListeners();
  }

  void toggleAnimation() {
    if (controller.isAnimating) {
      controller.stop();
    } else {
      controller.repeat(reverse: true);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class AnimationSettingsScope extends InheritedNotifier<AnimationSettings> {
  const AnimationSettingsScope({
    super.key,
    required AnimationSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AnimationSettings of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AnimationSettingsScope>();
    assert(scope != null, 'AnimationSettingsScope is missing from the app.');
    return scope!.notifier!;
  }
}
