import 'package:flutter/material.dart';

import '../models/favorite_poi_model.dart';
import '../models/poi_model.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

/// Gere a lista de POIs favoritos do utilizador.
/// Persiste em SharedPreferences via [StorageService] e sincroniza com o
/// JSON Server via [SyncService].
class FavoritesProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final SyncService _sync = SyncService();

  List<FavoritePoi> _favoritos = [];
  bool _isLoading = false;

  List<FavoritePoi> get favoritos => List.unmodifiable(_favoritos);
  bool get isLoading => _isLoading;
  int get count => _favoritos.length;

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

    final userId = _storage.obterUser()?.id;
    final estaFavorito = _favoritos.any((f) => f.id == id);

    if (estaFavorito) {
      _favoritos.removeWhere((f) => f.id == id);
      await _storage.guardarFavoritos(_favoritos);
      _enfileirarDelete(id, userId);
      notifyListeners();
      return false;
    }

    final fav = FavoritePoi.fromPoi(poi);
    _favoritos = [..._favoritos, fav];
    await _storage.guardarFavoritos(_favoritos);
    _enfileirarCreate(fav, userId);
    notifyListeners();
    return true;
  }

  /// Remove um POI dos favoritos pelo id.
  Future<void> remover(String poiId) async {
    final userId = _storage.obterUser()?.id;
    _favoritos.removeWhere((f) => f.id == poiId);
    await _storage.guardarFavoritos(_favoritos);
    _enfileirarDelete(poiId, userId);
    notifyListeners();
  }

  /// Limpa todos os favoritos.
  Future<void> limparTudo() async {
    final userId = _storage.obterUser()?.id;
    final idsAntigos = _favoritos.map((f) => f.id).toList();
    _favoritos = [];
    await _storage.guardarFavoritos(_favoritos);
    for (final id in idsAntigos) {
      _enfileirarDelete(id, userId);
    }
    notifyListeners();
  }

  // ─── Sync helpers ──────────────────────────────────────────────────────────

  /// O id no servidor é composto (`userId_poiId`) para garantir unicidade
  /// entre múltiplos utilizadores na mesma coleção.
  String _serverId(String userId, String poiId) => '${userId}_$poiId';

  void _enfileirarCreate(FavoritePoi fav, String? userId) {
    if (userId == null || userId.isEmpty) return;
    _sync.enfileirar(
      tipo: SyncTipo.create,
      recurso: SyncRecurso.favoritos,
      payload: {
        ...fav.toJson(),
        'id': _serverId(userId, fav.id),
        'userId': userId,
        'poiId': fav.id,
      },
    );
  }

  void _enfileirarDelete(String poiId, String? userId) {
    if (userId == null || userId.isEmpty) return;
    _sync.enfileirar(
      tipo: SyncTipo.delete,
      recurso: SyncRecurso.favoritos,
      recursoId: _serverId(userId, poiId),
    );
  }
}
