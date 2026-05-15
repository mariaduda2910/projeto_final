import 'package:flutter/material.dart';

import '../models/favorite_poi_model.dart';
import '../models/poi_model.dart';
import '../services/storage_service.dart';

/// Gere a lista de POIs favoritos do utilizador.
/// Persiste em SharedPreferences via [StorageService].
class FavoritesProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<FavoritePoi> _favoritos = [];
  bool _isLoading = false;

  List<FavoritePoi> get favoritos => List.unmodifiable(_favoritos);
  bool get isLoading => _isLoading;
  int get count => _favoritos.length;

  /// Carrega favoritos guardados.
  Future<void> carregar() async {
    _isLoading = true;
    notifyListeners();
    _favoritos = _storage.obterFavoritos();
    _isLoading = false;
    notifyListeners();
  }

  bool isFavorito(String? poiId) {
    if (poiId == null || poiId.isEmpty) return false;
    return _favoritos.any((f) => f.id == poiId);
  }

  /// Adiciona ou remove um POI dos favoritos.
  /// Retorna true se passou a estar favorito; false se foi removido.
  Future<bool> toggle(PoiModel poi) async {
    final id = poi.id ?? poi.placeId ?? '';
    if (id.isEmpty) return false;

    final estaFavorito = _favoritos.any((f) => f.id == id);
    if (estaFavorito) {
      _favoritos.removeWhere((f) => f.id == id);
      await _storage.guardarFavoritos(_favoritos);
      notifyListeners();
      return false;
    }

    _favoritos = [..._favoritos, FavoritePoi.fromPoi(poi)];
    await _storage.guardarFavoritos(_favoritos);
    notifyListeners();
    return true;
  }

  /// Remove um POI dos favoritos pelo id.
  Future<void> remover(String poiId) async {
    _favoritos.removeWhere((f) => f.id == poiId);
    await _storage.guardarFavoritos(_favoritos);
    notifyListeners();
  }

  /// Limpa todos os favoritos.
  Future<void> limparTudo() async {
    _favoritos = [];
    await _storage.guardarFavoritos(_favoritos);
    notifyListeners();
  }
}
