import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokeApiService {
  static const String _base = 'https://pokeapi.co/api/v2';

  Future<Map<String, dynamic>> _getJson(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Request gagal (${res.statusCode}) untuk $url');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Endpoint 1 (wajib): daftar pokemon.
  /// PokeAPI tidak punya endpoint search, jadi seluruh nama diambil sekali
  /// lalu pencarian dilakukan secara lokal.
  Future<List<PokemonListItem>> fetchPokemonList() async {
    final data = await _getJson('$_base/pokemon?limit=50');
    return (data['results'] as List<dynamic>)
        .map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Endpoint 2 (wajib): detail pokemon.
  Future<PokemonDetail> fetchPokemonDetail(String nameOrId) async {
    final data = await _getJson('$_base/pokemon/$nameOrId');
    return PokemonDetail.fromJson(data);
  }

  /// Endpoint tambahan (3+): species, evolution-chain, ability, pokemon-form.
  Future<PokemonExtras> fetchExtras(PokemonDetail p) async {
    // Species dulu, karena evolution-chain URL ada di dalamnya.
    final speciesFuture = _getJson(p.speciesUrl); // /pokemon-species/{id}
    final formFuture = p.formUrl == null
        ? Future<Map<String, dynamic>?>.value(null)
        : _getJson(p.formUrl!).then<Map<String, dynamic>?>((v) => v); // /pokemon-form/{id}
    final abilityFutures = p.abilities
        .map((a) => _getJson(a.url)) // /ability/{id}
        .toList();

    final species = await speciesFuture;
    final evolution =
        await _getJson(species['evolution_chain']['url'] as String);
    final form = await formFuture;
    final abilityJsons = await Future.wait(abilityFutures);

    // genus bahasa Inggris
    final genera = species['genera'] as List<dynamic>;
    final genus = genera.cast<Map<String, dynamic>>().firstWhere(
          (g) => g['language']['name'] == 'en',
          orElse: () => {'genus': '-'},
        )['genus'] as String;

    // deskripsi bahasa Inggris
    final entries = species['flavor_text_entries'] as List<dynamic>;
    final flavor = entries.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['language']['name'] == 'en',
          orElse: () => {'flavor_text': '-'},
        )['flavor_text'] as String;

    // efek ability
    final effects = <String, String>{};
    for (var i = 0; i < p.abilities.length; i++) {
      final effectEntries =
          abilityJsons[i]['effect_entries'] as List<dynamic>;
      final en = effectEntries.cast<Map<String, dynamic>>().where(
            (e) => e['language']['name'] == 'en',
          );
      effects[p.abilities[i].name] =
          en.isEmpty ? '-' : en.first['short_effect'] as String;
    }

    return PokemonExtras(
      genus: genus,
      flavorText: flavor.replaceAll(RegExp(r'[\n\f]'), ' '),
      evolutionPaths: _evolutionPaths(evolution['chain'] as Map<String, dynamic>),
      abilityEffects: effects,
      formName: form == null ? '-' : (form['form_name'] as String).isEmpty
          ? 'default'
          : form['form_name'] as String,
    );
  }

  /// Mengubah pohon evolusi menjadi daftar jalur, mis. "Pichu → Pikachu → Raichu".
  List<String> _evolutionPaths(Map<String, dynamic> node,
      [List<String> prefix = const []]) {
    final current = [...prefix, prettyName(node['species']['name'] as String)];
    final next = node['evolves_to'] as List<dynamic>;
    if (next.isEmpty) return [current.join(' → ')];
    return next
        .expand((n) => _evolutionPaths(n as Map<String, dynamic>, current))
        .toList();
  }
}
