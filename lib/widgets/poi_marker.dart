// lib/widgets/poi_marker_card.dart
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/poi_model.dart';

/// Card flutuante que aparece quando clicas num pin no mapa.
/// 
/// Uso:
/// PoiMarkerCard(
///   poi: meuPoi,
///   onVerDetalhes: () => navegarParaDetalhes(),
///   onToggleFavorito: () => adicionarAosFavoritos(),
///   isFavorito: false,
/// )
class PoiMarkerCard extends StatelessWidget {
  final PoiModel poi;
  final VoidCallback onVerDetalhes;
  final VoidCallback onToggleFavorito;
  final bool isFavorito;

  const PoiMarkerCard({
    super.key,
    required this.poi,
    required this.onVerDetalhes,
    required this.onToggleFavorito,
    this.isFavorito = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Ícone + Nome + Rating
            Row(
              children: [
                // Ícone da categoria
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF4A90D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconeCategoria(poi.categoriaPrincipal ?? ''),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Info do POI
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poi.nome,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Rating
                          if (poi.avaliacao != null) ...[
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${poi.avaliacao}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Distância
                          if (poi.distancia != null) ...[
                            const Icon(Icons.route, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              _formatarDistancia(poi.distancia!),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Categoria + Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    poi.categoriaPrincipal ?? 'Local',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status aberto/fechado (se tiver horário)
                if (poi.horario != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Aberto agora',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // BOTÕES DE AÇÃO
            Row(
              children: [
                // ❤️ FAVORITO
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: onToggleFavorito,
                    icon: Icon(
                      isFavorito ? Icons.favorite : Icons.favorite_border,
                      color: isFavorito ? Colors.red : AppColors.textSecondary,
                    ),
                    label: Text(
                      isFavorito ? 'Guardado' : 'Guardar',
                      style: TextStyle(
                        color: isFavorito ? Colors.red : AppColors.textSecondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isFavorito ? Colors.red : AppColors.textSecondary.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // → VER DETALHES
                Expanded(
                  flex: 2,
                  child: _buildGradientButton(
                    text: 'Ver detalhes',
                    icon: Icons.arrow_forward,
                    onPressed: onVerDetalhes,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Botão com gradiente (estilo login)
  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF0052A3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formata distância em metros ou km
  String _formatarDistancia(double distancia) {
    if (distancia < 1000) {
      return '${distancia.round()} m';
    }
    return '${(distancia / 1000).toStringAsFixed(1)} km';
  }

  /// Ícone baseado na categoria
  IconData _iconeCategoria(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('restaurant')) return Icons.restaurant;
    if (cat.contains('cafe')) return Icons.local_cafe;
    if (cat.contains('bar')) return Icons.local_bar;
    if (cat.contains('hotel')) return Icons.hotel;
    if (cat.contains('museum')) return Icons.museum;
    if (cat.contains('pharmacy')) return Icons.local_pharmacy;
    if (cat.contains('supermarket')) return Icons.shopping_cart;
    if (cat.contains('beach')) return Icons.beach_access;
    if (cat.contains('park')) return Icons.park;
    if (cat.contains('tourism')) return Icons.attractions;
    return Icons.place;
  }
}