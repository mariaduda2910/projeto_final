
import 'itinerary_event_model.dart';

class ItineraryModel {
  final String id;
  final String titulo;
  final DateTime dataInicio;
  final DateTime dataFim;
  final List<ItineraryEvent> eventos;
  final DateTime criadoEm;
  final bool ativo;

  ItineraryModel({
    required this.id, required this.titulo, required this.dataInicio,
    required this.dataFim, required this.eventos, required this.criadoEm,
    this.ativo = false, // Quando fica true, significa que é o roteiro actualmente activo do utilizador
  });

  int get totalParagens => eventos.length;
  double get distanciaTotalKm => 0.0;
  bool get isAtivo => ativo; // Isso faz com que this.ativo = True, mas é mais claro para o código que usa this.isAtivo

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'data_inicio': dataInicio.toIso8601String(),
        'data_fim': dataFim.toIso8601String(),
        'eventos': eventos.map((e) => e.toJson()).toList(),
        'criado_em': criadoEm.toIso8601String(),
        'ativo': ativo,
      };

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'],
      titulo: json['titulo'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      eventos: (json['eventos'] as List? ?? [])
          .map((e) => ItineraryEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      criadoEm: DateTime.parse(json['criado_em']),
      ativo: json['ativo'] ?? false,
    );
  }

  ItineraryModel copyWith({
    String? id, String? titulo, DateTime? dataInicio, DateTime? dataFim,
    List<ItineraryEvent>? eventos, DateTime? criadoEm, bool? ativo,
  }) => ItineraryModel(
    id: id ?? this.id, titulo: titulo ?? this.titulo,
    dataInicio: dataInicio ?? this.dataInicio, dataFim: dataFim ?? this.dataFim,
    eventos: eventos ?? this.eventos, criadoEm: criadoEm ?? this.criadoEm,
    ativo: ativo ?? this.ativo,
  );
}
