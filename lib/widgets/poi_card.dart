// Widget: Card de ponto turístico para listas
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';
import '../models/poi_model.dart';

/// Card reutilizável para mostrar um ponto turístico na lista.
/// Usar: PoiCard(poi: meuPoi, onTap: () {})
class PoiCard extends StatelessWidget {
  final PoiModel poi;
  final VoidCallback? onTap;
  final bool isSelecionado;
  final VoidCallback? onToggleRota;
  final double? distanciaKm; // distância pré-calculada

  const PoiCard({
    super.key,
    required this.poi,
    this.onTap,
    this.isSelecionado = false,
    this.onToggleRota,
    this.distanciaKm,
  });

  @override
  Widget build(BuildContext context) {
    final bool aberto = Helpers.estaAberto(poi.horaAbertura, poi.horaFecho);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Ícone da categoria
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
                child: Icon(
                  _iconeCategoria(poi.categoria),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.nome,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      poi.endereco,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        // Estado aberto/fechado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: aberto 
                                ? AppColors.openStatus.withOpacity(0.1)
                                : AppColors.closedStatus.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            aberto ? 'Aberto' : 'Fechado',
                            style: TextStyle(
                              fontSize: 12,
                              color: aberto 
                                  ? AppColors.openStatus 
                                  : AppColors.closedStatus,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (distanciaKm != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            Helpers.formatarDistancia(distanciaKm!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botão adicionar à rota
              if (onToggleRota != null)
                IconButton(
                  onPressed: onToggleRota,
                  icon: Icon(
                    isSelecionado 
                        ? Icons.check_circle 
                        : Icons.add_circle_outline,
                    color: isSelecionado ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconeCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'praia':
        return Icons.beach_access;
      case 'restaurante':
        return Icons.restaurant;
      case 'monumento':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }
}