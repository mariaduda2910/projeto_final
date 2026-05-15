// Service: login, logout, validação de sessão
import '../models/user_model.dart';
import '../models/session_model.dart';
import 'storage_service.dart';

/// Service responsável por toda a lógica de autenticação.
class AuthService {
  final StorageService _storage = StorageService();

  /// Faz login e retorna o utilizador se for válido.
  /// Se a API não existir ainda, podes simular aqui!
  Future<UserModel?> login(String email, String password) async {
    try {
      // SIMULAÇÃO: enquanto não tens API, retorna dados mockados
      await Future.delayed(const Duration(seconds: 1)); // simula rede

      if (email.isNotEmpty && password.length >= 4) {
        final user = UserModel(
          email: email,
          nome: 'Turista',
          dataAtivacao: DateTime.now(),
          dataExpiracao: DateTime.now().add(const Duration(days: 7)),
        );

        final session = SessionModel(
          token: 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          expiryDate: user.dataExpiracao,
        );

        await _storage.guardarSessao(session);
        return user;
      }
      return null;

      // QUANDO TIVERES API, descomenta isto:
      // final response = await _api.post(
      //   AppConstants.loginEndpoint,
      //   data: {'email': email, 'password': password},
      // );
      // return UserModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se existe uma sessão válida guardada.
  Future<bool> temSessaoValida() async {
    final session = _storage.obterSessao();
    return session != null && !session.isExpired;
  }

  /// Faz logout limpando os dados locais.
  Future<void> logout() async {
    await _storage.limparTudo();
  }
}
