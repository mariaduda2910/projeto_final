// 🆕 lib/widgets/itinerary/add_to_roteiro_modal.dart
// Bottom sheet: escolher roteiro e ordem
// RESPONSABILIDADE: Laura | USADO POR: AddToRoteiroButton

import 'package:flutter/material.dart';
import '../../models/poi_model.dart';

class AddToRoteiroModal extends StatefulWidget {
  final PoiModel poi;
  const AddToRoteiroModal({super.key, required this.poi});

  @override
  State<AddToRoteiroModal> createState() => _AddToRoteiroModalState();
}

class _AddToRoteiroModalState extends State<AddToRoteiroModal> {
  int _passo = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Adicionar ao Roteiro — Passo $_passo'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
