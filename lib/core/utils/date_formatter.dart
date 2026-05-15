// FORMATADOR DE DATAS
// USADO POR: ItineraryCard, EventCard, RoteiroCard, etc.

class DateFormatter {
  /// Formata data para display: "15 Mai 2026"
  static String formatCurto(DateTime date) {
    final meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day} ${meses[date.month - 1]} ${date.year}';
  }

  /// Formata data para display: "15 de Maio de 2026"
  static String formatLongo(DateTime date) {
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${date.day} de ${meses[date.month - 1]} de ${date.year}';
  }

  /// Formata intervalo: "15-17 Mai 2026"
  static String formatIntervalo(DateTime inicio, DateTime fim) {
    if (inicio.month == fim.month && inicio.year == fim.year) {
      return '${inicio.day}-${fim.day} ${formatCurto(inicio).split(' ')[1]} ${inicio.year}';
    }
    return '${formatCurto(inicio)} — ${formatCurto(fim)}';
  }

  /// Formata hora: "14:30"
  static String formatHora(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
