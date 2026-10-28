import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../store/contato-store.dart';
import '../widgets/avatar_contato.dart';
import '../widgets/estado_vazio.dart';

class Grupos extends StatelessWidget {
  const Grupos({super.key, required this.store});

  final ContatoStore store;

  Future<void> _criar(BuildContext context) async {
    final ctrl = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo grupo'),
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
    if (nome == null || nome.trim().isEmpty) return;
    store.criarGrupo(nome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupos')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final grupos = store.grupos;
          if (grupos.isEmpty) {
            return const EstadoVazio(
              icon: Icons.groups_outlined,
              title: 'Nenhum grupo ainda',
              message: 'Crie um grupo para organizar contatos.',
            );
          }
          return ListView(
            children: [
              for (final grupo in grupos)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  child: ListTile(
                    leading: const Icon(Icons.groups_outlined),
                    title: Text(grupo.nome),
                    subtitle: Text('${grupo.membros.length} contato(s)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GrupoDetalhes(store: store, grupo: grupo),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _criar(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo grupo'),
      ),
    );
  }
}

class GrupoDetalhes extends StatelessWidget {
  const GrupoDetalhes({super.key, required this.store, required this.grupo});

  final ContatoStore store;
  final Grupo grupo;

  Future<void> _escolherMembros(BuildContext context) async {
    final selecionados = <String>{...grupo.membros};
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Membros do grupo'),
          content: SizedBox(
            width: double.maxFinite,
            height: 320,
            child: ListView(
              children: [
                for (final contato in store.todos)
                  CheckboxListTile(
                    value: selecionados.contains(contato.id),
                    title: Text(contato.nome),
                    onChanged: (marcado) => setStateDialog(() {
                      if (marcado == true) {
                        selecionados.add(contato.id);
                      } else {
                        selecionados.remove(contato.id);
                      }
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    if (confirmado != true) return;

    for (final contato in store.todos) {
      final marcado = selecionados.contains(contato.id);
      if (marcado != grupo.membros.contains(contato.id)) {
        store.alternarMembro(grupo, contato.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(grupo.nome),
        actions: [
          IconButton(
            tooltip: 'Escolher membros',
            icon: const Icon(Icons.person_add_alt),
            onPressed: () => _escolherMembros(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final membros = store.membrosDe(grupo);
          if (membros.isEmpty) {
            return const EstadoVazio(
              icon: Icons.person_off_outlined,
              title: 'Nenhum membro',
              message: 'Use o ícone no topo para adicionar contatos.',
            );
          }
          return ListView(
            children: [
              for (final contato in membros)
                ListTile(
                  leading: AvatarContato(
                    initials: contato.initials,
                    foto: contato.foto,
                  ),
                  title: Text(contato.nome),
                  subtitle: contato.telefone.isEmpty
                      ? null
                      : Text(contato.telefone),
                  trailing: IconButton(
                    tooltip: 'Remover do grupo',
                    icon: const Icon(Icons.person_remove_outlined),
                    onPressed: () => store.alternarMembro(grupo, contato.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
