import 'package:flutter/material.dart';

import '../store/contato-store.dart';

class Categorias extends StatelessWidget {
  const Categorias({super.key, required this.store});

  final ContatoStore store;

  Future<void> _criar(BuildContext context) async {
    final ctrl = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova categoria'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (nome == null) return;

    if (!store.addCategoria(nome) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um nome novo para a categoria')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final categorias = store.categorias;
          return ListView(
            children: [
              for (final categoria in categorias)
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(categoria),
                  trailing: Text('${store.contatosNaCategoria(categoria)}'),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _criar(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova categoria'),
      ),
    );
  }
}
