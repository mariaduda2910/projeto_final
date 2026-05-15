import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/itinerary_provider.dart';

/// Cartão flutuante que aparece quando há um roteiro ativo no mapa.
/// Mostra título, paragens, distância e tempo da rota Geoapify.
class ActiveRouteInfo extends StatelessWidget {
  const ActiveRouteInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryProvider>(
      builder: (context, provider, _) {
        final ativo = provider.roteiroAtivo;
        if (ativo == null) return const SizedBox.shrink();

        final rota = provider.rotaCalculada;
        final calculando = provider.calculandoRota;
        final erro = provider.error;

        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.route,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ativo.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${ativo.totalParagens} ${ativo.totalParagens == 1 ? 'paragem' : 'paragens'}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Ocultar do mapa',
                      onPressed: () => provider.definirRoteiroAtivo(null),
                    ),
                  ],
                ),
                if (calculando)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text('A traçar a rota…',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                else if (rota != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.straighten,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          rota.distanciaFormatada,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Icon(Icons.schedule,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          rota.tempoFormatado,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (erro != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            size: 14, color: AppColors.error),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Não foi possível traçar a rota',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => provider.calcularRota(),
                          child: const Text('Tentar de novo'),
                        ),
                      ],
                    ),
                  )
                else if (ativo.totalParagens == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'Adiciona pontos ao roteiro para traçar a rota.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  )
                else if (provider.pontoPartida == null)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'A obter a tua localização para traçar a rota…',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
