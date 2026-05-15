class PoiModel {
  final String? id;
  final String? placeId;

  final String nome;
  final String descricao;

  final String? categoriaPrincipal;
  final List<String> categorias;

  final String? endereco;
  final String? cidade;
  final String? pais;
  final String? codigoPostal;

  final double latitude;
  final double longitude;
  final double? distancia;

  final String? telefone;
  final String? email;
  final String? website;
  final String? horario;
  final String? cozinha;
  final String? tipo;

  // Campos antigos mantidos para compatibilidade com o PoiProvider actual
  final String horaAbertura;
  final String horaFecho;
  final double? avaliacao;

  final Map<String, dynamic>? detalhesRaw;
  final Map<String, dynamic>? raw;

  PoiModel({
    required this.id,
    this.placeId,
    required this.nome, //este campo é obrigatório, pois é o mínimo para mostrar um POI na lista
    required this.descricao,

    // Atenção: aqui NÃO usamos this.categoriaPrincipal,
    // porque vamos inicializar no final com categoriaPrincipal ?? categoria
    String? categoriaPrincipal,

    // Campo antigo aceite pelo construtor
    String? categoria,
    this.categorias = const [],
    this.endereco,
    this.cidade,
    this.pais,
    this.codigoPostal,
    required this.latitude,
    required this.longitude,
    this.distancia,
    this.telefone,
    this.email,
    this.website,
    this.horario,
    this.cozinha,
    this.tipo,
    this.horaAbertura = '',
    this.horaFecho = '',
    this.avaliacao,
    this.detalhesRaw,
    this.raw,
  }) : categoriaPrincipal = categoriaPrincipal ?? categoria;

  // Getter antigo para permitir poi.categoria
  String? get categoria => categoriaPrincipal;

  factory PoiModel.fromGeoapify(Map<String, dynamic> feature) {
    final properties = Map<String, dynamic>.from(feature['properties'] ?? {});
    final geometry = Map<String, dynamic>.from(feature['geometry'] ?? {});

    final coordinates = geometry['coordinates'];

    double longitude = 0;
    double latitude = 0;

    if (coordinates is List && coordinates.length >= 2) {
      longitude = _toDouble(coordinates[0]);
      latitude = _toDouble(coordinates[1]);
    } else {
      longitude = _toDouble(properties['lon']);
      latitude = _toDouble(properties['lat']);
    }

    final categoriesRaw = properties['categories'];

    final categorias = categoriesRaw is List
        ? categoriesRaw.map((e) => e.toString()).toList()
        : <String>[];

    return PoiModel(
      id: properties['id']?.toString(),
      placeId: properties['place_id']?.toString(),
      nome: _valorNaoVazio(properties['name']) ??
          _valorNaoVazio(properties['formatted']) ??
          'Local sem nome',
      descricao: _valorNaoVazio(properties['description']) ?? 'Sem descrição',
      categoriaPrincipal: categorias.isNotEmpty
          ? categorias.first
          : _valorNaoVazio(properties['category']),
      categorias: categorias,
      endereco: _valorNaoVazio(properties['formatted']),
      cidade: _valorNaoVazio(properties['city']) ??
          _valorNaoVazio(properties['county']),
      pais: _valorNaoVazio(properties['country']),
      codigoPostal: _valorNaoVazio(properties['postcode']),
      latitude: latitude,
      longitude: longitude,
      distancia: _toNullableDouble(properties['distance']),
      telefone: _valorNaoVazio(properties['phone']),
      email: _valorNaoVazio(properties['email']),
      website: _valorNaoVazio(properties['website']),
      horario: _valorNaoVazio(properties['opening_hours']),
      cozinha: _valorNaoVazio(properties['cuisine']),
      tipo: _valorNaoVazio(properties['type']),
      horaAbertura: '',
      horaFecho: '',
      avaliacao: _toNullableDouble(properties['rating']),
      raw: feature,
    );
  }

  PoiModel copyWithDetalhes(Map<String, dynamic> detalhesFeature) {
    final properties = Map<String, dynamic>.from(
      detalhesFeature['properties'] ?? {},
    );

    final contact = properties['contact'] is Map
        ? Map<String, dynamic>.from(properties['contact'])
        : <String, dynamic>{};

    final datasource = properties['datasource'] is Map
        ? Map<String, dynamic>.from(properties['datasource'])
        : <String, dynamic>{};

    final rawData = datasource['raw'] is Map
        ? Map<String, dynamic>.from(datasource['raw'])
        : <String, dynamic>{};

    return PoiModel(
      id: id,
      placeId: placeId,
      nome: _valorNaoVazio(properties['name']) ?? nome,
      descricao: _valorNaoVazio(properties['description']) ?? descricao,
      categoriaPrincipal: categoriaPrincipal,
      categorias: categorias,
      endereco: _valorNaoVazio(properties['formatted']) ?? endereco,
      cidade: _valorNaoVazio(properties['city']) ?? cidade,
      pais: _valorNaoVazio(properties['country']) ?? pais,
      codigoPostal: _valorNaoVazio(properties['postcode']) ?? codigoPostal,
      latitude: latitude,
      longitude: longitude,
      distancia: distancia,
      telefone: _valorNaoVazio(properties['phone']) ??
          _valorNaoVazio(contact['phone']) ??
          telefone,
      email: _valorNaoVazio(properties['email']) ??
          _valorNaoVazio(contact['email']) ??
          email,
      website: _valorNaoVazio(properties['website']) ??
          _valorNaoVazio(contact['website']) ??
          website,
      horario: _valorNaoVazio(properties['opening_hours']) ??
          _valorNaoVazio(rawData['opening_hours']) ??
          horario,
      cozinha: _valorNaoVazio(properties['cuisine']) ??
          _valorNaoVazio(rawData['cuisine']) ??
          cozinha,
      tipo: _valorNaoVazio(properties['type']) ?? tipo,
      horaAbertura: horaAbertura,
      horaFecho: horaFecho,
      avaliacao: avaliacao,
      detalhesRaw: detalhesFeature,
      raw: raw,
    );
  }

  static String? _valorNaoVazio(dynamic value) {
    if (value == null) return null;

    final texto = value.toString().trim();

    if (texto.isEmpty) return null;

    return texto;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (placeId != null) 'placeId': placeId,
      'nome': nome,
      'descricao': descricao,
      if (categoriaPrincipal != null) 'categoriaPrincipal': categoriaPrincipal,
      'categorias': categorias,
      if (endereco != null) 'endereco': endereco,
      if (cidade != null) 'cidade': cidade,
      if (pais != null) 'pais': pais,
      if (codigoPostal != null) 'codigoPostal': codigoPostal,
      'latitude': latitude,
      'longitude': longitude,
      if (distancia != null) 'distancia': distancia,
      if (telefone != null) 'telefone': telefone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (horario != null) 'horario': horario,
      if (cozinha != null) 'cozinha': cozinha,
      if (tipo != null) 'tipo': tipo,
      'horaAbertura': horaAbertura,
      'horaFecho': horaFecho,
      if (avaliacao != null) 'avaliacao': avaliacao,
      if (detalhesRaw != null) 'detalhesRaw': detalhesRaw,
      if (raw != null) 'raw': raw,
    };
  }
}
