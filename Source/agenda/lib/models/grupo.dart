class Grupo {
  Grupo({required this.id, required this.nome, Set<String>? membros})
      : membros = membros ?? <String>{};

  final String id;
  final String nome;
  final Set<String> membros;
}
