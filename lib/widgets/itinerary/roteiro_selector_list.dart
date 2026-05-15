// 🆕 lib/widgets/itinerary/roteiro_selector_list.dart
// Lista de roteiros para seleção
// RESPONSABILIDADE: Laura | USADO POR: AddToRoteiroModal

import 'package:flutter/material.dart';
import '../../models/itinerary_model.dart';

class RoteiroSelectorList extends StatelessWidget {
  final List<ItineraryModel> roteiros;
  final String? roteiroSelecionadoId;
  final Function(String) onSelecionar;
  final VoidCallback onCriarNovo;

  const RoteiroSelectorList({
    super.key, required this.roteiros, this.roteiroSelecionadoId,
    required this.onSelecionar, required this.onCriarNovo,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: roteiros.length + 1,
      itemBuilder: (context, index) {
        if (index == roteiros.length) {
          return ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
            title: const Text('Criar novo roteiro'),
            onTap: onCriarNovo,
          );
        }
        final roteiro = roteiros[index];
        return ListTile(
          leading: Radio<String>(
            value: roteiro.id, groupValue: roteiroSelecionadoId,
            onChanged: (id) => onSelecionar(id!),
          ),
          title: Text(roteiro.titulo),
          subtitle: Text('${roteiro.totalParagens} paragens'),
          trailing: roteiro.isAtivo
              ? Chip(label: const Text('Ativo'), backgroundColor: Colors.blue[100])
              : null,
        );
      },
    );
  }
}
