
import 'package:flutter/material.dart';

class ItineraryListScreen extends StatefulWidget {
  const ItineraryListScreen({super.key});

  @override
  State<ItineraryListScreen> createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Os Meus Roteiros')),
      body: const Center(child: Text('ItineraryListScreen — TODO Laura')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
