// lib/views/map/poi_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/poi_model.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/itinerary_provider.dart';
import '../../services/geoapify_service.dart';
import '../../widgets/itinerary/active_itinerary_picker.dart';
import '../../widgets/itinerary/add_pois_to_itinerary_sheet.dart';
import '../../widgets/map/active_route_info.dart';
import '../../widgets/map/poi_category_ui.dart';
import '../../widgets/poi_marker.dart';

/// Página do Mapa - Algarve Explorer v2.0
class PoiExplorerScreen extends StatefulWidget {
  const PoiExplorerScreen({super.key});

  @override
  State<PoiExplorerScreen> createState() => _PoiExplorerScreenState();
}

// ═══════════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════════

class _PoiExplorerScreenState extends State<PoiExplorerScreen>
    with SingleTickerProviderStateMixin {
  final GeoapifyService _geoapifyService = GeoapifyService();
  late final TabController _tabController;

  LatLng? _userLocation;
  List<PoiModel> _pois = [];

  bool _loadingLocation = true;
  bool _loadingPois = false;
  String? _error;

final int _radius = 10000;
final int _limit = 50;

  final Set<String> _selectedCategories = {};
  bool _soAbertos = false;

  PoiModel? _poiSelecionado;
  final MapController _mapController = MapController();

  // Acesso ao FavoritesProvider sem ouvir mudanças (refresh é via Consumer)
  FavoritesProvider get _favProvider => context.read<FavoritesProvider>();
  bool _isFavorito(PoiModel poi) =>
      _favProvider.isFavorito(poi.id ?? poi.placeId);
  Future<void> _toggleFavorito(PoiModel poi) => _favProvider.toggle(poi);

  // Modo de seleção múltipla para criar/adicionar a roteiros
  bool _modoSelecao = false;
  final Set<String> _poisSelecionadosParaRoteiro = {};

  void _toggleModoSelecao() {
    setState(() {
      _modoSelecao = !_modoSelecao;
      if (!_modoSelecao) _poisSelecionadosParaRoteiro.clear();
      _poiSelecionado = null;
    });
  }

  String _poiId(PoiModel poi) => poi.id ?? poi.placeId ?? '';

  void _togglePoiSelecaoRoteiro(PoiModel poi) {
    final id = _poiId(poi);
    if (id.isEmpty) return;
    setState(() {
      if (_poisSelecionadosParaRoteiro.contains(id)) {
        _poisSelecionadosParaRoteiro.remove(id);
      } else {
        _poisSelecionadosParaRoteiro.add(id);
      }
    });
  }

  Future<void> _abrirSheetAdicionarAoRoteiro() async {
    final selecionados = _pois
        .where((p) => _poisSelecionadosParaRoteiro.contains(_poiId(p)))
        .toList();
    if (selecionados.isEmpty) return;

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, __) => AddPoisToItinerarySheet(pois: selecionados),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {
        _modoSelecao = false;
        _poisSelecionadosParaRoteiro.clear();
      });
    }
  }

  void _abrirSeletorRoteiroAtivo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, __) => const ActiveItineraryPicker(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LÓGICA (Geolocator + Geoapify)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _carregarDadosIniciais() async {
    try {
      final position = await _obterLocalizacaoActual();
      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = userLatLng;
        _loadingLocation = false;
      });

      // Partilha a posição atual com o ItineraryProvider para que ele a use
      // como ponto de partida ao traçar a rota (assim 1 POI já chega).
      if (mounted) {
        context.read<ItineraryProvider>().definirPontoPartida(userLatLng);
      }

      // Não buscar POIs automaticamente
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar localização: $e';
        _loadingLocation = false;
      });
    }
  }

  Future<void> _pesquisarPois() async {
    if (_userLocation == null) return;

    setState(() {
      _loadingPois = true;
      _error = null;
    });

    try {
      final categoriasParaBuscar = _selectedCategories.isEmpty
          ? poiCategoriesDisponiveis
          : _selectedCategories.toList();

      final resultados = await _geoapifyService.buscarLocaisProximos(
        latitude: _userLocation!.latitude,
        longitude: _userLocation!.longitude,
        categories: categoriasParaBuscar,
        radius: _radius,
        limit: _limit,
        incluirDetalhes: true,
      );

      setState(() {
        _pois = resultados;
        if (_soAbertos) {
          _pois = _pois.where((poi) => _estaAberto(poi)).toList();
        }
        _loadingPois = false;
      });

    } catch (e) {
      setState(() {
        _error = 'Erro ao procurar locais: $e';
        _loadingPois = false;
      });
    }
  }

  Future<Position> _obterLocalizacaoActual() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('A localização está desactivada no dispositivo.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'A permissão de localização foi bloqueada permanentemente.');
    }

    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _alternarCategoria(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  /// Verifica se um POI está aberto agora baseado no campo 'horario' (opening_hours da Geoapify).
  bool _estaAberto(PoiModel poi) {
    if (poi.horario == null || poi.horario!.isEmpty) {
      return true; // Se não tem horário, assume aberto
    }

    final now = DateTime.now();
    final dayOfWeek = _getDayAbbrev(now.weekday); // Ex: 'Mo', 'Tu', etc.
    final currentTime = TimeOfDay.fromDateTime(now);

    // Parse a string: "Mo-Fr 09:00-18:00; Sa 10:00-16:00"
    final rules = poi.horario!.split(';').map((r) => r.trim()).toList();

    for (final rule in rules) {
      if (_ruleMatches(rule, dayOfWeek, currentTime)) {
        return true;
      }
    }

    return false;
  }

  /// Retorna abreviação do dia da semana (Geoapify format).
  String _getDayAbbrev(int weekday) {
    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return days[weekday % 7];
  }

  /// Verifica se uma regra de horário corresponde ao dia e hora atuais.
  bool _ruleMatches(String rule, String day, TimeOfDay currentTime) {
    // Exemplo: "Mo-Fr 09:00-18:00"
    final parts = rule.split(' ');
    if (parts.length < 2) return false;

    final daysRange = parts[0]; // "Mo-Fr"
    final timeRange = parts[1]; // "09:00-18:00"

    // Verifica se o dia atual está no range
    if (!_dayInRange(day, daysRange)) return false;

    // Verifica se a hora atual está no range
    return _timeInRange(currentTime, timeRange);
  }

  /// Verifica se o dia está no range (ex: "Mo-Fr" inclui "Tu").
  bool _dayInRange(String day, String range) {
    if (range == day) return true; // Exato match

    final days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final dayIndex = days.indexOf(day);

    if (range.contains('-')) {
      final split = range.split('-');
      if (split.length == 2) {
        final start = days.indexOf(split[0]);
        final end = days.indexOf(split[1]);
        if (start != -1 && end != -1) {
          return dayIndex >= start && dayIndex <= end;
        }
      }
    }

    return false;
  }

  /// Verifica se a hora está no range (ex: "09:00-18:00").
  bool _timeInRange(TimeOfDay time, String range) {
    final times = range.split('-');
    if (times.length != 2) return false;

    final start = _parseTime(times[0]);
    final end = _parseTime(times[1]);

    if (start == null || end == null) return false;

    final current = time.hour * 60 + time.minute;
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;

    return current >= startMin && current <= endMin;
  }

  /// Parse uma string "HH:MM" para TimeOfDay.
  TimeOfDay? _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════════════

  String _formatarDistancia(double distancia) {
    if (distancia < 1000) return '${distancia.round()} m';
    return '${(distancia / 1000).toStringAsFixed(1)} km';
  }

  void _navegarParaDetalhes(PoiModel poi) {
    Navigator.pushNamed(context, '/detail', arguments: poi);
  }

  // NOVO helper para encontrar categoria:
  PoiCategoryUi _getCategoriaUI(PoiModel poi) {
    return resolvePoiCategoryUi(poi.categoriaPrincipal);
  }
  // ═══════════════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_loadingLocation) {
      return _buildLoadingState();
    }

    if (_userLocation == null && _error != null) {
      return _buildErroState();
    }

    return Scaffold(
      body: Stack(
        children: [
          // CAMADA 1: MAPA
          _buildMapa(),

          // CAMADA 2: FILTROS + TOGGLE (topo)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFiltrosComToggle(),
          ),

          // CAMADA 3: LISTA FLUTUANTE
          _buildListaFlutuante(),

          // CAMADA 4: POI MARKER CARD
          if (_poiSelecionado != null && !_modoSelecao)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: _buildPoiMarkerCard(),
            ),

          // CAMADA 5: BARRA DE SELEÇÃO (quando _modoSelecao está ativo)
          if (_modoSelecao)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBarraSelecao(),
            ),
        ],
      ),
      floatingActionButton: _modoSelecao
          ? null
          : FloatingActionButton.extended(
              onPressed: _pois.isEmpty ? null : _toggleModoSelecao,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_location_alt, color: Colors.white),
              label: const Text(
                'Adicionar ao roteiro',
                style: TextStyle(color: Colors.white),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // Barra inferior mostrada em modo de seleção
  Widget _buildBarraSelecao() {
    final count = _poisSelecionadosParaRoteiro.length;
    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                onPressed: _toggleModoSelecao,
                icon: const Icon(Icons.close),
                tooltip: 'Cancelar seleção',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      count == 0
                          ? 'Toca em pontos para selecionar'
                          : '$count ${count == 1 ? 'ponto selecionado' : 'pontos selecionados'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (count > 0)
                      const Text(
                        'Carrega em "Adicionar" para escolher um roteiro',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: count == 0 ? null : _abrirSheetAdicionarAoRoteiro,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOADING STATE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF4A90D9)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.waves, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'A descobrir o Algarve...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ERRO STATE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildErroState() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, size: 42, color: Colors.red),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Não foi possível carregar o mapa',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ?? 'Verifica a tua ligação ou tenta novamente.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _buildGradientButton(
                  text: 'Tentar novamente',
                  icon: Icons.refresh,
                  onPressed: _carregarDadosIniciais,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MAPA + BOTÕES FLUTUANTES
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMapa() {
    return Consumer2<ItineraryProvider, FavoritesProvider>(
      builder: (context, itineraryProvider, _, __) {
        final ativo = itineraryProvider.roteiroAtivo;
        final rota = itineraryProvider.rotaCalculada;

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation!,
                initialZoom: 15,
                onTap: (_, __) => setState(() => _poiSelecionado = null),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.algarve.explorer',
                ),
                // Polyline da rota Geoapify (segue estradas reais)
                if (rota != null && rota.polyline.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: rota.polyline,
                        color: AppColors.primary,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                // Marcadores numerados das paragens do roteiro ativo
                if (ativo != null && ativo.eventos.isNotEmpty)
                  MarkerLayer(
                    markers: ativo.eventos
                        .map((e) => Marker(
                              point: LatLng(e.poiLatitude, e.poiLongitude),
                              width: 36,
                              height: 36,
                              child: _buildRoteiroParagemMarker(e.ordem),
                            ))
                        .toList(),
                  ),
                MarkerLayer(markers: _criarMarkers()),
              ],
            ),
            // BOTÃO ROTEIRO ATIVO (canto inferior direito, topo)
            Positioned(
              right: 16,
              bottom: 340,
              child: _buildRoteiroButton(itineraryProvider),
            ),
            // BOTÃO FAVORITOS
            Positioned(
              right: 16,
              bottom: 280,
              child: _buildFavoritosButton(),
            ),
            // BOTÃO RECENTRAR
            Positioned(
              right: 16,
              bottom: 220,
              child: _buildRecentrarButton(),
            ),
            // Info da rota ativa (canto superior)
            if (ativo != null)
              Positioned(
                top: 130,
                left: 16,
                right: 16,
                child: const ActiveRouteInfo(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRoteiroParagemMarker(int ordem) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$ordem',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRoteiroButton(ItineraryProvider provider) {
    final ativo = provider.roteiroAtivo;
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: _abrirSeletorRoteiroAtivo,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ativo != null ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.route,
            color: ativo != null ? Colors.white : AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritosButton() {
    return Consumer<FavoritesProvider>(
      builder: (context, fav, _) => _buildFavoritosButtonContent(fav.count),
    );
  }

  Widget _buildFavoritosButtonContent(int count) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: _mostrarFavoritos,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 24),
              if (count > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentrarButton() {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          if (_userLocation != null) {
            _mapController.move(_userLocation!, 15);
          }
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.my_location,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  List<Marker> _criarMarkers() {
    final markers = <Marker>[];

    // PIN do user
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
          ),
        ),
      );
    }

    // PINs dos POIs (coloridos por categoria)
    for (final poi in _pois) {
      final ui = _getCategoriaUI(poi);
      final isFavorito = _isFavorito(poi);
      final isSelecionadoParaRoteiro =
          _poisSelecionadosParaRoteiro.contains(_poiId(poi));

      markers.add(
        Marker(
          point: LatLng(poi.latitude, poi.longitude),
          width: 50,
          height: 60,
          child: GestureDetector(
            onTap: () {
              if (_modoSelecao) {
                _togglePoiSelecaoRoteiro(poi);
              } else {
                setState(() => _poiSelecionado = poi);
              }
            },
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelecionadoParaRoteiro
                        ? AppColors.primary
                        : ui.cor,
                    shape: BoxShape.circle,
                    border: isSelecionadoParaRoteiro
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: (isSelecionadoParaRoteiro
                                ? AppColors.primary
                                : ui.cor)
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSelecionadoParaRoteiro
                        ? Icons.check
                        : (isFavorito ? Icons.favorite : ui.icon),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isSelecionadoParaRoteiro
                        ? AppColors.primary
                        : ui.cor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  transform: Matrix4.rotationZ(0.785),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // ═══════════════════════════════════════════════════════════════════
  // FILTROS + TOGGLE "ABERTO AGORA"
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFiltrosComToggle() {
    return Container(
      color: Colors.white.withValues(alpha: 0.95),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TOGGLE "Aberto agora"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Switch(
                  value: _soAbertos,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _soAbertos = value);
                    _pesquisarPois();
                  },
                ),
                const Expanded(
                  child: Text(
                    'Só abertos agora',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // CATEGORIAS COLORIDAS
          Container(
            height: 60,
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: poiCategoriesDisponiveis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final categoria = poiCategoriesDisponiveis[index];
                final ui = poiCategoryUi[categoria]!;
                final isSelected = _selectedCategories.contains(categoria);

                return FilterChip(
                  selected: isSelected,
                  showCheckmark: false,
                  avatar: Icon(
                    ui.icon,
                    size: 18,
                    color: isSelected ? Colors.white : ui.cor,
                  ),
                  label: Text(
                    ui.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : ui.cor,
                    ),
                  ),
                  selectedColor: ui.cor,
                  backgroundColor: ui.cor.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: isSelected ? ui.cor : ui.cor.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) {
                    _alternarCategoria(categoria);
                    _pesquisarPois();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // LISTA FLUTUANTE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildListaFlutuante() {
    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.15,
      maxChildSize: 0.80,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_pois.length} locais',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_loadingPois)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
              // Lista
              Expanded(
                child: _pois.isEmpty
                    ? _buildListaVazia()
                    : ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _pois.length,
                        itemBuilder: (context, index) {
                          final poi = _pois[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPoiListCard(poi),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListaVazia() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum local encontrado',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tenta ajustar os filtros ou voltar a procurar mais tarde.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoiListCard(PoiModel poi) {
    final ui = _getCategoriaUI(poi);
    final isFavorito = _isFavorito(poi);

    // Lógica para destacar POIs sem horário quando filtro "só abertos" está ativo
    final deveDestacarVermelho = _soAbertos && !_estaAberto(poi);
    final corCard = deveDestacarVermelho ? Colors.red.withValues(alpha: 0.1) : Colors.white;
    final corBorda = deveDestacarVermelho ? Colors.red.withValues(alpha: 0.3) : Colors.transparent;

    return Card(
      elevation: 2,
      color: corCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: corBorda, width: 1),
      ),
      child: InkWell(
        onTap: () => _navegarParaDetalhes(poi),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: deveDestacarVermelho ? Colors.red : ui.cor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    isFavorito ? Icons.favorite : ui.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.nome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: deveDestacarVermelho ? Colors.red[700] : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: deveDestacarVermelho
                                ? Colors.red.withValues(alpha: 0.15)
                                : ui.cor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            ui.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: deveDestacarVermelho ? Colors.red[700] : ui.cor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (poi.categoriaPrincipal != null)
                          Text(
                            poi.categoriaPrincipal!,
                            style: TextStyle(
                              fontSize: 12,
                              color: deveDestacarVermelho
                                  ? Colors.red[600]
                                  : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (poi.distancia != null) ...[
                          Icon(
                            Icons.route,
                            size: 14,
                            color: deveDestacarVermelho ? Colors.red : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatarDistancia(poi.distancia!),
                            style: TextStyle(
                              fontSize: 13,
                              color: deveDestacarVermelho ? Colors.red[700] : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (poi.avaliacao != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${poi.avaliacao}',
                            style: TextStyle(
                              fontSize: 13,
                              color: deveDestacarVermelho ? Colors.red[600] : null,
                            ),
                          ),
                        ],
                        // Indicador de horário indisponível
                        if (deveDestacarVermelho) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.red[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Horário indisponível',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: deveDestacarVermelho ? Colors.red[400] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // POI MARKER CARD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPoiMarkerCard() {
    final poi = _poiSelecionado!;
    return Consumer<FavoritesProvider>(
      builder: (context, fav, _) => PoiMarkerCard(
        poi: poi,
        isFavorito: fav.isFavorito(poi.id ?? poi.placeId),
        deveDestacarVermelho: _soAbertos && !_estaAberto(poi),
        onFechar: () {
          if (mounted) setState(() => _poiSelecionado = null);
        },
        onVerDetalhes: () {
          setState(() => _poiSelecionado = null);
          _navegarParaDetalhes(poi);
        },
        onToggleFavorito: () => _toggleFavorito(poi),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FAVORITOS (BottomSheet)
  // ═══════════════════════════════════════════════════════════════════

  void _mostrarFavoritos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Consumer<FavoritesProvider>(
              builder: (context, favProvider, _) {
                final favoritos = favProvider.favoritos;
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red),
                            const SizedBox(width: 12),
                            Text(
                              'Meus Favoritos (${favoritos.length})',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: favoritos.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.favorite_border,
                                        size: 64, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Ainda não guardaste nenhum local',
                                      style:
                                          TextStyle(color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: controller,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: favoritos.length,
                                itemBuilder: (context, index) {
                                  final fav = favoritos[index];
                                  return _buildFavoritoListItem(
                                      fav, favProvider);
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritoListItem(fav, FavoritesProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.favorite, color: Colors.white),
        ),
        title: Text(
          fav.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          fav.endereco ?? fav.categoria ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => provider.remover(fav.id),
          tooltip: 'Remover dos favoritos',
        ),
        onTap: () {
          Navigator.pop(context);
          // Centra o mapa no favorito
          _mapController.move(LatLng(fav.latitude, fav.longitude), 16);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // BOTÃO GRADIENTE (helper)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF0052A3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
