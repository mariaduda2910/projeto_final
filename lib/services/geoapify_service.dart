import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/poi_model.dart';

class GeoapifyService {
  final Dio _dio;

  GeoapifyService({Dio? dio}) : _dio = dio ?? Dio();

  final String _apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? '';

  static const String _placesUrl = 'https://api.geoapify.com/v2/places';
  static const String _detailsUrl = 'https://api.geoapify.com/v2/place-details';

  Future<List<PoiModel>> buscarLocaisProximos({
    required double latitude,
    required double longitude,
    required List<String> categories,
    int radius = 1000,
    int limit = 20,
    bool incluirDetalhes = true,
    List<String> detalhesFeatures = const ['details'],
  }) async {
    _validarApiKey();

    if (categories.isEmpty) {
      throw Exception('Deve informar pelo menos uma categoria Geoapify.');
    }

    if (radius <= 0) {
      throw Exception('O raio de pesquisa deve ser maior que zero.');
    }

    if (limit <= 0) {
      throw Exception('O limite de resultados deve ser maior que zero.');
    }

    try {
      final response = await _dio.get(
        _placesUrl,
        queryParameters: {
          'categories': categories.join(','),
          'filter': 'circle:$longitude,$latitude,$radius',
          'bias': 'proximity:$longitude,$latitude',
          'limit': limit,
          'apiKey': _apiKey,
        },
      );

      final List features = response.data['features'] ?? [];

      final pois = features
          .map((item) => PoiModel.fromGeoapify(Map<String, dynamic>.from(item)))
          .toList();

      if (!incluirDetalhes) {
        return pois;
      }

      final List<PoiModel> poisComDetalhes = [];

      for (final poi in pois) {
        final poiDetalhado = await _buscarDetalhesDoPoi(
          poi: poi,
          features: detalhesFeatures,
        );

        poisComDetalhes.add(poiDetalhado);
      }

      return poisComDetalhes;
    } on DioException catch (e) {
      throw Exception(_formatarErroDio(e));
    } catch (e) {
      throw Exception('Erro ao procurar locais próximos: $e');
    }
  }

  Future<PoiModel> _buscarDetalhesDoPoi({
    required PoiModel poi,
    required List<String> features,
  }) async {
    if (poi.id == null || poi.id!.trim().isEmpty) {
      return poi;
    }

    final detalhe = await buscarDetalhesPorPlaceId(
      placeId: poi.id!,
      features: features,
    );

    return detalhe ?? poi;
  }

  Future<PoiModel?> buscarDetalhesPorPlaceId({
    required String placeId,
    List<String> features = const ['details'],
  }) async {
    _validarApiKey();

    if (placeId.trim().isEmpty) {
      throw Exception('O placeId não pode estar vazio.');
    }

    try {
      final response = await _dio.get(
        _detailsUrl,
        queryParameters: {
          'id': placeId,
          'features': features.join(','),
          'apiKey': _apiKey,
        },
      );

      final List detalhesFeatures = response.data['features'] ?? [];

      if (detalhesFeatures.isEmpty) {
        return null;
      }

      final detalhe = Map<String, dynamic>.from(detalhesFeatures.first);

      return PoiModel.fromGeoapify(detalhe).copyWithDetalhes(detalhe);
    } on DioException catch (e) {
      throw Exception(_formatarErroDio(e));
    } catch (e) {
      throw Exception('Erro ao procurar detalhes do local: $e');
    }
  }

  void _validarApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'GEOAPIFY_API_KEY não foi encontrada no ficheiro .env.',
      );
    }
  }

  String _formatarErroDio(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401 || statusCode == 403) {
      return 'Erro de autenticação na Geoapify. Verifica a API key.';
    }

    if (statusCode == 400) {
      return 'Pedido inválido enviado para a Geoapify: $data';
    }

    if (statusCode == 429) {
      return 'Limite de pedidos da Geoapify atingido. Tenta novamente mais tarde.';
    }

    if (statusCode != null) {
      return 'Erro Geoapify [$statusCode]: $data';
    }

    return 'Erro de ligação à Geoapify: ${e.message}';
  }
}

/*
ex: 
final geoapifyService = GeoapifyService();

final restaurantes = await geoapifyService.buscarLocaisProximos(
  latitude: latitude,
  longitude: longitude,
  categories: ['catering.restaurant'],
  radius: 1000,
  limit: 20,
  incluirDetalhes: true,
);

final locais = await geoapifyService.buscarLocaisProximos(
  latitude: latitude,
  longitude: longitude,
  categories: [
    'catering.restaurant',
    'catering.cafe',
    'catering.bar',
  ],
  radius: 3000,
  limit: 30,
  incluirDetalhes: true,
);

final atracoes = await geoapifyService.buscarLocaisProximos(
  latitude: latitude,
  longitude: longitude,
  categories: [
    'tourism.attraction',
    'tourism.sights',
    'entertainment.museum',
  ],
  radius: 5000,
  limit: 40,
  incluirDetalhes: true,
);
*/
