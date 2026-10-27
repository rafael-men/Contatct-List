import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../models/contato.dart';

class ContatosArquivo {
  static const List<String> _cabecalhos = [
    'nome',
    'email',
    'telefone',
    'cidade',
    'empresa',
    'dataCadastro',
    'aniversario',
    'categorias',
    'favorito',
    'observacoes',
  ];

  static List<Contato> importar({
    required Uint8List bytes,
    required String extensao,
  }) {
    final linhas = switch (extensao.toLowerCase()) {
      'csv' => _lerCsv(bytes),
      'xlsx' => _lerExcel(bytes),
      _ => throw FormatException('Formato não suportado: .$extensao'),
    };

    return _linhasParaContatos(linhas);
  }

  static Uint8List exportarCsv(List<Contato> contatos) {
    final csv = Csv(fieldDelimiter: ';').encode(_contatosParaLinhas(contatos));
    return Uint8List.fromList(utf8.encode('\uFEFF$csv'));
  }

  static Uint8List exportarExcel(List<Contato> contatos) {
    final arquivo = Excel.createExcel();
    final planilha = arquivo['Contatos'];

    for (final linha in _contatosParaLinhas(contatos)) {
      planilha.appendRow(linha.map(TextCellValue.new).toList());
    }

    final bytes = arquivo.encode();
    if (bytes == null) {
      throw StateError('Não foi possível gerar o arquivo Excel.');
    }
    return Uint8List.fromList(bytes);
  }

  static List<List<String>> _lerCsv(Uint8List bytes) {
    var texto = utf8.decode(bytes, allowMalformed: true);
    texto = texto.replaceFirst('\uFEFF', '');
    return Csv()
        .decode(texto)
        .map((linha) => linha.map((valor) => valor.toString()).toList())
        .toList();
  }

  static List<List<String>> _lerExcel(Uint8List bytes) {
    final arquivo = Excel.decodeBytes(bytes);
    final nomesPlanilhas = arquivo.tables.keys;
    if (nomesPlanilhas.isEmpty) {
      throw const FormatException('O Excel não contém planilhas.');
    }

    final planilha = arquivo.tables[nomesPlanilhas.first];
    if (planilha == null) {
      throw const FormatException('Não foi possível ler a planilha.');
    }

    return planilha.rows.map((linha) {
      return linha.map((celula) => _valorCelula(celula?.value)).toList();
    }).toList();
  }

  static String _valorCelula(CellValue? valor) {
    return switch (valor) {
      null => '',
      TextCellValue() => valor.value.text ?? '',
      IntCellValue() => valor.value.toString(),
      DoubleCellValue() => valor.value.toString(),
      BoolCellValue() => valor.value.toString(),
      DateCellValue() => valor.asDateTimeLocal().toIso8601String(),
      DateTimeCellValue() => valor.asDateTimeLocal().toIso8601String(),
      TimeCellValue() => valor.toString(),
      FormulaCellValue() => valor.formula,
    };
  }

  static List<List<String>> _contatosParaLinhas(List<Contato> contatos) => [
        _cabecalhos,
        ...contatos.map((contato) => [
              contato.nome,
              contato.email,
              contato.telefone,
              contato.cidade,
              contato.empresa,
              contato.dataCadastro.toIso8601String(),
              contato.aniversario?.toIso8601String() ?? '',
              jsonEncode(contato.categorias),
              contato.favorito.toString(),
              contato.obs,
            ]),
      ];

  static List<Contato> _linhasParaContatos(List<List<String>> linhas) {
    if (linhas.isEmpty) {
      throw const FormatException('O arquivo não contém dados.');
    }

    final cabecalho = linhas.first
        .map((valor) => valor.trim().replaceFirst('\uFEFF', '').toLowerCase())
        .toList();
    final colunas = <String, int>{
      for (var i = 0; i < cabecalho.length; i++) cabecalho[i]: i,
    };

    if (!colunas.containsKey('nome')) {
      throw const FormatException('A coluna obrigatória "nome" não existe.');
    }

    String campo(List<String> linha, String nome) {
      final indice = colunas[nome.toLowerCase()];
      if (indice == null || indice >= linha.length) return '';
      return linha[indice].trim();
    }

    final contatos = <Contato>[];
    for (final linha in linhas.skip(1)) {
      final nome = campo(linha, 'nome');
      if (nome.isEmpty) continue;

      contatos.add(
        Contato(
          id: '', // O store atribui um ID novo na importação.
          nome: nome,
          email: campo(linha, 'email'),
          telefone: campo(linha, 'telefone'),
          cidade: campo(linha, 'cidade'),
          empresa: campo(linha, 'empresa'),
          dataCadastro: DateTime.tryParse(campo(linha, 'dataCadastro')) ??
              DateTime.now(),
          aniversario: DateTime.tryParse(campo(linha, 'aniversario')),
          categorias: _lerCategorias(campo(linha, 'categorias')),
          favorito: _lerBooleano(campo(linha, 'favorito')),
          obs: campo(linha, 'observacoes'),
        ),
      );
    }
    return contatos;
  }

  static List<String> _lerCategorias(String texto) {
    if (texto.isEmpty) return [];
    try {
      final valor = jsonDecode(texto);
      if (valor is List) return valor.map((item) => item.toString()).toList();
    } on FormatException {
      // Aceita também categorias separadas por vírgula.
    }
    return texto
        .split(',')
        .map((categoria) => categoria.trim())
        .where((categoria) => categoria.isNotEmpty)
        .toList();
  }

  static bool _lerBooleano(String texto) {
    final valor = texto.trim().toLowerCase();
    return valor == 'true' || valor == 'sim' || valor == '1';
  }
}
