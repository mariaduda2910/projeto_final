// 🆕 lib/widgets/itinerary/periodo_selector.dart
// Seletor de período do dia: Manhã | Tarde | Noite
// RESPONSABILIDADE: Laura | USADO POR: AddToRoteiroModal, EventCard

import 'package:flutter/material.dart';
import '../../models/itinerary_event_model.dart';

class PeriodoSelector extends StatelessWidget {
  final PeriodoDia? periodoSelecionado;
  final Function(PeriodoDia) onSelecionar;

  const PeriodoSelector({super.key, this.periodoSelecionado, required this.onSelecionar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildOpcao(PeriodoDia.manha, '🌅 Manhã'),
        _buildOpcao(PeriodoDia.tarde, '☀️ Tarde'),
        _buildOpcao(PeriodoDia.noite, '🌙 Noite'),
      ],
    );
  }

  Widget _buildOpcao(PeriodoDia periodo, String label) {
    final isSelecionado = periodoSelecionado == periodo;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => onSelecionar(periodo),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelecionado ? Colors.blue : Colors.grey[200],
            foregroundColor: isSelecionado ? Colors.white : Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
