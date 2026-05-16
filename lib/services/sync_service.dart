import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'connectivity_service.dart';

/// Tipo de operação que pode estar pendente de sincronização.
enum SyncTipo { create, update, delete }

/// Coleção do JSON Server à qual a operação se aplica.
enum SyncRecurso { users, favoritos, roteiros, rotasPartilhadas }

/// Uma operação pendente guardada na fila offline.
class _PendingOp {
  final String id; // id único da operação (timestamp + random)
  final SyncTipo tipo;
  final SyncRecurso recurso;
  final String? recursoId; // só para update/delete
  final Map<String, dynamic>? payload;
  final DateTime criadaEm;

  _PendingOp({
    required this.id,
    required this.tipo,
    required this.recurso,
    this.recursoId,
    this.payload,
    required this.criadaEm,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo.name,
        'recurso': recurso.name,
        'recursoId': recursoId,
        'payload': payload,
        'criadaEm': criadaEm.toIso8601String(),
      };

  factory _PendingOp.fromJson(Map<String, dynamic> json) => _PendingOp(
        id: json['id'],
        tipo: SyncTipo.values.firstWhere((t) => t.name == json['tipo']),
        recurso:
            SyncRecurso.values.firstWhere((r) => r.name == json['recurso']),
        recursoId: json['recursoId'],
        payload: json['payload'] != null
            ? Map<String, dynamic>.from(json['payload'])
            : null,
        criadaEm: DateTime.parse(json['criadaEm']),
      );
}

/// Orquestra a sincronização entre SharedPreferences (local) e JSON Server.
///
/// Padrão de uso:
/// ```
/// 1. await SyncService().init();
/// 2. Sempre que algo muda localmente, providers chamam
///    SyncService().enfileirar(...) que tenta enviar logo.
/// 3. Se estiver offline, fica na fila e é enviado quando a internet voltar.
/// ```
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _keyFila = 'PENDING_SYNC_QUEUE';

  final ApiService _api = ApiService();
  final ConnectivityService _connectivity = ConnectivityService();

  SharedPreferences? _prefs;
  StreamSubscription<bool>? _connectivitySub;
  bool _aProcessar = false;

  // ─── Inicialização ─────────────────────────────────────────────────────────

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _connectivity.init();

    // Quando a internet volta, processa a fila automaticamente
    _connectivitySub = _connectivity.onStatusChange.listen((online) {
      debugPrint('[SyncService] 🌐 rede mudou: ${online ? "online" : "offline"}');
      if (online) processarFila();
    });

    // Tenta processar SEMPRE — o próprio pedido HTTP avisa se não houver rede.
    // ignore: unawaited_futures
    processarFila();
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  // ─── API pública ───────────────────────────────────────────────────────────

  /// Enfileira uma operação e tenta logo enviá-la.
  ///
  /// Sempre tenta processar — o `connectivity_plus` no Web pode mentir, por
  /// isso confiamos no próprio pedido HTTP para falhar se não houver rede.
  Future<void> enfileirar({
    required SyncTipo tipo,
    required SyncRecurso recurso,
    String? recursoId,
    Map<String, dynamic>? payload,
  }) async {
    final op = _PendingOp(
      id: '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      tipo: tipo,
      recurso: recurso,
      recursoId: recursoId,
      payload: payload,
      criadaEm: DateTime.now(),
    );

    final fila = _lerFila();
    fila.add(op);
    await _gravarFila(fila);

    debugPrint('[SyncService] 📥 enfileirado: ${tipo.name} ${recurso.name}'
        ' (fila: ${fila.length})');

    // Tenta processar imediatamente — não confiamos só no connectivity check
    // ignore: unawaited_futures
    processarFila();
  }

  /// Processa a fila de operações pendentes. Pára à primeira falha de rede
  /// (assume que se uma falha, as próximas também vão falhar).
  Future<void> processarFila() async {
    if (_aProcessar) return; // evita corridas
    _aProcessar = true;

    try {
      var fila = _lerFila();
      if (fila.isEmpty) return;

      debugPrint('[SyncService] 🔄 a processar ${fila.length} operações…');

      while (fila.isNotEmpty) {
        final op = fila.first;
        try {
          await _executar(op);
          fila.removeAt(0);
          await _gravarFila(fila);
          debugPrint(
              '[SyncService] ✅ sincronizado: ${op.tipo.name} ${op.recurso.name}');
        } on ApiException catch (e) {
          debugPrint('[SyncService] ⚠️ falha de rede — fica em fila: $e');
          break;
        } catch (e, st) {
          debugPrint('[SyncService] ❌ erro irrecuperável: $e\n$st');
          fila.removeAt(0);
          await _gravarFila(fila);
        }
      }

      if (fila.isEmpty) {
        debugPrint('[SyncService] ✨ fila esvaziada');
      }
    } finally {
      _aProcessar = false;
    }
  }

  /// Quantas operações estão à espera de sincronizar.
  int get pendentes => _lerFila().length;

  /// Atalho para `ConnectivityService` para o UI saber o estado.
  bool get estaOnline => _connectivity.estaOnline;
  Stream<bool> get onStatusChange => _connectivity.onStatusChange;

  // ─── Execução por tipo de operação ─────────────────────────────────────────

  Future<void> _executar(_PendingOp op) async {
    switch (op.recurso) {
      case SyncRecurso.users:
        await _executarUser(op);
        break;
      case SyncRecurso.favoritos:
        await _executarFavorito(op);
        break;
      case SyncRecurso.roteiros:
        await _executarRoteiro(op);
        break;
      case SyncRecurso.rotasPartilhadas:
        await _executarRotaPartilhada(op);
        break;
    }
  }

  Future<void> _executarUser(_PendingOp op) async {
    switch (op.tipo) {
      case SyncTipo.create:
        await _api.createUser(op.payload!);
        break;
      case SyncTipo.update:
        await _api.updateUser(op.recursoId!, op.payload!);
        break;
      case SyncTipo.delete:
        // Não implementado por agora
        break;
    }
  }

  Future<void> _executarFavorito(_PendingOp op) async {
    switch (op.tipo) {
      case SyncTipo.create:
        await _api.criarFavorito(op.payload!);
        break;
      case SyncTipo.delete:
        await _api.apagarFavorito(op.recursoId!);
        break;
      case SyncTipo.update:
        // Favoritos não se atualizam — apaga e cria novo
        break;
    }
  }

  Future<void> _executarRoteiro(_PendingOp op) async {
    switch (op.tipo) {
      case SyncTipo.create:
        await _api.criarRoteiro(op.payload!);
        break;
      case SyncTipo.update:
        await _api.atualizarRoteiro(op.recursoId!, op.payload!);
        break;
      case SyncTipo.delete:
        await _api.apagarRoteiro(op.recursoId!);
        break;
    }
  }

  Future<void> _executarRotaPartilhada(_PendingOp op) async {
    if (op.tipo == SyncTipo.create) {
      await _api.partilharRota(op.payload!);
    }
  }

  // ─── Persistência da fila ──────────────────────────────────────────────────

  List<_PendingOp> _lerFila() {
    final dados = _prefs?.getString(_keyFila);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List;
    return lista
        .map((j) => _PendingOp.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Future<void> _gravarFila(List<_PendingOp> fila) async {
    await _prefs?.setString(
      _keyFila,
      jsonEncode(fila.map((op) => op.toJson()).toList()),
    );
  }
}
