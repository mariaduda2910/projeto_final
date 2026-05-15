import 'package:latlong2/latlong.dart';

/// Resultado de um pedido à Geoapify Routing API.
///
/// Contém a polyline completa que segue as estradas reais, mais
/// distância total e tempo estimado de viagem.
class RouteResult {
  /// Pontos consecutivos que formam a linha do percurso.
  /// Usar diretamente num [Polyline] do flutter_map.
  final List<LatLng> polyline;

  /// Distância total em metros.
  final double distanciaMetros;

  /// Tempo de condução estimado em segundos.
  final double tempoSegundos;

  const RouteResult({
    required this.polyline,
    required this.distanciaMetros,
    required this.tempoSegundos,
  });

  /// Formata a distância: "12.3 km" ou "850 m".
  String get distanciaFormatada {
    if (distanciaMetros < 1000) return '${distanciaMetros.toStringAsFixed(0)} m';
    return '${(distanciaMetros / 1000).toStringAsFixed(1)} km';
  }

  /// Formata o tempo: "1h 20min" ou "45 min".
  String get tempoFormatado {
    final totalMin = (tempoSegundos / 60).round();
    if (totalMin < 60) return '$totalMin min';
    final horas = totalMin ~/ 60;
    final minutos = totalMin % 60;
    return minutos == 0 ? '${horas}h' : '${horas}h ${minutos}min';
  }
}
