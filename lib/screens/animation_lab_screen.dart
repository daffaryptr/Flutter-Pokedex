import 'package:flutter/material.dart';

import '../animation_settings.dart';
import '../models/pokemon.dart';
import '../theme.dart';
import 'detail_screen.dart';

class AnimationLabScreen extends StatelessWidget {
  const AnimationLabScreen({super.key});

  static const _background = pageColor;
  static const _cardColor = Colors.white;
  static const _accent = Color(0xFFE5484D);

  void _openHeroPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DetailScreen(
          item: PokemonListItem(id: 25, name: 'pikachu'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AnimationSettingsScope.of(context);
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: inkColor,
        elevation: 0,
        title: const Text('Animation Lab'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _labCard(
            title: 'AnimatedContainer',
            description: 'Ubah ukuran dan warna dengan transisi halus.',
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  width: settings.containerExpanded ? 116 : 88,
                  height: settings.containerExpanded ? 116 : 88,
                  decoration: BoxDecoration(
                    color: settings.containerExpanded
                        ? const Color(0xFFFF8A65)
                        : const Color(0xFFE5484D),
                    borderRadius: BorderRadius.circular(
                      settings.containerExpanded ? 32 : 20,
                    ),
                  ),
                  child: Image.network(
                    const PokemonListItem(id: 25, name: 'pikachu').artworkUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.catching_pokemon_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _actionButton(
                  label: 'Ubah ukuran & warna',
                  onPressed: settings.toggleContainer,
                ),
              ],
            ),
          ),
          _labCard(
            title: 'AnimatedOpacity',
            description: 'Tampilkan atau sembunyikan Pokémon.',
            child: Column(
              children: [
                AnimatedOpacity(
                  opacity: settings.pokemonVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 350),
                  child: Image.network(
                    const PokemonListItem(id: 25, name: 'pikachu').artworkUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.catching_pokemon_rounded,
                      color: Color(0xFFFF5B67),
                      size: 52,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _actionButton(
                  label: settings.pokemonVisible
                      ? 'Sembunyikan Pokémon'
                      : 'Tampilkan Pokémon',
                  onPressed: settings.togglePokemonVisibility,
                ),
              ],
            ),
          ),
          _labCard(
            title: 'AnimatedCrossFade',
            description: 'Ganti tampilan detail dengan crossfade.',
            child: Column(
              children: [
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 350),
                  crossFadeState: settings.detailsVisible
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(
                    height: 32,
                    child: Center(
                      child: Text(
                        'Detail disembunyikan',
                        style: TextStyle(color: mutedColor),
                      ),
                    ),
                  ),
                  secondChild: const SizedBox(
                    height: 32,
                    child: Center(
                      child: Text(
                        'Detail Pokémon ditampilkan',
                        style: TextStyle(
                          color: inkColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _actionButton(
                  label: 'Toggle Detail Pokémon',
                  onPressed: settings.toggleDetails,
                ),
              ],
            ),
          ),
          _labCard(
            title: 'AnimationController & Hero',
            description:
                'Pokémon diam di sini. Jeda atau lanjutkan gerakannya di halaman detail.',
            child: Column(
              children: [
                Hero(
                  tag: 'pokemon-25',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openHeroPage(context),
                      borderRadius: BorderRadius.circular(32),
                      child: Image.network(
                        const PokemonListItem(id: 25, name: 'pikachu')
                            .artworkUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.catching_pokemon_rounded,
                          color: _accent,
                          size: 58,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: settings.toggleAnimation,
                      icon: Icon(
                        settings.controller.isAnimating
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 18,
                      ),
                      label: Text(
                        settings.controller.isAnimating ? 'Jeda' : 'Lanjut',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: inkColor,
                        side: BorderSide(color: inkColor.withAlpha(100)),
                      ),
                    ),
                    _actionButton(
                      label: 'Buka halaman Hero',
                      onPressed: () => _openHeroPage(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: inkColor.withAlpha(12)),
        boxShadow: [
          BoxShadow(
            color: inkColor.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: inkColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
      child: Text(label),
    );
  }
}
