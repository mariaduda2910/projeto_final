// Modelo: Sessão de autenticação
/// Guarda o estado da sessão do utilizador.
/// Usado para persistir o login localmente no telemóvel.
class SessionModel {
  final String token;
  final String email;
  final DateTime expiryDate;

  SessionModel({
    required this.token,
    required this.email,
    required this.expiryDate,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'expiry_date': expiryDate.toIso8601String(),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      token: json['token'],
      email: json['email'],
      expiryDate: DateTime.parse(json['expiry_date']),
    );
  }
}
