// lib/app.dart — ATUALIZADO com ItineraryProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/poi_provider.dart';
import 'providers/itinerary_provider.dart';
import 'routes.dart';
import 'widgets/shell_layout.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PoiProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()), // ← NOVO
      ],
      child: MaterialApp(
        title: 'Algarve Explorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/shell',
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