// Funções utilitárias: cálculo de distância, formatação de datas
import 'dart:math';
import 'package:intl/intl.dart';

/// Helpers globais para cálculos e formatações.
/// Usar: Helpers.calcularDistancia(...) em qualquer parte do código.
class Helpers {
  
  /// Calcula distância entre duas coordenadas (fórmula de Haversine).
  /// Retorna a distância em quilómetros.
  static double calcularDistancia(
    double lat1, 
    double lon1, 
    double lat2, 
    double lon2,
  ) {
    const double raioTerra = 6371; // km
    
    final double dLat = _grausParaRadianos(lat2 - lat1);
    final double dLon = _grausParaRadianos(lon2 - lon1);
    
    final double a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_grausParaRadianos(lat1)) * 
        cos(_grausParaRadianos(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return raioTerra * c;
  }
  
  static double _grausParaRadianos(double graus) {
    return graus * pi / 180;
  }
  
  /// Formata uma data para o formato português.
  static String formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy', 'pt_PT').format(data);
  }
  
  /// Formata distância para exibição amigável.
  /// Ex: 1.2 km ou 450 m
  static String formatarDistancia(double distanciaKm) {
    if (distanciaKm < 1) {
      return '${(distanciaKm * 1000).toInt()} m';
    }
    return '${distanciaKm.toStringAsFixed(1)} km';
  }
  
  /// Verifica se um local está aberto com base no horário.
  /// Simplificado: verifica se a hora atual está entre abertura e fecho.
  static bool estaAberto(String horaAbertura, String horaFecho) {
    final agora = DateTime.now();
    final horaAtual = agora.hour * 60 + agora.minute; // minutos desde meia-noite
    
    final abertura = _parseHora(horaAbertura);
    final fecho = _parseHora(horaFecho);
    
    return horaAtual >= abertura && horaAtual <= fecho;
  }
  
  static int _parseHora(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }
}