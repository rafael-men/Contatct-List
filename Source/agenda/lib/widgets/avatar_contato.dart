import 'dart:typed_data';
import 'package:flutter/material.dart';

class AvatarContato extends StatelessWidget {
  const AvatarContato({
    super.key,
    required this.initials,
    this.foto,
    this.radius = 20,
  });

  final String initials; 
  final Uint8List? foto;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = foto;

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      backgroundImage: bytes != null ? MemoryImage(bytes) : null,
      child:bytes == null ? Text(initials, style: TextStyle(fontSize:radius*0.75, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer,)) 
      : null,
    );
  }
}