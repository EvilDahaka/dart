import 'dart:io';

import 'package:lab1_2_dart/models/pokemon.dart';
import 'package:lab1_2_dart/repositories/pokemon_repository.dart';
import 'package:lab1_2_dart/services/poke_api_service.dart';

Future<void> main() async {
  final repository = PokemonRepository();
  final api = PokeApiService();

  List<Pokemon> pokemons;

  try {
    pokemons = await repository.load();
  } catch (error) {
    print('Помилка читання даних: $error');
    pokemons = <Pokemon>[];
  }

  var running = true;

  while (running) {
    print('\nКОЛЕКЦІЯ ПОКЕМОНІВ');
    print('1. Показати список');
    print('2. Додати покемона з API');
    print('3. Видалити запис');
    print('4. Пошук');
    print('5. Сортування за назвою');
    print('6. Змінити статус');
    print('0. Вихід');

    stdout.write('Ваш вибір: ');
    final choice = stdin.readLineSync()?.trim();

    try {
      switch (choice) {
        case '1':
          if (pokemons.isEmpty) {
            print('Колекція порожня');
          } else {
            for (final pokemon in pokemons) {
              print(pokemon);
            }
          }
          break;

        case '2':
          stdout.write('Ім’я або ID покемона: ');
          final query = stdin.readLineSync() ?? '';

          final pokemon = await api.fetchPokemon(query);

          if (pokemons.any((p) => p.id == pokemon.id)) {
            print('Цей покемон уже є в колекції.');
          } else {
            pokemons.add(pokemon);
            await repository.save(pokemons);
            print('Покемона додано: $pokemon');
          }
          break;

        case '3':
          if (pokemons.isEmpty) {
            print('Колекція порожня.');
            break;
          }

          for (var i = 0; i < pokemons.length; i++) {
            print('${i + 1}. ${pokemons[i].name}');
          }

          stdout.write('Номер запису для видалення: ');
          final index = int.tryParse(stdin.readLineSync() ?? '');

          if (index == null || index < 1 || index > pokemons.length) {
            print('Некоректний номер.');
          } else {
            final removed = pokemons.removeAt(index - 1);
            await repository.save(pokemons);
            print('Видалено: ${removed.name}');
          }
          break;

        case '4':
          stdout.write('Ім’я або тип для пошуку: ');
          final query = (stdin.readLineSync() ?? '').trim().toLowerCase();

          final found = pokemons.where((pokemon) {
            return pokemon.name.toLowerCase().contains(query) ||
                pokemon.types.any(
                  (type) => type.name.toLowerCase().contains(query),
                );
          });

          if (found.isEmpty) {
            print('Нічого не знайдено');
          }

          for (final pokemon in found) {
            print(pokemon);
          }
          break;

        case '5':
          pokemons.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

          await repository.save(pokemons);
          print('Колекцію відсортовано та збережено');
          break;

        case '6':
          if (pokemons.isEmpty) {
            print('Колекція порожня.');
            break;
          }

          for (var i = 0; i < pokemons.length; i++) {
            print(
              '${i + 1}. ${pokemons[i].name} '
              '— ${pokemons[i].status.name}',
            );
          }

          stdout.write('Номер покемона: ');
          final index = int.tryParse(stdin.readLineSync() ?? '');

          if (index == null || index < 1 || index > pokemons.length) {
            print('Некоректний номер');
            break;
          }

          print('Статуси: planned, caught, favorite');
          stdout.write('Новий статус: ');
          final statusName = (stdin.readLineSync() ?? '').trim().toLowerCase();

          final matches = PokemonStatus.values.where(
            (status) => status.name == statusName,
          );

          if (matches.isEmpty) {
            print('Невідомий статус.');
          } else {
            pokemons[index - 1].status = matches.first;
            await repository.save(pokemons);
            print('Статус змінено');
          }
          break;

        case '0':
          running = false;
          break;

        default:
          print('Введіть номер пункту з меню');
      }
    } catch (error) {
      print('Не вдалося виконати операцію: $error');
    }
  }

  api.close();
  print('Роботу завершено.');
}
