import 'package:flutter/material.dart';
import 'store/contato-store.dart';
import 'pages/lista_contatos.dart';

void main() {
  runApp(const AgendaApp());
}

class AgendaApp extends StatelessWidget {
  const AgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ContatoStore();

    return MaterialApp(
      title: 'Lista Telefônica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 105, 17, 3),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 6, 20, 99)),
        useMaterial3: true,
      ),
      home: ListaContatos(store: store),
    );
  }
}
