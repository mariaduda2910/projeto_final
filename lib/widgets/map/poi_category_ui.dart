import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class PoiCategoryUi {
  final String label;
  final IconData icon;
  final Color cor;

  const PoiCategoryUi(this.label, this.icon, this.cor);
}

const Map<String, PoiCategoryUi> poiCategoryUi = {
  'catering.restaurant': PoiCategoryUi('Restaurantes', Icons.restaurant, Color(0xFFFF6B6B)),
  'catering.cafe': PoiCategoryUi('Cafés', Icons.local_cafe, Color(0xFFFFB347)),
  'catering.bar': PoiCategoryUi('Bares', Icons.local_bar, Color(0xFFAA96DA)),
  'accommodation.hotel': PoiCategoryUi('Hotéis', Icons.hotel, Color(0xFF4ECDC4)),
  'tourism.attraction': PoiCategoryUi('Atrações', Icons.attractions, Color(0xFFF38181)),
  'entertainment.museum': PoiCategoryUi('Museus', Icons.museum, Color(0xFF95E1D3)),
  'commercial.supermarket': PoiCategoryUi('Supermercados', Icons.shopping_cart, Color(0xFF74B9FF)),
  'healthcare.pharmacy': PoiCategoryUi('Farmácias', Icons.local_pharmacy, Color(0xFFFD79A8)),
  'natural.beach': PoiCategoryUi('Praias', Icons.beach_access, Color(0xFFFFD93D)),
  'leisure.park': PoiCategoryUi('Parques', Icons.park, Color(0xFF55EFC4)),
};

const List<String> poiCategoriesDisponiveis = [
  'catering.restaurant',
  'catering.cafe',
  'catering.bar',
  'accommodation.hotel',
  'tourism.attraction',
  'entertainment.museum',
  'commercial.supermarket',
  'healthcare.pharmacy',
  'natural.beach',
  'leisure.park',
];

PoiCategoryUi resolvePoiCategoryUi(String? category) {
  final normalized = (category ?? '').toLowerCase();

  if (normalized == 'tourism') return poiCategoryUi['tourism.attraction']!;
  if (normalized == 'catering') return poiCategoryUi['catering.restaurant']!;
  if (normalized == 'commercial') return poiCategoryUi['commercial.supermarket']!;
  if (normalized == 'entertainment') return poiCategoryUi['entertainment.museum']!;
  if (normalized == 'natural') return poiCategoryUi['natural.beach']!;
  if (normalized == 'leisure') return poiCategoryUi['leisure.park']!;
  if (normalized == 'accommodation') return poiCategoryUi['accommodation.hotel']!;
  if (normalized == 'healthcare') return poiCategoryUi['healthcare.pharmacy']!;

  if (normalized.contains('restaurant')) return poiCategoryUi['catering.restaurant']!;
  if (normalized.contains('cafe')) return poiCategoryUi['catering.cafe']!;
  if (normalized.contains('bar')) return poiCategoryUi['catering.bar']!;
  if (normalized.contains('hotel')) return poiCategoryUi['accommodation.hotel']!;
  if (normalized.contains('attraction') || normalized.contains('tourism')) {
    return poiCategoryUi['tourism.attraction']!;
  }
  if (normalized.contains('museum')) return poiCategoryUi['entertainment.museum']!;
  if (normalized.contains('supermarket') || normalized.contains('commercial')) {
    return poiCategoryUi['commercial.supermarket']!;
  }
  if (normalized.contains('pharmacy')) return poiCategoryUi['healthcare.pharmacy']!;
  if (normalized.contains('beach')) return poiCategoryUi['natural.beach']!;
  if (normalized.contains('park')) return poiCategoryUi['leisure.park']!;

  return const PoiCategoryUi('Local', Icons.place, AppColors.primary);
}
