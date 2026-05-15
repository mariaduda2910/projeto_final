import 'package:flutter/material.dart';
import 'app.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();

  // Restaura sessão antes de arrancar a app.
  // Se houver sessão válida, o utilizador vai direto para /home.
  final UserModel? utilizadorRestaurado = await AuthService().restaurarSessao();

  runApp(MyApp(utilizadorInicial: utilizadorRestaurado));
}
