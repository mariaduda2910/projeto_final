import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wrapper fino sobre `connectivity_plus`.
///
/// **Responsabilidade única:** dizer se há rede agora e avisar quando muda.
///
/// **Nota:** "tem rede" ≠ "tem internet a sério". O `connectivity_plus` só
/// sabe se estamos ligados a WiFi/Mobile, não se há conectividade real. Para
/// um TP académico isto chega; em produção podias confirmar com um ping ao
/// servidor.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();
  StreamSubscription<ConnectivityResult>? _sub;
  bool _ultimoEstado = true;

  /// Stream que emite `true` (online) ou `false` (offline) a cada mudança.
  Stream<bool> get onStatusChange => _statusController.stream;

  /// Último valor conhecido — útil para verificações imediatas sem aguardar.
  bool get estaOnline => _ultimoEstado;

  /// Inicializa o serviço — começa a ouvir mudanças de conectividade.
  /// Chamar uma vez no arranque da app (em `main.dart`).
  Future<void> init() async {
    final atual = await _connectivity.checkConnectivity();
    _ultimoEstado = _temRede(atual);

    _sub = _connectivity.onConnectivityChanged.listen((resultado) {
      final novo = _temRede(resultado);
      if (novo != _ultimoEstado) {
        _ultimoEstado = novo;
        _statusController.add(novo);
      }
    });
  }

  /// Pergunta o estado atual de forma assíncrona (sem cache).
  Future<bool> temInternet() async {
    final resultado = await _connectivity.checkConnectivity();
    return _temRede(resultado);
  }

  bool _temRede(ConnectivityResult resultado) {
    return resultado != ConnectivityResult.none;
  }

  void dispose() {
    _sub?.cancel();
    _statusController.close();
  }
}
