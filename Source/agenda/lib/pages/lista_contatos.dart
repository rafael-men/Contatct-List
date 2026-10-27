import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/contato.dart';
import '../models/dados_contato.dart';
import '../store/contato-store.dart';
import '../services/contatos_files.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/barra_de_contatos.dart';
import 'detalhes_contato.dart';
import 'favoritos.dart';
import 'grupos.dart';
import 'aniversarios.dart';
import 'categorias.dart';
import '../widgets/formulario_contato.dart';
import 'pesquisa_avancada.dart';

class ListaContatos extends StatefulWidget {
  const ListaContatos({super.key, required this.store});

  final ContatoStore store;

  @override
  State<ListaContatos> createState() => _ListaContatosState();
}

class _ListaContatosState extends State<ListaContatos> {
  final _buscaCtrl = TextEditingController();

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario([Contato? contato]) async {
    final dados = await Navigator.of(context).push<DadosContato>(
      MaterialPageRoute(
        builder: (_) => FormularioContato(
          initial: contato,
          categorias: widget.store.categorias,
        ),
      ),
    );
    if (dados == null || !context.mounted) return;

    if (contato == null) {
      widget.store.add(dados);
    } else {
      widget.store.update(contato, dados);
    }
    if (!context.mounted) return;

    final msg = contato == null
        ? '${dados.nome} adicionado'
        : '${dados.nome} atualizado';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _abrirDetalhes(Contato contato) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DetalhesContato(
          store: widget.store,
          contatoId: contato.id,
        ),
      ),
    );
  }

  Future<void> _abrirFavoritos() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => Favoritos(store: widget.store)),
    );
  }

  Future<void> _excluir(Contato contato) async {
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
    if (confirma != true || !mounted) return;
    widget.store.remove(contato);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${contato.nome} removido')),
    );
  }

  Future<void> _importarContatos() async {
  try {
    final arquivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (arquivo == null) return;

    final bytes = await arquivo.readAsBytes();
    final extensao = arquivo.extension?.toLowerCase();

    if (extensao == null) {
      throw const FormatException('O arquivo não tem uma extensão válida.');
    }

    final contatos = ContatosArquivo.importar(
      bytes: bytes,
      extensao: extensao,
    );

    widget.store.importarContatos(contatos);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${contatos.length} contato(s) importado(s).')),
    );
  } catch (erro) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Falha ao importar: $erro')),
    );
  }
}

Future<void> _exportarCsv() async {
  await _salvarBackup(
    nomeArquivo: 'backup_contatos.csv',
    bytes: ContatosArquivo.exportarCsv(widget.store.todos),
  );
}

Future<void> _exportarExcel() async {
  await _salvarBackup(
    nomeArquivo: 'backup_contatos.xlsx',
    bytes: ContatosArquivo.exportarExcel(widget.store.todos),
  );
}

Future<void> _salvarBackup({
  required String nomeArquivo,
  required Uint8List bytes,
}) async {
  try {
    await FilePicker.saveFile(
      fileName: nomeArquivo,
      bytes: bytes,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportação concluída.')),
    );
  } catch (erro) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Falha ao exportar: $erro')),
    );
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Telefônica'),
        actions: [
          ListenableBuilder(
            listenable: widget.store,
            builder: (context, _) {
              final total = widget.store.totalFavoritos;
              return IconButton(
                tooltip: 'Favoritos',
                icon: Badge(
                  isLabelVisible: total > 0,
                  label: Text('$total'),
                  child: const Icon(Icons.star_outline),
                ),
                onPressed: _abrirFavoritos,
              );
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Mais',
            onSelected: (valor) {
              if (valor == 'importar_contatos') {
                _importarContatos();
                return;
              }
              if (valor == 'exportar_csv') {
                _exportarCsv();
                return;
              }
              if (valor == 'exportar_excel') {
                _exportarExcel();
                return;
              }

              final pagina = switch (valor) {
                'categorias' => Categorias(store: widget.store),
                'grupos' => Grupos(store: widget.store),
                'aniversarios' => Aniversarios(store: widget.store),
                _ => PesquisaAvancada(store: widget.store),
              };
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => pagina),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'categorias', child: Text('Categorias')),
              PopupMenuItem(value: 'grupos', child: Text('Grupos')),
              PopupMenuItem(value: 'aniversarios', child: Text('Aniversários')),
              PopupMenuItem(value: 'pesquisa', child: Text('Pesquisa avançada')),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'importar_contatos',
                child: Text('Importar contatos'),
              ),
              PopupMenuItem(
                value: 'exportar_csv',
                child: Text('Exportar backup CSV'),
              ),
              PopupMenuItem(
                value: 'exportar_excel',
                child: Text('Exportar backup Excel'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _buscaCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar por nome, e-mail ou telefone',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _buscaCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaCtrl.clear();
                          widget.store.setQuery('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (valor) {
                widget.store.setQuery(valor);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.store,
              builder: (_, _) {
                final lista = widget.store.contacts;
                if (lista.isEmpty) {
                  final vazioPorBusca = widget.store.query.isNotEmpty;
                  return EstadoVazio(
                    icon: vazioPorBusca ? Icons.search_off : Icons.people_outline,
                    title: vazioPorBusca
                        ? 'Nada encontrado'
                        : 'Nenhum contato ainda',
                    message: vazioPorBusca
                        ? 'Não há contatos que correspondam à sua busca.'
                        : 'Clique no botão abaixo para adicionar um novo contato.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final c = lista[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      child: BarraDeContatos(
                        contact: c,
                        onTap: () => _abrirDetalhes(c),
                        onEdit: () => _abrirFormulario(c),
                        onDelete: () => _excluir(c),
                        onToggleFavorito: () => widget.store.toggleFavorito(c),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo contato'),
      ),
    );
  }
}
