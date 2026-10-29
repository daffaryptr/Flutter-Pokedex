import 'package:flutter/material.dart';

import '../animation_settings.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import '../theme.dart';

class DetailScreen extends StatefulWidget {
  final PokemonListItem item;
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _service = PokeApiService();
  late Future<PokemonDetail> _detailFuture;
  Future<PokemonExtras>? _extrasFuture;
  Color? _typeColor; // diketahui setelah detail dimuat

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.fetchPokemonDetail(widget.item.name).then((d) {
      // extras diminta setelah detail tersedia (butuh URL species/form/ability)
      if (mounted) {
        final extras = _service.fetchExtras(d);
        setState(() {
          _extrasFuture = extras;
          _typeColor = typeColors[d.types.first];
        });
      }
      return d;
    });
  }

  Color get _color => _typeColor ?? deepen(tintFor(widget.item.id), 0.25);

  @override
  Widget build(BuildContext context) {
    final settings = AnimationSettingsScope.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: Color.lerp(
          _color, Colors.white, settings.containerExpanded ? 0.1 : 0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<PokemonDetail>(
          future: _detailFuture,
          builder: (context, snap) {
            final detail = snap.data;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header(detail)),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: pageColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(36)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                    child: _sheetContent(snap, detail),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(PokemonDetail? d) {
    final item = widget.item;
    final settings = AnimationSettingsScope.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;
    final artworkHeight = isDesktop
        ? (settings.containerExpanded ? 210.0 : 170.0)
        : (settings.containerExpanded ? 270.0 : 220.0);
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: 70,
            child: Icon(Icons.catching_pokemon,
                size: 280, color: Colors.white.withAlpha(40)),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      '#${item.id.toString().padLeft(4, '0')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    prettyName(item.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 34,
                    child: d == null
                        ? null
                        : Wrap(
                            spacing: 8,
                            children: d.types
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(60),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(capitalize(t),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700)),
                                    ))
                                .toList(),
                          ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: settings.pokemonVisible ? 1 : 0,
                duration: const Duration(milliseconds: 350),
                child: Hero(
                  tag: 'pokemon-${item.id}',
                  child: AnimatedBuilder(
                    animation: settings.controller,
                    builder: (context, child) => Transform.scale(
                      scale: (settings.containerExpanded ? 1.05 : 0.9) +
                          (settings.controller.value * 0.12),
                      child: child,
                    ),
                    child: Image.network(
                      item.artworkUrl,
                      height: artworkHeight,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => SizedBox(
                        height: artworkHeight,
                        child: const Icon(Icons.catching_pokemon,
                            size: 120, color: Colors.white54),
                      ),
                      loadingBuilder: (c, child, progress) => progress == null
                          ? child
                          : SizedBox(
                              height: artworkHeight,
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white)),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sheetContent(AsyncSnapshot<PokemonDetail> snap, PokemonDetail? d) {
    if (snap.connectionState != ConnectionState.done) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Align(
          alignment: Alignment.topCenter,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }
    if (snap.hasError || d == null) {
      return Text(
        'Detail tidak bisa dimuat.\n${snap.error}',
        style: const TextStyle(color: mutedColor),
      );
    }
    final settings = AnimationSettingsScope.of(context);
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 350),
      crossFadeState: settings.detailsVisible
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Text(
            'Detail Pokémon disembunyikan.\nAktifkan kembali dari Animation Lab.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedColor),
          ),
        ),
      ),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _measureTile(
                      'Height',
                      '${(d.height / 10).toStringAsFixed(1)} m',
                      '${d.height}')),
              const SizedBox(width: 12),
              Expanded(
                  child: _measureTile(
                      'Weight',
                      '${(d.weight / 10).toStringAsFixed(1)} kg',
                      '${d.weight}')),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Base stats'),
          ...d.stats.map(_statBar),
          const SizedBox(height: 28),
          _extrasSection(d),
        ],
      ),
    );
  }

  Widget _measureTile(String label, String value, String raw) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: mutedColor)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text('nilai API: $raw',
              style: const TextStyle(color: mutedColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _extrasSection(PokemonDetail p) {
    final future = _extrasFuture;
    if (future == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<PokemonExtras>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
          );
        }
        if (snap.hasError) {
          return Text('Data tambahan tidak bisa dimuat.\n${snap.error}',
              style: const TextStyle(color: mutedColor));
        }
        final x = snap.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('About'),
            Text(x.genus,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Form: ${x.formName}',
                style: const TextStyle(color: mutedColor)),
            const SizedBox(height: 10),
            Text(x.flavorText, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 28),
            _sectionTitle('Abilities'),
            ...p.abilities
                .map((a) => _abilityTile(a, x.abilityEffects[a.name])),
            const SizedBox(height: 16),
            _sectionTitle('Evolution'),
            ...x.evolutionPaths.map(_evolutionRow),
          ],
        );
      },
    );
  }

  Widget _abilityTile(PokemonAbilityRef a, String? effect) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(prettyName(a.name),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              if (a.isHidden) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _color.withAlpha(35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Hidden',
                      style: TextStyle(
                          color: deepen(_color, 0.2),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(effect ?? '-',
              style: const TextStyle(color: mutedColor, height: 1.4)),
        ],
      ),
    );
  }

  Widget _evolutionRow(String path) {
    final names = path.split(' → ');
    final current = prettyName(widget.item.name).toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 8,
        children: [
          for (var i = 0; i < names.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: current.startsWith(names[i].toLowerCase())
                    ? _color
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                names[i],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: current.startsWith(names[i].toLowerCase())
                      ? Colors.white
                      : inkColor,
                ),
              ),
            ),
            if (i < names.length - 1)
              const Icon(Icons.chevron_right_rounded, color: mutedColor),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3)),
      );

  Widget _statBar(PokemonStat s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 118,
              child: Text(prettyName(s.name),
                  style: const TextStyle(color: mutedColor)),
            ),
            SizedBox(
              width: 38,
              child: Text('${s.value}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (s.value / 255).clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    color: _color,
                    backgroundColor: _color.withAlpha(35),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
