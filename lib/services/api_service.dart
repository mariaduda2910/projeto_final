// Service: comunicação HTTP com API REST (Dio)
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';

/// Service para comunicação com a API REST.
/// Centraliza todas as chamadas HTTP da aplicação.
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Interceptor: adiciona token a todos os pedidos automaticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Aqui podes adicionar o token de autenticação
        // final token = StorageService().obterSessao()?.token;
        // if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) {
        // Tratamento global de erros
        return handler.next(error);
      },
    ));
  }

  /// GET genérico
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await _dio.get(path, queryParameters: query);
  }

  /// POST genérico
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
}