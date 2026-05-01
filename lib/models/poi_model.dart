class PoiModel {
  final String id;
  final String nome;
  final String descricao;
  final String endereco;
  final double latitude;
  final double longitude;
  final String? categoria;
  final String horaAbertura;
  final String horaFecho;
  final double? avaliacao;
  final String? imagemUrl;

  PoiModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    this.categoria,
    this.horaAbertura = '00:00',
    this.horaFecho = '23:59',
    this.avaliacao,
    this.imagemUrl,
  });

  factory PoiModel.fromGeoapify(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};
    final geometry = json['geometry'] ?? {};
    final coordinates = geometry['coordinates'] ?? [];

    return PoiModel(
      id: properties['place_id']?.toString() ??
          properties['osm_id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      nome: properties['name'] ?? 'Local sem nome',
      descricao: properties['formatted'] ?? 'Sem descrição disponível.',
      endereco: properties['formatted'] ?? 'Endereço desconhecido',
      latitude: (coordinates[1] as num).toDouble(),
      longitude: (coordinates[0] as num).toDouble(),
      categoria: properties['categories'] != null &&
              properties['categories'].isNotEmpty
          ? properties['categories'][0]
          : null,
      horaAbertura: '00:00',
      horaFecho: '23:59',
      avaliacao: null,
      imagemUrl: null,
    );
  }
}