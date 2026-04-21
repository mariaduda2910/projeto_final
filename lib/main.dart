// Ponto de entrada da aplicação
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/storage_service.dart';

/// Função principal que arranca a aplicação.
void main() async {
  // Garante que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa serviços globais antes de correr a app
  await StorageService().init();
  
  // Corre a aplicação
  runApp(const MyApp());
}