// Definição centralizada de rotas/navegação
import 'package:flutter/material.dart';
import 'views/login/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/map/poi_explorer_screen.dart';
import 'views/list/list_screen.dart';
import 'views/detail/detail_screen.dart';

/// Todas as rotas da aplicação definidas num só sítio.
/// Facilita manutenção e evita strings espalhadas pelo código.
class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String map = '/map';
  static const String list = '/list';
  static const String detail = '/detail';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      map: (context) => const PoiExplorerScreen(),
      list: (context) => const ListScreen(),
      detail: (context) => const DetailScreen(),
    };
  }
}