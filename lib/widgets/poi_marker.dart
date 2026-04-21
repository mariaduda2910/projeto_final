// Widget: Marcador personalizado no mapa
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants/app_constants.dart';
import '../models/poi_model.dart';

/// Marcador personalizado para o mapa.
/// Usar: PoiMarker(poi: meuPoi, onTap: () {})
class PoiMarker extends Marker {
  final PoiModel poi;
  final VoidCallback? onTap;

  PoiMarker({
    required this.poi,
    this.onTap,
  }) : super(
          point: LatLng(poi.latitude, poi.longitude),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: poi.isParceiro 
                        ? AppColors.secondary 
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.place,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                // "Tooltip" pequeno em baixo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4, 
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    poi.nome,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
}