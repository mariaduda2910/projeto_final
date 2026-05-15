// 🆕 lib/models/itinerary_event_model.dart
import 'itinerary_attachment_model.dart';

enum PeriodoDia { manha, tarde, noite }

class ItineraryEvent {
  final String id;
  final String poiId;
  final String poiNome;
  final double poiLatitude;
  final double poiLongitude;
  final String? poiEndereco;
  final String? poiCategoria;
  final DateTime? dataHora;
  final PeriodoDia? periodo;
  final int ordem;
  final List<ItineraryAttachment> anexos;
  final bool visitado;
  final String? notas;

  ItineraryEvent({
    required this.id, required this.poiId, required this.poiNome,
    required this.poiLatitude, required this.poiLongitude,
    this.poiEndereco, this.poiCategoria, this.dataHora, this.periodo,
    required this.ordem, this.anexos = const [], this.visitado = false, this.notas,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'poi_id': poiId,
        'poi_nome': poiNome,
        'poi_latitude': poiLatitude,
        'poi_longitude': poiLongitude,
        'poi_endereco': poiEndereco,
        'poi_categoria': poiCategoria,
        'data_hora': dataHora?.toIso8601String(),
        'periodo': periodo?.name,
        'ordem': ordem,
        'anexos': anexos.map((a) => a.toJson()).toList(),
        'visitado': visitado,
        'notas': notas,
      };

  factory ItineraryEvent.fromJson(Map<String, dynamic> json) {
    return ItineraryEvent(
      id: json['id'],
      poiId: json['poi_id'],
      poiNome: json['poi_nome'],
      poiLatitude: (json['poi_latitude'] as num).toDouble(),
      poiLongitude: (json['poi_longitude'] as num).toDouble(),
      poiEndereco: json['poi_endereco'],
      poiCategoria: json['poi_categoria'],
      dataHora: json['data_hora'] != null ? DateTime.parse(json['data_hora']) : null,
      periodo: json['periodo'] != null
          ? PeriodoDia.values.firstWhere((p) => p.name == json['periodo'])
          : null,
      ordem: json['ordem'],
      anexos: (json['anexos'] as List? ?? [])
          .map((a) => ItineraryAttachment.fromJson(Map<String, dynamic>.from(a)))
          .toList(),
      visitado: json['visitado'] ?? false,
      notas: json['notas'],
    );
  }

  ItineraryEvent copyWith({
    String? id, String? poiId, String? poiNome, double? poiLatitude,
    double? poiLongitude, String? poiEndereco, String? poiCategoria,
    DateTime? dataHora, PeriodoDia? periodo, int? ordem,
    List<ItineraryAttachment>? anexos, bool? visitado, String? notas,
  }) => ItineraryEvent(
    id: id ?? this.id, poiId: poiId ?? this.poiId, poiNome: poiNome ?? this.poiNome,
    poiLatitude: poiLatitude ?? this.poiLatitude, poiLongitude: poiLongitude ?? this.poiLongitude,
    poiEndereco: poiEndereco ?? this.poiEndereco, poiCategoria: poiCategoria ?? this.poiCategoria,
    dataHora: dataHora ?? this.dataHora, periodo: periodo ?? this.periodo,
    ordem: ordem ?? this.ordem, anexos: anexos ?? this.anexos,
    visitado: visitado ?? this.visitado, notas: notas ?? this.notas,
  );
}
