// Service: login, logout, registo e validação de sessão
import '../models/session_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

/// Service responsável por toda a lógica de autenticação local.
class AuthService {
  final StorageService _storage = StorageService();

  // ─── Login ─────────────────────────────────────────────────────────────────

  /// Verifica as credenciais e abre sessão se válidas.
  /// Retorna o [UserModel] em caso de sucesso, null caso contrário.
  Future<UserModel?> login(String email, String password) async {
    try {
      final dados = _storage.verificarCredencial(email, password);
      if (dados == null) return null;

      final dataExpiracao = dados['data_expiracao'] != null
          ? DateTime.parse(dados['data_expiracao'])
          : null;

      final user = UserModel(
        id: dados['id'],
        email: dados['email'],
        nome: dados['nome'],
        dataRegisto: DateTime.parse(dados['data_registo']),
        dataExpiracao: dataExpiracao,
        idiomaPreferido: dados['idioma_preferido'] ?? 'pt',
      );

      if (!user.isValido) return null; // conta expirada

      final session = SessionModel(
        token: 'local_${email}_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        expiryDate:
            dataExpiracao ?? DateTime.now().add(const Duration(days: 365)),
      );

      await _storage.guardarSessao(session);
      await _storage.guardarUser(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  // ─── Registo ───────────────────────────────────────────────────────────────

  /// Regista um novo utilizador localmente.
  ///
  /// Retorna o [UserModel] criado em caso de sucesso.
  /// Lança [AuthException] se o email já estiver registado.
  Future<UserModel> registar(String email, String password) async {
    final id = await _storage.registarCredencial(
      email: email,
      password: password,
      nome: _nomeAPartirDeEmail(email),
    );

    if (id == null) throw AuthException('Este email já está registado.');

    // Após registo faz login automático
    final user = await login(email, password);
    if (user == null) throw AuthException('Erro ao criar sessão após registo.');
    return user;
  }

  // ─── Sessão ────────────────────────────────────────────────────────────────

  /// Verifica se existe uma sessão válida guardada localmente.
  Future<bool> temSessaoValida() async {
    final session = _storage.obterSessao();
    return session != null && !session.isExpired;
  }

  /// Restaura o utilizador a partir do storage local (auto-login).
  /// Retorna null se não houver sessão válida ou utilizador guardado.
  Future<UserModel?> restaurarSessao() async {
    final temSessao = await temSessaoValida();
    if (!temSessao) return null;
    return _storage.obterUser();
  }

  /// Termina a sessão — remove sessão e utilizador, mas preserva credenciais.
  Future<void> logout() async {
    await _storage.limparSessao();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Extrai um nome a partir do email (parte antes do @).
  String _nomeAPartirDeEmail(String email) {
    final parte = email.split('@').first;
    return parte[0].toUpperCase() + parte.substring(1);
  }
}

/// Exceção específica de autenticação com mensagem legível pelo utilizador.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
