import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';
import '../models/pokemon_type.dart';

class PokeApiService {
  final http.Client client;

  PokeApiService({http.Client? client}) : client = client ?? http.Client();

  Future<Pokemon> fetchPokemon(String query) async {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) {
      throw ArgumentError('Введіть ім’я або ID покемона');
    }

    final uri = Uri.https('pokeapi.co', '/api/v2/pokemon/$value');

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Помилка API: ${response.statusCode}. '
        'Перевірте ім’я або ID покемона.',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('API повернуло некоректний JSON');
    }

    final rawTypes = decoded['types'];

    if (rawTypes is! List) {
      throw const FormatException('У відповіді API немає списку типів');
    }

    final types = <PokemonType>[];

    for (final item in rawTypes) {
      if (item is Map && item['type'] is Map) {
        final typeData = Map<String, dynamic>.from(item['type'] as Map);

        types.add(
          PokemonType.fromJson({
            'name': typeData['name'],
            'slot': item['slot'],
          }),
        );
      }
    }

    return Pokemon(
      id: decoded['id'] as int,
      name: decoded['name'] as String,
      height: decoded['height'] as int,
      weight: decoded['weight'] as int,
      types: types,
    );
  }

  void close() {
    client.close();
  }
}
