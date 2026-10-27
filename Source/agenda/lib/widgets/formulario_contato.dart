import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/contato.dart';
import '../models/dados_contato.dart';
import 'formulario_contato/campo_aniversario.dart';
import 'formulario_contato/campos_basicos.dart';
import 'formulario_contato/foto_contato_field.dart';
import 'formulario_contato/seletor_categorias.dart';

class FormularioContato extends StatefulWidget {
  const FormularioContato({
    super.key,
    this.initial,
    this.categorias = const <String>[],
  });

  final Contato? initial;
  final List<String> categorias;

  @override
  State<FormularioContato> createState() => _FormularioContatoState();
}

class _FormularioContatoState extends State<FormularioContato> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _cidadeCtrl;
  late final TextEditingController _empresaCtrl;
  late final TextEditingController _obsCtrl;

  late final String _nomeInicial;
  late final String _emailInicial;
  late final String _telefoneInicial;
  late final String _cidadeInicial;
  late final String _empresaInicial;
  late final String _obsInicial;
  late final Uint8List? _fotoInicial;
  late final Set<String> _categoriasIniciais;

  Uint8List? _foto;
  bool _removerFoto = false;
  bool _saindo = false;
  late Set<String> _categoriasSelecionadas;
  DateTime? _aniversario;
  DateTime? _aniversarioInicial;

  List<TextEditingController> get _controladores => [
    _nomeCtrl,
    _emailCtrl,
    _telefoneCtrl,
    _cidadeCtrl,
    _empresaCtrl,
    _obsCtrl,
  ];

  @override
  void initState() {
    super.initState();
    final contato = widget.initial;

    _nomeInicial = contato?.nome ?? '';
    _emailInicial = contato?.email ?? '';
    _telefoneInicial = contato?.telefone ?? '';
    _cidadeInicial = contato?.cidade ?? '';
    _empresaInicial = contato?.empresa ?? '';
    _obsInicial = contato?.obs ?? '';
    _fotoInicial = contato?.foto;
    _categoriasIniciais = {...?contato?.categorias};
    _categoriasSelecionadas = {..._categoriasIniciais};
    _aniversarioInicial = contato?.aniversario;
    _aniversario = _aniversarioInicial;
    _foto = _fotoInicial;

    _nomeCtrl = TextEditingController(text: _nomeInicial);
    _emailCtrl = TextEditingController(text: _emailInicial);
    _telefoneCtrl = TextEditingController(text: _telefoneInicial);
    _cidadeCtrl = TextEditingController(text: _cidadeInicial);
    _empresaCtrl = TextEditingController(text: _empresaInicial);
    _obsCtrl = TextEditingController(text: _obsInicial);
    for (final controller in _controladores) {
      controller.addListener(_aoDigitar);
    }
  }

  @override
  void dispose() {
    for (final controller in _controladores) {
      controller.removeListener(_aoDigitar);
      controller.dispose();
    }
    super.dispose();
  }

  bool get _alterado =>
      _nomeCtrl.text.trim() != _nomeInicial ||
      _emailCtrl.text.trim() != _emailInicial ||
      _telefoneCtrl.text.trim() != _telefoneInicial ||
      _cidadeCtrl.text.trim() != _cidadeInicial ||
      _empresaCtrl.text.trim() != _empresaInicial ||
      _obsCtrl.text.trim() != _obsInicial ||
      !identical(_foto, _fotoInicial) ||
      _removerFoto ||
      !_mesmasCategorias ||
      !_mesmaData(_aniversario, _aniversarioInicial);

  bool get _mesmasCategorias =>
      _categoriasSelecionadas.length == _categoriasIniciais.length &&
      _categoriasSelecionadas.containsAll(_categoriasIniciais);

  bool _mesmaData(DateTime? a, DateTime? b) =>
      a?.year == b?.year && a?.month == b?.month && a?.day == b?.day;

  void _aoDigitar() => setState(() {});

  void _atualizarFoto(Uint8List? foto, bool remover) {
    setState(() {
      _foto = foto;
      _removerFoto = remover;
    });
  }

  Future<bool> _confirmarDescarte() async {
    final resposta = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('As mudanças feitas neste contato serão perdidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return resposta ?? false;
  }

  Future<void> _cancelar() async {
    if (!_alterado || await _confirmarDescarte()) {
      if (!mounted) return;
      _saindo = true;
      Navigator.of(context).pop();
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    _saindo = true;
    Navigator.of(context).pop(
      DadosContato(
        nome: _nomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        telefone: _telefoneCtrl.text.trim(),
        cidade: _cidadeCtrl.text.trim(),
        empresa: _empresaCtrl.text.trim(),
        observacoes: _obsCtrl.text.trim(),
        foto: _foto,
        removerFoto: _removerFoto,
        categorias: _categoriasSelecionadas.toList(),
        aniversario: _aniversario,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.initial != null;

    return PopScope(
      canPop: !_alterado,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _saindo) return;
        if (!await _confirmarDescarte() || !context.mounted) return;
        _saindo = true;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editando ? 'Editar contato' : 'Novo contato'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FotoContatoField(
                  foto: _foto,
                  nome: _nomeCtrl.text,
                  onFotoAlterada: _atualizarFoto,
                ),
                const SizedBox(height: 16),
                CamposBasicosContato(
                  nome: _nomeCtrl,
                  email: _emailCtrl,
                  telefone: _telefoneCtrl,
                  cidade: _cidadeCtrl,
                  empresa: _empresaCtrl,
                  observacoes: _obsCtrl,
                  autofocusNome: !editando,
                ),
                const SizedBox(height: 12),
                CampoAniversario(
                  data: _aniversario,
                  onChanged: (data) => setState(() => _aniversario = data),
                ),
                const SizedBox(height: 12),
                SeletorCategorias(
                  categorias: widget.categorias,
                  selecionadas: _categoriasSelecionadas,
                  onChanged: (selecionadas) =>
                      setState(() => _categoriasSelecionadas = selecionadas),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelar,
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _salvar,
                        icon: Icon(editando ? Icons.check : Icons.add),
                        label: Text(editando ? 'Salvar' : 'Adicionar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
