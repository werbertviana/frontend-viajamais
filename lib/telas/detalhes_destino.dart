import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado_global.dart';

class DetalhesDestinoScreen extends StatefulWidget {
  final Map<String, dynamic> destino;

  DetalhesDestinoScreen({required this.destino});

  @override
  _DetalhesDestinoScreenState createState() => _DetalhesDestinoScreenState();
}

class _DetalhesDestinoScreenState extends State<DetalhesDestinoScreen> {
  late PageController _pageController;
  double currentPage =
      0.0; // Página atual para o controle do indicador de página

  bool isPontosVisible = false; // Controla a visibilidade dos pontos turísticos

  // Função para alternar a visibilidade dos pontos turísticos
  void _togglePontosVisibility() {
    setState(() {
      isPontosVisible = !isPontosVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Monitorar as mudanças de página
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estadoGlobal = Provider.of<EstadoGlobal>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: null,
        flexibleSpace: Container(
          alignment: Alignment.center,
          child: Image.asset(
            'lib/recursos/imagens/logo.png',
            height: 25,
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slider de imagens (PageView)
            Container(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.destino['blobs'].length,
                itemBuilder: (context, index) {
                  String imagem = widget.destino['blobs'][index]['file'];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(imagem, fit: BoxFit.cover),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            // Indicador de página (marcador customizado)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    List.generate(widget.destino['blobs'].length, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentPage.round() == index
                          ? Colors.blue
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16),
            // Nome do destino
            Text(
              widget.destino['cidade']['nome'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Nome do estado
            Text(
              widget.destino['cidade']['estado'],
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            // Descrição do destino com barra de rolagem e justificada
            Flexible(
              flex: 2,
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(10),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    widget.destino['descricao'] ?? 'Descrição não disponível.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Título de Pontos Turísticos
            Text(
              "Pontos Turísticos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Botão de seta para mostrar os pontos turísticos
            IconButton(
              icon: Icon(
                isPontosVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 30,
                color: Colors.blue,
              ),
              onPressed: _togglePontosVisibility,
            ),
            // Se os pontos turísticos estiverem visíveis, mostra a lista
            if (isPontosVisible && estadoGlobal.isLoggedIn) ...[
              // Lista de pontos turísticos
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.destino['pontos_turisticos']
                    .map<Widget>((ponto) => Text(
                          '- $ponto',
                          style: TextStyle(fontSize: 16),
                        ))
                    .toList(),
              ),
            ] else if (!estadoGlobal.isLoggedIn) ...[
              Text('Faça login para ver os pontos turísticos.')
            ],
          ],
        ),
      ),
    );
  }
}
