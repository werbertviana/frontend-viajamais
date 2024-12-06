import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'estado_global.dart';
import 'telas/feed_destinos.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => EstadoGlobal(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FeedDestinosScreen(),
    );
  }
}
