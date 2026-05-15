// 🆕 lib/widgets/itinerary/event_card.dart
// Card de evento (paragem) na timeline do roteiro
// RESPONSABILIDADE: Laura | USADO POR: ItineraryDetailScreen

import 'package:flutter/material.dart';
import '../../models/itinerary_event_model.dart';

class EventCard extends StatelessWidget {
  final ItineraryEvent evento;
  final bool isUltimo;
  final VoidCallback? onTap;
  final VoidCallback? onMarcarVisitado;

  const EventCard({
    super.key, required this.evento,
    this.isUltimo = false, this.onTap, this.onMarcarVisitado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            CircleAvatar(child: Text('${evento.ordem}')),
            if (!isUltimo) Container(width: 2, height: 50, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: ListTile(
              title: Text(evento.poiNome),
              subtitle: Text(_periodoTexto),
              trailing: evento.visitado
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  String get _periodoTexto {
    switch (evento.periodo) {
      case PeriodoDia.manha: return '🌅 Manhã';
      case PeriodoDia.tarde: return '☀️ Tarde';
      case PeriodoDia.noite: return '🌙 Noite';
      default: return '';
    }
  }
}
