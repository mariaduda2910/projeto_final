// Definição centralizada de rotas/navegação
// IMPORTA MOCKS PARA TESTES - NÃO DEVE SER USADO EM PRODUÇÃO
import 'package:algarve_explorer/models/poi_model.dart'; // PACKAGE SIGNIFICA QUE É UM MODELO DEFINIDO NA APLICAÇÃO, NÃO UM PACOTE EXTERNO
import '../core/mocks/mock_itineraries.dart'; 
import 'package:flutter/material.dart';
import 'views/login/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/map/poi_explorer_screen.dart';
import 'views/list/list_screen.dart';
import 'views/detail/detail_screen.dart';
import 'views/itinerary/itinerary_list_screen.dart';
import 'views/itinerary/itinerary_detail_screen.dart';
import 'views/settings/settings_screen.dart';
// Todas as rotas da aplicação definidas num só sítio.
// Facilita manutenção e evita strings espalhadas pelo código.
class AppRoutes {
  static const String login = '/'; // Rota inicial (login)
  static const String home = '/home'; // Rota para o ecrã principal após login
  static const String map = '/map'; // Rota para o explorador visão do mapa com POI e Roteiros
  static const String list = '/list'; // Rota para a lista de POIs
  static const String detail = '/detail'; // Rota para detalhes de um POI específico
  static const String settings = '/settings'; // Rota para as definições da aplicação
  static const String itineraryList = '/itinerary/list'; // Rota para a lista de roteiros do utilizador
  static const String itineraryDetail = '/itinerary/detail'; // Rota para detalhes de um roteiro específico

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(), 
      home: (context) => const HomeScreen(),
      map: (context) => const PoiExplorerScreen(),
      list: (context) => const ListScreen(),
      detail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments;
       return DetailScreen(poi: args as PoiModel?);
},
      itineraryDetail: (context) => ItineraryDetailScreen(roteiro: mockRoteiroAtivo), // USAR MOCK PARA TESTES, DEVE SER SUBSTITUÍDO POR DADOS REAIS
      itineraryList: (context) => const ItineraryListScreen(),      
      settings: (context) => const SettingsScreen(), 
    };
  }
}
