// 🆕 lib/widgets/itinerary/attachment_list.dart
// Lista de anexos (bilhetes, reservas, PDFs)
// RESPONSABILIDADE: Laura | USADO POR: EventCard, ItineraryDetailScreen

import 'package:flutter/material.dart';
import '../../models/itinerary_attachment_model.dart';

class AttachmentList extends StatelessWidget {
  final List<ItineraryAttachment> anexos;
  final Function(ItineraryAttachment)? onVisualizar;
  final Function(ItineraryAttachment)? onApagar;

  const AttachmentList({
    super.key, required this.anexos,
    this.onVisualizar, this.onApagar,
  });

  @override
  Widget build(BuildContext context) {
    if (anexos.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      children: anexos.map((anexo) => Chip(
        avatar: Text(anexo.tipoIcone),
        label: Text(anexo.nome, overflow: TextOverflow.ellipsis),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onApagar != null ? () => onApagar!(anexo) : null,
      )).toList(),
    );
  }
}
