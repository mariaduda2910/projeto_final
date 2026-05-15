import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/itinerary_event_model.dart';
import '../models/itinerary_model.dart';
import '../models/route_result_model.dart';
import '../services/geoapify_service.dart';
import '../services/storage_service.dart';

/// Gere a lista de roteiros do utilizador, o roteiro ativo (visível no
/// mapa) e o cálculo da rota real via Geoapify Routing.
class ItineraryProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final GeoapifyService _geoapify = GeoapifyService();

  List<ItineraryModel> _roteiros = [];
  ItineraryModel? _roteiroAtivo;
  RouteResult? _rotaCalculada;
  bool _isLoading = false;
  bool _calculandoRota = false;
  String? _error;

  /// Posição atual do utilizador, usada como ponto de partida da rota.
  /// Quando definida, basta 1 POI no roteiro para traçar uma rota.
  LatLng? _pontoPartida;

  LatLng? get pontoPartida => _pontoPartida;

  /// Atualiza o ponto de partida (geralmente a posição GPS atual) e
  /// recalcula a rota se houver roteiro ativo.
  void definirPontoPartida(LatLng? ponto) {
    final mudou = _pontoPartida?.latitude != ponto?.latitude ||
        _pontoPartida?.longitude != ponto?.longitude;
    _pontoPartida = ponto;
    if (mudou && _roteiroAtivo != null && _roteiroAtivo!.eventos.isNotEmpty) {
      // ignore: unawaited_futures
      calcularRota();
    } else {
      notifyListeners();
    }
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  List<ItineraryModel> get roteiros => List.unmodifiable(_roteiros);
  ItineraryModel? get roteiroAtivo => _roteiroAtivo;
  RouteResult? get rotaCalculada => _rotaCalculada;
  bool get isLoading => _isLoading;
  bool get calculandoRota => _calculandoRota;
  String? get error => _error;
  bool get temRoteiroAtivo => _roteiroAtivo != null;

  // ─── Inicialização ─────────────────────────────────────────────────────────

  /// Carrega todos os roteiros guardados localmente.
  Future<void> carregarRoteiros() async {
    _isLoading = true;
    notifyListeners();

    _roteiros = _storage.obterRoteiros();

    final idAtivo = _storage.obterRoteiroAtivoId();
    if (idAtivo != null) {
      try {
        _roteiroAtivo = _roteiros.firstWhere((r) => r.id == idAtivo);
      } catch (_) {
        _roteiroAtivo = null;
      }
    }

    _isLoading = false;
    notifyListeners();

    // Se restaurou um roteiro ativo, calcula a rota em background
    if (_roteiroAtivo != null && _podeCalcularRota(_roteiroAtivo!)) {
      // ignore: unawaited_futures
      calcularRota();
    }
  }

  // ─── CRUD de roteiros ──────────────────────────────────────────────────────

  Future<ItineraryModel> criarRoteiro({
    required String titulo,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    final novo = ItineraryModel(
      id: _gerarId(),
      titulo: titulo,
      dataInicio: dataInicio,
      dataFim: dataFim,
      eventos: const [],
      criadoEm: DateTime.now(),
    );

    _roteiros = [..._roteiros, novo];
    await _persistir();
    notifyListeners();
    return novo;
  }

  Future<bool> apagarRoteiro(String roteiroId) async {
    _roteiros = _roteiros.where((r) => r.id != roteiroId).toList();
    if (_roteiroAtivo?.id == roteiroId) {
      _roteiroAtivo = null;
      _rotaCalculada = null;
      await _storage.guardarRoteiroAtivoId(null);
    }
    await _persistir();
    notifyListeners();
    return true;
  }

  // ─── Eventos (paragens) ────────────────────────────────────────────────────

  /// Adiciona um POI como nova paragem no fim do roteiro.
  /// Retorna false se o POI já existir no roteiro.
  Future<bool> adicionarPoiAoRoteiro({
    required String roteiroId,
    required String poiId,
    required String poiNome,
    required double poiLatitude,
    required double poiLongitude,
    String? poiEndereco,
    String? poiCategoria,
  }) async {
    final index = _roteiros.indexWhere((r) => r.id == roteiroId);
    if (index == -1) return false;

    final roteiro = _roteiros[index];
    if (roteiro.eventos.any((e) => e.poiId == poiId)) return false;

    final evento = ItineraryEvent(
      id: _gerarId(),
      poiId: poiId,
      poiNome: poiNome,
      poiLatitude: poiLatitude,
      poiLongitude: poiLongitude,
      poiEndereco: poiEndereco,
      poiCategoria: poiCategoria,
      ordem: roteiro.eventos.length + 1,
    );

    _roteiros[index] = roteiro.copyWith(eventos: [...roteiro.eventos, evento]);

    if (_roteiroAtivo?.id == roteiroId) {
      _roteiroAtivo = _roteiros[index];
      if (_podeCalcularRota(_roteiroAtivo!)) {
        // ignore: unawaited_futures
        calcularRota();
      }
    }

    await _persistir();
    notifyListeners();
    return true;
  }

  /// A rota só faz sentido com pelo menos 2 waypoints. Conta o ponto de
  /// partida quando está definido.
  bool _podeCalcularRota(ItineraryModel r) {
    final base = _pontoPartida != null ? 1 : 0;
    return r.eventos.length + base >= 2;
  }

  Future<bool> removerEvento(String roteiroId, String eventoId) async {
    final index = _roteiros.indexWhere((r) => r.id == roteiroId);
    if (index == -1) return false;

    final roteiro = _roteiros[index];
    final eventos = roteiro.eventos.where((e) => e.id != eventoId).toList();

    final reordenados = <ItineraryEvent>[];
    for (var i = 0; i < eventos.length; i++) {
      reordenados.add(eventos[i].copyWith(ordem: i + 1));
    }

    _roteiros[index] = roteiro.copyWith(eventos: reordenados);

    if (_roteiroAtivo?.id == roteiroId) {
      _roteiroAtivo = _roteiros[index];
      if (_podeCalcularRota(_roteiroAtivo!)) {
        // ignore: unawaited_futures
        calcularRota();
      } else {
        _rotaCalculada = null;
      }
    }

    await _persistir();
    notifyListeners();
    return true;
  }

  Future<bool> marcarEventoVisitado(
      String roteiroId, String eventoId, bool visitado) async {
    final index = _roteiros.indexWhere((r) => r.id == roteiroId);
    if (index == -1) return false;

    final roteiro = _roteiros[index];
    final eventos = roteiro.eventos
        .map((e) => e.id == eventoId ? e.copyWith(visitado: visitado) : e)
        .toList();
    _roteiros[index] = roteiro.copyWith(eventos: eventos);

    if (_roteiroAtivo?.id == roteiroId) _roteiroAtivo = _roteiros[index];

    await _persistir();
    notifyListeners();
    return true;
  }

  // ─── Roteiro ativo + cálculo de rota ───────────────────────────────────────

  /// Escolhe qual o roteiro a mostrar no mapa e calcula a rota Geoapify.
  /// Passa null para limpar o roteiro ativo.
  Future<void> definirRoteiroAtivo(String? roteiroId) async {
    if (roteiroId == null) {
      _roteiroAtivo = null;
      _rotaCalculada = null;
      _error = null;
      await _storage.guardarRoteiroAtivoId(null);
      notifyListeners();
      return;
    }

    try {
      _roteiroAtivo = _roteiros.firstWhere((r) => r.id == roteiroId);
    } catch (_) {
      _roteiroAtivo = null;
    }

    await _storage.guardarRoteiroAtivoId(_roteiroAtivo?.id);
    notifyListeners();

    if (_roteiroAtivo != null && _podeCalcularRota(_roteiroAtivo!)) {
      await calcularRota();
    } else {
      _rotaCalculada = null;
      notifyListeners();
    }
  }

  /// Recalcula a rota Geoapify para o roteiro ativo.
  /// Se houver [pontoPartida] definido, ele é usado como primeiro waypoint
  /// (basta 1 POI no roteiro nesse caso).
  Future<void> calcularRota({String mode = 'drive'}) async {
    if (_roteiroAtivo == null || _roteiroAtivo!.eventos.isEmpty) {
      _rotaCalculada = null;
      notifyListeners();
      return;
    }

    if (!_podeCalcularRota(_roteiroAtivo!)) {
      _rotaCalculada = null;
      notifyListeners();
      return;
    }

    _calculandoRota = true;
    _error = null;
    notifyListeners();

    try {
      final waypoints = <LatLng>[
        if (_pontoPartida != null) _pontoPartida!,
        ..._roteiroAtivo!.eventos
            .map((e) => LatLng(e.poiLatitude, e.poiLongitude)),
      ];

      _rotaCalculada = await _geoapify.calcularRota(
        waypoints: waypoints,
        mode: mode,
      );
    } catch (e) {
      _error = e.toString();
      _rotaCalculada = null;
    }

    _calculandoRota = false;
    notifyListeners();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _persistir() => _storage.guardarRoteiros(_roteiros);

  String _gerarId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_${now.microsecond}';
  }

  void limparErro() {
    _error = null;
    notifyListeners();
  }

  // ─── Compatibilidade com chamadas antigas ──────────────────────────────────

  /// API antiga usada pelos ecrãs de detalhe / lista de roteiros.
  Future<bool> adicionarEventoAoRoteiro({
    required String roteiroId,
    required String poiId,
    required String poiNome,
    required double poiLatitude,
    required double poiLongitude,
    required int ordem,
    PeriodoDia? periodo,
    DateTime? dataHora,
  }) {
    return adicionarPoiAoRoteiro(
      roteiroId: roteiroId,
      poiId: poiId,
      poiNome: poiNome,
      poiLatitude: poiLatitude,
      poiLongitude: poiLongitude,
    );
  }

  /// Reordena as paragens de um roteiro segundo a lista de IDs fornecida.
  Future<bool> reordenarEventos(
      String roteiroId, List<String> eventoIdsOrdenados) async {
    final index = _roteiros.indexWhere((r) => r.id == roteiroId);
    if (index == -1) return false;

    final roteiro = _roteiros[index];
    final mapa = {for (final e in roteiro.eventos) e.id: e};
    final reordenados = <ItineraryEvent>[];
    for (var i = 0; i < eventoIdsOrdenados.length; i++) {
      final evento = mapa[eventoIdsOrdenados[i]];
      if (evento != null) {
        reordenados.add(evento.copyWith(ordem: i + 1));
      }
    }

    _roteiros[index] = roteiro.copyWith(eventos: reordenados);
    if (_roteiroAtivo?.id == roteiroId) {
      _roteiroAtivo = _roteiros[index];
      // ignore: unawaited_futures
      calcularRota();
    }

    await _persistir();
    notifyListeners();
    return true;
  }
}
