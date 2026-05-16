// Service: persistência local (SharedPreferences)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/favorite_poi_model.dart';
import '../models/itinerary_model.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';

/// Service para persistência local usando SharedPreferences.
/// Padrão Singleton: só existe uma instância em toda a app.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Chaves internas
  static const String _keyUser = 'LOGGED_USER';
  static const String _keyCredenciais = 'USER_CREDENTIALS';
  static const String _keyRoteiros = 'USER_ITINERARIES';
  static const String _keyRoteiroAtivo = 'ACTIVE_ITINERARY_ID';
  static const String _keyFavoritos = 'USER_FAVORITES';

  /// Inicializa o service. Chamar no main.dart antes de correr a app.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Sessão ────────────────────────────────────────────────────────────────

  Future<void> guardarSessao(SessionModel session) async {
    await _prefs?.setString(
      AppConstants.keyToken,
      jsonEncode(session.toJson()),
    );
  }

  SessionModel? obterSessao() {
    final dados = _prefs?.getString(AppConstants.keyToken);
    if (dados == null) return null;
    return SessionModel.fromJson(jsonDecode(dados));
  }

  // ─── Utilizador logado ──────────────────────────────────────────────────────

  Future<void> guardarUser(UserModel user) async {
    await _prefs?.setString(_keyUser, jsonEncode(user.toJson()));
  }

  UserModel? obterUser() {
    final dados = _prefs?.getString(_keyUser);
    if (dados == null) return null;
    return UserModel.fromJson(jsonDecode(dados));
  }

  // ─── Credenciais locais ─────────────────────────────────────────────────────
  // Nota: armazenamento local sem encriptação — apenas para demonstração académica.
  // Numa app de produção usar um backend com hashing seguro (bcrypt, Argon2).

  /// Regista um utilizador localmente.
  /// Retorna o `id` gerado em caso de sucesso; null se o email já existir.
  Future<String?> registarCredencial({
    required String email,
    required String password,
    required String nome,
    String idiomaPreferido = 'pt',
  }) async {
    final credenciais = _obterTodasCredenciais();

    if (credenciais.containsKey(email)) return null;

    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final agora = DateTime.now();

    credenciais[email] = {
      'id': id,
      'password': password,
      'nome': nome,
      'data_registo': agora.toIso8601String(),
      'data_expiracao':
          agora.add(const Duration(days: AppConstants.sessionTimeoutDays)).toIso8601String(),
      'idioma_preferido': idiomaPreferido,
    };

    await _prefs?.setString(_keyCredenciais, jsonEncode(credenciais));
    return id;
  }

  /// Verifica se email + password são válidos.
  /// Retorna os dados do utilizador (incluindo `id`) se válido, null caso contrário.
  /// Para registos antigos sem `id`, gera um e persiste (auto-migração).
  Map<String, dynamic>? verificarCredencial(String email, String password) {
    final credenciais = _obterTodasCredenciais();
    final entrada = credenciais[email];
    if (entrada == null) return null;
    if (entrada['password'] != password) return null;

    // Auto-migração: contas registadas antes de existir `id` recebem um agora.
    if (entrada['id'] == null) {
      entrada['id'] = 'user_${DateTime.now().millisecondsSinceEpoch}';
      credenciais[email] = entrada;
      // ignore: discarded_futures
      _prefs?.setString(_keyCredenciais, jsonEncode(credenciais));
    }

    return {'email': email, ...entrada};
  }

  /// Verifica se um email já está registado.
  bool emailJaRegistado(String email) {
    return _obterTodasCredenciais().containsKey(email);
  }

  Map<String, dynamic> _obterTodasCredenciais() {
    final dados = _prefs?.getString(_keyCredenciais);
    if (dados == null) return {};
    return Map<String, dynamic>.from(jsonDecode(dados));
  }

  // ─── Roteiros ───────────────────────────────────────────────────────────────

  /// Guarda toda a lista de roteiros do utilizador.
  Future<void> guardarRoteiros(List<ItineraryModel> roteiros) async {
    final lista = roteiros.map((r) => r.toJson()).toList();
    await _prefs?.setString(_keyRoteiros, jsonEncode(lista));
  }

  /// Lê todos os roteiros guardados. Retorna lista vazia se não houver.
  List<ItineraryModel> obterRoteiros() {
    final dados = _prefs?.getString(_keyRoteiros);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List;
    return lista
        .map((r) => ItineraryModel.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// Guarda o ID do roteiro ativo (null para limpar).
  Future<void> guardarRoteiroAtivoId(String? id) async {
    if (id == null) {
      await _prefs?.remove(_keyRoteiroAtivo);
    } else {
      await _prefs?.setString(_keyRoteiroAtivo, id);
    }
  }

  String? obterRoteiroAtivoId() => _prefs?.getString(_keyRoteiroAtivo);

  // ─── Favoritos ──────────────────────────────────────────────────────────────

  Future<void> guardarFavoritos(List<FavoritePoi> favoritos) async {
    final lista = favoritos.map((f) => f.toJson()).toList();
    await _prefs?.setString(_keyFavoritos, jsonEncode(lista));
  }

  List<FavoritePoi> obterFavoritos() {
    final dados = _prefs?.getString(_keyFavoritos);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List;
    return lista
        .map((f) => FavoritePoi.fromJson(Map<String, dynamic>.from(f)))
        .toList();
  }

  // ─── Localização ────────────────────────────────────────────────────────────

  Future<void> guardarUltimaLocalizacao(double lat, double lng) async {
    await _prefs?.setString(AppConstants.keyLastLocation, '$lat,$lng');
  }

  // ─── Reset ──────────────────────────────────────────────────────────────────

  /// Apaga sessão e utilizador logado, mas mantém as credenciais registadas.
  Future<void> limparSessao() async {
    await _prefs?.remove(AppConstants.keyToken);
    await _prefs?.remove(_keyUser);
  }

  /// Apaga tudo (incluindo utilizadores registados). Usar com cuidado.
  Future<void> limparTudo() async {
    await _prefs?.clear();
  }
}
