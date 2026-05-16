import 'itinerary_event_model.dart';

class ItineraryModel {
  final String id;
  final String userId; // ← novo: dono do roteiro (necessário para sync)
  final String titulo;
  final String? descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final List<ItineraryEvent> eventos;
  final DateTime criadoEm;
  final bool ativo;
  final bool partilhado;

  ItineraryModel({
    required this.id,
    this.userId = '', // default vazio para retrocompatibilidade
    required this.titulo,
    this.descricao,
    required this.dataInicio,
    required this.dataFim,
    required this.eventos,
    required this.criadoEm,
    this.ativo = false,
    this.partilhado = false,
  });

  int get totalParagens => eventos.length;
  double get distanciaTotalKm => 0.0;
  bool get isAtivo => ativo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'titulo': titulo,
        'descricao': descricao,
        'data_inicio': dataInicio.toIso8601String(),
        'data_fim': dataFim.toIso8601String(),
        'eventos': eventos.map((e) => e.toJson()).toList(),
        'criado_em': criadoEm.toIso8601String(),
        'ativo': ativo,
        'partilhado': partilhado,
      };

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      eventos: (json['eventos'] as List? ?? [])
          .map((e) => ItineraryEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      criadoEm: DateTime.parse(json['criado_em']),
      ativo: json['ativo'] ?? false,
      partilhado: json['partilhado'] ?? false,
    );
  }

  ItineraryModel copyWith({
    String? id,
    String? userId,
    String? titulo,
    String? descricao,
    DateTime? dataInicio,
    DateTime? dataFim,
    List<ItineraryEvent>? eventos,
    DateTime? criadoEm,
    bool? ativo,
    bool? partilhado,
  }) =>
      ItineraryModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        titulo: titulo ?? this.titulo,
        descricao: descricao ?? this.descricao,
        dataInicio: dataInicio ?? this.dataInicio,
        dataFim: dataFim ?? this.dataFim,
        eventos: eventos ?? this.eventos,
        criadoEm: criadoEm ?? this.criadoEm,
        ativo: ativo ?? this.ativo,
        partilhado: partilhado ?? this.partilhado,
      );
}
