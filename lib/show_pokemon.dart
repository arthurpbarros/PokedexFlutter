import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/show_favoritos.dart';
import 'pokemonAPI.dart';
import 'main.dart';
import 'models.dart';

class Show_Pokemon extends StatefulWidget {
  int index;

  Show_Pokemon(@required this.index);

  State<StatefulWidget> createState() => _Show_Pokemon_State();
}

class _Show_Pokemon_State extends State<Show_Pokemon> {
  List<dynamic> pokemon = [];
  int index = 0;

  _Show_Pokemon_State() {
    DBHelper.selectAll().then((lista) {
      setState(() {
        pokemon = lista;
        index = widget.index;
      });
    });
  }

  @override
  Widget build(BuildContext bc) {
    // print("tamanho dos pok" + (pokemon.length.toString()));
    // print("indice $index");
    // print("list $pokemon");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Visualizar Pokemon"),
          actions: [
            PopupMenuButton(
                // add icon, by default "3 dot" icon
                // icon: Icon(Icons.book)
                itemBuilder: (context) {
              return [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text("Pokedex"),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text("Favoritos"),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Text("Sair"),
                )
              ];
            }, onSelected: (value) {
              if (value == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(true)),
                  (route) => false,
                );
              } else if (value == 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritosPage()),
                  (route) => false,
                );
              } else {
                SystemNavigator.pop();
              }
            }),
          ],
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return
              // print(index);
              Container(
                  color: pokemon.isNotEmpty && pokemon[index]['favorito'] == 1
                      ? Color.fromARGB(255, 230, 231, 172)
                      : Color(0xffb5d3d9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          color: pokemon.isNotEmpty &&
                                  pokemon[index]['favorito'] == 1
                              ? Color.fromARGB(255, 158, 159, 100)
                              : Color(0xff95b8bf),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              if (index > 0) {
                                setState(() {
                                  index--;
                                });
                              }
                            },
                          )),
                      Column(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            color: pokemon.isNotEmpty &&
                                    pokemon[index]['favorito'] == 1
                                ? Color.fromARGB(255, 230, 231, 172)
                                : Color(0xffb5d3d9),
                            child: Column(
                              children: <Widget>[
                                pokemon.isNotEmpty
                                    ? Image(
                                        image: NetworkImage(
                                          pokemon[index]['image'],
                                        ),
                                        height: 200,
                                        width: 200,
                                        fit: BoxFit.fill,
                                      )
                                    : Align(
                                        // alignment: Alignment.centerRight,
                                        child: Image.asset(
                                            'images/pokeball.png',
                                            width: 80,
                                            fit: BoxFit.fill)),
                                pokemon.isNotEmpty
                                    ? Text(pokemon[index]['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Color(0xff0a3c64)))
                                    : SizedBox.shrink(),
                                pokemon.isNotEmpty
                                    ? Text(pokemon[index]['height'].toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Color(0xff131101)))
                                    : SizedBox.shrink(),
                                pokemon.isNotEmpty
                                    ? Text(pokemon[index]['weight'].toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Color(0xff131101)))
                                    : SizedBox.shrink(),
                                const SizedBox(height: 10),
                              ],
                              mainAxisAlignment:
                                  orientation == Orientation.portrait
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                          ))
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                      Container(
                          color: pokemon.isNotEmpty &&
                                  pokemon[index]['favorito'] == 1
                              ? Color.fromARGB(255, 158, 159, 100)
                              : Color(0xff95b8bf),
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () {
                              if (index < pokemon.length - 1) {
                                setState(() {
                                  index++;
                                });
                              }
                            },
                          )),
                    ],
                  ));
        }));
  }
}
