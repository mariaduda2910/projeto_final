// Service: persistência local (SharedPreferences)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/session_model.dart';

/// Service para persistência local usando SharedPreferences.
/// Padrão Singleton: só existe uma instância em toda a app.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  /// Inicializa o service. Chamar no main.dart antes de correr a app!
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Guarda a sessão do utilizador localmente.
  Future<void> guardarSessao(SessionModel session) async {
    await _prefs?.setString(
      AppConstants.keyToken,
      jsonEncode(session.toJson()),
    );
  }

  /// Lê a sessão guardada. Retorna null se não houver.
  SessionModel? obterSessao() {
    final String? dados = _prefs?.getString(AppConstants.keyToken);
    if (dados == null) return null;
    return SessionModel.fromJson(jsonDecode(dados));
  }

  /// Apaga todos os dados locais (logout).
  Future<void> limparTudo() async {
    await _prefs?.clear();
  }

  /// Guarda a última localização conhecida.
  Future<void> guardarUltimaLocalizacao(double lat, double lng) async {
    await _prefs?.setString(
      AppConstants.keyLastLocation,
      '$lat,$lng',
    );
  }
}
