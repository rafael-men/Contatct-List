import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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
import 'configuracoes.dart';
import '../services/preferencias_app.dart';

class ListaContatos extends StatefulWidget {
  const ListaContatos({
    super.key,
    required this.store,
    required this.preferencias,
  });

  final ContatoStore store;
  final PreferenciasApp preferencias;

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
    if (dados == null || !mounted) return;

    if (contato == null) {
      widget.store.add(dados);
    } else {
      widget.store.update(contato, dados);
    }
    if (!mounted) return;

    final msg = contato == null
        ? '${dados.nome} adicionado'
        : '${dados.nome} atualizado';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _abrirDetalhes(Contato contato) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            DetalhesContato(store: widget.store, contatoId: contato.id),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${contato.nome} removido')));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao importar: $erro')));
    }
  }

  Future<void> _importarDaAgendaDoCelular() async {
    if (kIsWeb ||
        ![TargetPlatform.android, TargetPlatform.iOS].contains(
          defaultTargetPlatform,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A importação da agenda está disponível no Android e iOS.',
          ),
        ),
      );
      return;
    }

    try {
      var permissao = await FlutterContacts.permissions.check(PermissionType.read);
      if (permissao != PermissionStatus.granted &&
          permissao != PermissionStatus.limited) {
        final continuar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Acesso aos contatos'),
            content: const Text(
              'Para importar sua agenda, o app precisa da sua autorização para ler os contatos do dispositivo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Agora não'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
        if (continuar != true || !mounted) return;

        permissao = await FlutterContacts.permissions.request(PermissionType.read);
      }
      if (permissao != PermissionStatus.granted &&
          permissao != PermissionStatus.limited) {
        if (!mounted) return;
        final bloqueada = permissao == PermissionStatus.permanentlyDenied ||
            permissao == PermissionStatus.restricted;
        final abrirConfiguracoes = bloqueada
            ? await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Permissão bloqueada'),
                  content: const Text(
                    'Autorize o acesso aos contatos nas configurações do app para importar sua agenda.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Abrir configurações'),
                    ),
                  ],
                ),
              )
            : false;
        if (abrirConfiguracoes == true) {
          await FlutterContacts.permissions.openSettings();
          return;
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acesso aos contatos não autorizado.')),
        );
        return;
      }

      final contatos = await FlutterContacts.getAll(
        properties: {ContactProperty.phone, ContactProperty.email},
      );
      if (!mounted) return;
      if (contatos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum contato encontrado no dispositivo.'),
          ),
        );
        return;
      }

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Importar contatos'),
          content: Text(
            'Deseja importar ${contatos.length} contato(s) do dispositivo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );
      if (confirmar != true || !mounted) return;

      final telefonesExistentes = widget.store.todos
          .map((contato) => contato.telefone.replaceAll(RegExp(r'\D'), ''))
          .where((telefone) => telefone.isNotEmpty)
          .toSet();
      final emailsExistentes = widget.store.todos
          .map((contato) => contato.email.trim().toLowerCase())
          .where((email) => email.isNotEmpty)
          .toSet();
      var importados = 0;

      for (final contato in contatos) {
        final nome = contato.displayName?.trim() ?? '';
        if (nome.isEmpty) continue;

        final telefone = contato.phones.isEmpty
            ? ''
            : contato.phones.first.number.trim();
        final email = contato.emails.isEmpty
            ? ''
            : contato.emails.first.address.trim();
        final telefoneNormalizado = telefone.replaceAll(RegExp(r'\D'), '');
        final emailNormalizado = email.toLowerCase();

        final duplicado =
            (telefoneNormalizado.isNotEmpty &&
                telefonesExistentes.contains(telefoneNormalizado)) ||
            (emailNormalizado.isNotEmpty &&
                emailsExistentes.contains(emailNormalizado));
        if (duplicado) {
          continue;
        }

        if (telefoneNormalizado.isNotEmpty) {
          telefonesExistentes.add(telefoneNormalizado);
        }
        if (emailNormalizado.isNotEmpty) {
          emailsExistentes.add(emailNormalizado);
        }

        widget.store.add(
          DadosContato(nome: nome, telefone: telefone, email: email),
        );
        importados++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$importados contato(s) importado(s); '
            '${contatos.length - importados} ignorado(s) por duplicidade ou dados inválidos.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao acessar os contatos: $erro')),
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
      await FilePicker.saveFile(fileName: nomeArquivo, bytes: bytes);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exportação concluída.')));
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao exportar: $erro')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo.png',
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 8),
            const Text('Lista Telefônica'),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: widget.preferencias,
            builder: (context, _) => IconButton(
              tooltip: widget.preferencias.escuro
                  ? 'Ativar modo claro'
                  : 'Ativar modo escuro',
              icon: Icon(
                widget.preferencias.escuro
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () => widget.preferencias.definirTema(
                !widget.preferencias.escuro,
              ),
            ),
          ),
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
              if (valor == 'importar_dispositivo') {
                _importarDaAgendaDoCelular();
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
              if (valor == 'configuracoes') {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        Configuracoes(preferencias: widget.preferencias),
                  ),
                );
                return;
              }

              final pagina = switch (valor) {
                'categorias' => Categorias(store: widget.store),
                'grupos' => Grupos(store: widget.store),
                'aniversarios' => Aniversarios(store: widget.store),
                _ => PesquisaAvancada(store: widget.store),
              };
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => pagina));
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'categorias', child: Text('Categorias')),
              PopupMenuItem(value: 'grupos', child: Text('Grupos')),
              PopupMenuItem(value: 'aniversarios', child: Text('Aniversários')),
              PopupMenuItem(
                value: 'pesquisa',
                child: Text('Pesquisa avançada'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'importar_dispositivo',
                child: Text('Importar contatos do dispositivo'),
              ),
              PopupMenuItem(
                value: 'configuracoes',
                child: Text('Configurações'),
              ),
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
              listenable: Listenable.merge([widget.store, widget.preferencias]),
              builder: (_, _) {
                final lista = widget.store.contacts;
                if (lista.isEmpty) {
                  final vazioPorBusca = widget.store.query.isNotEmpty;
                  return EstadoVazio(
                    icon: vazioPorBusca
                        ? Icons.search_off
                        : Icons.people_outline,
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      child: BarraDeContatos(
                        contact: c,
                        onTap: () => _abrirDetalhes(c),
                        onEdit: () => _abrirFormulario(c),
                        onDelete: () => _excluir(c),
                        onToggleFavorito: () => widget.store.toggleFavorito(c),
                        mostrarAvatar: widget.preferencias.mostrarAvatares,
                        compacto: widget.preferencias.listaCompacta,
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
