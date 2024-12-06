import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado_global.dart';

class DestinoCard extends StatefulWidget {
  final Map<String, dynamic> destino;
  final bool showFavoriteIcon;
  final VoidCallback? onRemove;

  DestinoCard({
    required this.destino,
    required this.showFavoriteIcon,
    this.onRemove,
  });

  @override
  _DestinoCardState createState() => _DestinoCardState();
}

class _DestinoCardState extends State<DestinoCard> {
  late bool favorito;

  @override
  void initState() {
    super.initState();
    favorito = widget.destino['fav'] ?? false;
  }

  void _toggleFavorito(BuildContext context) {
    final estadoGlobal = Provider.of<EstadoGlobal>(context, listen: false);
    if (estadoGlobal.isLoggedIn) {
      setState(() {
        favorito = !favorito;
        widget.destino['fav'] = favorito;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: null, // Remove o título
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning,
                  color: Colors.orange, size: 30), // Ícone de alerta
              SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Você precisa estar logado para adicionar aos favoritos!',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green, // Cor de fundo verde
                  foregroundColor: Colors.white, // Cor do texto branco
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Borda arredondada
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Excluir confirmação
  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Exclusão"),
          content: Text(
              "Você tem certeza que deseja remover este destino dos favoritos?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o alerta sem fazer nada
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o alerta
                if (widget.onRemove != null) {
                  widget.onRemove!(); // Chama a função de remoção
                }
              },
              child: Text("Remover"),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String imagem =
        widget.destino['blobs'][0]['file']; // Primeira imagem do JSON
    String nomeCidade = widget.destino['cidade']['nome'];
    String estado = widget.destino['cidade']['estado'];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
            child: Image.asset(
              imagem,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Nome da cidade (centralizado)
                Text(
                  nomeCidade,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                // Nome do estado (centralizado)
                Text(
                  estado,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                // Botão de remover com confirmação
                if (widget.onRemove != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmRemove(
                        context), // Chama o método de confirmação
                  ),
                // Exibe o ícone de favorito se permitido
                if (widget.showFavoriteIcon)
                  IconButton(
                    icon: Icon(
                      favorito ? Icons.star : Icons.star_border,
                      color: favorito ? Colors.orange : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorito(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
