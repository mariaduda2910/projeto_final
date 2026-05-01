// Tela: Mapa com localização real do utilizador e restaurantes próximos

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/poi_model.dart';
import '../../services/geoapify_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _userLocation;
  List<PoiModel> _restaurantes = [];

  bool _loading = true;
  String? _error;

  final GeoapifyService _geoapifyService = GeoapifyService();

  @override
  void initState() {
    super.initState();
    _carregarMapa();
  }

  Future<void> _carregarMapa() async {
    try {
      final position = await _obterLocalizacaoActual();

      final userLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      final restaurantes = await _geoapifyService.buscarRestaurantesProximos(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _userLocation = userLatLng;
        _restaurantes = restaurantes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar o mapa: $e';
        _loading = false;
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

    for (final restaurante in _restaurantes) {
      markers.add(
        Marker(
          point: LatLng(
            restaurante.latitude,
            restaurante.longitude,
          ),
          width: 60,
          height: 60,
          child: Tooltip(
            message: restaurante.nome,
            child: const Icon(
              Icons.restaurant,
              size: 35,
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa'),
        ),
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _userLocation!,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.projeto_final_flutter',
          ),
          MarkerLayer(
            markers: _criarMarkers(),
          ),
        ],
      ),
    );
  }
}
