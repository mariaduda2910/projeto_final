// lib/views/itinerary/itinerary_list_screen.dart — FUNCIONAL
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../models/poi_model.dart';
import '../../models/itinerary_model.dart';
import '../../models/itinerary_event_model.dart';
import '../../providers/itinerary_provider.dart';
import 'itinerary_detail_screen.dart';

class ItineraryListScreen extends StatefulWidget {
  const ItineraryListScreen({super.key});

  @override
  State<ItineraryListScreen> createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['acao'] == 'criar') {
        final poiInicial = args['poiInicial'] as PoiModel?;
        _mostrarDialogCriarRoteiro(poiInicial: poiInicial);
      }
    });
  }

  void _mostrarDialogCriarRoteiro({PoiModel? poiInicial}) { // Permite pré-selecionar um POI para o novo roteiro, se vier da tela de detalhes de um POI
    final tituloCtrl = TextEditingController();
    DateTime? dataInicio;
    DateTime? dataFim; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.map, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Novo Roteiro',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome do roteiro',
                        hintText: 'Ex: Fim de semana em Lagos',
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (_, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => dataInicio = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de início',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          dataInicio != null
                              ? Helpers.formatarData(dataInicio!)
                              : 'Selecionar data',
                          style: TextStyle(
                            color: dataInicio != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dataInicio ?? DateTime.now(),
                          firstDate: dataInicio ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (_, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => dataFim = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de fim',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          dataFim != null
                              ? Helpers.formatarData(dataFim!)
                              : 'Selecionar data',
                          style: TextStyle(
                            color: dataFim != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    if (poiInicial != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Primeira paragem: ${poiInicial.nome}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (tituloCtrl.text.trim().isEmpty || dataInicio == null || dataFim == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preenche todos os campos'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final provider = context.read<ItineraryProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    await provider.criarRoteiro(
                      titulo: tituloCtrl.text.trim(),
                      dataInicio: dataInicio!,
                      dataFim: dataFim!,
                    );

                    if (mounted) {
                      if (poiInicial != null) {
                        final roteiros = provider.roteiros;
                        if (roteiros.isNotEmpty) {
                          final novoRoteiro = roteiros.last;
                          await provider.adicionarEventoAoRoteiro(
                            roteiroId: novoRoteiro.id,
                            poiId: poiInicial.id ?? poiInicial.placeId ?? '',
                            poiNome: poiInicial.nome,
                            poiLatitude: poiInicial.latitude,
                            poiLongitude: poiInicial.longitude,
                            ordem: 1,
                            periodo: PeriodoDia.tarde,
                          );
                        }
                      }

                      if (!mounted) return;
                      navigator.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Roteiro criado com sucesso!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRoteiroCard(ItineraryModel roteiro) {
    final isAtivo = roteiro.ativo;
    final eventos = roteiro.eventos;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isAtivo ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isAtivo
            ? BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItineraryDetailScreen(roteiro: roteiro),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isAtivo
                            ? [AppColors.primary, const Color(0xFF4A90D9)]
                            : [Colors.grey[400]!, Colors.grey[300]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isAtivo ? Icons.map : Icons.map_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roteiro.titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${Helpers.formatarData(roteiro.dataInicio)} - ${Helpers.formatarData(roteiro.dataFim)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAtivo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ATIVO',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStat(
                    icon: Icons.place,
                    value: '${eventos.length}',
                    label: 'Paragens',
                  ),
                  const SizedBox(width: 24),
                  _buildStat(
                    icon: Icons.check_circle_outline,
                    value: '${eventos.where((e) => e.visitado).length}',
                    label: 'Visitados',
                  ),
                  const SizedBox(width: 24),
                  _buildStat(
                    icon: Icons.calendar_today,
                    value: '${roteiro.dataFim.difference(roteiro.dataInicio).inDays + 1}',
                    label: 'Dias',
                  ),
                ],
              ),
              if (eventos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: eventos.take(3).map((evento) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: _corPeriodo(evento.periodo),
                        child: Text(
                          '${evento.ordem}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: Text(
                        evento.poiNome,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey[100],
                    );
                  }).toList(),
                ),
                if (eventos.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${eventos.length - 3} mais paragens',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
              if (isAtivo && eventos.length > 1) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/itinerary/detail',
                        arguments: roteiro,
                      );
                    },
                    icon: const Icon(Icons.route, size: 18),
                    label: const Text('Ver em Rota'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _corPeriodo(PeriodoDia? periodo) {
    switch (periodo) {
      case PeriodoDia.manha:
        return Colors.orange;
      case PeriodoDia.tarde:
        return AppColors.primary;
      case PeriodoDia.noite:
        return const Color(0xFF5B4B8A);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryProvider>(
      builder: (context, provider, _) {
        final roteiros = provider.roteiros;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Os Meus Roteiros'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.textPrimary,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : roteiros.isEmpty
                  ? _buildEstadoVazio()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: roteiros.length,
                      itemBuilder: (context, index) {
                        return _buildRoteiroCard(roteiros[index]);
                      },
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _mostrarDialogCriarRoteiro(),
            icon: const Icon(Icons.add),
            label: const Text('Novo Roteiro'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 48,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ainda não tens roteiros',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cria o teu primeiro roteiro para começar a explorar o Algarve',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogCriarRoteiro(),
              icon: const Icon(Icons.add),
              label: const Text('Criar Roteiro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}