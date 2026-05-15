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

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'tipo': tipo,
        'caminho_local': caminhoLocal,
        'adicionado_em': adicionadoEm.toIso8601String(),
        'tamanho_bytes': tamanhoBytes,
      };

  factory ItineraryAttachment.fromJson(Map<String, dynamic> json) {
    return ItineraryAttachment(
      id: json['id'],
      nome: json['nome'],
      tipo: json['tipo'],
      caminhoLocal: json['caminho_local'],
      adicionadoEm: DateTime.parse(json['adicionado_em']),
      tamanhoBytes: json['tamanho_bytes'],
    );
  }
}
