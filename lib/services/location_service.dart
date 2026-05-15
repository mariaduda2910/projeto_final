// Service: geolocalização (Geolocator)
import 'package:geolocator/geolocator.dart';

/// Service para obter e gerir a localização do utilizador.
class LocationService {
  /// Verifica e pede permissões de localização.
  Future<bool> _verificarPermissoes() async {
    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) return false;

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) return false;
    }

    if (permissao == LocationPermission.deniedForever) return false;

    return true;
  }

  /// Obtém a localização atual do dispositivo.
  /// Retorna null se não tiver permissão.
  Future<Position?> obterLocalizacaoAtual() async {
    final temPermissao = await _verificarPermissoes();
    if (!temPermissao) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Stream de localização em tempo real (atualizações contínuas).
  /// Útil para seguir o turista no mapa.
  Stream<Position>? streamLocalizacao() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // atualiza a cada 10 metros
      ),
    );
  }
}
