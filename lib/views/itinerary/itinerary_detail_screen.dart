
import 'package:flutter/material.dart';
import '../../models/itinerary_model.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final ItineraryModel roteiro;
  const ItineraryDetailScreen({super.key, required this.roteiro});

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roteiro.titulo)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.roteiro.eventos.length,
        itemBuilder: (context, index) {
          final evento = widget.roteiro.eventos[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${evento.ordem}')),
            title: Text(evento.poiNome),
            subtitle: Text('${evento.periodo}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
