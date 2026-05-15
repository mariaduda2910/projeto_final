import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/itinerary_provider.dart';
import 'providers/location_provider.dart';
import 'providers/poi_provider.dart';
import 'routes.dart';
import 'widgets/shell_layout.dart';

class MyApp extends StatelessWidget {
  final UserModel? utilizadorInicial;

  const MyApp({super.key, this.utilizadorInicial});

  @override
  Widget build(BuildContext context) {
    final temSessao = utilizadorInicial != null;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(utilizadorInicial: utilizadorInicial),
        ),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PoiProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Algarve Explorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Sessão válida → vai direto para o shell (com tabs Início/Mapa/Perfil)
        // Sem sessão → vai para o login
        initialRoute: temSessao ? '/shell' : AppRoutes.login,
        routes: {
          '/shell': (context) => const ShellLayout(),
          ...AppRoutes.routes,
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Página não encontrada')),
            ),
          );
        },
      ),
    );
  }
}
