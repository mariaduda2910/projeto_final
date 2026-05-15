// Provider: estado dos pontos turísticos
import 'package:flutter/material.dart';
import '../models/poi_model.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';
import '../core/utils/helpers.dart';

/// Provider que gere a lista de pontos turísticos e a rota calculada.
class PoiProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();

  List<PoiModel> _pois = [];
  List<PoiModel> _poisFiltrados = [];
  bool _aCarregar = false;
  final List<String> _poisSelecionados = []; // IDs dos POIs na rota
  RouteModel? _rotaCalculada;

  List<PoiModel> get pois => _poisFiltrados;
  bool get aCarregar => _aCarregar;
  RouteModel? get rotaCalculada => _rotaCalculada;

  /// POIs selecionados na ordem original de seleção (sem otimização).
  List<PoiModel> get poisSelecionados => _pois
      .where((p) => _poisSelecionados.contains(p.id))
      .toList();

  /// Atalho: percurso já otimizado ou, se ainda não calculado, lista vazia.
  List<PoiModel> get rota => _rotaCalculada?.percurso ?? [];

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
        imagemUrl: null,
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
        imagemUrl: null,
      ),
    ];
    
    _poisFiltrados = List.from(_pois);
    _aCarregar = false;
    notifyListeners();
  }

  /// Ordena POIs por proximidade a uma coordenada.
  void ordenarPorProximidade(double lat, double lng) {
    _poisFiltrados.sort((a, b) {
      final distA = Helpers.calcularDistancia(lat, lng, a.latitude, a.longitude);
      final distB = Helpers.calcularDistancia(lat, lng, b.latitude, b.longitude);
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
  /// Limpa a rota calculada anteriormente — o utilizador deve recalcular.
  void toggleSelecaoRota(String poiId) {
    if (_poisSelecionados.contains(poiId)) {
      _poisSelecionados.remove(poiId);
    } else {
      _poisSelecionados.add(poiId);
    }
    _rotaCalculada = null; // rota desatualizada após mudança de seleção
    notifyListeners();
  }

  /// Calcula a rota otimizada entre os POIs selecionados.
  ///
  /// Usa o algoritmo Nearest Neighbor a partir da posição [lat]/[lng].
  /// Depois de chamar este método, [rotaCalculada] fica disponível.
  void calcularRota(double lat, double lng) {
    final selecionados = poisSelecionados;
    if (selecionados.isEmpty) {
      _rotaCalculada = null;
      notifyListeners();
      return;
    }

    _rotaCalculada = _routeService.calcularRota(
      pois: selecionados,
      latAtual: lat,
      lngAtual: lng,
    );
    notifyListeners();
  }

  /// Remove todos os POIs da seleção e limpa a rota.
  void limparRota() {
    _poisSelecionados.clear();
    _rotaCalculada = null;
    notifyListeners();
  }

  /// Indica se um POI está atualmente selecionado para a rota.
  bool estaSelecionado(String poiId) => _poisSelecionados.contains(poiId);

  /// Compatibilidade com chamadas anteriores — delega para [calcularRota].
  void ordenarRotaPorProximidade(double lat, double lng) =>
      calcularRota(lat, lng);
}