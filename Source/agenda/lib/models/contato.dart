import 'dart:typed_data';

String iniciais(String nome) {
  final partes = nome.trim().split(RegExp(r'\s+'));
  if (partes.isEmpty || partes.first.isEmpty) {
    return '?';
  }
  final primeiro = partes.first[0].toUpperCase();
  if (partes.length == 1) {
    return primeiro;
  }
  return '$primeiro${partes.last[0].toUpperCase()}';
}

class Contato {
  Contato({
    required this.id,
    required this.nome,
    this.email = '',
    this.telefone = '',
    this.cidade = '',
    this.empresa ='',
    DateTime? dataCadastro,
    this.obs = '',
    this.foto,
    this.favorito = false,
    List<String>? categorias,
    this.aniversario,
  }) : dataCadastro = dataCadastro ?? DateTime.now(),
    categorias = categorias ?? <String>[];

  final String id;
  final String nome;
  final String email;
  final String cidade;
  final String empresa;
  final DateTime dataCadastro;
  final String telefone;
  final String obs;
  final Uint8List? foto;
  final bool favorito;
  final List<String> categorias;
  final DateTime? aniversario;

  Contato comFavorito(bool valor) => Contato(
        id: id,
        nome: nome,
        email: email,
        cidade: cidade,
        empresa: empresa,
        dataCadastro: dataCadastro,
        telefone: telefone,
        obs: obs,
        foto: foto,
        favorito: valor,
        categorias: categorias,
        aniversario: aniversario,
      );

  String get initials {
    final parts = nome.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0].toUpperCase();
    if (parts.length == 1) return first;
    return '$first${parts.last[0].toUpperCase()}';
  }

  String get aniversarioFormatado {
    final data = aniversario;
    if (data == null) return '';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
  }

  // Dias até o próximo aniversário, com hoje valendo 0.
  int? diasParaAniversario(DateTime hoje) {
    final data = aniversario;
    if (data == null) return null;
    final base = DateTime(hoje.year, hoje.month, hoje.day);
    var proximo = DateTime(base.year, data.month, data.day);
    if (proximo.isBefore(base)) {
      proximo = DateTime(base.year + 1, data.month, data.day);
    }
    return proximo.difference(base).inDays;
  }
}
