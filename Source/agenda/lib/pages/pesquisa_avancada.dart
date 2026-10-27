import 'package:flutter/material.dart';

import '../models/contato.dart';
import '../store/contato-store.dart';
import '../widgets/barra_de_contatos.dart';
import '../widgets/estado_vazio.dart';
import 'detalhes_contato.dart';

class PesquisaAvancada extends StatefulWidget {
  const PesquisaAvancada({super.key, required this.store});

  final ContatoStore store;

  @override
  State<PesquisaAvancada> createState() => _PesquisaAvancadaState();
}

class _PesquisaAvancadaState extends State<PesquisaAvancada> {
  final _cidadeCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  String? _categoria;
  DateTime? _dataInicial;
  DateTime? _dataFinal;

  @override
  void dispose() {
    _cidadeCtrl.dispose();
    _empresaCtrl.dispose();
    super.dispose();
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Selecionar data';
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Future<void> _selecionarData({required bool inicial}) async {
    final hoje = DateTime.now();
    final atual = inicial ? _dataInicial : _dataFinal;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual ?? hoje,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: inicial ? 'Cadastrado a partir de' : 'Cadastrado até',
    );
    if (escolhida == null || !mounted) return;
    setState(() {
      if (inicial) {
        _dataInicial = escolhida;
      } else {
        _dataFinal = escolhida;
      }
    });
  }

  void _limparFiltros() {
    setState(() {
      _cidadeCtrl.clear();
      _empresaCtrl.clear();
      _categoria = null;
      _dataInicial = null;
      _dataFinal = null;
    });
  }

  Future<void> _abrirContato(Contato contato) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DetalhesContato(
          store: widget.store,
          contatoId: contato.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisa avançada'),
        actions: [
          TextButton.icon(
            onPressed: _limparFiltros,
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Limpar'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final resultados = widget.store.filtrarContatos(
            contatos: widget.store.todos,
            categoria: _categoria,
            cidade: _cidadeCtrl.text.trim().isEmpty
                ? null
                : _cidadeCtrl.text.trim(),
            empresa: _empresaCtrl.text.trim().isEmpty
                ? null
                : _empresaCtrl.text.trim(),
            cadastradoDe: _dataInicial,
            cadastradoAte: _dataFinal == null
                ? null
                : DateTime(_dataFinal!.year, _dataFinal!.month, _dataFinal!.day, 23, 59, 59),
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todas as categorias'),
                        ),
                        ...widget.store.categorias.map(
                          (categoria) => DropdownMenuItem<String>(
                            value: categoria,
                            child: Text(categoria),
                          ),
                        ),
                      ],
                      onChanged: (valor) => setState(() => _categoria = valor),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _cidadeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _empresaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Empresa',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selecionarData(inicial: true),
                            icon: const Icon(Icons.calendar_today),
                            label: Text('De: ${_formatarData(_dataInicial)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selecionarData(inicial: false),
                            icon: const Icon(Icons.event),
                            label: Text('Até: ${_formatarData(_dataFinal)}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: resultados.isEmpty
                    ? const EstadoVazio(
                        icon: Icons.search_off,
                        title: 'Nenhum contato encontrado',
                        message: 'Altere ou limpe os filtros para ver contatos.',
                      )
                    : ListView.builder(
                        itemCount: resultados.length,
                        itemBuilder: (context, index) {
                          final contato = resultados[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            child: BarraDeContatos(
                              contact: contato,
                              onTap: () => _abrirContato(contato),
                              onToggleFavorito: () =>
                                  widget.store.toggleFavorito(contato),
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
