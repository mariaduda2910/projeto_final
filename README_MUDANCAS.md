# GUIA DETALHADO DO CÓDIGO FONTE:
## PERSISTÊNCIA DE DADOS:
- shared preferences -> Guarda dados localmente
- json server -> Simula sincronização com servidor em nuvem, é um progrma node.js que lê o ficheiro db.json e expõe os dados como numa api rest ;
- API geoapify -> Conectamos com api key na api da empresa Geoapify para obter informações dos locais próximos e detalhes sobre o mesmo; 

#### Na persistencia de dados queremos que o shared preferences sincronize com o bd.json como aconteceria em um ambiente real de uma aplciação, pois queremos o compartilhamento de rotas e sincronização dos dados pessoais do cliente; 
#### Dessa forma temos app funcionado offline e criamos uma fila de alteração para sincronizar quando detectamos internet com o connectivity_plus;

lib/
├── services/
│   ├── api_service.dart (Wrapper baixo nível à volta do Dio. Métodos getRoteiros(), postRoteiro(json), deleteRoteiro(id), etc. Nada de lógica de sync — só HTTP.)      
│   ├── sync_service.dart         
│   ├── connectivity_service.dart 
│   ├── storage_service.dart      
│   ├── auth_service.dart
│   ├── geoapify_service.dart
│   └── location_service.dart
│
├── providers/
│   ├── sync_provider.dart   
└──

# _____________________________________________________


# 📝 GUIA DE MUDANÇAS — feature/detalhes-roteiro

## Como usar esta estrutura

### 1. Criar a branch
```bash
git checkout -b feature/detalhes-roteiro interface-mapa2.0
```

### 2. Copiar os ficheiros
Copia todos os ficheiros desta pasta para o teu projeto `lib/`.

### 3. Atualizar pubspec.yaml
Adicionar dependências:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Para anexos (Maria adiciona)
  image_picker: ^1.0.7
  file_picker: ^6.1.1
  path_provider: ^2.1.2
  permission_handler: ^11.3.0
```

### 4. Ordem de implementação sugerida

#### Fase 1 — Fundação (Laura + Maria)
1. `models/` — criar os 3 modelos novos
2. `core/mocks/mock_itineraries.dart` — para testar a UI
3. `providers/itinerary_provider.dart` — Maria implementa, Laura consome

#### Fase 2 — Detalhes (Laura)
4. `widgets/detail/` — todos os 6 widgets
5. `views/detail/detail_screen.dart` — refactor completo

#### Fase 3 — Roteiro no Mapa (Laura)
6. `widgets/map/` — os 4 widgets (incluindo o VISIONÁRIO!)
7. `views/map/poi_explorer_screen.dart` — integrar widget flutuante

#### Fase 4 — Home (Laura)
8. `widgets/home/` — RoteiroCard + FavoritosRapidos
9. `views/home/home_screen.dart` — usar widgets reais

#### Fase 5 — Itinerary Screens (Laura)
10. `widgets/itinerary/` — todos os 8 widgets
11. `views/itinerary/` — 2 ecrãs novos

#### Fase 6 — Polimento
12. `views/settings/settings_screen.dart`
13. `l10n/` — traduções (se houver tempo)
14. Testes e ajustes finais

### 5. Comandos úteis
```bash
# Gerar código de localização
flutter gen-l10n

# Verificar erros
flutter analyze

# Correr a app
flutter run
```

---

**Prazo: 18/05/2026 | Apresentação: 29/05/2026**
**Força, Laura! 🌊**
