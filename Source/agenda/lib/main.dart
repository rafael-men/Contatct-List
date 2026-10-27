import 'package:flutter/material.dart';
import 'store/contato-store.dart';
import 'pages/lista_contatos.dart';
import 'services/preferencias_app.dart';

void main() {
  runApp(const AgendaApp());
}

class AgendaApp extends StatefulWidget {
  const AgendaApp({super.key});

  @override
  State<AgendaApp> createState() => _AgendaAppState();
}

class _AgendaAppState extends State<AgendaApp> {
  final _preferencias = PreferenciasApp();
  final _store = ContatoStore();

  @override
  void initState() {
    super.initState();
    _preferencias.carregar();
    _preferencias.atualizarContatos(_store.todos);
    _store.addListener(_atualizarBackup);
  }

  void _atualizarBackup() => _preferencias.atualizarContatos(_store.todos);

  @override
  void dispose() {
    _store.removeListener(_atualizarBackup);
    _preferencias.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _preferencias,
      builder: (context, _) => MaterialApp(
        title: 'Lista Telefônica',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 105, 17, 3),
          ),
          iconTheme: const IconThemeData(color: Color.fromARGB(255, 6, 20, 99)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 105, 17, 3),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: _preferencias.themeMode,
        home: ListaContatos(store: _store, preferencias: _preferencias),
      ),
    );
  }
}
