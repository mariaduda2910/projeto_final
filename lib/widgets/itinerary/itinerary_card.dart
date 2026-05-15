// 🆕 lib/widgets/itinerary/itinerary_card.dart
// Card de roteiro (usado na lista de roteiros)
// RESPONSABILIDADE: Laura | USADO POR: ItineraryListScreen, RoteiroSelectorList

import 'package:flutter/material.dart';
import '../../models/itinerary_model.dart';

class ItineraryCard extends StatelessWidget {
  final ItineraryModel roteiro;
  final bool isSelecionado;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ItineraryCard({
    super.key, required this.roteiro,
    this.isSelecionado = false, this.onTap, this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelecionado ? Colors.blue.withOpacity(0.05) : null,
      child: ListTile(
        title: Text(roteiro.titulo),
        subtitle: Text('${roteiro.dataInicio.day}/${roteiro.dataInicio.month} — ${roteiro.dataFim.day}/${roteiro.dataFim.month}'),
        trailing: roteiro.isAtivo
            ? const Chip(label: Text('Ativo'), backgroundColor: Colors.blue)
            : null,
        onTap: onTap,
      ),
    );
  }
}
