import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/poi_model.dart';
import '../../models/route_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/poi_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/poi_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _centroAlgarve = LatLng(37.1, -8.5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PoiProvider>().carregarPois();
      context.read<LocationProvider>().obterLocalizacao();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _calcularRota() {
    final pos = context.read<LocationProvider>().posicaoAtual;
    context.read<PoiProvider>().calcularRota(
          pos?.latitude ?? _centroAlgarve.latitude,
          pos?.longitude ?? _centroAlgarve.longitude,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildBottomSheet(),
          _buildTopBar(),
        ],
      ),
    );
  }

  // ─── Top overlay: back + center-on-me ────────────────────────────────────

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _MapIconButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            Consumer<LocationProvider>(
              builder: (_, loc, __) => _MapIconButton(
                icon: Icons.my_location,
                onTap: loc.posicaoAtual != null
                    ? () => _mapController.move(
                          LatLng(loc.posicaoAtual!.latitude,
                              loc.posicaoAtual!.longitude),
                          13,
                        )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Map ─────────────────────────────────────────────────────────────────

  Widget _buildMap() {
    return Consumer2<PoiProvider, LocationProvider>(
      builder: (_, poi, loc, __) {
        final rota = poi.rota;
        final userPos = loc.posicaoAtual;

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userPos != null
                ? LatLng(userPos.latitude, userPos.longitude)
                : _centroAlgarve,
            initialZoom: AppConstants.defaultMapZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.algarve_explorer',
            ),
            // Polyline da rota calculada
            if (rota.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: rota
                        .map((p) => LatLng(p.latitude, p.longitude))
                        .toList(),
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),
            // Marcadores dos POIs
            MarkerLayer(
              markers: poi.pois
                  .map((p) => _buildPoiMarker(p, poi.estaSelecionado(p.id)))
                  .toList(),
            ),
            // Posição do utilizador
            if (userPos != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point:
                        LatLng(userPos.latitude, userPos.longitude),
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Marker _buildPoiMarker(PoiModel poi, bool selecionado) {
    return Marker(
      point: LatLng(poi.latitude, poi.longitude),
      width: 54,
      height: 62,
      child: GestureDetector(
        onTap: () => context.read<PoiProvider>().toggleSelecaoRota(poi.id),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: selecionado
                    ? AppColors.accent
                    : poi.isParceiro
                        ? AppColors.secondary
                        : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                selecionado ? Icons.check : Icons.place,
                color: Colors.white,
                size: 18,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ],
              ),
              child: Text(
                poi.nome,
                style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom sheet ────────────────────────────────────────────────────────

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.33,
      minChildSize: 0.12,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, -2)),
            ],
          ),
          child: Consumer2<PoiProvider, LocationProvider>(
            builder: (_, poi, loc, __) => Column(
              children: [
                _buildHandle(),
                Expanded(
                  child: poi.aCarregar
                      ? const LoadingIndicator(
                          message: 'A carregar pontos...')
                      : _buildSheetContent(poi, loc, scrollController),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetContent(
    PoiProvider poi,
    LocationProvider loc,
    ScrollController sc,
  ) {
    final rota = poi.rotaCalculada;

    if (rota != null && !rota.isEmpty) {
      return _buildRotaCalculada(rota, poi, sc);
    }

    return _buildSelecao(poi, loc, sc);
  }

  // Estado: nenhuma rota calculada — lista de POIs com seleção
  Widget _buildSelecao(
      PoiProvider poi, LocationProvider loc, ScrollController sc) {
    final selecionados = poi.poisSelecionados;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selecionados.isEmpty
                      ? 'Toque nos pontos para selecionar'
                      : '${selecionados.length} ponto${selecionados.length > 1 ? 's' : ''} selecionado${selecionados.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (selecionados.isNotEmpty) ...[
                TextButton(
                  onPressed: poi.limparRota,
                  child: const Text('Limpar'),
                ),
                const SizedBox(width: AppSpacing.xs),
                CustomButton(
                  text: 'Calcular Rota',
                  icon: Icons.route,
                  onPressed: _calcularRota,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: sc,
            itemCount: poi.pois.length,
            itemBuilder: (_, i) {
              final p = poi.pois[i];
              final userPos = loc.posicaoAtual;
              final dist = userPos != null
                  ? Helpers.calcularDistancia(
                      userPos.latitude,
                      userPos.longitude,
                      p.latitude,
                      p.longitude,
                    )
                  : null;
              return PoiCard(
                poi: p,
                isSelecionado: poi.estaSelecionado(p.id),
                onToggleRota: () => poi.toggleSelecaoRota(p.id),
                distanciaKm: dist,
                onTap: () =>
                    _mapController.move(LatLng(p.latitude, p.longitude), 14),
              );
            },
          ),
        ),
      ],
    );
  }

  // Estado: rota calculada — resumo + lista ordenada
  Widget _buildRotaCalculada(
      RouteModel rota, PoiProvider poi, ScrollController sc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cartão de resumo
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius:
                  BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.route, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rota otimizada · ${rota.numeroPontos} pontos',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${rota.distanciaFormatada}  ·  ${rota.tempoFormatado}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: poi.limparRota,
                  tooltip: 'Limpar rota',
                ),
              ],
            ),
          ),
        ),
        // Lista de paragens na ordem otimizada
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
          child: Text(
            'Percurso sugerido',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: sc,
            itemCount: rota.percurso.length,
            itemBuilder: (_, i) {
              final p = rota.percurso[i];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Número da paragem
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppSpacing.md, top: 14),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PoiCard(
                      poi: p,
                      isSelecionado: true,
                      onTap: () => _mapController.move(
                          LatLng(p.latitude, p.longitude), 15),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// Botão circular flutuante sobre o mapa
class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _MapIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: onTap != null
                ? AppColors.primary
                : AppColors.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
