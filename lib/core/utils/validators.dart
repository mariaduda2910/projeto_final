// VALIDADORES REUTILIZÁVEIS
// USADO POR: CriarRoteiroForm, LoginScreen, etc.

class Validators {
  /// Valida título do roteiro (não vazio, min 3 chars)
  static String? validarTituloRoteiro(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O título é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'O título deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  /// Valida datas do roteiro (fim > início)
  static String? validarDatasRoteiro(DateTime? inicio, DateTime? fim) {
    if (inicio == null || fim == null) {
      return 'Ambas as datas são obrigatórias';
    }
    if (fim.isBefore(inicio) || fim.isAtSameMomentAs(inicio)) {
      return 'A data de fim deve ser posterior à data de início';
    }
    return null;
  }

  /// Valida email
  static String? validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O email é obrigatório';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }
}
