// Ponto de entrada da aplicação
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ← adicionar
import 'app.dart';
import 'services/storage_service.dart';

/// Função principal que arranca a aplicação.
void main() async {
  // Garante que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente          // ← adicionar
  await dotenv.load(fileName: ".env"); // ← adicionar

  // Inicializa serviços globais antes de correr a app
  await StorageService().init();

  // Corre a aplicação
  runApp(const MyApp());
}
