import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente (.env com GEOAPIFY_API_KEY e API_BASE_URL).
  // Tem de ser feito ANTES de qualquer serviço externo ser instanciado.
  await dotenv.load(fileName: '.env');

  await StorageService().init();

  // Inicializa o serviço de sincronização (deteta online/offline e processa
  // a fila pendente assim que houver internet).
  await SyncService().init();

  // Restaura sessão antes de arrancar a app.
  // Se houver sessão válida, o utilizador vai direto para /shell.
  final UserModel? utilizadorRestaurado = await AuthService().restaurarSessao();

  runApp(MyApp(utilizadorInicial: utilizadorRestaurado));
}
