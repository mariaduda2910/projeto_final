// lib/views/map/poi_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';
import '../../models/poi_model.dart';
import '../../services/geoapify_service.dart';
import '../../widgets/poi_marker.dart';

/// Página do Mapa - Algarve Explorer v2.0
class PoiExplorerScreen extends StatefulWidget {
  const PoiExplorerScreen({super.key});

  @override
  State<PoiExplorerScreen> createState() => _PoiExplorerScreenState();
}

// ═══════════════════════════════════════════════════════════════════
// CONFIGURAÇÃO DE CORES POR CATEGORIA
// ═══════════════════════════════════════════════════════════════════

class _CategoriaUI {
  final String label;
  final IconData icon;
  final Color cor;
  const _CategoriaUI(this.label, this.icon, this.cor);
}

final Map<String, _CategoriaUI> _categoriaUI = {
  'catering.restaurant':
      const _CategoriaUI('Restaurantes', Icons.restaurant, Color(0xFFFF6B6B)),
  'catering.cafe':
      const _CategoriaUI('Cafés', Icons.local_cafe, Color(0xFFFFB347)),
  'catering.bar':
      const _CategoriaUI('Bares', Icons.local_bar, Color(0xFFAA96DA)),
  'accommodation.hotel':
      const _CategoriaUI('Hotéis', Icons.hotel, Color(0xFF4ECDC4)),
  'tourism.attraction':
      const _CategoriaUI('Atrações', Icons.attractions, Color(0xFFF38181)),
  'entertainment.museum':
      const _CategoriaUI('Museus', Icons.museum, Color(0xFF95E1D3)),
  'commercial.supermarket': const _CategoriaUI(
      'Supermercados', Icons.shopping_cart, Color(0xFF74B9FF)),
  'healthcare.pharmacy':
      const _CategoriaUI('Farmácias', Icons.local_pharmacy, Color(0xFFFD79A8)),
  'natural.beach':
      const _CategoriaUI('Praias', Icons.beach_access, Color(0xFFFFD93D)),
  'leisure.park': const _CategoriaUI('Parques', Icons.park, Color(0xFF55EFC4)),
};

final List<String> _categoriasDisponiveis = [
  'catering.restaurant',
  'catering.cafe',
  'catering.bar',
  'accommodation.hotel',
  'tourism.attraction',
  'entertainment.museum',
  'commercial.supermarket',
  'healthcare.pharmacy',
  'natural.beach',
  'leisure.park',
];

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

  int _radius = 10000;
  int _limit = 50;

  final Set<String> _selectedCategories = {};
  bool _soAbertos = false;

  PoiModel? _poiSelecionado;
  final Set<String> _favoritos = {};
  final MapController _mapController = MapController();

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
          ? _categoriasDisponiveis
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

      print('POIs fetched: ${resultados.length}');
      for (var poi in resultados) {
        print('  - ${poi.nome}: ${poi.categoriaPrincipal}');
      }
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
  _CategoriaUI _getCategoriaUI(PoiModel poi) {
    final cat = poi.categoriaPrincipal?.toLowerCase() ?? '';

    // Mapeamento direto das categorias da API Geoapify
    if (cat == 'tourism') return _categoriaUI['tourism.attraction']!;
    if (cat == 'catering') return _categoriaUI['catering.restaurant']!;
    if (cat == 'commercial') return _categoriaUI['commercial.supermarket']!;
    if (cat == 'entertainment') return _categoriaUI['entertainment.museum']!;
    if (cat == 'natural') return _categoriaUI['natural.beach']!;
    if (cat == 'leisure') return _categoriaUI['leisure.park']!;
    if (cat == 'accommodation') return _categoriaUI['accommodation.hotel']!;
    if (cat == 'healthcare') return _categoriaUI['healthcare.pharmacy']!;

    // Fallback para substrings (para subcategorias como catering.restaurant)
    if (cat.contains('restaurant')) return _categoriaUI['catering.restaurant']!;
    if (cat.contains('cafe')) return _categoriaUI['catering.cafe']!;
    if (cat.contains('bar')) return _categoriaUI['catering.bar']!;
    if (cat.contains('hotel')) return _categoriaUI['accommodation.hotel']!;
    if (cat.contains('attraction') || cat.contains('tourism'))
      return _categoriaUI['tourism.attraction']!;
    if (cat.contains('museum')) return _categoriaUI['entertainment.museum']!;
    if (cat.contains('supermarket') || cat.contains('commercial'))
      return _categoriaUI['commercial.supermarket']!;
    if (cat.contains('pharmacy')) return _categoriaUI['healthcare.pharmacy']!;
    if (cat.contains('beach')) return _categoriaUI['natural.beach']!;
    if (cat.contains('park')) return _categoriaUI['leisure.park']!;

    // Fallback
    return const _CategoriaUI('Local', Icons.place, AppColors.primary);
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
          if (_poiSelecionado != null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: _buildPoiMarkerCard(),
            ),
        ],
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
                    color: AppColors.primary.withOpacity(0.3),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline,
                    size: 40, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MAPA + BOTÕES FLUTUANTES
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMapa() {
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
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.algarve.explorer',
            ),
            MarkerLayer(
              markers: _criarMarkers(),
            ),
          ],
        ),
        // BOTÃO FAVORITOS (canto inferior direito, acima)
        Positioned(
          right: 16,
          bottom: 280,
          child: _buildFavoritosButton(),
        ),
        // BOTÃO RECENTRAR (canto inferior direito, abaixo)
        Positioned(
          right: 16,
          bottom: 220,
          child: _buildRecentrarButton(),
        ),
      ],
    );
  }

  Widget _buildFavoritosButton() {
    final count = _favoritos.length;
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
      final isFavorito = _favoritos.contains(poi.id);

      markers.add(
        Marker(
          point: LatLng(poi.latitude, poi.longitude),
          width: 50,
          height: 60,
          child: GestureDetector(
            onTap: () => setState(() => _poiSelecionado = poi),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ui.cor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ui.cor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorito ? Icons.favorite : ui.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ui.cor,
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
      color: Colors.white.withValues(alpha:0.95),
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
                const Text(
                  'Só abertos agora',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
              itemCount: _categoriasDisponiveis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final categoria = _categoriasDisponiveis[index];
                final ui = _categoriaUI[categoria]!;
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
                  backgroundColor: ui.cor.withOpacity(0.1),
                  side: BorderSide(
                    color: isSelected ? ui.cor : ui.cor.withOpacity(0.3),
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
                color: Colors.black.withOpacity(0.1),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Nenhum local encontrado',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPoiListCard(PoiModel poi) {
    final ui = _getCategoriaUI(poi);
    final isFavorito = _favoritos.contains(poi.id);

    // Lógica para destacar POIs sem horário quando filtro "só abertos" está ativo
    final deveDestacarVermelho = _soAbertos && !_estaAberto(poi);
    final corCard = deveDestacarVermelho ? Colors.red.withOpacity(0.1) : Colors.white;
    final corBorda = deveDestacarVermelho ? Colors.red.withOpacity(0.3) : Colors.transparent;

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
                                ? Colors.red.withOpacity(0.15)
                                : ui.cor.withOpacity(0.15),
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
    return PoiMarkerCard(
      poi: _poiSelecionado!,
      isFavorito: _favoritos.contains(_poiSelecionado!.id),
      deveDestacarVermelho: _soAbertos && !_estaAberto(_poiSelecionado!),
      onFechar: () {
        if (mounted) {
          setState(() => _poiSelecionado = null);
        }
      },
      onVerDetalhes: () {
        final poi = _poiSelecionado!;
        setState(() => _poiSelecionado = null);
        _navegarParaDetalhes(poi);
      },
      onToggleFavorito: () {
        setState(() {
          final id = _poiSelecionado!.id!;
          if (_favoritos.contains(id)) {
            _favoritos.remove(id);
          } else {
            _favoritos.add(id);
          }
        });
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FAVORITOS (BottomSheet)
  // ═══════════════════════════════════════════════════════════════════

  void _mostrarFavoritos() {
    final favoritosPois =
        _pois.where((p) => _favoritos.contains(p.id)).toList();

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
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          'Meus Favoritos (${favoritosPois.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: favoritosPois.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_border,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'Ainda não guardaste nenhum local',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: favoritosPois.length,
                            itemBuilder: (context, index) {
                              final poi = favoritosPois[index];
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
      },
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
