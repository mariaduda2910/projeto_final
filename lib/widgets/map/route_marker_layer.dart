// 🆕 lib/widgets/map/route_marker_layer.dart
// Marcadores numerados da rota: ① ② ③
// RESPONSABILIDADE: Laura | USADO POR: PoiExplorerScreen

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/itinerary_event_model.dart';

class RouteMarkerLayer extends StatelessWidget {
  final List<ItineraryEvent> eventos;
  final Function(ItineraryEvent)? onTap;

  const RouteMarkerLayer({super.key, required this.eventos, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: eventos.map((evento) => Marker(
        point: LatLng(evento.poiLatitude, evento.poiLongitude),
        width: 40, height: 40,
        child: GestureDetector(
          onTap: () => onTap?.call(evento),
          child: _buildMarcador(evento),
        ),
      )).toList(),
    );
  }

  Widget _buildMarcador(ItineraryEvent evento) {
    return Container(
      decoration: BoxDecoration(
        color: evento.visitado ? Colors.green : Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Text('${evento.ordem}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}
