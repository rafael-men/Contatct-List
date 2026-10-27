import 'package:flutter/material.dart';

class CamposBasicosContato extends StatelessWidget {
  const CamposBasicosContato({
    super.key,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cidade,
    required this.empresa,
    required this.observacoes,
    required this.autofocusNome,
  });

  final TextEditingController nome;
  final TextEditingController email;
  final TextEditingController telefone;
  final TextEditingController cidade;
  final TextEditingController empresa;
  final TextEditingController observacoes;
  final bool autofocusNome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nome,
          autofocus: autofocusNome,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nome',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: _validarNome,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-mail (opcional)',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          validator: _validarEmail,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: telefone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefone (opcional)',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          validator: _validarTelefone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: cidade,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Cidade (opcional)',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: empresa,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Empresa (opcional)',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: observacoes,
          maxLines: 4,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Observações (opcional)',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.notes),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

String? _validarNome(String? valor) {
  final nome = valor?.trim() ?? '';
  if (nome.isEmpty) return 'Nome é obrigatório';
  if (nome.length < 3) return 'Nome muito curto';
  if (nome.length > 80) return 'Nome muito longo';
  return null;
}

String? _validarEmail(String? valor) {
  final email = valor?.trim() ?? '';
  if (email.isEmpty) return null;
  final valido = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email);
  return valido ? null : 'E-mail inválido';
}

String? _validarTelefone(String? valor) {
  final telefone = valor?.trim() ?? '';
  if (telefone.isEmpty) return null;
  if (!RegExp(r'^[0-9()+\-\s]+$').hasMatch(telefone)) {
    return 'Só números, +, espaços e ().-';
  }
  if (telefone.replaceAll(RegExp(r'\D'), '').length < 6) {
    return 'Telefone muito curto';
  }
  return null;
}
