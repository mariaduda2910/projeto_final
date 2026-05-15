import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/poi_provider.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  final UserModel? utilizadorInicial;

  const MyApp({super.key, this.utilizadorInicial});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(utilizadorInicial: utilizadorInicial),
        ),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PoiProvider()),
      ],
      child: MaterialApp(
        title: 'Algarve Explorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Se há sessão válida vai para /home, caso contrário para /login
        initialRoute:
            utilizadorInicial != null ? AppRoutes.home : AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
