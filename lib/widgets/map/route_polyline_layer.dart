// 🆕 lib/widgets/map/route_polyline_layer.dart
// Camada de polyline no mapa: linha azul entre pontos da rota
// RESPONSABILIDADE: Laura | USADO POR: PoiExplorerScreen

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/itinerary_event_model.dart';

class RoutePolylineLayer extends StatelessWidget {
  final List<ItineraryEvent> eventos;
  final Color cor;
  final double espessura;

  const RoutePolylineLayer({
    super.key, required this.eventos,
    this.cor = Colors.blue, this.espessura = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    if (eventos.length < 2) return const SizedBox.shrink();
    final pontos = eventos.map((e) => LatLng(e.poiLatitude, e.poiLongitude)).toList();
    return PolylineLayer(
      polylines: [Polyline(points: pontos, color: cor, strokeWidth: espessura)],
    );
  }
}
