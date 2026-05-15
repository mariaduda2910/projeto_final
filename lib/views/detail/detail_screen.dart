// lib/views/detail/detail_screen.dart — FUNCIONAL, SEM MOCK
// Recebe PoiModel via arguments e busca detalhes completos da Geoapify
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/poi_model.dart';
import '../../models/itinerary_event_model.dart';
import '../../services/geoapify_service.dart';
import '../../providers/itinerary_provider.dart';

class DetailScreen extends StatefulWidget {
  final PoiModel? poi;
  const DetailScreen({super.key, this.poi});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  PoiModel? _poiDetalhado;
  bool _loadingDetalhes = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarDetalhes();
  }

  Future<void> _carregarDetalhes() async {
    final poi = widget.poi;
    if (poi == null) return;

    if (poi.placeId != null && poi.placeId!.isNotEmpty) {
      setState(() => _loadingDetalhes = true);
      try {
        final detalhado = await _geoapifyService.buscarDetalhesPorPlaceId(
          placeId: poi.placeId!,
          features: const ['details', 'contact'],
        );
        if (detalhado != null && mounted) {
          setState(() => _poiDetalhado = detalhado);
        }
      } catch (e) {
        if (mounted) setState(() => _error = 'Erro ao carregar detalhes: $e');
      } finally {
        if (mounted) setState(() => _loadingDetalhes = false);
      }
    }
  }

  PoiModel get _poi => _poiDetalhado ?? widget.poi!;

  _CategoriaUI _getCategoriaUI() {
    final cat = _poi.categoriaPrincipal?.toLowerCase() ?? '';
    if (cat.contains('restaurant')) {
      return const _CategoriaUI('Restaurante', Icons.restaurant, Color(0xFFFF6B6B));
    }
    if (cat.contains('cafe')) {
      return const _CategoriaUI('Café', Icons.local_cafe, Color(0xFFFFB347));
    }
    if (cat.contains('bar')) {
      return const _CategoriaUI('Bar', Icons.local_bar, Color(0xFFAA96DA));
    }
    if (cat.contains('hotel') || cat.contains('accommodation')) {
      return const _CategoriaUI('Alojamento', Icons.hotel, Color(0xFF4ECDC4));
    }
    if (cat.contains('attraction') || cat.contains('tourism')) {
      return const _CategoriaUI('Atração', Icons.attractions, Color(0xFFF38181));
    }
    if (cat.contains('museum') || cat.contains('entertainment')) {
      return const _CategoriaUI('Museu', Icons.museum, Color(0xFF95E1D3));
    }
    if (cat.contains('beach') || cat.contains('natural')) {
      return const _CategoriaUI('Praia/Natureza', Icons.beach_access, Color(0xFFFFD93D));
    }
    if (cat.contains('park') || cat.contains('leisure')) {
      return const _CategoriaUI('Parque', Icons.park, Color(0xFF55EFC4));
    }
    if (cat.contains('pharmacy') || cat.contains('healthcare')) {
      return const _CategoriaUI('Farmácia', Icons.local_pharmacy, Color(0xFFFD79A8));
    }
    if (cat.contains('supermarket') || cat.contains('commercial')) {
      return const _CategoriaUI('Comércio', Icons.shopping_cart, Color(0xFF74B9FF));
    }
    return const _CategoriaUI('Local', Icons.place, AppColors.primary);
  }

  Future<void> _abrirGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${_poi.latitude},${_poi.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirWaze() async {
    final url = Uri.parse(
      'https://waze.com/ul?ll=${_poi.latitude},${_poi.longitude}&navigate=yes',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirTelefone() async {
    if (_poi.telefone == null) return;
    final url = Uri.parse('tel:${_poi.telefone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _abrirWebsite() async {
    if (_poi.website == null) return;
    final url = Uri.parse(_poi.website!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirEmail() async {
    if (_poi.email == null) return;
    final url = Uri.parse('mailto:${_poi.email}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _mostrarBottomSheetAdicionar() {
    final provider = context.read<ItineraryProvider>();
    final roteiros = provider.roteiros;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_location_alt, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Adicionar ao Roteiro',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: AppColors.accent),
                    ),
                    title: const Text(
                      'Criar novo roteiro',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Começar um roteiro novo com este local'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _navegarParaCriarRoteiro();
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(),
                  ),
                  Expanded(
                    child: roteiros.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_outlined, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'Ainda não tens roteiros',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _navegarParaCriarRoteiro();
                                  },
                                  child: const Text('Criar primeiro roteiro'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: roteiros.length,
                            itemBuilder: (context, index) {
                              final roteiro = roteiros[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: roteiro.ativo
                                        ? AppColors.primary
                                        : Colors.grey[300],
                                    child: Icon(
                                      Icons.map,
                                      color: roteiro.ativo ? Colors.white : Colors.grey[600],
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    roteiro.titulo,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${roteiro.totalParagens} paragens • ${Helpers.formatarData(roteiro.dataInicio)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  trailing: roteiro.ativo
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'ATIVO',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                                  onTap: () async {
                                    final success = await provider.adicionarEventoAoRoteiro(
                                      roteiroId: roteiro.id,
                                      poiId: _poi.id ?? _poi.placeId ?? '',
                                      poiNome: _poi.nome,
                                      poiLatitude: _poi.latitude,
                                      poiLongitude: _poi.longitude,
                                      ordem: roteiro.eventos.length + 1,
                                      periodo: PeriodoDia.tarde,
                                    );
                                    if (success && mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${_poi.nome} adicionado a "${roteiro.titulo}"'),
                                          backgroundColor: AppColors.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
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

  void _navegarParaCriarRoteiro() {
    Navigator.pushNamed(
      context,
      '/itinerary/list',
      arguments: {'acao': 'criar', 'poiInicial': _poi},
    );
  }

  @override
  Widget build(BuildContext context) {
    final poi = widget.poi;
    if (poi == null) {
      return const Scaffold(
        body: Center(child: Text('POI não encontrado')),
      );
    }

    final ui = _getCategoriaUI();
    final isLoading = _loadingDetalhes;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ui.cor, ui.cor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(ui.icon, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ui.label,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _poi.nome,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ui.cor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(ui.icon, size: 16, color: ui.cor),
                            const SizedBox(width: 6),
                            Text(
                              ui.label,
                              style: TextStyle(
                                color: ui.cor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_poi.avaliacao != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${_poi.avaliacao}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_poi.descricao.isNotEmpty && _poi.descricao != 'Sem descrição')
                    _buildSecao(
                      icon: Icons.description_outlined,
                      title: 'Sobre',
                      child: Text(
                        _poi.descricao,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  if (_poi.endereco != null)
                    _buildSecao(
                      icon: Icons.location_on_outlined,
                      title: 'Endereço',
                      child: Text(
                        _poi.endereco!,
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ),
                  if (_poi.telefone != null || _poi.email != null || _poi.website != null)
                    _buildSecao(
                      icon: Icons.contact_phone_outlined,
                      title: 'Contactos',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_poi.telefone != null)
                            _buildChipContacto(
                              icon: Icons.phone,
                              label: _poi.telefone!,
                              onTap: _abrirTelefone,
                            ),
                          if (_poi.email != null)
                            _buildChipContacto(
                              icon: Icons.email,
                              label: _poi.email!,
                              onTap: _abrirEmail,
                            ),
                          if (_poi.website != null)
                            _buildChipContacto(
                              icon: Icons.language,
                              label: 'Website',
                              onTap: _abrirWebsite,
                            ),
                        ],
                      ),
                    ),
                  if (_poi.horario != null)
                    _buildSecao(
                      icon: Icons.access_time,
                      title: 'Horário',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          _poi.horario!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  if (_poi.cozinha != null)
                    _buildSecao(
                      icon: Icons.restaurant_menu,
                      title: 'Cozinha',
                      child: Wrap(
                        spacing: 8,
                        children: _poi.cozinha!
                            .split(',')
                            .map((c) => Chip(
                                  label: Text(c.trim()),
                                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 12,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildSecao(
                    icon: Icons.map_outlined,
                    title: 'Localização',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(_poi.latitude, _poi.longitude),
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.algarve.explorer',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(_poi.latitude, _poi.longitude),
                                  width: 50,
                                  height: 60,
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
                                        child: Icon(ui.icon, color: Colors.white, size: 20),
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBotaoNavegacao(
                          icon: Icons.navigation,
                          label: 'Google Maps',
                          cor: AppColors.primary,
                          onTap: _abrirGoogleMaps,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBotaoNavegacao(
                          icon: Icons.directions_car,
                          label: 'Waze',
                          cor: const Color(0xFF33CCFF),
                          onTap: _abrirWaze,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _mostrarBottomSheetAdicionar,
            icon: const Icon(Icons.add_location_alt),
            label: const Text(
              'Adicionar ao Roteiro',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecao({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildChipContacto({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoNavegacao({
    required IconData icon,
    required String label,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: cor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriaUI {
  final String label;
  final IconData icon;
  final Color cor;
  const _CategoriaUI(this.label, this.icon, this.cor);
}