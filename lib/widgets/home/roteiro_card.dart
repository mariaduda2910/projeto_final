// 🆕 lib/widgets/home/roteiro_card.dart
// Card do roteiro ativo na HomeScreen
// RESPONSABILIDADE: Laura | USADO POR: HomeScreen

import 'package:flutter/material.dart';
import '../../models/itinerary_model.dart';

class RoteiroCard extends StatelessWidget {
  final ItineraryModel? roteiro;
  final VoidCallback? onVerNoMapa;
  final VoidCallback? onVerDetalhes;
  final VoidCallback? onExplorar;

  const RoteiroCard({
    super.key, this.roteiro,
    this.onVerNoMapa, this.onVerDetalhes, this.onExplorar,
  });

  @override
  Widget build(BuildContext context) {
    if (roteiro == null) return _buildEmptyState(context);
    return _buildComRoteiro(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Nenhum roteiro ativo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Explora locais e cria o teu roteiro', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: onExplorar, icon: const Icon(Icons.explore), label: const Text('Explorar Locais')),
          ],
        ),
      ),
    );
  }

  Widget _buildComRoteiro(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7BD6), Color(0xFF4A90D9)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.map, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(roteiro!.titulo, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${roteiro!.totalParagens} paragens', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < roteiro!.eventos.length && i < 3; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _buildMiniParagem(roteiro!.eventos[i]),
            ],
            if (roteiro!.eventos.length > 3)
              Text('+${roteiro!.eventos.length - 3} mais...', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onVerNoMapa,
                icon: const Icon(Icons.route, color: Color(0xFF2E7BD6)),
                label: const Text('Ver no Mapa', style: TextStyle(color: Color(0xFF2E7BD6))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniParagem(dynamic evento) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(child: Text(evento.poiNome, style: const TextStyle(color: Colors.white, fontSize: 14))),
      ],
    );
  }
}
