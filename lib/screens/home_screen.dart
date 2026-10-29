import 'package:flutter/material.dart';

import '../animation_settings.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import '../theme.dart';
import 'animation_lab_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PokeApiService();
  final _searchController = TextEditingController();

  List<PokemonListItem> _all = [];
  List<PokemonListItem> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchPokemonList();
      if (!mounted) return;
      setState(() {
        _all = list;
        _filtered = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _search(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
              .where((p) => p.name.contains(q) || p.id.toString() == q)
              .toList();
    });
  }

  void _openDetail(PokemonListItem p) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => DetailScreen(item: p),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 14, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pokédex',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AnimationLabScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.animation_rounded, size: 19),
                    label: const Text('Animation Lab'),
                    style: TextButton.styleFrom(
                      foregroundColor: inkColor,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                _loading || _error != null
                    ? 'Mengambil data dari PokéAPI'
                    : '${_all.length} pokemon, cari atau pilih satu',
                style: const TextStyle(color: mutedColor, fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _searchField(),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: _search,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Cari nama atau ID, mis. pikachu atau 25',
        hintStyle: const TextStyle(color: mutedColor, fontSize: 15),
        prefixIcon: const Icon(Icons.search_rounded, color: mutedColor),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, color: mutedColor),
                onPressed: () {
                  _searchController.clear();
                  _search('');
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: inkColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 52, color: mutedColor),
              const SizedBox(height: 12),
              const Text('Data tidak bisa dimuat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: mutedColor)),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Muat ulang')),
            ],
          ),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Tidak ada pokemon dengan nama atau ID itu. Coba ejaan lain.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedColor, fontSize: 16),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, i) {
        final p = _filtered[i];
        return _PokemonCard(item: p, onTap: () => _openDetail(p));
      },
    );
  }
}

class _PokemonCard extends StatelessWidget {
  final PokemonListItem item;
  final VoidCallback onTap;
  const _PokemonCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final settings = AnimationSettingsScope.of(context);
    final tint = tintFor(item.id);
    final deep = deepen(tint);
    final expanded = settings.containerExpanded;
    final radius = expanded ? 38.0 : 28.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: Color.lerp(tint, Colors.white, expanded ? 0.18 : 0),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: -28,
                bottom: -28,
                child: Icon(Icons.catching_pokemon,
                    size: 130, color: Colors.white.withAlpha(110)),
              ),
              Positioned(
                right: expanded ? 2 : 8,
                top: expanded ? 8 : 14,
                left: expanded ? 2 : 8,
                bottom: 40,
                child: AnimatedOpacity(
                  opacity: settings.pokemonVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 350),
                  child: Hero(
                    tag: 'pokemon-${item.id}',
                    child: Image.network(
                      item.artworkUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.catching_pokemon,
                          size: 64, color: deep.withAlpha(120)),
                      loadingBuilder: (c, child, progress) => progress == null
                          ? child
                          : Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: deep),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 350),
                  crossFadeState: settings.detailsVisible
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: _pokemonName(deep),
                  secondChild: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _pokemonName(deep)),
                      Text(
                        item.id.toString().padLeft(3, '0'),
                        style: TextStyle(
                            color: deep.withAlpha(170),
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pokemonName(Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        prettyName(item.name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
