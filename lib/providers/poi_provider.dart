// Provider: estado dos pontos turísticos
import 'package:flutter/material.dart';
import '../models/poi_model.dart';
import '../core/utils/helpers.dart';

/// Provider que gere a lista de pontos turísticos.
class PoiProvider extends ChangeNotifier {
  List<PoiModel> _pois = [];
  List<PoiModel> _poisFiltrados = [];
  bool _aCarregar = false;
  final List<String> _poisSelecionados = []; // IDs dos POIs na rota

  List<PoiModel> get pois => _poisFiltrados;
  bool get aCarregar => _aCarregar;
  List<PoiModel> get rota =>
      _pois.where((p) => _poisSelecionados.contains(p.id)).toList();

  /// Carrega pontos turísticos (mock por enquanto).
  Future<void> carregarPois() async {
    _aCarregar = true;
    notifyListeners();

    // SIMULAÇÃO: dados mockados do Algarve
    await Future.delayed(const Duration(seconds: 1));

    _pois = [
      PoiModel(
        id: '1',
        nome: 'Praia da Marinha',
        descricao: 'Uma das praias mais bonitas do mundo.',
        categoria: 'praia',
        latitude: 37.0891,
        longitude: -8.4113,
        endereco: 'Lagoa, Algarve',
        horaAbertura: '00:00',
        horaFecho: '23:59',
        avaliacao: 4.9,
        //imagemUrl: null,
      ),
      PoiModel(
        id: '2',
        nome: 'Ponta da Piedade',
        descricao: 'Formações rochosas impressionantes em Lagos.',
        categoria: 'monumento',
        latitude: 37.0808,
        longitude: -8.6684,
        endereco: 'Lagos, Algarve',
        horaAbertura: '08:00',
        horaFecho: '20:00',
        avaliacao: 4.8,
        //imagemUrl: null,
      ),
    ];

    _poisFiltrados = List.from(_pois);
    _aCarregar = false;
    notifyListeners();
  }

  /// Ordena POIs por proximidade a uma coordenada.
  void ordenarPorProximidade(double lat, double lng) {
    _poisFiltrados.sort((a, b) {
      final distA =
          Helpers.calcularDistancia(lat, lng, a.latitude, a.longitude);
      final distB =
          Helpers.calcularDistancia(lat, lng, b.latitude, b.longitude);
      return distA.compareTo(distB);
    });
    notifyListeners();
  }

  /// Filtra apenas os que estão abertos agora.
  void filtrarAbertosAgora() {
    _poisFiltrados = _pois.where((poi) {
      return Helpers.estaAberto(poi.horaAbertura, poi.horaFecho);
    }).toList();
    notifyListeners();
  }

  /// Mostra todos novamente.
  void mostrarTodos() {
    _poisFiltrados = List.from(_pois);
    notifyListeners();
  }

  /// Adiciona/remove um POI da rota do turista.
  void toggleSelecaoRota(String poiId) {
    if (_poisSelecionados.contains(poiId)) {
      _poisSelecionados.remove(poiId);
    } else {
      _poisSelecionados.add(poiId);
    }
    notifyListeners();
  }

  /// Ordena a rota selecionada por proximidade (TSP simplificado).
  void ordenarRotaPorProximidade(double lat, double lng) {
    // Implementação futura: algoritmo do vizinho mais próximo
    notifyListeners();
  }
}
