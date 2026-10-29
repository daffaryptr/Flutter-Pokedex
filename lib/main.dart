import 'package:flutter/material.dart';

import 'animation_settings.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() => runApp(const MiniPokedexApp());

class MiniPokedexApp extends StatefulWidget {
  const MiniPokedexApp({super.key});

  @override
  State<MiniPokedexApp> createState() => _MiniPokedexAppState();
}

class _MiniPokedexAppState extends State<MiniPokedexApp>
    with SingleTickerProviderStateMixin {
  late final AnimationSettings _animationSettings;

  @override
  void initState() {
    super.initState();
    _animationSettings = AnimationSettings(vsync: this);
  }

  @override
  void dispose() {
    _animationSettings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimationSettingsScope(
      settings: _animationSettings,
      child: MaterialApp(
        title: 'Pokédex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE5484D),
            surface: pageColor,
          ),
          scaffoldBackgroundColor: pageColor,
          textTheme: ThemeData.light().textTheme.apply(
            bodyColor: inkColor,
            displayColor: inkColor,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
