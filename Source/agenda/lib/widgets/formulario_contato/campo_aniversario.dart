import 'package:flutter/material.dart';

class CampoAniversario extends StatelessWidget {
  const CampoAniversario({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final DateTime? data;
  final ValueChanged<DateTime?> onChanged;

  String get _texto {
    final valor = data;
    if (valor == null) return '';
    return '${valor.day.toString().padLeft(2, '0')}/'
        '${valor.month.toString().padLeft(2, '0')}/${valor.year}';
  }

  Future<void> _escolher(BuildContext context) async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: data ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Data de nascimento',
    );
    if (escolhida != null) onChanged(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _escolher(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Aniversário (opcional)',
          prefixIcon: const Icon(Icons.cake_outlined),
          border: const OutlineInputBorder(),
          suffixIcon: data == null
              ? null
              : IconButton(
                  tooltip: 'Limpar data',
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(_texto.isEmpty ? 'Selecionar data' : _texto),
      ),
    );
  }
}
