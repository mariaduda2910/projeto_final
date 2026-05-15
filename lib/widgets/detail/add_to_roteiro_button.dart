// 🆕 lib/widgets/detail/add_to_roteiro_button.dart
import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import '../itinerary/add_to_roteiro_modal.dart';

class AddToRoteiroButton extends StatelessWidget {
  final PoiModel poi;
  const AddToRoteiroButton({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _mostrarModal(context),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Adicionar ao Roteiro'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _mostrarModal(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => AddToRoteiroModal(poi: poi),
    );
  }
}
