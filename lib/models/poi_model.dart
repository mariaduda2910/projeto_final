/// POI = Point of Interest (Ponto de Interesse Turístico)
/// Este modelo representa um local turístico no Algarve.
class PoiModel {
  final String id;
  final String nome;
  final String descricao;
  final String categoria; // ex: 'praia', 'restaurante', 'monumento'
  final double latitude;
  final double longitude;
  final String endereco;
  final String horaAbertura; // formato "09:00"
  final String horaFecho;    // formato "18:00"
  final double avaliacao;    // 0.0 a 5.0
  final String? imagemUrl;
  final bool isParceiro;     // true se é ponto patrocinado

  PoiModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.latitude,
    required this.longitude,
    required this.endereco,
    required this.horaAbertura,
    required this.horaFecho,
    required this.avaliacao,
    this.imagemUrl,
    this.isParceiro = false,
  });

  /// Cria um POI a partir de JSON (quando vier da API)
  factory PoiModel.fromJson(Map<String, dynamic> json) {
    return PoiModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      categoria: json['categoria'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      endereco: json['endereco'],
      horaAbertura: json['hora_abertura'],
      horaFecho: json['hora_fecho'],
      avaliacao: json['avaliacao'].toDouble(),
      imagemUrl: json['imagem_url'],
      isParceiro: json['is_parceiro'] ?? false,
    );
  }

  /// Converte para JSON (se precisares enviar para a API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'latitude': latitude,
      'longitude': longitude,
      'endereco': endereco,
      'hora_abertura': horaAbertura,
      'hora_fecho': horaFecho,
      'avaliacao': avaliacao,
      'imagem_url': imagemUrl,
      'is_parceiro': isParceiro,
    };
  }
}