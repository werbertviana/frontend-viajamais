// lib/estado_global.dart
import 'package:flutter/material.dart';

class EstadoGlobal with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void toggleLogin(BuildContext context) {
    _isLoggedIn = !_isLoggedIn;
    notifyListeners();

    // Exibir mensagem ao logar/deslogar
    final mensagem = _isLoggedIn ? 'Você está logado!' : 'Você está deslogado!';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
