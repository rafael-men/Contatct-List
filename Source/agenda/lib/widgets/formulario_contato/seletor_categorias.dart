import 'package:flutter/material.dart';

class SeletorCategorias extends StatelessWidget {
  const SeletorCategorias({
    super.key,
    required this.categorias,
    required this.selecionadas,
    required this.onChanged,
  });

  final List<String> categorias;
  final Set<String> selecionadas;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categorias', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final categoria in categorias)
              FilterChip(
                label: Text(categoria),
                selected: selecionadas.contains(categoria),
                onSelected: (selecionada) {
                  final novas = Set<String>.of(selecionadas);
                  if (selecionada) {
                    novas.add(categoria);
                  } else {
                    novas.remove(categoria);
                  }
                  onChanged(novas);
                },
              ),
          ],
        ),
      ],
    );
  }
}
