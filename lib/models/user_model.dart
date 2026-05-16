// Modelo: Utilizador (Turista)
/// Representa o turista logado na aplicação.
///
/// Espelha a entidade `Utilizador` definida no plano de dados:
/// id, email, password (separada nas credenciais), nome, dataRegisto,
/// dataExpiracao (opcional), idiomaPreferido (opcional).
class UserModel {
  final String id;
  final String email;
  final String nome;
  final DateTime dataRegisto;
  final DateTime? dataExpiracao;
  final String idiomaPreferido;
  final bool isAtivo;

  UserModel({
    required this.id,
    required this.email,
    required this.nome,
    required this.dataRegisto,
    this.dataExpiracao,
    this.idiomaPreferido = 'pt',
    this.isAtivo = true,
  });

  /// Verifica se a conta ainda está dentro do prazo de validade.
  /// Contas sem [dataExpiracao] são sempre válidas.
  bool get isValido =>
      dataExpiracao == null || DateTime.now().isBefore(dataExpiracao!);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Aceita ambos os nomes de campo (dataRegisto novo, dataAtivacao legado)
    // para retrocompatibilidade com sessões antigas guardadas localmente.
    final dataRegistoStr = json['data_registo'] ?? json['data_ativacao'];

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      nome: json['nome'],
      dataRegisto: DateTime.parse(dataRegistoStr),
      dataExpiracao: json['data_expiracao'] != null
          ? DateTime.parse(json['data_expiracao'])
          : null,
      idiomaPreferido: json['idioma_preferido'] ?? 'pt',
      isAtivo: json['is_ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
      'data_registo': dataRegisto.toIso8601String(),
      'data_expiracao': dataExpiracao?.toIso8601String(),
      'idioma_preferido': idiomaPreferido,
      'is_ativo': isAtivo,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nome,
    DateTime? dataRegisto,
    DateTime? dataExpiracao,
    String? idiomaPreferido,
    bool? isAtivo,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      dataRegisto: dataRegisto ?? this.dataRegisto,
      dataExpiracao: dataExpiracao ?? this.dataExpiracao,
      idiomaPreferido: idiomaPreferido ?? this.idiomaPreferido,
      isAtivo: isAtivo ?? this.isAtivo,
    );
  }
}
