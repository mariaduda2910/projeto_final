// Provider: estado de autenticação (Provider package)
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider que gere o estado de autenticação em toda a app.
/// Notifica todas as telas quando o utilizador faz login/logout/registo.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  /// [utilizadorInicial] é passado pelo main.dart quando há sessão válida,
  /// evitando um ecrã de splash extra.
  AuthProvider({UserModel? utilizadorInicial}) : _user = utilizadorInicial;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // ─── Login ─────────────────────────────────────────────────────────────────

  /// Tenta fazer login com email e password.
  /// Retorna true em caso de sucesso.
  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final result = await _authService.login(email, password);
      if (result != null) {
        _user = result;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = 'Email ou palavra-passe incorretos.';
        _setLoading(false);
        return false;
      }
    } catch (_) {
      _error = 'Erro de ligação. Tenta novamente.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Registo ───────────────────────────────────────────────────────────────

  /// Regista um novo utilizador e faz login automático.
  /// Retorna true em caso de sucesso; em caso de erro popula [error].
  Future<bool> registar(String email, String password) async {
    _setLoading(true);

    try {
      final user = await _authService.registar(email, password);
      _user = user;
      _error = null;
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _error = 'Erro ao criar conta. Tenta novamente.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Sessão ────────────────────────────────────────────────────────────────

  /// Restaura a sessão ao arrancar a app.
  /// Retorna true se havia sessão válida e o utilizador foi restaurado.
  Future<bool> verificarSessao() async {
    final user = await _authService.restaurarSessao();
    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }
    _user = null;
    notifyListeners();
    return false;
  }

  /// Termina a sessão e limpa o estado.
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void limparErro() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
