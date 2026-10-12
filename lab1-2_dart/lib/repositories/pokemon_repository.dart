import 'dart:convert';
import 'dart:io';

import '../models/pokemon.dart';

class PokemonRepository {
  final File file;

  PokemonRepository({String path = 'data.json'}) : file = File(path);

  Future<List<Pokemon>> load() async {
    if (!await file.exists()) {
      return <Pokemon>[];
    }

    final content = await file.readAsString();

    if (content.trim().isEmpty) {
      return <Pokemon>[];
    }

    final decoded = jsonDecode(content);

    if (decoded is! List) {
      throw const FormatException('Файл data.json має містити список');
    }

    return decoded.map((item) {
      if (item is! Map) {
        throw const FormatException('Некоректний запис у data.json');
      }

      return Pokemon.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<void> save(List<Pokemon> pokemons) async {
    final encoder = const JsonEncoder.withIndent('  ');

    final content = encoder.convert(
      pokemons.map((pokemon) => pokemon.toJson()).toList(),
    );

    await file.writeAsString(content);
  }
}
