import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/contato.dart';
import '../avatar_contato.dart';

class FotoContatoField extends StatefulWidget {
  const FotoContatoField({
    super.key,
    required this.foto,
    required this.nome,
    required this.onFotoAlterada,
  });

  final Uint8List? foto;
  final String nome;
  final void Function(Uint8List? foto, bool remover) onFotoAlterada;

  @override
  State<FotoContatoField> createState() => _FotoContatoFieldState();
}

class _FotoContatoFieldState extends State<FotoContatoField> {
  final _picker = ImagePicker();

  bool get _cameraDisponivel =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _escolherFoto() async {
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            if (_cameraDisponivel)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
          ],
        ),
      ),
    );
    if (origem == null) return;

    try {
      final imagem = await _picker.pickImage(
        source: origem,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (imagem == null) return;
      final bytes = await imagem.readAsBytes();
      if (!mounted) return;
      widget.onFotoAlterada(bytes, false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar a foto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AvatarContato(
            foto: widget.foto,
            initials: iniciais(widget.nome),
            radius: 44,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: _escolherFoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                widget.foto == null ? 'Adicionar foto' : 'Trocar foto',
              ),
            ),
            if (widget.foto != null)
              TextButton.icon(
                onPressed: () => widget.onFotoAlterada(null, true),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remover foto'),
              ),
          ],
        ),
      ],
    );
  }
}
