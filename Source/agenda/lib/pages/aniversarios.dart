import 'package:flutter/material.dart';

import '../models/contato.dart';
import '../store/contato-store.dart';
import '../widgets/avatar_contato.dart';
import '../widgets/estado_vazio.dart';

class Aniversarios extends StatelessWidget {
  const Aniversarios({super.key, required this.store});

  final ContatoStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aniversários')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final doMes = store.aniversariantesDoMes;
          final proximos = store.proximosAniversarios;
          if (doMes.isEmpty && proximos.isEmpty) {
            return const EstadoVazio(
              icon: Icons.cake_outlined,
              title: 'Nenhum aniversário',
              message: 'Informe a data de nascimento em um contato.',
            );
          }

          final hoje = DateTime.now();
          return ListView(
            children: [
              const _Secao('Neste mês'),
              if (doMes.isEmpty)
                const ListTile(title: Text('Ninguém faz aniversário neste mês.'))
              else
                for (final contato in doMes)
                  _LinhaAniversario(contato: contato, hoje: hoje),
              const _Secao('Próximos 30 dias'),
              if (proximos.isEmpty)
                const ListTile(
                  title: Text('Nenhum aniversário nos próximos 30 dias.'),
                )
              else
                for (final contato in proximos)
                  _LinhaAniversario(contato: contato, hoje: hoje, comDias: true),
            ],
          );
        },
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        titulo,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _LinhaAniversario extends StatelessWidget {
  const _LinhaAniversario({
    required this.contato,
    required this.hoje,
    this.comDias = false,
  });

  final Contato contato;
  final DateTime hoje;
  final bool comDias;

  @override
  Widget build(BuildContext context) {
    final dias = contato.diasParaAniversario(hoje);
    final String lembrete;
    if (dias == 0) {
      lembrete = 'Hoje';
    } else if (dias == 1) {
      lembrete = 'Amanhã';
    } else {
      lembrete = 'Em $dias dias';
    }

    return ListTile(
      leading: AvatarContato(
        initials: contato.initials,
        foto: contato.foto,
      ),
      title: Text(contato.nome),
      subtitle: Text(contato.aniversarioFormatado),
      trailing: comDias ? Text(lembrete) : null,
    );
  }
}
