// Constantes globais: cores, textos, endpoints, chaves de storage
import 'package:flutter/material.dart';

/// Constantes globais da aplicação.
class AppConstants {
  // Nomes e textos
  static const String appName = 'Algarve Explorer';
  static const String welcomeMessage = 'Bem-vindo ao Algarve!';

  // Endpoints da API (quando existir)
  static const String baseUrl = 'https://api.algarve-explorer.pt';
  static const String loginEndpoint = '/auth/login';
  static const String poisEndpoint = '/pois';
  static const String geoapifyPlaceDetailsUrl = 
    String.fromEnvironment('GEOAPIFY_PLACE_DETAILS_URL', 
    defaultValue: 'https://api.geoapify.com/v2/place-details');


  // Durações e limites
  static const int sessionTimeoutDays = 7;
  static const double defaultMapZoom = 13.0;
  static const double maxDistanceKm = 70.0;

  // Chaves para SharedPreferences (persistência local)
  static const String keyUserEmail = 'USER_EMAIL';
  static const String keyToken = 'USER_TOKEN';
  static const String keyExpiryDate = 'ACCOUNT_EXPIRY';
  static const String keyLastLocation = 'LAST_LOCATION';
}

/// Cores da marca - alterar aqui muda o tema todo
class AppColors {
  static const Color primary = Color(0xFF0066CC); // Azul oceano
  static const Color secondary = Color(0xFFFF6B35); // Laranja pôr-do-sol
  static const Color accent = Color(0xFF00BFA6); // Verde água
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color openStatus = Color(0xFF4CAF50); // Aberto
  static const Color closedStatus = Color(0xFFF44336); // Fechado
}

/// Espaçamentos padronizados para manter consistência visual
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double borderRadius = 12.0;
}
