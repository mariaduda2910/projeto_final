// lib/views/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold é necessário para ter o SafeArea e o bottomNavigationBar
      body: SafeArea( //safe area para evitar notch, barra de status, etc porque??
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Bem-vindo ao Algarve! 🌊',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Planeia a tua próxima aventura',
                style: TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 32),

              // CARD: ROTEIRO/ITINERÁRIO
              _buildRoteiroCard(context),

              const SizedBox(height: 24),

              // CARD: FAVORITOS RÁPIDOS
              _buildFavoritosRapidos(context),

              const SizedBox(height: 24),

              // MERCHANDISING (placeholder)
              _buildMerchandising(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoteiroCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF4A90D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.map, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'O Meu Roteiro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '3 paragens • 12 km',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mini lista de paragens
              _buildMiniParagem('Praia da Marinha', 'Praia', Colors.amber),
              const SizedBox(height: 8),
              _buildMiniParagem(
                  'Restaurante O Leão', 'Restaurante', Colors.red),
              const SizedBox(height: 8),
              _buildMiniParagem('Castelo de Silves', 'Monumento', Colors.teal),

              const SizedBox(height: 16),
              // Botão
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navegar para Mapa com rota
                    // TODO: Implementar
                  },
                  icon: const Icon(Icons.route, color: AppColors.primary),
                  label: const Text(
                    'Ver no Mapa',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniParagem(String nome, String tipo, Color cor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            nome,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        Text(
          tipo,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFavoritosRapidos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Favoritos Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                // Ir para Mapa > Favoritos
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Lista horizontal de favoritos
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFavoritoCard(
                  'Praia da Marinha', Icons.beach_access, Colors.amber),
              _buildFavoritoCard('O Leão', Icons.restaurant, Colors.red),
              _buildFavoritoCard(
                  'Castelo Silves', Icons.account_balance, Colors.teal),
            ],
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            nome,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMerchandising(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Merchandising',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            color: Colors.grey[300],
            child: const Center(child: Text('Em breve...')),
          ),
        ],
      ),
    );
  }
}
