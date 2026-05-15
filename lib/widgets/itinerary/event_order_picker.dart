// 🆕 lib/widgets/itinerary/event_order_picker.dart
// Escolher ordem do evento no roteiro
// RESPONSABILIDADE: Laura | USADO POR: AddToRoteiroModal

import 'package:flutter/material.dart';
import '../../models/itinerary_event_model.dart';

class EventOrderPicker extends StatefulWidget {
  final List<ItineraryEvent> eventosExistentes;
  final String novoEventoNome;
  final Function(int) onOrdemSelecionada;

  const EventOrderPicker({
    super.key, required this.eventosExistentes,
    required this.novoEventoNome, required this.onOrdemSelecionada,
  });

  @override
  State<EventOrderPicker> createState() => _EventOrderPickerState();
}

class _EventOrderPickerState extends State<EventOrderPicker> {
  int _posicaoInsercao = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Escolhe a ordem:'),
        for (int i = 0; i <= widget.eventosExistentes.length; i++) ...[
          if (i > 0) _buildEventoExistente(widget.eventosExistentes[i - 1]),
          _buildSlotInsercao(i + 1),
        ],
      ],
    );
  }

  Widget _buildEventoExistente(ItineraryEvent evento) {
    return ListTile(
      leading: CircleAvatar(child: Text('${evento.ordem}')),
      title: Text(evento.poiNome), dense: true,
    );
  }

  Widget _buildSlotInsercao(int posicao) {
    final isSelecionado = _posicaoInsercao == posicao;
    return InkWell(
      onTap: () { setState(() => _posicaoInsercao = posicao); widget.onOrdemSelecionada(posicao); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelecionado ? Colors.blue.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: isSelecionado ? Colors.blue : Colors.grey),
            const SizedBox(width: 8),
            Text(
              isSelecionado ? '🆕 ${widget.novoEventoNome}' : 'Inserir aqui',
              style: TextStyle(color: isSelecionado ? Colors.blue : Colors.grey, fontWeight: isSelecionado ? FontWeight.bold : null),
            ),
          ],
        ),
      ),
    );
  }
}
