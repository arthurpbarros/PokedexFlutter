import 'package:flutter/material.dart';
import 'package:pokedex/main.dart';
import 'show_pokemon.dart';
import 'models.dart';
import 'package:flutter/services.dart';

class FavoritosPage extends StatefulWidget {
  // FavoritosPage();

  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<dynamic> pok = [];
  int qnt = 0;

  Future<List<dynamic>> init() async {
    return await DBHelper.selectFavorites();
  }

  @override
  void initState() {
    super.initState();
    init().then((favoritos) {
      setState(() {
        pok = favoritos;
        qnt = favoritos.length;
      });
    });
  }

  @override
  Widget build(BuildContext bc) {
    // print("favoritos $pok");
    // print("qnt " + pok.length.toString());
    return Scaffold(
        appBar: AppBar(
          title: const Text("Favoritos"),
          automaticallyImplyLeading: false,
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
              } else {
                SystemNavigator.pop();
              }
            }),
          ],
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return GridView.count(
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
                                    heroTag: "add_fav$index",
                                    onPressed: () {
                                      String name = pok[index]['name'];
                                      DBHelper.updateFavoritoStatus(pok[index])
                                          .then((pokemon_updated) {
                                        setState(() {
                                          pok.removeAt(index);
                                          qnt = pok.length;
                                        });
                                      });
                                      String texto =
                                          "$name foi removido da Pokedex";
                                      var snackBar = SnackBar(
                                          duration: Duration(seconds: 1),
                                          backgroundColor: Color(0xffbc3a3a),
                                          content: Text(texto,
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
                                    heroTag: "view_fav$index",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Show_Pokemon(
                                                pok.isNotEmpty
                                                    ? pok[index]['id'] - 1
                                                    : 0)),
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
