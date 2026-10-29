/// Item ringan untuk daftar pokemon (endpoint: /pokemon).
class PokemonListItem {
  final int id;
  final String name;

  const PokemonListItem({required this.id, required this.name});

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    // contoh url: https://pokeapi.co/api/v2/pokemon/25/
    final segments = Uri.parse(url).pathSegments.where((s) => s.isNotEmpty);
    return PokemonListItem(
      id: int.parse(segments.last),
      name: json['name'] as String,
    );
  }

  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

class PokemonStat {
  final String name;
  final int value;
  const PokemonStat(this.name, this.value);
}

class PokemonAbilityRef {
  final String name;
  final String url;
  final bool isHidden;
  const PokemonAbilityRef(this.name, this.url, this.isHidden);
}

/// Detail pokemon (endpoint: /pokemon/{name}).
class PokemonDetail {
  final int id;
  final String name;
  final int height; // desimeter
  final int weight; // hektogram
  final List<String> types;
  final List<PokemonStat> stats;
  final List<PokemonAbilityRef> abilities;
  final String imageUrl;
  final String speciesUrl;
  final String? formUrl;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.imageUrl,
    required this.speciesUrl,
    required this.formUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final sprites = json['sprites'] as Map<String, dynamic>;
    final artwork = (sprites['other']?['official-artwork']
        as Map<String, dynamic>?)?['front_default'] as String?;
    final forms = json['forms'] as List<dynamic>;

    return PokemonDetail(
      id: id,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: (json['types'] as List<dynamic>)
          .map((t) => t['type']['name'] as String)
          .toList(),
      stats: (json['stats'] as List<dynamic>)
          .map((s) => PokemonStat(s['stat']['name'] as String,
              s['base_stat'] as int))
          .toList(),
      abilities: (json['abilities'] as List<dynamic>)
          .map((a) => PokemonAbilityRef(
                a['ability']['name'] as String,
                a['ability']['url'] as String,
                a['is_hidden'] as bool,
              ))
          .toList(),
      imageUrl: artwork ?? (sprites['front_default'] as String? ?? ''),
      speciesUrl: json['species']['url'] as String,
      formUrl: forms.isEmpty ? null : forms.first['url'] as String,
    );
  }
}

/// Data tambahan dari 4 endpoint lain:
/// /pokemon-species, /evolution-chain, /ability, /pokemon-form.
class PokemonExtras {
  final String genus; // contoh: "Mouse Pokémon"
  final String flavorText;
  final List<String> evolutionPaths; // contoh: "Pichu → Pikachu → Raichu"
  final Map<String, String> abilityEffects; // nama ability -> efek singkat
  final String formName;

  const PokemonExtras({
    required this.genus,
    required this.flavorText,
    required this.evolutionPaths,
    required this.abilityEffects,
    required this.formName,
  });
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String prettyName(String s) => s.split('-').map(capitalize).join(' ');
