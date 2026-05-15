// 🆕 lib/widgets/detail/opening_hours_accordion.dart
import 'package:flutter/material.dart';

class OpeningHoursAccordion extends StatefulWidget {
  final String? horarioRaw;
  final bool isOpenNow;

  const OpeningHoursAccordion({super.key, this.horarioRaw, this.isOpenNow = true});

  @override
  State<OpeningHoursAccordion> createState() => _OpeningHoursAccordionState();
}

class _OpeningHoursAccordionState extends State<OpeningHoursAccordion> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.access_time, color: widget.isOpenNow ? Colors.green : Colors.red),
      title: Text(
        widget.isOpenNow ? 'Aberto agora' : 'Fechado',
        style: TextStyle(color: widget.isOpenNow ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
      ),
      children: const [
        ListTile(title: Text('Segunda — 09:00 às 18:00')),
        ListTile(title: Text('Terça — 09:00 às 18:00')),
      ],
    );
  }
}
