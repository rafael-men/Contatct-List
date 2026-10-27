import 'dart:typed_data';

class DadosContato {
  const DadosContato({
    required this.nome,
    required this.email,
    required this.telefone,
    this.cidade = '',
    this.empresa = '',
    this.observacoes = '',
    this.foto,
    this.removerFoto = false,
    this.categorias = const <String>[],
    this.aniversario,
  });

  final String nome;
  final String email;
  final String telefone;
  final String cidade;
  final String empresa;
  final String observacoes;
  final Uint8List? foto;
  final bool removerFoto;
  final List<String> categorias;
  final DateTime? aniversario;
}
