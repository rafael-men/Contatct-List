import 'package:flutter/material.dart';

import '../models/contato.dart';
import 'avatar_contato.dart';

class BarraDeContatos extends StatelessWidget {
  const BarraDeContatos({
    super.key,
    required this.contact,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorito,
    this.mostrarAvatar = true,
    this.compacto = false,
  });

  final Contato contact;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorito;
  final bool mostrarAvatar;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasEmail = contact.email.isNotEmpty;
    final hasPhone = contact.telefone.isNotEmpty;

    return ListTile(
      onTap: onTap,
      dense: compacto,
      leading: mostrarAvatar
          ? AvatarContato(initials: contact.initials, foto: contact.foto)
          : null,
      title: Text(contact.nome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasEmail)
            Text(contact.email, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (hasPhone)
            Text(
              contact.telefone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (!hasEmail && !hasPhone)
            Text('Sem nenhum contato salvo', style: theme.textTheme.bodySmall),
        ],
      ),
      isThreeLine: hasEmail && hasPhone,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onToggleFavorito != null)
            IconButton(
              tooltip: contact.favorito
                  ? 'Remover dos favoritos'
                  : 'Adicionar aos favoritos',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                contact.favorito ? Icons.star : Icons.star_border,
                color: contact.favorito ? Colors.amber.shade700 : null,
              ),
              onPressed: onToggleFavorito,
            ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Editar',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Excluir',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
