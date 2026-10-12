import 'json_model.dart';

class PokemonType implements JsonModel {
  final String name;
  final int? slot;

  const PokemonType({required this.name, this.slot});

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    final name = json['name'];

    if (name is! String) {
      throw const FormatException('Некоректна назва типу');
    }

    return PokemonType(
      name: name,
      slot: json['slot'] is int ? json['slot'] as int : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'name': name, 'slot': slot};
  }

  @override
  String toString() => name;
}
