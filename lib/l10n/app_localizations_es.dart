// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Algarve Explorer';

  @override
  String get welcomeMessage => '¡Bienvenido al Algarve! 🌊';

  @override
  String get planNextAdventure => 'Planifica tu próxima aventura';

  @override
  String get myItinerary => 'Mi Itinerario';

  @override
  String stopsCount(Object count) {
    return '$count paradas';
  }

  @override
  String get addToItinerary => 'Añadir al Itinerario';

  @override
  String get createItinerary => 'Crear Itinerario';

  @override
  String get itineraryTitle => 'Título del itinerario';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get endDate => 'Fecha de fin';

  @override
  String get morning => 'Mañana';

  @override
  String get afternoon => 'Tarde';

  @override
  String get evening => 'Noche';

  @override
  String get openNow => 'Abierto ahora';

  @override
  String get closed => 'Cerrado';

  @override
  String opensAt(Object time) {
    return 'Abre a las $time';
  }

  @override
  String closesAt(Object time) {
    return 'Cierra a las $time';
  }

  @override
  String distanceFromYou(Object distance) {
    return 'A $distance km de ti';
  }

  @override
  String get phone => 'Teléfono';

  @override
  String get email => 'Correo';

  @override
  String get website => 'Sitio web';

  @override
  String get address => 'Dirección';

  @override
  String get openingHours => 'Horario';

  @override
  String get description => 'Descripción';

  @override
  String get readMore => 'Leer más';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get viewOnMap => 'Ver en el Mapa';

  @override
  String get route => 'Ruta';

  @override
  String get currentRoute => 'Ruta Actual';

  @override
  String get noActiveItinerary => 'Ningún itinerario activo';

  @override
  String get exploreToCreate => 'Explora lugares y crea un itinerario';

  @override
  String get addTicket => 'Añadir billete';

  @override
  String get attachments => 'Adjuntos';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get favorites => 'Favoritos';

  @override
  String get recentFavorites => 'Favoritos Recientes';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get merchandising => 'Merchandising';

  @override
  String get comingSoon => 'Próximamente...';

  @override
  String get login => 'Entrar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get details => 'Detalles';

  @override
  String get navigate => 'Navegar';

  @override
  String get hide => 'Ocultar';

  @override
  String get profile => 'Perfil';

  @override
  String get languageChanged => 'Idioma cambiado';

  @override
  String get noFavoritesYet => 'Todavía no hay favoritos guardados';

  @override
  String get oneSavedPlace => 'lugar guardado';

  @override
  String get savedPlaces => 'lugares guardados';

  @override
  String get openMapToSeeFavorites => 'Abre el mapa y toca el icono ♥ para ver tus favoritos';

  @override
  String get itineraries => 'Rutas';

  @override
  String get createFirstItinerary => 'Crea tu primera ruta';

  @override
  String get oneItinerary => 'ruta';

  @override
  String get itinerariesCount => 'rutas';

  @override
  String get planned => 'planificada';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get joinCommunity => 'Únete a la comunidad Algarve Explorer';

  @override
  String get continueWithGitHub => 'Continuar con GitHub';

  @override
  String get or => 'o';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordHint => 'Mínimo 8 caracteres';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get confirmPasswordHint => 'Confirma tu contraseña';

  @override
  String get appLanguage => 'Idioma de la app';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';
}
