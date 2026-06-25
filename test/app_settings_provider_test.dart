import 'package:algarve_explorer/providers/app_settings_provider.dart';
import 'package:algarve_explorer/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().init();
  });

  test('persists and restores the app language choice', () async {
    final provider = AppSettingsProvider();
    await provider.setLocale('en');
    expect(provider.locale.languageCode, 'en');

    final restoredProvider = AppSettingsProvider();
    await restoredProvider.loadPreferences();
    expect(restoredProvider.locale.languageCode, 'en');
  });
}
