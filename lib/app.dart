// Widget raiz: configuração de tema e providers
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/poi_provider.dart';
import 'routes.dart';
import 'widgets/shell_layout.dart';

/// Widget raiz da aplicação.
/// Configura tema, providers globais e rotas.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Providers disponíveis em toda a app
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PoiProvider()),
      ],
      child: MaterialApp(
        title: 'Algarve Explorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/shell', // Começa na tela de login
        // ROTAS: define '/shell' PRIMEIRO, depois as outras
        routes: {
          '/shell': (context) => const ShellLayout(), // ← ANTES das outras
          ...AppRoutes.routes, // ← Depois expande as do routes.dart
        },

        // Fallback para rotas não definidas (segurança)
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

/*
App inicia
   ↓
MyApp
   ↓
Providers são criados (estado global)
   ↓
Vai para login (initialRoute)
   ↓
Utilizador faz login
   ↓
AuthProvider guarda sessão
   ↓
Vai para MapScreen
   ↓
LocationProvider obtém localização
   ↓
PoiProvider chama API (Geoapify)
   ↓
Recebe lista de locais
   ↓
MapScreen mostra markers
*/
