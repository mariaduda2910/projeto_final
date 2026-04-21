// Modelo: Utilizador (Turista)
/// Representa o turista logado na aplicação.
class UserModel {
  final String email;
  final String nome;
  final DateTime dataAtivacao;
  final DateTime dataExpiracao;
  final bool isAtivo;

  UserModel({
    required this.email,
    required this.nome,
    required this.dataAtivacao,
    required this.dataExpiracao,
    this.isAtivo = true,
  });

  /// Verifica se a conta ainda está dentro do prazo de validade.
  bool get isValido => DateTime.now().isBefore(dataExpiracao);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      nome: json['nome'],
      dataAtivacao: DateTime.parse(json['data_ativacao']),
      dataExpiracao: DateTime.parse(json['data_expiracao']),
      isAtivo: json['is_ativo'] ?? true,
    );
  }
}