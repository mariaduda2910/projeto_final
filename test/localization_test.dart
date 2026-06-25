import 'package:algarve_explorer/l10n/app_localizations_en.dart';
import 'package:algarve_explorer/l10n/app_localizations_pt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes the home and detail strings in Portuguese', () {
    final pt = AppLocalizationsPt();

    expect(pt.viewItinerary, 'Ver Roteiro');
    expect(pt.noItinerariesYet, 'Ainda não tens roteiros');
    expect(pt.poiNotFound, 'POI não encontrado');
    expect(pt.selectDate, 'Selecionar data');
    expect(pt.fillAllFields, 'Preenche todos os campos');
    expect(pt.cancel, 'Cancelar');
    expect(pt.firstStop('Lagos'), 'Primeira paragem: Lagos');
  });

  test('exposes the home and detail strings in English', () {
    final en = AppLocalizationsEn();

    expect(en.viewItinerary, 'View itinerary');
    expect(en.noItinerariesYet, 'You have no itineraries yet');
    expect(en.poiNotFound, 'POI not found');
    expect(en.selectDate, 'Select date');
    expect(en.fillAllFields, 'Please fill in all fields');
    expect(en.cancel, 'Cancel');
    expect(en.firstStop('Lagos'), 'First stop: Lagos');
  });
}
