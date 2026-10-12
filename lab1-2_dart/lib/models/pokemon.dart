import 'pokemon_type.dart';
import 'json_model.dart';

enum PokemonStatus { planned, caught, favorite }

class Pokemon implements JsonModel {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonType> types;
  PokemonStatus status;

  Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    this.status = PokemonStatus.planned,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['types'];

    if (json['id'] is! int ||
        json['name'] is! String ||
        json['height'] is! int ||
        json['weight'] is! int ||
        rawTypes is! List) {
      throw const FormatException('Некоректні дані покемона.');
    }

    final types = rawTypes.map((item) {
      if (item is Map) {
        return PokemonType.fromJson(Map<String, dynamic>.from(item));
      }

      if (item is String) {
        return PokemonType(name: item);
      }

      throw const FormatException('Некоректний тип покемона.');
    }).toList();

    final statusName = json['status'] as String? ?? 'planned';

    final status = PokemonStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => PokemonStatus.planned,
    );

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: types,
      status: status,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'types': types.map((type) => type.toJson()).toList(),
      'status': status.name,
    };
  }

  @override
  String toString() {
    final typeNames = types.isEmpty
        ? 'невідомо'
        : types.map((type) => type.name).join(', ');

    return '#$id $name | Тип: $typeNames | '
        'Зріст: $height | Вага: $weight | Статус: ${status.name}';
  }
}
