import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/itinerary_provider.dart';

/// Bottom sheet que mostra os roteiros do utilizador e permite escolher qual
/// fica ativo no mapa (= caminho traçado).
class ActiveItineraryPicker extends StatelessWidget {
  const ActiveItineraryPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ItineraryProvider>(
        builder: (context, provider, _) {
          final roteiros = provider.roteiros;
          final ativo = provider.roteiroAtivo;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Escolher roteiro ativo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'O percurso será traçado no mapa',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (ativo != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TextButton.icon(
                      onPressed: () async {
                        await provider.definirRoteiroAtivo(null);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Ocultar roteiro do mapa'),
                    ),
                  ),
                if (roteiros.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        'Ainda não tens nenhum roteiro criado.\nSeleciona pontos no mapa e adiciona-os a um roteiro.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: roteiros.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (_, i) {
                        final r = roteiros[i];
                        final selecionado = ativo?.id == r.id;
                        return Card(
                          margin: EdgeInsets.zero,
                          color: selecionado
                              ? AppColors.primary.withOpacity(0.08)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.borderRadius),
                            side: BorderSide(
                              color: selecionado
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: selecionado
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              child: Icon(
                                selecionado ? Icons.check : Icons.map,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              r.titulo,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${r.totalParagens} ${r.totalParagens == 1 ? 'paragem' : 'paragens'}'
                              '${r.totalParagens == 0 ? ' · adiciona pontos primeiro' : ''}',
                            ),
                            trailing: selecionado
                                ? const Icon(Icons.radio_button_checked,
                                    color: AppColors.primary)
                                : const Icon(Icons.radio_button_unchecked),
                            onTap: () async {
                              await provider.definirRoteiroAtivo(r.id);
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
