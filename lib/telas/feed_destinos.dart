import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../componentes/destino_card.dart';
import '../estado_global.dart';
import 'detalhes_destino.dart';

class FeedDestinosScreen extends StatefulWidget {
  @override
  _FeedDestinosScreenState createState() => _FeedDestinosScreenState();
}

class _FeedDestinosScreenState extends State<FeedDestinosScreen> {
  List<dynamic> allDestinos = [];
  List<dynamic> displayedDestinos = [];
  int currentMax = 6;
  bool hasError = false;
  bool isLoading = true;
  bool showOnlyFavorites = false; // Controla a exibição dos favoritos

  @override
  void initState() {
    super.initState();
    _loadDestinos();
  }

  Future<void> _loadDestinos() async {
    try {
      final String response =
          await rootBundle.loadString('lib/recursos/json/feed.json');
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        allDestinos = data['cidades'];
        displayedDestinos = allDestinos.sublist(
            0, currentMax); // Carrega os destinos inicialmente
        _filterDestinos(); // Aplica o filtro de favoritos logo ao carregar
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void _filterDestinos() {
    setState(() {
      if (showOnlyFavorites) {
        displayedDestinos =
            allDestinos.where((destino) => destino['fav'] == true).toList();
      } else {
        displayedDestinos = List.from(allDestinos);
      }
    });
  }

  void _resetFavoritos() {
    for (var destino in allDestinos) {
      destino['fav'] = false;
    }
    setState(() {
      displayedDestinos = List.from(allDestinos);
    });
  }

  void _removeFavorito(int index) {
    setState(() {
      displayedDestinos[index]['fav'] = false;
      if (showOnlyFavorites) {
        displayedDestinos.removeAt(index);
      }
    });
  }

  void _loadMore() {
    int nextMax = currentMax + 6;

    if (nextMax <= allDestinos.length) {
      setState(() {
        displayedDestinos.addAll(allDestinos.sublist(currentMax, nextMax));
        currentMax = nextMax;
        _filterDestinos(); // Aplica o filtro de favoritos após o carregamento
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estadoGlobal = Provider.of<EstadoGlobal>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: estadoGlobal.isLoggedIn
                  ? IconButton(
                      icon: Icon(
                        showOnlyFavorites ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        setState(() {
                          showOnlyFavorites = !showOnlyFavorites;
                          _filterDestinos();
                        });
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.star_border,
                        color: Colors.grey,
                      ),
                      onPressed: null,
                    ),
            ),
            Image.asset(
              'lib/recursos/imagens/logo.png',
              height: 25,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(
                  estadoGlobal.isLoggedIn ? Icons.logout : Icons.login,
                  color: Colors.blue,
                ),
                onPressed: () {
                  if (estadoGlobal.isLoggedIn) {
                    _resetFavoritos();
                  }
                  estadoGlobal.toggleLogin(context);
                  _loadDestinos();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => FeedDestinosScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar os destinos.'))
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      _loadMore();
                    }
                    return true;
                  },
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: displayedDestinos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalhesDestinoScreen(
                                destino: displayedDestinos[index],
                              ),
                            ),
                          );
                        },
                        child: DestinoCard(
                          destino: displayedDestinos[index],
                          showFavoriteIcon: !showOnlyFavorites,
                          onRemove: showOnlyFavorites
                              ? () => _removeFavorito(index)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
