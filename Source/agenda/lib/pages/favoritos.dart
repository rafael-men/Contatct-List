import 'package:flutter/material.dart';

import '../models/contato.dart';
import '../store/contato-store.dart';
import '../widgets/barra_de_contatos.dart';
import '../widgets/estado_vazio.dart';
import 'detalhes_contato.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({super.key, required this.store});

  final ContatoStore store;

  @override
  State<Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> {
  final _buscaCtrl = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  List<Contato> _filtrar(List<Contato> lista) {
    final q = _filtro.trim().toLowerCase();
    if (q.isEmpty) return lista;
    return lista.where((Contato c) {
      return c.nome.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.telefone.contains(q);
    }).toList();
  }

  Future<void> _abrirDetalhes(Contato contato) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            DetalhesContato(store: widget.store, contatoId: contato.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final favoritos = widget.store.favoritos;
          if (favoritos.isEmpty) {
            return const EstadoVazio(
              icon: Icons.star_border,
              title: 'Nenhum favorito ainda',
              message:
                  'Toque na estrela de um contato para marcá-lo como favorito.',
            );
          }

          final lista = _filtrar(favoritos);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _buscaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Buscar nos favoritos',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (valor) => setState(() => _filtro = valor),
                ),
              ),
              Expanded(
                child: lista.isEmpty
                    ? const EstadoVazio(
                        icon: Icons.search_off,
                        title: 'Nada encontrado',
                        message: 'Nenhum favorito corresponde à sua busca.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: lista.length,
                        itemBuilder: (context, i) {
                          final c = lista[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            child: BarraDeContatos(
                              contact: c,
                              onTap: () => _abrirDetalhes(c),
                              onToggleFavorito: () =>
                                  widget.store.toggleFavorito(c),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
