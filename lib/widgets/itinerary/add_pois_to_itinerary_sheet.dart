import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/itinerary_model.dart';
import '../../models/poi_model.dart';
import '../../providers/itinerary_provider.dart';

/// Bottom sheet que pergunta ao utilizador a qual roteiro quer adicionar os
/// [pois] selecionados, ou permite criar um novo roteiro.
class AddPoisToItinerarySheet extends StatefulWidget {
  final List<PoiModel> pois;

  const AddPoisToItinerarySheet({super.key, required this.pois});

  @override
  State<AddPoisToItinerarySheet> createState() =>
      _AddPoisToItinerarySheetState();
}

class _AddPoisToItinerarySheetState extends State<AddPoisToItinerarySheet> {
  bool _aGuardar = false;

  Future<void> _adicionarAoRoteiro(ItineraryModel roteiro) async {
    setState(() => _aGuardar = true);
    final provider = context.read<ItineraryProvider>();
    int adicionados = 0;
    int duplicados = 0;

    for (final poi in widget.pois) {
      final poiId = poi.id ?? poi.placeId ?? '';
      if (poiId.isEmpty) continue;
      final ok = await provider.adicionarPoiAoRoteiro(
        roteiroId: roteiro.id,
        poiId: poiId,
        poiNome: poi.nome,
        poiLatitude: poi.latitude,
        poiLongitude: poi.longitude,
        poiEndereco: poi.endereco,
        poiCategoria: poi.categoria,
      );
      if (ok) {
        adicionados++;
      } else {
        duplicados++;
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          duplicados == 0
              ? '$adicionados ${adicionados == 1 ? 'ponto adicionado' : 'pontos adicionados'} a "${roteiro.titulo}"'
              : '$adicionados adicionados, $duplicados já existiam',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _criarNovoRoteiro() async {
    final novo = await showDialog<ItineraryModel>(
      context: context,
      builder: (_) => const _NovoRoteiroDialog(),
    );

    if (novo != null && mounted) {
      await _adicionarAoRoteiro(novo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryProvider>(
      builder: (context, provider, _) {
        final roteiros = provider.roteiros;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Adicionar ${widget.pois.length} ${widget.pois.length == 1 ? 'ponto' : 'pontos'} a um roteiro',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.pois.map((p) => p.nome).take(3).join(', ') +
                      (widget.pois.length > 3
                          ? ' e mais ${widget.pois.length - 3}'
                          : ''),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Botão criar novo
                Material(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.borderRadius),
                  child: InkWell(
                    onTap: _aGuardar ? null : _criarNovoRoteiro,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.borderRadius),
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle, color: AppColors.primary),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Criar novo roteiro',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (roteiros.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Ou adicionar a um roteiro existente',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: roteiros.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (_, i) {
                        final r = roteiros[i];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.map, color: Colors.white),
                            ),
                            title: Text(r.titulo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${r.totalParagens} ${r.totalParagens == 1 ? 'paragem' : 'paragens'}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _aGuardar
                                ? null
                                : () => _adicionarAoRoteiro(r),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                if (_aGuardar)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dialog mínimo para criar um roteiro novo a partir do sheet anterior.
class _NovoRoteiroDialog extends StatefulWidget {
  const _NovoRoteiroDialog();

  @override
  State<_NovoRoteiroDialog> createState() => _NovoRoteiroDialogState();
}

class _NovoRoteiroDialogState extends State<_NovoRoteiroDialog> {
  final _titulo = TextEditingController(text: 'Roteiro de Algarve');
  DateTime _dataInicio = DateTime.now();
  DateTime _dataFim = DateTime.now().add(const Duration(days: 3));
  bool _aGuardar = false;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  Future<void> _escolherData({required bool inicio}) async {
    final data = await showDatePicker(
      context: context,
      initialDate: inicio ? _dataInicio : _dataFim,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (data == null) return;
    setState(() {
      if (inicio) {
        _dataInicio = data;
        if (_dataFim.isBefore(_dataInicio)) _dataFim = _dataInicio;
      } else {
        _dataFim = data;
      }
    });
  }

  Future<void> _criar() async {
    final titulo = _titulo.text.trim();
    if (titulo.isEmpty) return;

    setState(() => _aGuardar = true);
    final provider = context.read<ItineraryProvider>();
    final novo = await provider.criarRoteiro(
      titulo: titulo,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    );

    if (mounted) Navigator.pop(context, novo);
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo roteiro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titulo,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _escolherData(inicio: true),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('Início: ${_formatarData(_dataInicio)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _escolherData(inicio: false),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('Fim: ${_formatarData(_dataFim)}'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _aGuardar ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _aGuardar ? null : _criar,
          child: _aGuardar
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Criar'),
        ),
      ],
    );
  }
}
