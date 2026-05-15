// ⚠️ lib/views/detail/detail_screen.dart — REFACTOR
import 'package:flutter/material.dart';
import '../../models/poi_model.dart';

class DetailScreen extends StatefulWidget {
  final PoiModel? poi; // final é usado para garantir que o valor não muda depois de atribuído no construtor
  const DetailScreen({super.key, this.poi}); //const é usado para garantir que o widget é imutável e pode ser otimizado pelo Flutter
// a diferença entre final e const é que final permite atribuir um valor uma vez, 
//enquanto const é para valores que são conhecidos em tempo de compilação e não mudam em tempo de execução. 
//No caso do DetailScreen, o poi é passado no construtor e não muda depois disso, então faz sentido ser final. 
//O widget em si é imutável, então pode ser const para otimização.
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    final poi = widget.poi;
    if (poi == null) {
      return const Scaffold(body: Center(child: Text('POI não encontrado')));
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(poi.nome, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(poi.descricao),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Adicionar ao Roteiro'),
          ),
        ),
      ),
    );
  }
}
