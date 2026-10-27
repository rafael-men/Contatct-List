import 'package:flutter/material.dart';

import '../services/preferencias_app.dart';

class Configuracoes extends StatelessWidget {
  const Configuracoes({super.key, required this.preferencias});

  final PreferenciasApp preferencias;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Configurações')),
    body: ListenableBuilder(
      listenable: preferencias,
      builder: (context, _) => ListView(
        children: [
          const ListTile(title: Text('Aparência'), enabled: false),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema escuro'),
            value: preferencias.escuro,
            onChanged: preferencias.definirTema,
          ),
          const Divider(),
          const ListTile(title: Text('Backup'), enabled: false),
          SwitchListTile(
            secondary: const Icon(Icons.backup_outlined),
            title: const Text('Backup automático'),
            subtitle: const Text('Salvo nos documentos do aplicativo'),
            value: preferencias.backupAutomatico,
            onChanged: preferencias.definirBackup,
          ),
          if (preferencias.backupAutomatico)
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Frequência'),
              trailing: DropdownButton<int>(
                value: preferencias.intervaloBackup,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Diária')),
                  DropdownMenuItem(value: 7, child: Text('Semanal')),
                ],
                onChanged: (valor) {
                  if (valor != null) preferencias.definirIntervalo(valor);
                },
              ),
            ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Fazer backup agora'),
            onTap: () async {
              try {
                await preferencias.backupAgora();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Backup salvo nos documentos do aplicativo.',
                      ),
                    ),
                  );
                }
              } catch (erro) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Falha ao salvar backup: $erro')),
                  );
                }
              }
            },
          ),
          const Divider(),
          const ListTile(title: Text('Preferências'), enabled: false),
          SwitchListTile(
            secondary: const Icon(Icons.view_agenda_outlined),
            title: const Text('Lista compacta'),
            value: preferencias.listaCompacta,
            onChanged: preferencias.definirListaCompacta,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.account_circle_outlined),
            title: const Text('Mostrar fotos dos contatos'),
            value: preferencias.mostrarAvatares,
            onChanged: preferencias.definirAvatares,
          ),
        ],
      ),
    ),
  );
}
