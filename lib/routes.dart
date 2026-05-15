// lib/routes.dart — ATUALIZADO, SEM MOCK
import 'package:algarve_explorer/models/itinerary_model.dart';
import 'package:flutter/material.dart';
import 'models/poi_model.dart';
import 'views/login/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/map/poi_explorer_screen.dart';
import 'views/list/list_screen.dart';
import 'views/detail/detail_screen.dart';
import 'views/itinerary/itinerary_list_screen.dart';
import 'views/itinerary/itinerary_detail_screen.dart';
import 'views/settings/settings_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String map = '/map';
  static const String list = '/list';
  static const String detail = '/detail';
  static const String settings = '/settings';
  static const String itineraryList = '/itinerary/list';
  static const String itineraryDetail = '/itinerary/detail';

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
      itineraryList: (context) => const ItineraryListScreen(),
      itineraryDetail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments;
        if (args is ItineraryModel) {
          return ItineraryDetailScreen(roteiro: args);
        }
        // Fallback se não receber argumentos
        return const Scaffold(
          body: Center(child: Text('Roteiro não encontrado')),
        );
      },
      settings: (context) => const SettingsScreen(),
    };
  }
}