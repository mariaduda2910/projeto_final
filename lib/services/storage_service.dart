// Service: persistência local (SharedPreferences)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
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
  /// Retorna false se o email já estiver registado.
  Future<bool> registarCredencial(String email, String password, String nome) async {
    final credenciais = _obterTodasCredenciais();

    if (credenciais.containsKey(email)) return false;

    credenciais[email] = {
      'password': password,
      'nome': nome,
      'data_ativacao': DateTime.now().toIso8601String(),
      'data_expiracao':
          DateTime.now().add(const Duration(days: AppConstants.sessionTimeoutDays)).toIso8601String(),
    };

    await _prefs?.setString(_keyCredenciais, jsonEncode(credenciais));
    return true;
  }

  /// Verifica se email + password são válidos.
  /// Retorna os dados do utilizador se válido, null caso contrário.
  Map<String, dynamic>? verificarCredencial(String email, String password) {
    final credenciais = _obterTodasCredenciais();
    final entrada = credenciais[email];
    if (entrada == null) return null;
    if (entrada['password'] != password) return null;
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
