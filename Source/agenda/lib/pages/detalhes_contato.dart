import 'package:flutter/material.dart';
import '../models/contato.dart';
import '../models/dados_contato.dart';
import '../store/contato-store.dart';
import '../widgets/avatar_contato.dart';
import '../widgets/formulario_contato.dart';

class DetalhesContato extends StatelessWidget {
  const DetalhesContato({
    super.key,
    required this.store,
    required this.contatoId,
  });

  final ContatoStore store;
  final String contatoId;

  Future<void> _editar(BuildContext context, Contato contato) async {
    final dados = await Navigator.of(context).push<DadosContato>(
      MaterialPageRoute(
        builder: (_) => FormularioContato(
          initial: contato,
          categorias: store.categorias,
        ),
      ),
    );
    if (dados == null || !context.mounted) return;

    store.update(contato, dados);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${dados.nome} atualizado')));
  }

  Future<void> _excluir(BuildContext context, Contato contato) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir contato'),
        content: Text('Deseja excluir ${contato.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirma != true) return;

    store.remove(contato);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final contato = store.porId(contatoId);
        if (contato == null) {
          return const Scaffold(
            body: Center(child: Text('Este contato foi removido.')),
          );
        }
        final contatoAtual = contato;

        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do contato'),
            actions: [
              IconButton(
                tooltip: contatoAtual.favorito
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                icon: Icon(
                  contatoAtual.favorito ? Icons.star : Icons.star_border,
                  color: contatoAtual.favorito ? Colors.amber.shade700 : null,
                ),
                onPressed: () => store.toggleFavorito(contatoAtual),
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editar(context, contatoAtual),
              ),
              IconButton(
                tooltip: 'Excluir',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _excluir(context, contatoAtual),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              Center(
                child: AvatarContato(
                  foto: contatoAtual.foto,
                  initials: contatoAtual.initials,
                  radius: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                contatoAtual.nome,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      _LinhaDetalhe(
                        icon: Icons.phone_outlined,
                        label: 'Telefone',
                        valor: contatoAtual.telefone,
                      ),
                      const Divider(height: 1),
                      _LinhaDetalhe(
                        icon: Icons.email_outlined,
                        label: 'E-mail',
                        valor: contatoAtual.email,
                      ),
                      const Divider(height: 1),
                      _LinhaDetalhe(
                        icon: Icons.notes_outlined,
                        label: 'Observações',
                        valor: contatoAtual.obs,
                      ),
                      const Divider(height: 1),
                      _LinhaDetalhe(
                        icon: Icons.cake_outlined,
                        label: 'Aniversário',
                        valor: contatoAtual.aniversarioFormatado,
                      ),
                      const Divider(height: 1),
                      _LinhaDetalhe(
                        icon: Icons.label_outline,
                        label: 'Categorias',
                        valor: contatoAtual.categorias.join(', '),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _editar(context, contatoAtual),
                icon: const Icon(Icons.edit),
                label: const Text('Editar contato'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LinhaDetalhe extends StatelessWidget {
  const _LinhaDetalhe({
    required this.icon,
    required this.label,
    required this.valor,
  });

  final IconData icon;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preenchido = valor.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preenchido ? valor : 'Não informado',
                  style: preenchido
                      ? theme.textTheme.bodyLarge
                      : theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
