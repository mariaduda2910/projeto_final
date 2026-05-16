import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cliente HTTP para o JSON Server.
///
/// **Responsabilidade única:** falar HTTP com o backend. Não toma decisões,
/// não guarda estado, não sabe nada sobre sincronização. Só faz pedidos e
/// devolve o resultado.
///
/// A URL base é lida do `.env` (`API_BASE_URL=http://localhost:3000`).
class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl:
                    dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000',
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  // ─── Utilizadores ──────────────────────────────────────────────────────────

  /// Pesquisa utilizador pelo email. Retorna `null` se não existir.
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('/users', queryParameters: {
        'email': email,
      });
      final lista = response.data as List;
      if (lista.isEmpty) return null;
      return Map<String, dynamic>.from(lista.first);
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  /// Cria um novo utilizador no servidor.
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> user) async {
    try {
      final response = await _dio.post('/users', data: user);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  /// Atualiza dados de um utilizador (PATCH = só os campos enviados).
  Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> changes) async {
    try {
      final response = await _dio.patch('/users/$userId', data: changes);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  // ─── Favoritos ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFavoritosDoUtilizador(
      String userId) async {
    try {
      final response = await _dio.get('/favoritos', queryParameters: {
        'userId': userId,
      });
      return (response.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  Future<Map<String, dynamic>> criarFavorito(
      Map<String, dynamic> favorito) async {
    try {
      final response = await _dio.post('/favoritos', data: favorito);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  Future<void> apagarFavorito(String favoritoId) async {
    try {
      await _dio.delete('/favoritos/$favoritoId');
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  // ─── Roteiros ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getRoteirosDoUtilizador(
      String userId) async {
    try {
      final response = await _dio.get('/roteiros', queryParameters: {
        'userId': userId,
      });
      return (response.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  Future<Map<String, dynamic>> criarRoteiro(
      Map<String, dynamic> roteiro) async {
    try {
      final response = await _dio.post('/roteiros', data: roteiro);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  Future<Map<String, dynamic>> atualizarRoteiro(
      String roteiroId, Map<String, dynamic> changes) async {
    try {
      final response = await _dio.patch('/roteiros/$roteiroId', data: changes);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  Future<void> apagarRoteiro(String roteiroId) async {
    try {
      await _dio.delete('/roteiros/$roteiroId');
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  // ─── Rotas partilhadas ─────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getRotasPartilhadas({
    String? regiao,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/rotasPartilhadas', queryParameters: {
        if (regiao != null) 'regiao': regiao,
        '_limit': limit,
      });
      return (response.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  Future<Map<String, dynamic>> partilharRota(
      Map<String, dynamic> rotaAnonima) async {
    try {
      final response =
          await _dio.post('/rotasPartilhadas', data: rotaAnonima);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw ApiException(_msgErro(e));
    }
  }

  // ─── Helpers internos ──────────────────────────────────────────────────────

  String _msgErro(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Servidor demorou demasiado a responder.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Sem ligação ao servidor (json-server está a correr?).';
    }
    final status = e.response?.statusCode;
    if (status != null) return 'Servidor devolveu erro $status.';
    return 'Erro de rede: ${e.message}';
  }
}

/// Exceção tipada lançada pelo [ApiService] em qualquer falha HTTP.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
