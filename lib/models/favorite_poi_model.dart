import 'poi_model.dart';

/// Snapshot mínimo de um POI guardado nos favoritos do utilizador.
/// Guardamos apenas o essencial para mostrar e usar em roteiros — quando o
/// utilizador toca num favorito podemos sempre recarregar os detalhes via
/// GeoapifyService.detalhesPoi() se necessário.
class FavoritePoi {
  final String id;
  final String nome;
  final double latitude;
  final double longitude;
  final String? endereco;
  final String? categoria;
  final DateTime adicionadoEm;

  const FavoritePoi({
    required this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    this.endereco,
    this.categoria,
    required this.adicionadoEm,
  });

  factory FavoritePoi.fromPoi(PoiModel poi) {
    final id = poi.id ?? poi.placeId ?? '';
    return FavoritePoi(
      id: id,
      nome: poi.nome,
      latitude: poi.latitude,
      longitude: poi.longitude,
      endereco: poi.endereco,
      categoria: poi.categoria,
      adicionadoEm: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'latitude': latitude,
        'longitude': longitude,
        'endereco': endereco,
        'categoria': categoria,
        'adicionado_em': adicionadoEm.toIso8601String(),
      };

  factory FavoritePoi.fromJson(Map<String, dynamic> json) {
    return FavoritePoi(
      id: json['id'],
      nome: json['nome'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      endereco: json['endereco'],
      categoria: json['categoria'],
      adicionadoEm: DateTime.parse(json['adicionado_em']),
    );
  }
}
