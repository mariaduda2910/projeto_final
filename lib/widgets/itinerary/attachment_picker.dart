// 🆕 lib/widgets/itinerary/attachment_picker.dart
// Botão + sheet para adicionar anexos
// RESPONSABILIDADE: Laura | USADO POR: EventCard, ItineraryDetailScreen

import 'package:flutter/material.dart';

class AttachmentPicker extends StatelessWidget {
  final Function(String caminho, String tipo) onFicheiroSelecionado;
  const AttachmentPicker({super.key, required this.onFicheiroSelecionado});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.attach_file),
      onPressed: () => _mostrarOpcoes(context),
    );
  }

  void _mostrarOpcoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Câmara'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeria'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.insert_drive_file), title: const Text('Ficheiro (PDF)'), onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
