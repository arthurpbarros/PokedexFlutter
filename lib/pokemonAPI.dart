import 'package:http/http.dart';
import 'dart:convert';

class PokemonAPI {
  //Future<Tipo> nomeDaFuncao() async{}
  static Future<Map<String, dynamic>> getPokemon(int num) async {
    Uri pokemonUrl = Uri(
        scheme: 'https',
        host: 'pokeapi.co',
        path: '/api/v2/pokemon/' + num.toString());

    Response res = await get(pokemonUrl);
    var dados_pokemons = jsonDecode(res.body);

    var pokemon = {
      "name": dados_pokemons['name'].toUpperCase(),
      "id": dados_pokemons['id'],
      "image": dados_pokemons['sprites']['front_default'],
      "weight": (dados_pokemons['weight'] / 10.0) >= 2.0
          ? (dados_pokemons['weight'] / 10.0).toString() + " quilos"
          : (dados_pokemons['weight'] / 10.0).toString() + " quilo",
      "height": (dados_pokemons['height'] / 10.0) >= 2.0
          ? (dados_pokemons['height'] / 10.0).toString() + " metros"
          : (dados_pokemons['height'] / 10.0).toString() + " metro",
      "favorito": 0
    };

    return pokemon;
  }

  static Future<List> getAllPokemons(int begin, int end) async {
    var pokemons = [];

    for (int i = begin; i <= end; i++) {
      pokemons.add(await getPokemon(i));
    }

    return pokemons;
  }
}
