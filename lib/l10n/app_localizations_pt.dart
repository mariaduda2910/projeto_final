// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Algarve Explorer';

  @override
  String get welcomeMessage => 'Bem-vindo ao Algarve! 🌊';

  @override
  String get planNextAdventure => 'Planeia a tua próxima aventura';

  @override
  String get myItinerary => 'O Meu Roteiro';

  @override
  String stopsCount(Object count) {
    return '$count paragens';
  }

  @override
  String get addToItinerary => 'Adicionar ao Roteiro';

  @override
  String get createItinerary => 'Criar Roteiro';

  @override
  String get viewItinerary => 'Ver Roteiro';

  @override
  String get allItineraries => 'Todos os Roteiros';

  @override
  String get noItinerariesYet => 'Ainda não tens roteiros';

  @override
  String get createFirstItineraryHint => 'Cria o teu primeiro roteiro para explorar o Algarve';

  @override
  String get tapHeartToSave => 'Toca no ♥ de um local no mapa para guardar';

  @override
  String get allFavorites => 'Todos os Favoritos';

  @override
  String get poiNotFound => 'POI não encontrado';

  @override
  String get about => 'Sobre';

  @override
  String get contacts => 'Contactos';

  @override
  String get cuisine => 'Cozinha';

  @override
  String get location => 'Localização';

  @override
  String get discoverCoastalParadise => 'Descubra o paraíso costeiro';

  @override
  String get featureInDevelopment => 'Funcionalidade em desenvolvimento';

  @override
  String get forgotPassword => 'Esqueci-me da palavra-passe';

  @override
  String get noAccountYet => 'Ainda não tem conta?';

  @override
  String get myItineraries => 'Os Meus Roteiros';

  @override
  String get newItinerary => 'Novo Roteiro';

  @override
  String get itineraryTitle => 'Título do roteiro';

  @override
  String get startDate => 'Data de início';

  @override
  String get endDate => 'Data de fim';

  @override
  String get selectDate => 'Selecionar data';

  @override
  String get fillAllFields => 'Preenche todos os campos';

  @override
  String firstStop(String poiName) {
    return 'Primeira paragem: $poiName';
  }

  @override
  String get itineraryCreatedSuccessfully => 'Roteiro criado com sucesso!';

  @override
  String get morning => 'Manhã';

  @override
  String get afternoon => 'Tarde';

  @override
  String get evening => 'Noite';

  @override
  String get openNow => 'Aberto agora';

  @override
  String get closed => 'Fechado';

  @override
  String opensAt(Object time) {
    return 'Abre às $time';
  }

  @override
  String closesAt(Object time) {
    return 'Fecha às $time';
  }

  @override
  String distanceFromYou(Object distance) {
    return 'A $distance km de ti';
  }

  @override
  String get phone => 'Telefone';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get address => 'Endereço';

  @override
  String get openingHours => 'Horário';

  @override
  String get description => 'Descrição';

  @override
  String get readMore => 'Ler mais';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get viewOnMap => 'Ver no Mapa';

  @override
  String get route => 'Rota';

  @override
  String get currentRoute => 'Rota Atual';

  @override
  String get noActiveItinerary => 'Nenhum roteiro ativo';

  @override
  String get exploreToCreate => 'Explora locais e cria um roteiro';

  @override
  String get addTicket => 'Adicionar bilhete';

  @override
  String get attachments => 'Anexos';

  @override
  String get search => 'Pesquisar';

  @override
  String get filter => 'Filtrar';

  @override
  String get favorites => 'Favoritos';

  @override
  String get recentFavorites => 'Favoritos Recentes';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get merchandising => 'Merchandising';

  @override
  String get comingSoon => 'Em breve...';

  @override
  String get login => 'Entrar';

  @override
  String get logout => 'Terminar Sessão';

  @override
  String get settings => 'Definições';

  @override
  String get language => 'Idioma';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get details => 'Detalhes';

  @override
  String get navigate => 'Navegar';

  @override
  String get hide => 'Ocultar';

  @override
  String get profile => 'Perfil';

  @override
  String get languageChanged => 'Idioma alterado';

  @override
  String get noFavoritesYet => 'Ainda sem favoritos guardados';

  @override
  String get oneSavedPlace => 'local guardado';

  @override
  String get savedPlaces => 'locais guardados';

  @override
  String get openMapToSeeFavorites => 'Abre o Mapa e toca no ícone ♥ para veres os favoritos';

  @override
  String get itineraries => 'Roteiros';

  @override
  String get createFirstItinerary => 'Cria o teu primeiro roteiro';

  @override
  String get oneItinerary => 'roteiro';

  @override
  String get itinerariesCount => 'roteiros';

  @override
  String get planned => 'planeado';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get joinCommunity => 'Junta-te à comunidade Algarve Explorer';

  @override
  String get continueWithGitHub => 'Continuar com GitHub';

  @override
  String get or => 'ou';

  @override
  String get password => 'Palavra-passe';

  @override
  String get passwordHint => 'Mínimo 8 caracteres';

  @override
  String get confirmPassword => 'Confirmar palavra-passe';

  @override
  String get confirmPasswordHint => 'Confirma a palavra-passe';

  @override
  String get appLanguage => 'Idioma da app';

  @override
  String get alreadyHaveAccount => 'Já tens conta?';
}
