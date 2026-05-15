// 🆕 lib/models/itinerary_attachment_model.dart
class ItineraryAttachment {
  final String id;
  final String nome;
  final String tipo;
  final String caminhoLocal;
  final DateTime adicionadoEm;
  final int? tamanhoBytes;

  ItineraryAttachment({
    required this.id, required this.nome, required this.tipo,
    required this.caminhoLocal, required this.adicionadoEm, this.tamanhoBytes,
  });

  String get tipoIcone {
    switch (tipo) {
      case 'pdf': return '📄';
      case 'image': return '🖼️';
      case 'ticket': return '🎫';
      default: return '📎';
    }
  }

  Map<String, dynamic> toJson() => {};
  factory ItineraryAttachment.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
}
