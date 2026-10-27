import 'package:agenda/models/dados_contato.dart';
import 'package:flutter/foundation.dart';
import '../models/contato.dart';
import '../models/grupo.dart';

class ContatoStore extends ChangeNotifier {

  final List<Contato> _contacts = <Contato>[];
  final Set<String> _categorias = <String>{'Família', 'Amigos', 'Trabalho'};
  final List<Grupo> _grupos = <Grupo>[];
  String _query = '';
  int _nextId = 1;
  int _nextGrupoId = 1;

  String get query => _query;
  int get totalCount => _contacts.length;
  int get totalFavoritos => _contacts.where((Contato c) => c.favorito).length;

  List<Contato> get todos => _ordenados(_contacts);

  List<Contato> get contacts {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return todos;
    return _ordenados(_contacts.where((Contato c) {
      return c.nome.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.telefone.contains(q);
    }));
  }

  List<Contato> get favoritos =>
      _ordenados(_contacts.where((Contato c) => c.favorito));

  List<Contato> _ordenados(Iterable<Contato> lista) {
    final copia = lista.toList();
    copia.sort((Contato a, Contato b) =>
        a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return copia;
  }

  List<String> get categorias => _categorias.toList()..sort();

  bool addCategoria(String nome) {
    final limpo = nome.trim();
    if (limpo.isEmpty) return false;
    final criada = _categorias.add(limpo);
    if (criada) notifyListeners();
    return criada;
  }

  int contatosNaCategoria(String categoria) =>
      _contacts.where((Contato c) => c.categorias.contains(categoria)).length;

  List<Grupo> get grupos => List.of(_grupos);

  Grupo criarGrupo(String nome) {
    final grupo = Grupo(id: '${_nextGrupoId++}', nome: nome.trim());
    _grupos.add(grupo);
    notifyListeners();
    return grupo;
  }

  List<Contato> membrosDe(Grupo grupo) =>
      _ordenados(grupo.membros.map(porId).whereType<Contato>());

  void alternarMembro(Grupo grupo, String contatoId) {
    if (!grupo.membros.remove(contatoId)) {
      grupo.membros.add(contatoId);
    }
    notifyListeners();
  }

  List<Contato> get aniversariantesDoMes {
    final mes = DateTime.now().month;
    final lista =
        _contacts.where((Contato c) => c.aniversario?.month == mes).toList();
    lista.sort((Contato a, Contato b) =>
        a.aniversario!.day.compareTo(b.aniversario!.day));
    return lista;
  }

  List<Contato> get proximosAniversarios {
    final hoje = DateTime.now();
    final lista = _contacts
        .where((Contato c) => (c.diasParaAniversario(hoje) ?? 999) <= 30)
        .toList();
    lista.sort((Contato a, Contato b) => a
        .diasParaAniversario(hoje)!
        .compareTo(b.diasParaAniversario(hoje)!));
    return lista;
  }

  Contato? porId(String id) {
    for (final contato in _contacts) {
      if (contato.id == id) return contato;
    }
    return null;
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void add(DadosContato dados) {
    _contacts.add(
      Contato(
        id: '${_nextId++}',
        nome: dados.nome,
        email: dados.email,
        telefone: dados.telefone,
        cidade: dados.cidade,
        empresa: dados.empresa,
        obs: dados.observacoes,
        foto: dados.foto,
        categorias: dados.categorias,
        aniversario: dados.aniversario,
        dataCadastro: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  List<Contato> filtrarContatos({
    required List<Contato> contatos,
    String? categoria,
    String? cidade,
    String? empresa,
    DateTime? cadastradoDe,
    DateTime? cadastradoAte,
  }) {
    return contatos.where((contato) {
    final correspondeCategoria =
        categoria == null || contato.categorias.contains(categoria);

    final correspondeCidade = cidade == null ||
        contato.cidade.toLowerCase().contains(cidade.toLowerCase());

    final correspondeEmpresa = empresa == null ||
        contato.empresa.toLowerCase().contains(empresa.toLowerCase());

    final correspondeDataInicial = cadastradoDe == null ||
        !contato.dataCadastro.isBefore(cadastradoDe);

    final correspondeDataFinal = cadastradoAte == null ||
        !contato.dataCadastro.isAfter(cadastradoAte);

    return correspondeCategoria &&
        correspondeCidade &&
        correspondeEmpresa &&
        correspondeDataInicial &&
        correspondeDataFinal;
  }).toList();
  }

  void importarContatos(List<Contato> importados) {
    for (final contato in importados) {
      _contacts.add(
        Contato(
          id: '${_nextId++}',
          nome: contato.nome,
          email: contato.email,
          telefone: contato.telefone,
          cidade: contato.cidade,
          empresa: contato.empresa,
          obs: contato.obs,
          foto: contato.foto,
          favorito: contato.favorito,
          categorias: List<String>.of(contato.categorias),
          aniversario: contato.aniversario,
          dataCadastro: contato.dataCadastro,
        ),
      );
      _categorias.addAll(contato.categorias);
    }
    if(importados.isNotEmpty) {
      notifyListeners();
    }
  }

  void update(Contato contato, DadosContato dados) {
    final index = _contacts.indexWhere((Contato c) => c.id == contato.id);
    if (index == -1) {
      return;
    }
    final atual = _contacts[index];
    _contacts[index] = Contato(
      id: atual.id,
      nome: dados.nome,
      email: dados.email,
      cidade: dados.cidade,
      empresa: dados.empresa,
      dataCadastro: atual.dataCadastro,
      telefone: dados.telefone,
      obs: dados.observacoes,
      foto: dados.removerFoto ? null : (dados.foto ?? atual.foto),
      favorito: atual.favorito,
      categorias: List<String>.of(dados.categorias),
      aniversario: dados.aniversario,
    );
    notifyListeners();
  }

  void toggleFavorito(Contato contato) {
    final index = _contacts.indexWhere((Contato c) => c.id == contato.id);
    if (index == -1) return;
    _contacts[index] = _contacts[index].comFavorito(!_contacts[index].favorito);
    notifyListeners();
  }

  void remove(Contato contact) {
    _contacts.removeWhere((Contato c) => c.id == contact.id);
    notifyListeners();
  }
}
