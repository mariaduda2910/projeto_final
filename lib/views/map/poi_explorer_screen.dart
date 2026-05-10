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
/// 
/// Lógica: Mantém a tua (Geolocator + Geoapify API)
/// UI: Novo estilo Airbnb com DraggableScrollableSheet + PoiMarkerCard
class PoiExplorerScreen extends StatefulWidget {
  const PoiExplorerScreen({super.key});

  @override
  State<PoiExplorerScreen> createState() => _PoiExplorerScreenState();
}

// ═══════════════════════════════════════════════════════════════════
// ═══ ESTADO (LÓGICA ORIGINAL — NÃO MEXER ══════════════════════════
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

  int _radius = 1000;
  int _limit = 20;

  final Set<String> _selectedCategories = {'catering.restaurant'};

  // ═══ NOVO: Estado para UI ═══════════════════════════════════════
  PoiModel? _poiSelecionado;        // POI clicado no mapa
  final Set<String> _favoritos = {}; // IDs dos favoritos
  final MapController _mapController = MapController();

  // ═══ CATEGORIAS (tua lista original) ════════════════════════════
  final List<_PoiCategoryOption> _availableCategories = const [
    _PoiCategoryOption(label: 'Restaurantes', category: 'catering.restaurant', icon: Icons.restaurant),
    _PoiCategoryOption(label: 'Cafés', category: 'catering.cafe', icon: Icons.local_cafe),
    _PoiCategoryOption(label: 'Bares', category: 'catering.bar', icon: Icons.local_bar),
    _PoiCategoryOption(label: 'Hotéis', category: 'accommodation.hotel', icon: Icons.hotel),
    _PoiCategoryOption(label: 'Atrações', category: 'tourism.attraction', icon: Icons.attractions),
    _PoiCategoryOption(label: 'Museus', category: 'entertainment.museum', icon: Icons.museum),
    _PoiCategoryOption(label: 'Supermercados', category: 'commercial.supermarket', icon: Icons.shopping_cart),
    _PoiCategoryOption(label: 'Farmácias', category: 'healthcare.pharmacy', icon: Icons.local_pharmacy),
    _PoiCategoryOption(label: 'Praias', category: 'natural.beach', icon: Icons.beach_access),
    _PoiCategoryOption(label: 'Parques', category: 'leisure.park', icon: Icons.park),
  ];

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
  // ═══ LÓGICA ORIGINAL (Geolocator + Geoapify) — NÃO MEXER ══════════
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _carregarDadosIniciais() async {
    try {
      final position = await _obterLocalizacaoActual();
      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = userLatLng;
        _loadingLocation = false;
      });

      await _pesquisarPois();
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar localização: $e';
        _loadingLocation = false;
      });
    }
  }

  Future<void> _pesquisarPois() async {
    if (_userLocation == null) return;
    if (_selectedCategories.isEmpty) {
      setState(() => _error = 'Selecciona pelo menos uma categoria.');
      return;
    }

    setState(() {
      _loadingPois = true;
      _error = null;
    });

    try {
      final resultados = await _geoapifyService.buscarLocaisProximos(
        latitude: _userLocation!.latitude,
        longitude: _userLocation!.longitude,
        categories: _selectedCategories.toList(),
        radius: _radius,
        limit: _limit,
        incluirDetalhes: true,
      );

      setState(() {
        _pois = resultados;
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
      throw Exception('A permissão de localização foi bloqueada permanentemente.');
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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

  // ═══════════════════════════════════════════════════════════════════
  // ═══ NOVO: UI HELPERS ═════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════

  String _formatarDistancia(double distancia) {
    if (distancia < 1000) return '${distancia.round()} m';
    return '${(distancia / 1000).toStringAsFixed(1)} km';
  }

  IconData _iconeParaPoi(PoiModel poi) {
    final categoria = poi.categoriaPrincipal ?? '';
    if (categoria.contains('restaurant')) return Icons.restaurant;
    if (categoria.contains('cafe')) return Icons.local_cafe;
    if (categoria.contains('bar')) return Icons.local_bar;
    if (categoria.contains('hotel')) return Icons.hotel;
    if (categoria.contains('museum')) return Icons.museum;
    if (categoria.contains('pharmacy')) return Icons.local_pharmacy;
    if (categoria.contains('supermarket')) return Icons.shopping_cart;
    if (categoria.contains('beach')) return Icons.beach_access;
    if (categoria.contains('park')) return Icons.park;
    if (categoria.contains('tourism')) return Icons.attractions;
    return Icons.place;
  }

  void _navegarParaDetalhes(PoiModel poi) {
    Navigator.pushNamed(context, '/detail', arguments: poi);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ═══ BUILD — UI NOVO (Airbnb-style) ═══════════════════════════════
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // Loading inicial
    if (_loadingLocation) {
      return _buildLoadingState();
    }

    // Erro de localização
    if (_userLocation == null && _error != null) {
      return _buildErroState();
    }

    // UI principal: Stack com Mapa + Filtros + Lista + Card
    return Scaffold(
      body: Stack(
        children: [
          // CAMADA 1: MAPA (fundo)
          _buildMapa(),
          
          // CAMADA 2: FILTROS (topo, sobre o mapa)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFiltros(),
          ),
          
          // CAMADA 3: LISTA FLUTUANTE (de baixo, arrastável)
          _buildListaFlutuante(),
          
          // CAMADA 4: POI MARKER CARD (quando clica num pin)
          if (_poiSelecionado != null)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _buildPoiMarkerCard(),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ═══ LOADING STATE (bonito, estilo login) ════════════════════════
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🌊 Onda animada (igual login)
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
  // ═══ ERRO STATE (bonito, com retry) ═══════════════════════════════
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
                child: const Icon(Icons.error_outline, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
  // ═══ MAPA (com pins estilo login) ══════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMapa() {
    return FlutterMap(
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
    );
  }

  List<Marker> _criarMarkers() {
    final markers = <Marker>[];

    // PIN da localização do user (azul)
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

    // PINs dos POIs (gradiente azul, estilo login)
    for (final poi in _pois) {
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
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF4A90D9)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _iconeParaPoi(poi),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
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
  // ═══ FILTROS (chips estilo login) ════════════════════════════════
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _availableCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final option = _availableCategories[index];
          final isSelected = _selectedCategories.contains(option.category);

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              option.icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            label: Text(
              option.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            selectedColor: AppColors.primary,
            backgroundColor: const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
              ),
            ),
            onSelected: (_) {
              _alternarCategoria(option.category);
              _pesquisarPois(); // Recarrega com novo filtro
            },
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ═══ LISTA FLUTUANTE (DraggableScrollableSheet — Airbnb) ════════
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildListaFlutuante() {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,  // Começa a 25%
      minChildSize: 0.12,       // Mínimo: só handle
      maxChildSize: 0.85,       // Máximo: quase fullscreen
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
              // Handle de arrastar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header: "N locais encontrados"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_pois.length} locais encontrados',
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
              
              // Lista de POIs
              Expanded(
                child: _pois.isEmpty
                    ? _buildListaVazia()
                    : ListView.builder(
                        controller: scrollController,
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

  // Card da lista (simplificado, estilo login)
  Widget _buildPoiListCard(PoiModel poi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navegarParaDetalhes(poi),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone gradiente
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF4A90D9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconeParaPoi(poi),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (poi.categoriaPrincipal != null)
                      Text(
                        poi.categoriaPrincipal!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (poi.distancia != null) ...[
                          Icon(Icons.route, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            _formatarDistancia(poi.distancia!),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (poi.avaliacao != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${poi.avaliacao}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Seta
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ═══ POI MARKER CARD (quando clica num pin) ═══════════════════════
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPoiMarkerCard() {
    return PoiMarkerCard(
      poi: _poiSelecionado!,
      isFavorito: _favoritos.contains(_poiSelecionado!.id),
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
  // ═══ BOTÃO GRADIENTE (helper, estilo login) ════════════════════════
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

// ═══════════════════════════════════════════════════════════════════
// ═══ CLASSE AUXILIAR (tua original) ════════════════════════════════
// ═══════════════════════════════════════════════════════════════════

class _PoiCategoryOption {
  final String label;
  final String category;
  final IconData icon;

  const _PoiCategoryOption({
    required this.label,
    required this.category,
    required this.icon,
  });
}