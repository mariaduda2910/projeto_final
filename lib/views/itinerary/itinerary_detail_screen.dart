// lib/views/itinerary/itinerary_detail_screen.dart — FUNCIONAL
// Detalhe do roteiro + Visualização em ROTA no mapa
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/itinerary_model.dart';
import '../../models/itinerary_event_model.dart';
import '../../providers/itinerary_provider.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final ItineraryModel roteiro;
  const ItineraryDetailScreen({super.key, required this.roteiro});

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ─── CORES POR PERÍODO ───
  Color _corPeriodo(PeriodoDia? periodo) {
    switch (periodo) {
      case PeriodoDia.manha:
        return Colors.orange;
      case PeriodoDia.tarde:
        return AppColors.primary;
      case PeriodoDia.noite:
        return const Color(0xFF5B4B8A);
      default:
        return Colors.grey;
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

  // ─── NAVEGAR PARA POI ───
  Future<void> _navegarParaPoi(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ─── MARCAR VISITADO ───
  Future<void> _marcarVisitado(String eventoId, bool visitado) async {
    final provider = context.read<ItineraryProvider>();
    await provider.marcarEventoVisitado(
      widget.roteiro.id,
      eventoId,
      visitado,
    );
  }

  // ─── REMOVER EVENTO ───
  Future<void> _removerEvento(String eventoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover paragem?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<ItineraryProvider>();
      await provider.removerEvento(widget.roteiro.id, eventoId);
    }
  }

  // ─── MAPA COM ROTA ───
  Widget _buildMapaRota() {
    final eventos = widget.roteiro.eventos;
    if (eventos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Sem paragens para mostrar no mapa',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Calcular bounds para fit
    final points = eventos
        .map((e) => LatLng(e.poiLatitude, e.poiLongitude))
        .toList();

    final center = points.length == 1
        ? points.first
        : LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length,
            points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length,
          );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: points.length == 1 ? 15 : 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.algarve.explorer',
            ),
            // Linha da rota (polyline)
            if (points.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 4,
                    color: AppColors.primary.withOpacity(0.7),
                    borderStrokeWidth: 1,
                    borderColor: Colors.white,
                  ),
                ],
              ),
            // Marcadores dos eventos
            MarkerLayer(
              markers: eventos.map((evento) {
                final cor = _corPeriodo(evento.periodo);
                return Marker(
                  point: LatLng(evento.poiLatitude, evento.poiLongitude),
                  width: 50,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _mostrarInfoEvento(evento),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: evento.visitado ? Colors.green : cor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (evento.visitado ? Colors.green : cor)
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: evento.visitado
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${evento.ordem}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: evento.visitado ? Colors.green : cor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          transform: Matrix4.rotationZ(0.785),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Legenda
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Legenda',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildLegendaItem(Colors.orange, 'Manhã'),
                const SizedBox(height: 4),
                _buildLegendaItem(AppColors.primary, 'Tarde'),
                const SizedBox(height: 4),
                _buildLegendaItem(const Color(0xFF5B4B8A), 'Noite'),
                const SizedBox(height: 4),
                _buildLegendaItem(Colors.green, 'Visitado'),
              ],
            ),
          ),
        ),

        // Botão "Navegar rota completa"
        if (points.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () => _navegarRotaCompleta(points),
              icon: const Icon(Icons.navigation),
              label: const Text('Navegar Rota Completa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLegendaItem(Color cor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Future<void> _navegarRotaCompleta(List<LatLng> points) async {
    if (points.isEmpty) return;
    final dest = points.last;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}&waypoints=${points.sublist(0, points.length - 1).map((p) => '${p.latitude},${p.longitude}').join('|')}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _mostrarInfoEvento(ItineraryEvent evento) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _corPeriodo(evento.periodo).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${evento.ordem}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _corPeriodo(evento.periodo),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.poiNome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _labelPeriodo(evento.periodo),
                          style: TextStyle(
                            fontSize: 13,
                            color: _corPeriodo(evento.periodo),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (evento.poiEndereco != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        evento.poiEndereco!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _navegarParaPoi(evento.poiLatitude, evento.poiLongitude);
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navegar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _marcarVisitado(evento.id, !evento.visitado);
                      },
                      icon: Icon(
                        evento.visitado
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(evento.visitado ? 'Visitado' : 'Marcar visitado'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            evento.visitado ? Colors.green : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── LISTA DE EVENTOS ───
  Widget _buildListaEventos() {
    final eventos = widget.roteiro.eventos;
    if (eventos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Ainda não há paragens neste roteiro',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'Adiciona locais do mapa!',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventos.length,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        final reordered = List<ItineraryEvent>.from(eventos);
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);

        // Atualiza ordem
        for (int i = 0; i < reordered.length; i++) {
          reordered[i] = reordered[i].copyWith(ordem: i + 1);
        }

        final provider = context.read<ItineraryProvider>();
        await provider.reordenarEventos(
          widget.roteiro.id,
          reordered.map((e) => e.id).toList(),
        );
      },
      itemBuilder: (context, index) {
        final evento = eventos[index];
        final cor = _corPeriodo(evento.periodo);

        return Card(
          key: ValueKey(evento.id),
          margin: const EdgeInsets.only(bottom: 12),
          elevation: evento.visitado ? 1 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: evento.visitado
                ? BorderSide(color: Colors.green.withOpacity(0.5), width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: evento.visitado ? Colors.green : cor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: evento.visitado
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : Text(
                        '${evento.ordem}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            title: Text(
              evento.poiNome,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: evento.visitado ? TextDecoration.lineThrough : null,
                color: evento.visitado ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _labelPeriodo(evento.periodo),
                        style: TextStyle(
                          fontSize: 11,
                          color: cor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (evento.poiEndereco != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          evento.poiEndereco!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    evento.visitado
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: evento.visitado ? Colors.green : Colors.grey[400],
                  ),
                  onPressed: () => _marcarVisitado(evento.id, !evento.visitado),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                  onPressed: () => _removerEvento(evento.id),
                ),
              ],
            ),
            onTap: () => _navegarParaPoi(evento.poiLatitude, evento.poiLongitude),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roteiro.titulo),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Paragens'),
            Tab(icon: Icon(Icons.map), text: 'Rota'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListaEventos(),
          _buildMapaRota(),
        ],
      ),
    );
  }
}