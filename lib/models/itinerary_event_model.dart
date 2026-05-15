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

  Map<String, dynamic> toJson() => {};
  factory ItineraryEvent.fromJson(Map<String, dynamic> json) => throw UnimplementedError();

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
