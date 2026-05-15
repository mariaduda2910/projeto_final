// 🆕 lib/widgets/itinerary/criar_roteiro_form.dart
// Form rápido para criar novo roteiro
// RESPONSABILIDADE: Laura | USADO POR: RoteiroSelectorList

import 'package:flutter/material.dart';

class CriarRoteiroForm extends StatefulWidget {
  final Function(String titulo, DateTime inicio, DateTime fim) onCriar;
  const CriarRoteiroForm({super.key, required this.onCriar});

  @override
  State<CriarRoteiroForm> createState() => _CriarRoteiroFormState();
}

class _CriarRoteiroFormState extends State<CriarRoteiroForm> {
  final _tituloController = TextEditingController();
  DateTime _dataInicio = DateTime.now();
  DateTime _dataFim = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Novo Roteiro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título', hintText: 'Ex: Tarde em Tavira',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.onCriar(_tituloController.text, _dataInicio, _dataFim),
            child: const Text('Criar Roteiro'),
          ),
        ],
      ),
    );
  }
}
