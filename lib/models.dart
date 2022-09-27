import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';

class PokemonModel {
  String name = "", image = "", height = "", weight = "";
  int id = 1, favorito = 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'height': height,
      'weight': weight,
      'favorito': favorito
    };
  }

  PokemonModel.fromMap(Map<String, dynamic> pokemon) {
    id = pokemon['id'];
    name = pokemon['name'];
    image = pokemon['image'];
    height = pokemon['height'];
    weight = pokemon['weight'];
    favorito = pokemon['favorito'];
  }
}

class DBHelper {
  static const tabela = "pokemons";
  static Future<Database> database() async {
    // var dbpath = await ;
    String dbpath = await getDatabasesPath();
    String path = join(dbpath, "pokemons.db");
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      // Run the CREATE TABLE statement on the database.
      await db.execute(
          'CREATE TABLE IF NOT EXISTS pokemons (id INTEGER PRIMARY KEY, name TEXT, image TEXT, height TEXT, weight TEXT, favorito INTEGER)');
    });
  }

  static Future<List> selectAll() async {
    List<dynamic> pokemons = [];
    final db = await DBHelper.database();
    pokemons =
        (await db.query(tabela)).map((pokemon) => Map.of(pokemon)).toList();
    // print("pokemons $pokemons");
    db.close();
    return pokemons;
    // pokemons = await db.rawQuery("SELECT * FROM $tabela");
  }

  static Future<List> selectFavorites() async {
    List<dynamic> pokemons = [];
    final db = await DBHelper.database();
    pokemons = (await db.query(tabela,
            columns: null, where: 'favorito = ?', whereArgs: [1]))
        .map((pokemon) => Map.of(pokemon))
        .toList();
    // print("pokemons $pokemons");
    await db.close();
    return pokemons;
    // pokemons = await db.rawQuery("SELECT * FROM $tabela");
  }

  static Future<void> insertAll(List<dynamic> pok) async {
    final db = await DBHelper.database();
    for (var pokemon in pok) {
      PokemonModel pk = PokemonModel.fromMap(pokemon);
      await db.insert(tabela, pk.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await db.close();
  }

  static Future<Map<String, dynamic>> updateFavoritoStatus(
      Map<String, dynamic> pok) async {
    pok['favorito'] = pok['favorito'] == 0 ? 1 : 0;
    final db = await DBHelper.database();
    int update =
        await db.update(tabela, pok, where: 'id = ?', whereArgs: [pok['id']]);
    // print("foi atualizado $update");
    await db.close();
    return pok;
  }

  static Future<bool?> databaseExist() async {
    final dbpath = await getDatabasesPath();
    // final dbpath = (await getApplicationDocumentsDirectory()).path;
    final pokemondb_path = join(dbpath, "pokemons.db");
    return await databaseExists(pokemondb_path);
  }
}
