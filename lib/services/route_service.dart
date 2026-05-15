import '../core/utils/helpers.dart';
import '../models/poi_model.dart';
import '../models/route_model.dart';

/// Calcula a rota ótima entre um conjunto de POIs selecionados.
///
/// Usa o algoritmo Nearest Neighbor (vizinho mais próximo), uma heurística
/// O(n²) para o Problema do Caixeiro Viajante (TSP).
/// Começa na posição atual do utilizador e visita sempre o POI não visitado
/// mais próximo.
class RouteService {
  // Velocidade média assumida em estrada do Algarve (km/h)
  static const double _velocidadeMediaKmH = 50.0;

  // Tempo de paragem por POI (minutos)
  static const int _tempoParagemMin = 15;

  /// Calcula a rota otimizada a partir da posição atual do utilizador.
  ///
  /// [pois] — lista de POIs selecionados pelo utilizador (sem ordem).
  /// [latAtual] / [lngAtual] — posição atual do utilizador (ponto de partida).
  ///
  /// Retorna um [RouteModel] com o percurso ordenado, distância total e tempo.
  RouteModel calcularRota({
    required List<PoiModel> pois,
    required double latAtual,
    required double lngAtual,
  }) {
    if (pois.isEmpty) {
      return const RouteModel(
        percurso: [],
        distanciaTotal: 0,
        tempoEstimadoMin: 0,
      );
    }

    final naoVisitados = List<PoiModel>.from(pois);
    final percurso = <PoiModel>[];
    double latCorrente = latAtual;
    double lngCorrente = lngAtual;
    double distanciaTotal = 0.0;

    // Nearest Neighbor: em cada passo, escolhe o POI não visitado mais próximo.
    while (naoVisitados.isNotEmpty) {
      PoiModel? maisProximo;
      double menorDist = double.infinity;

      for (final poi in naoVisitados) {
        final dist = Helpers.calcularDistancia(
          latCorrente,
          lngCorrente,
          poi.latitude,
          poi.longitude,
        );
        if (dist < menorDist) {
          menorDist = dist;
          maisProximo = poi;
        }
      }

      // Nunca é null aqui porque naoVisitados não está vazio.
      percurso.add(maisProximo!);
      distanciaTotal += menorDist;
      latCorrente = maisProximo.latitude;
      lngCorrente = maisProximo.longitude;
      naoVisitados.remove(maisProximo);
    }

    final tempoConducaoMin = (distanciaTotal / _velocidadeMediaKmH * 60).round();
    final tempoParagensMin = percurso.length * _tempoParagemMin;

    return RouteModel(
      percurso: percurso,
      distanciaTotal: distanciaTotal,
      tempoEstimadoMin: tempoConducaoMin + tempoParagensMin,
    );
  }

  /// Calcula a distância total de uma lista de POIs já ordenada.
  /// Útil para comparar diferentes ordenações.
  double calcularDistanciaTotalOrdenada({
    required List<PoiModel> percurso,
    required double latInicio,
    required double lngInicio,
  }) {
    if (percurso.isEmpty) return 0.0;

    double total = Helpers.calcularDistancia(
      latInicio,
      lngInicio,
      percurso.first.latitude,
      percurso.first.longitude,
    );

    for (int i = 0; i < percurso.length - 1; i++) {
      total += Helpers.calcularDistancia(
        percurso[i].latitude,
        percurso[i].longitude,
        percurso[i + 1].latitude,
        percurso[i + 1].longitude,
      );
    }

    return total;
  }
}
