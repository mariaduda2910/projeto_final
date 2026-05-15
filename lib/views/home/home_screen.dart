// lib/views/home/home_screen.dart — ATUALIZADO
// Card de roteiro com botão "Criar Roteiro" quando vazio
import 'package:algarve_explorer/models/itinerary_event_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/itinerary_model.dart';
import '../../providers/itinerary_provider.dart';
import '../itinerary/itinerary_list_screen.dart';
import '../itinerary/itinerary_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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

              // CARD: ROTEIRO (funcional)
              _buildRoteiroCard(context),

              const SizedBox(height: 24),

              // CARD: FAVORITOS RÁPIDOS
              _buildFavoritosRapidos(context),

              const SizedBox(height: 24),

              // MERCHANDISING
              _buildMerchandising(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoteiroCard(BuildContext context) {
    return Consumer<ItineraryProvider>(
      builder: (context, provider, _) {
        final roteiroAtivo = provider.roteiroAtivo;

        // Se tem roteiro ativo, mostra-o. Se não, mostra card vazio com botão criar.
        if (roteiroAtivo != null) {
          return _buildRoteiroAtivoCard(context, roteiroAtivo);
        }

        return _buildRoteiroVazioCard(context);
      },
    );
  }

  // ─── CARD COM ROTEIRO ATIVO ───
  Widget _buildRoteiroAtivoCard(BuildContext context, ItineraryModel roteiro) {
    final eventos = roteiro.eventos;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roteiro.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${eventos.length} paragens • ${Helpers.formatarData(roteiro.dataInicio)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ATIVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mini lista de paragens (máx 3)
              if (eventos.isNotEmpty) ...[
                ...eventos.take(3).map((evento) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildMiniParagem(
                      evento.poiNome,
                      _labelPeriodo(evento.periodo),
                      _corPeriodo(evento.periodo),
                    ),
                  );
                }),
                if (eventos.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${eventos.length - 3} mais paragens',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ] else
                Text(
                  'Ainda sem paragens. Adiciona locais do mapa!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),

              const SizedBox(height: 16),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItineraryDetailScreen(roteiro: roteiro),
                          ),
                        );
                      },
                      icon: const Icon(Icons.route, color: AppColors.primary, size: 18),
                      label: const Text(
                        'Ver Roteiro',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/itinerary/list');
                      },
                      icon: const Icon(Icons.list, color: Colors.white, size: 18),
                      label: const Text(
                        'Todos os Roteiros',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  // ─── CARD VAZIO COM BOTÃO CRIAR ───
  Widget _buildRoteiroVazioCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.map_outlined,
                  color: AppColors.primary.withOpacity(0.5),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ainda não tens roteiros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cria o teu primeiro roteiro para explorar o Algarve',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ItineraryListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Roteiro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          tipo,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Color _corPeriodo(PeriodoDia? periodo) {
    switch (periodo) {
      case PeriodoDia.manha:
        return Colors.orange;
      case PeriodoDia.tarde:
        return Colors.white;
      case PeriodoDia.noite:
        return const Color(0xFFD1C4E9);
      default:
        return Colors.white70;
    }
  }

   String _labelPeriodo(PeriodoDia? periodo) {
    switch (periodo) {
      case PeriodoDia.manha:
        return 'Manhã';
      case PeriodoDia.tarde:
        return 'Tarde';
      case PeriodoDia.noite:
        return 'Noite';
      default:
        return 'Sem período';
    }
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
              onPressed: () {},
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
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