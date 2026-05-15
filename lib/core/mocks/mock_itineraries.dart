// DADOS MOCK PARA TESTAR A UI ENQUANTO DESENVOLVE O BACKEND
// COMO USAR:
//   final roteiro = mockRoteiroAtivo;
//   final roteiros = mockRoteiros;
//   Passa estes dados aos widgets enquanto a Maria não entrega o Provider

import '../../../models/itinerary_model.dart';
import '../../../models/itinerary_event_model.dart';

final mockRoteiroAtivo = ItineraryModel(
  id: 'roteiro-001',
  titulo: 'Tarde em Tavira',
  dataInicio: DateTime(2026, 5, 15, 14, 0),
  dataFim: DateTime(2026, 5, 15, 22, 0),
  eventos: [
    ItineraryEvent(
      id: 'evt-001',
      poiId: 'geoapify-001',
      poiNome: 'Praia da Marinha',
      poiLatitude: 37.0878,
      poiLongitude: -8.4189,
      poiEndereco: 'Praia da Marinha, Lagoa',
      poiCategoria: 'praia',
      periodo: PeriodoDia.tarde,
      ordem: 1,
      visitado: false,
    ),
    ItineraryEvent(
      id: 'evt-002',
      poiId: 'geoapify-002',
      poiNome: 'Restaurante O Leão de Porches',
      poiLatitude: 37.1275,
      poiLongitude: -8.4021,
      poiEndereco: 'Porches, Lagoa',
      poiCategoria: 'restaurante',
      periodo: PeriodoDia.noite,
      ordem: 2,
      visitado: false,
    ),
    ItineraryEvent(
      id: 'evt-003',
      poiId: 'geoapify-003',
      poiNome: 'Castelo de Silves',
      poiLatitude: 37.1897,
      poiLongitude: -8.4378,
      poiEndereco: 'Silves',
      poiCategoria: 'monumento',
      periodo: PeriodoDia.tarde,
      ordem: 3,
      visitado: true,
    ),
  ],
  criadoEm: DateTime(2026, 5, 10),
  ativo: true,
);

final mockRoteiros = [
  mockRoteiroAtivo,
  ItineraryModel(
    id: 'roteiro-002',
    titulo: 'Fim de semana em Vilamoura',
    dataInicio: DateTime(2026, 5, 20),
    dataFim: DateTime(2026, 5, 22),
    eventos: [
      ItineraryEvent(
        id: 'evt-004',
        poiId: 'geoapify-004',
        poiNome: 'Marina de Vilamoura',
        poiLatitude: 37.0779,
        poiLongitude: -8.1173,
        poiCategoria: 'comercial',
        periodo: PeriodoDia.tarde,
        ordem: 1,
      ),
      ItineraryEvent(
        id: 'evt-005',
        poiId: 'geoapify-005',
        poiNome: 'Praia da Falésia',
        poiLatitude: 37.0725,
        poiLongitude: -8.1250,
        poiCategoria: 'praia',
        periodo: PeriodoDia.manha,
        ordem: 2,
      ),
    ],
    criadoEm: DateTime(2026, 5, 12),
    ativo: false,
  ),
  ItineraryModel(
    id: 'roteiro-003',
    titulo: 'Aniversário em Albufeira',
    dataInicio: DateTime(2026, 6, 1),
    dataFim: DateTime(2026, 6, 3),
    eventos: [],
    criadoEm: DateTime(2026, 5, 13),
    ativo: false,
  ),
];
