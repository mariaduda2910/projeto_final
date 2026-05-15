import 'poi_model.dart';

/// Representa uma rota calculada entre pontos de interesse.
/// O [percurso] está ordenado pela ordem ótima de visita (Nearest Neighbor).
class RouteModel {
  final List<PoiModel> percurso;
  final double distanciaTotal; // km
  final int tempoEstimadoMin;  // minutos (condução + paragens)

  const RouteModel({
    required this.percurso,
    required this.distanciaTotal,
    required this.tempoEstimadoMin,
  });

  bool get isEmpty => percurso.isEmpty;
  int get numeroPontos => percurso.length;

  /// Formata o tempo estimado para exibição: "1h 20min" ou "45 min".
  String get tempoFormatado {
    if (tempoEstimadoMin < 60) return '$tempoEstimadoMin min';
    final horas = tempoEstimadoMin ~/ 60;
    final minutos = tempoEstimadoMin % 60;
    return minutos == 0 ? '${horas}h' : '${horas}h ${minutos}min';
  }

  /// Formata a distância total para exibição: "12.3 km".
  String get distanciaFormatada => '${distanciaTotal.toStringAsFixed(1)} km';
}
