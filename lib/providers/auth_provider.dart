// Provider: estado de autenticação (Provider package)
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider que gere o estado de autenticação em toda a app.
/// Notifica todas as telas quando o utilizador faz login/logout.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Getters: as telas leem estas variáveis
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  /// Tenta fazer login.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // avisa as telas para atualizarem

    try {
      final result = await _authService.login(email, password);
      if (result != null) {
        _user = result;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email ou password inválidos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verifica se já existe sessão ao abrir a app.
  Future<void> verificarSessao() async {
    final temSessao = await _authService.temSessaoValida();
    if (!temSessao) {
      _user = null;
      notifyListeners();
    }
    // Se tiver sessão, podes carregar os dados do user aqui
  }

  /// Faz logout.
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
