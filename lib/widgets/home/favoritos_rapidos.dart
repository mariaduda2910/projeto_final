// 🆕 lib/widgets/home/favoritos_rapidos.dart
// Secção de favoritos rápidos na HomeScreen
// RESPONSABILIDADE: Laura | USADO POR: HomeScreen

import 'package:flutter/material.dart';

class FavoritosRapidos extends StatelessWidget {
  final List<Map<String, dynamic>> favoritos;
  final VoidCallback? onVerTodos;
  final Function(String nome)? onTapFavorito;

  const FavoritosRapidos({
    super.key, required this.favoritos,
    this.onVerTodos, this.onTapFavorito,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Favoritos Recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            TextButton(onPressed: onVerTodos, child: const Text('Ver todos')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final fav = favoritos[index];
              return _buildFavoritoCard(fav['nome'], fav['icone'] as IconData, fav['cor'] as Color);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritoCard(String nome, IconData icon, Color cor) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: cor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: cor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(nome, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
