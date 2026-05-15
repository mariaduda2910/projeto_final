// 🆕 lib/widgets/map/route_info_card.dart
// Card informativo da rota (versão compacta)
// RESPONSABILIDADE: Laura | USADO POR: PoiExplorerScreen (opcional)

import 'package:flutter/material.dart';
import '../../models/itinerary_model.dart';

class RouteInfoCard extends StatelessWidget {
  final ItineraryModel roteiro;
  final VoidCallback? onExpandir;

  const RouteInfoCard({super.key, required this.roteiro, this.onExpandir});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.route, color: Colors.blue),
        title: Text(roteiro.titulo, overflow: TextOverflow.ellipsis),
        subtitle: Text('${roteiro.totalParagens} paragens'),
        trailing: const Icon(Icons.keyboard_arrow_up),
        onTap: onExpandir,
      ),
    );
  }
}
