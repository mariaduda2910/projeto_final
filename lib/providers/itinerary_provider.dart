// 🆕 lib/providers/itinerary_provider.dart
import 'package:flutter/material.dart';
import '../models/itinerary_model.dart';
import '../models/itinerary_event_model.dart';

class ItineraryProvider extends ChangeNotifier {
  final List<ItineraryModel> _roteiros = []; // Lista de roteiros do utilizador TEM QUE SER FINAL PARA EVITAR ERROS DE REFERÊNCIA
  ItineraryModel? _roteiroAtivo;
  bool _isLoading = false;
  String? _error;

  List<ItineraryModel> get roteiros => List.unmodifiable(_roteiros);
  ItineraryModel? get roteiroAtivo => _roteiroAtivo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get temRoteiroAtivo => _roteiroAtivo != null;

  Future<void> carregarRoteiros() async { _setLoading(true); _setLoading(false); notifyListeners(); }
  Future<void> carregarRoteiroAtivo() async { notifyListeners(); }
  Future<bool> criarRoteiro({required String titulo, required DateTime dataInicio, required DateTime dataFim}) async { notifyListeners(); return true; }
  Future<bool> adicionarEventoAoRoteiro({required String roteiroId, required String poiId, required String poiNome, required double poiLatitude, required double poiLongitude, required int ordem, PeriodoDia? periodo, DateTime? dataHora}) async { notifyListeners(); return true; }
  Future<bool> reordenarEventos(String roteiroId, List<String> eventoIdsOrdenados) async { notifyListeners(); return true; }
  Future<bool> definirRoteiroAtivo(String roteiroId) async { notifyListeners(); return true; }
  Future<bool> removerEvento(String roteiroId, String eventoId) async { notifyListeners(); return true; }
  Future<bool> marcarEventoVisitado(String roteiroId, String eventoId, bool visitado) async { notifyListeners(); return true; }
  Future<bool> adicionarAnexo(String roteiroId, String eventoId, String caminhoFicheiro, String tipo) async { notifyListeners(); return true; }
  Future<bool> removerAnexo(String roteiroId, String eventoId, String anexoId) async { notifyListeners(); return true; }

  void _setLoading(bool value) { _isLoading = value; notifyListeners(); }
}
