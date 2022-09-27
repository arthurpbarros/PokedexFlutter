import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'show_pokemon.dart';
import 'pokemonAPI.dart';
import 'models.dart';
import 'show_favoritos.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(false),
    );
  }
}

class MyHomePage extends StatefulWidget {
  bool vez;
  MyHomePage(this.vez);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> pok = [];
  int qnt = 30;

  //Recuperar informações dos pokemons da API e armazená-las no banco
  Future<List<dynamic>> init(bool existe) async {
    if (!existe) {
      List<dynamic> result = await PokemonAPI.getAllPokemons(1, qnt);
      await DBHelper.insertAll(result);
    }
    return await DBHelper.selectAll();
  }

  @override
  void initState() {
    bool vez = widget.vez;
    super.initState();

    DBHelper.databaseExist().then((existe) {
      init(existe!).then((recuperados) {
        setState(() {
          pok = recuperados;
        });
      });
    });
  }

  @override
  Widget build(BuildContext bc) {
    // print(pok);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Pokemons"),
          actions: [
            PopupMenuButton(
                // add icon, by default "3 dot" icon
                // icon: Icon(Icons.book)
                itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Favoritos"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("Sair"),
                )
              ];
            }, onSelected: (value) {
              if (value == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritosPage()),
                ).then((_) {
                  setState(() {});
                });
              } else {
                SystemNavigator.pop();
              }
            }),
          ],
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return GridView.count(
            dragStartBehavior: DragStartBehavior.down,
            mainAxisSpacing: orientation == Orientation.portrait ? 5 : 5,
            crossAxisSpacing: 5,
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            // Generate 100 widgets that display their index in the List.
            children: List.generate(qnt, (index) {
              // print(index);
              return Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    //const Color(0xffb5d3d9)
                    color: pok.isNotEmpty && pok[index]['favorito'] == 1
                        ? Color.fromARGB(255, 230, 231, 172)
                        : Color(0xffb5d3d9),
                    child: Column(
                      children: <Widget>[
                        pok.isEmpty
                            ? Align(
                                // alignment: Alignment.centerRight,
                                child: Image.asset('images/pokeball.png',
                                    width: 80, fit: BoxFit.fill))
                            : Image(
                                image: NetworkImage(
                                  pok[index]['image'],
                                ),
                                height: 85,
                                width: 85,
                              ),
                        pok.isNotEmpty
                            ? Text(
                                pok[index]['id'].toString() +
                                    " - " +
                                    pok[index]['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xff0a3c64)))
                            : SizedBox.shrink(),
                        pok.isNotEmpty
                            ? const SizedBox(height: 10)
                            : SizedBox.shrink(),
                        pok.isNotEmpty
                            ? Row(
                                children: <Widget>[
                                  FloatingActionButton.small(
                                    heroTag: "add$index",
                                    onPressed: () {
                                      bool result = true;
                                      DBHelper.updateFavoritoStatus(pok[index])
                                          .then((pokemon_updated) {
                                        setState(() {
                                          pok[index] = pokemon_updated;
                                        });
                                      });
                                      String texto = pok[index]['favorito'] == 1
                                          ? " foi salvo na Pokedex"
                                          : " foi removido da Pokedex";
                                      var snackBar = SnackBar(
                                          duration: Duration(seconds: 1),
                                          backgroundColor:
                                              pok[index]['favorito'] == 1
                                                  ? Color(0xffa6c9a7)
                                                  : Color(0xffbc3a3a),
                                          content: Text(
                                              (pok[index]['name']) + texto,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold)));
                                      // Step 3
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    },
                                    child: pok[index]['favorito'] == 1
                                        ? Icon(Icons.star)
                                        : Icon(Icons.star_border_outlined),
                                    backgroundColor: pok[index]['favorito'] == 1
                                        ? Colors.red
                                        : Color(0xffc6b200),
                                  ),
                                  const SizedBox(width: 10),
                                  FloatingActionButton.small(
                                    heroTag: "view$index",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Show_Pokemon(index)),
                                      );
                                    },
                                    child: const Icon(Icons.remove_red_eye),
                                    backgroundColor: Colors.blueGrey,
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              )
                            : const SizedBox.shrink()
                      ],
                      mainAxisAlignment: orientation == Orientation.portrait
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ))
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              );
            }),
          );
        }));
  }
}

// body: OrientationBuilder(
//   builder: (context, orientation) {
//     return GridView.count(
//       // Create a grid with 2 columns in portrait mode,
//       // or 3 columns in landscape mode.
//       crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
//     );
//   },
// ),
