// 🆕 lib/widgets/map/active_route_widget.dart
// ⭐ WIDGET FLUTUANTE DA ROTA ATIVA NO MAPA ⭐
// RESPONSABILIDADE: Laura | USADO POR: PoiExplorerScreen

import 'package:flutter/material.dart';
import '../../models/itinerary_model.dart';

class ActiveRouteWidget extends StatelessWidget {
  final ItineraryModel roteiro;
  final VoidCallback? onVerDetalhes;
  final VoidCallback? onOcultar;
  final VoidCallback? onNavegarParaProximo;

  const ActiveRouteWidget({
    super.key, required this.roteiro,
    this.onVerDetalhes, this.onOcultar, this.onNavegarParaProximo,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80, left: 16, right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.route, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(roteiro.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${roteiro.totalParagens} paragens', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.keyboard_arrow_up), onPressed: onOcultar),
                ],
              ),
              const Divider(),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: roteiro.eventos.length,
                  separatorBuilder: (_, __) => const Icon(Icons.arrow_forward, size: 16),
                  itemBuilder: (context, index) {
                    final evento = roteiro.eventos[index];
                    return Chip(
                      avatar: CircleAvatar(radius: 10, child: Text('${evento.ordem}', style: const TextStyle(fontSize: 10))),
                      label: Text(evento.poiNome, style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onVerDetalhes,
                      icon: const Icon(Icons.list, size: 18),
                      label: const Text('Detalhes'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNavegarParaProximo,
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navegar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
