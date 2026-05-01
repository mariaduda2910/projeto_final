import 'package:dio/dio.dart';
import '../models/poi_model.dart';

class GeoapifyService {
  final Dio _dio = Dio();

  static const String _apiKey = '555f1e7ee9cb4908babba56e80d5c48e';

  Future<List<PoiModel>> buscarRestaurantesProximos({
    required double latitude,
    required double longitude,
  }) async {
    const String url = 'https://api.geoapify.com/v2/places';

    final response = await _dio.get(
      url,
      queryParameters: {
        'categories': 'catering.restaurant',
        'filter': 'circle:$longitude,$latitude,1000',
        'bias': 'proximity:$longitude,$latitude',
        'limit': 20,
        'apiKey': _apiKey,
      },
    );

    final List features = response.data['features'] ?? [];

    return features.map((item) => PoiModel.fromGeoapify(item)).toList();
  }
}
