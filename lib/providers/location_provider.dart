// Provider: estado da localização
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

/// Provider que gere a localização do utilizador.
/// Mantém a posição atualizada para o mapa e a lista usarem.
class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  Position? _posicaoAtual;
  bool _aCarregar = false;
  String? _erro;

  Position? get posicaoAtual => _posicaoAtual;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;

  /// Obtém a localização uma vez.
  Future<void> obterLocalizacao() async {
    _aCarregar = true;
    _erro = null;
    notifyListeners();

    try {
      final posicao = await _locationService.obterLocalizacaoAtual();
      if (posicao != null) {
        _posicaoAtual = posicao;
      } else {
        _erro = 'Permissão de localização negada';
      }
    } catch (e) {
      _erro = 'Erro ao obter localização';
    }

    _aCarregar = false;
    notifyListeners();
  }

  /// Inicia stream de localização em tempo real.
  void iniciarSeguimento() {
    _locationService.streamLocalizacao()?.listen((posicao) {
      _posicaoAtual = posicao;
      notifyListeners();
    });
  }
}