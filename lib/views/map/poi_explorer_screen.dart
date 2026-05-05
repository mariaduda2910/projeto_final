import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../models/poi_model.dart';
import '../../services/geoapify_service.dart';

class PoiExplorerScreen extends StatefulWidget {
  const PoiExplorerScreen({super.key});

  @override
  State<PoiExplorerScreen> createState() => _PoiExplorerScreenState();
}

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

  final Set<String> _selectedCategories = {
    'catering.restaurant',
  };

  final List<_PoiCategoryOption> _availableCategories = const [
    _PoiCategoryOption(
      label: 'Restaurantes',
      category: 'catering.restaurant',
      icon: Icons.restaurant,
    ),
    _PoiCategoryOption(
      label: 'Cafés',
      category: 'catering.cafe',
      icon: Icons.local_cafe,
    ),
    _PoiCategoryOption(
      label: 'Bares',
      category: 'catering.bar',
      icon: Icons.local_bar,
    ),
    _PoiCategoryOption(
      label: 'Hotéis',
      category: 'accommodation.hotel',
      icon: Icons.hotel,
    ),
    _PoiCategoryOption(
      label: 'Atrações',
      category: 'tourism.attraction',
      icon: Icons.attractions,
    ),
    _PoiCategoryOption(
      label: 'Museus',
      category: 'entertainment.museum',
      icon: Icons.museum,
    ),
    _PoiCategoryOption(
      label: 'Supermercados',
      category: 'commercial.supermarket',
      icon: Icons.shopping_cart,
    ),
    _PoiCategoryOption(
      label: 'Farmácias',
      category: 'healthcare.pharmacy',
      icon: Icons.local_pharmacy,
    ),
    _PoiCategoryOption(
      label: 'Praias',
      category: 'natural.beach',
      icon: Icons.beach_access,
    ),
    _PoiCategoryOption(
      label: 'Parques',
      category: 'leisure.park',
      icon: Icons.park,
    ),
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

    super.dispose();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final position = await _obterLocalizacaoActual();

      final userLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

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
    if (_userLocation == null) {
      return;
    }

    if (_selectedCategories.isEmpty) {
      setState(() {
        _error = 'Selecciona pelo menos uma categoria.';
      });

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
      throw Exception(
        'A permissão de localização foi bloqueada permanentemente.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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

  List<Marker> _criarMarkers() {
    final markers = <Marker>[];

    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 60,
          height: 60,
          child: const Icon(
            Icons.my_location,
            size: 40,
            color: Colors.blue,
          ),
        ),
      );
    }

    for (final poi in _pois) {
      markers.add(
        Marker(
          point: LatLng(
            poi.latitude,
            poi.longitude,
          ),
          width: 60,
          height: 60,
          child: GestureDetector(
            onTap: () => _abrirResumoPoi(poi),
            child: Icon(
              _iconeParaPoi(poi),
              size: 36,
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    return markers;
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

  void _abrirResumoPoi(PoiModel poi) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poi.nome,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (poi.endereco != null)
                Text(
                  poi.endereco!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (poi.distancia != null)
                    Chip(
                      avatar: const Icon(Icons.route, size: 18),
                      label: Text(_formatarDistancia(poi.distancia!)),
                    ),
                  if (poi.categoriaPrincipal != null)
                    Chip(
                      avatar: const Icon(Icons.category, size: 18),
                      label: Text(poi.categoriaPrincipal!),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.list),
                label: const Text('Ver detalhes na lista'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatarDistancia(double distancia) {
    if (distancia < 1000) {
      return '${distancia.round()} m';
    }

    final km = distancia / 1000;

    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingLocation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Locais próximos'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userLocation == null && _error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Locais próximos'),
        ),
        body: _ErroEstado(
          mensagem: _error!,
          onRetry: _carregarDadosIniciais,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais próximos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.map),
              text: 'Mapa',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'Lista',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _PainelFiltros(
            availableCategories: _availableCategories,
            selectedCategories: _selectedCategories,
            radius: _radius,
            limit: _limit,
            loading: _loadingPois,
            onToggleCategory: _alternarCategoria,
            onRadiusChanged: (value) {
              setState(() {
                _radius = value;
              });
            },
            onLimitChanged: (value) {
              setState(() {
                _limit = value;
              });
            },
            onSearch: _pesquisarPois,
          ),
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                  },
                  child: const Text('Fechar'),
                ),
              ],
            ),
          if (_loadingPois)
            const LinearProgressIndicator(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MapaPois(
                  userLocation: _userLocation!,
                  markers: _criarMarkers(),
                ),
                _ListaPois(
                  pois: _pois,
                  formatarDistancia: _formatarDistancia,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PainelFiltros extends StatelessWidget {
  final List<_PoiCategoryOption> availableCategories;
  final Set<String> selectedCategories;

  final int radius;
  final int limit;

  final bool loading;

  final ValueChanged<String> onToggleCategory;
  final ValueChanged<int> onRadiusChanged;
  final ValueChanged<int> onLimitChanged;
  final VoidCallback onSearch;

  const _PainelFiltros({
    required this.availableCategories,
    required this.selectedCategories,
    required this.radius,
    required this.limit,
    required this.loading,
    required this.onToggleCategory,
    required this.onRadiusChanged,
    required this.onLimitChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorias',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: availableCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final option = availableCategories[index];
                  final selected = selectedCategories.contains(option.category);

                  return FilterChip(
                    selected: selected,
                    avatar: Icon(
                      option.icon,
                      size: 18,
                    ),
                    label: Text(option.label),
                    onSelected: (_) => onToggleCategory(option.category),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: radius,
                    decoration: const InputDecoration(
                      labelText: 'Raio',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 500,
                        child: Text('500 m'),
                      ),
                      DropdownMenuItem(
                        value: 1000,
                        child: Text('1 km'),
                      ),
                      DropdownMenuItem(
                        value: 3000,
                        child: Text('3 km'),
                      ),
                      DropdownMenuItem(
                        value: 5000,
                        child: Text('5 km'),
                      ),
                      DropdownMenuItem(
                        value: 10000,
                        child: Text('10 km'),
                      ),
                    ],
                    onChanged: loading
                        ? null
                        : (value) {
                            if (value != null) {
                              onRadiusChanged(value);
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: limit,
                    decoration: const InputDecoration(
                      labelText: 'Limite',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 10,
                        child: Text('10 locais'),
                      ),
                      DropdownMenuItem(
                        value: 20,
                        child: Text('20 locais'),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text('30 locais'),
                      ),
                      DropdownMenuItem(
                        value: 50,
                        child: Text('50 locais'),
                      ),
                    ],
                    onChanged: loading
                        ? null
                        : (value) {
                            if (value != null) {
                              onLimitChanged(value);
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: loading ? null : onSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Pesquisar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapaPois extends StatelessWidget {
  final LatLng userLocation;
  final List<Marker> markers;

  const _MapaPois({
    required this.userLocation,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: userLocation,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.projeto_final_flutter',
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }
}

class _ListaPois extends StatelessWidget {
  final List<PoiModel> pois;
  final String Function(double distancia) formatarDistancia;

  const _ListaPois({
    required this.pois,
    required this.formatarDistancia,
  });

  @override
  Widget build(BuildContext context) {
    if (pois.isEmpty) {
      return const Center(
        child: Text('Nenhum local encontrado com os filtros seleccionados.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: pois.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final poi = pois[index];

        return _PoiCard(
          poi: poi,
          formatarDistancia: formatarDistancia,
        );
      },
    );
  }
}

class _PoiCard extends StatelessWidget {
  final PoiModel poi;
  final String Function(double distancia) formatarDistancia;

  const _PoiCard({
    required this.poi,
    required this.formatarDistancia,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poi.nome,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (poi.distancia != null)
                  Chip(
                    avatar: const Icon(Icons.route, size: 18),
                    label: Text(formatarDistancia(poi.distancia!)),
                  ),
                if (poi.categoriaPrincipal != null)
                  Chip(
                    avatar: const Icon(Icons.category, size: 18),
                    label: Text(poi.categoriaPrincipal!),
                  ),
                if (poi.cozinha != null)
                  Chip(
                    avatar: const Icon(Icons.restaurant_menu, size: 18),
                    label: Text(poi.cozinha!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (poi.endereco != null)
              _InfoLinha(
                icon: Icons.place,
                label: poi.endereco!,
              ),
            if (poi.cidade != null)
              _InfoLinha(
                icon: Icons.location_city,
                label: poi.cidade!,
              ),
            if (poi.telefone != null)
              _InfoLinha(
                icon: Icons.phone,
                label: poi.telefone!,
              ),
            if (poi.email != null)
              _InfoLinha(
                icon: Icons.email,
                label: poi.email!,
              ),
            if (poi.website != null)
              _InfoLinha(
                icon: Icons.language,
                label: poi.website!,
              ),
            if (poi.horario != null)
              _InfoLinha(
                icon: Icons.schedule,
                label: poi.horario!,
              ),
            if (poi.descricao != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  poi.descricao!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text('Categorias Geoapify'),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: poi.categorias
                        .map(
                          (categoria) => Chip(
                            label: Text(categoria),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLinha extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoLinha({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

class _ErroEstado extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _ErroEstado({
    required this.mensagem,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

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