// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Algarve Explorer';

  @override
  String get welcomeMessage => 'Willkommen in der Algarve! 🌊';

  @override
  String get planNextAdventure => 'Plane dein nächstes Abenteuer';

  @override
  String get myItinerary => 'Meine Reiseroute';

  @override
  String stopsCount(Object count) {
    return '$count Stationen';
  }

  @override
  String get addToItinerary => 'Zur Reiseroute hinzufügen';

  @override
  String get createItinerary => 'Reiseroute erstellen';

  @override
  String get viewItinerary => 'Reiseroute ansehen';

  @override
  String get allItineraries => 'Alle Reiserouten';

  @override
  String get noItinerariesYet => 'Sie haben noch keine Reiserouten';

  @override
  String get createFirstItineraryHint => 'Erstellen Sie Ihre erste Reiseroute, um die Algarve zu erkunden';

  @override
  String get tapHeartToSave => 'Tippen Sie auf das ♥ an einem Ort auf der Karte, um ihn zu speichern';

  @override
  String get allFavorites => 'Alle Favoriten';

  @override
  String get poiNotFound => 'POI nicht gefunden';

  @override
  String get about => 'Über';

  @override
  String get contacts => 'Kontakte';

  @override
  String get cuisine => 'Küche';

  @override
  String get location => 'Ort';

  @override
  String get discoverCoastalParadise => 'Entdecken Sie das Küstenparadies';

  @override
  String get featureInDevelopment => 'Funktion in Entwicklung';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get noAccountYet => 'Sie haben noch kein Konto?';

  @override
  String get myItineraries => 'Meine Reiserouten';

  @override
  String get newItinerary => 'Neue Reiseroute';

  @override
  String get itineraryTitle => 'Titel der Reiseroute';

  @override
  String get startDate => 'Startdatum';

  @override
  String get endDate => 'Enddatum';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get fillAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String firstStop(String poiName) {
    return 'Erster Stopp: $poiName';
  }

  @override
  String get itineraryCreatedSuccessfully => 'Reiseroute erfolgreich erstellt!';

  @override
  String get morning => 'Morgen';

  @override
  String get afternoon => 'Nachmittag';

  @override
  String get evening => 'Abend';

  @override
  String get openNow => 'Jetzt geöffnet';

  @override
  String get closed => 'Geschlossen';

  @override
  String opensAt(Object time) {
    return 'Öffnet um $time';
  }

  @override
  String closesAt(Object time) {
    return 'Schließt um $time';
  }

  @override
  String distanceFromYou(Object distance) {
    return '$distance km entfernt';
  }

  @override
  String get phone => 'Telefon';

  @override
  String get email => 'E-Mail';

  @override
  String get website => 'Webseite';

  @override
  String get address => 'Adresse';

  @override
  String get openingHours => 'Öffnungszeiten';

  @override
  String get description => 'Beschreibung';

  @override
  String get readMore => 'Mehr lesen';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get viewOnMap => 'Auf Karte anzeigen';

  @override
  String get route => 'Route';

  @override
  String get currentRoute => 'Aktuelle Route';

  @override
  String get noActiveItinerary => 'Keine aktive Reiseroute';

  @override
  String get exploreToCreate => 'Entdecke Orte und erstelle eine Reiseroute';

  @override
  String get addTicket => 'Ticket hinzufügen';

  @override
  String get attachments => 'Anhänge';

  @override
  String get search => 'Suchen';

  @override
  String get filter => 'Filtern';

  @override
  String get favorites => 'Favoriten';

  @override
  String get recentFavorites => 'Neueste Favoriten';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get merchandising => 'Merchandising';

  @override
  String get comingSoon => 'Demnächst...';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get lightMode => 'Hellmodus';

  @override
  String get details => 'Details';

  @override
  String get navigate => 'Navigieren';

  @override
  String get hide => 'Ausblenden';

  @override
  String get profile => 'Profile';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get noFavoritesYet => 'No favorites saved yet';

  @override
  String get oneSavedPlace => 'saved place';

  @override
  String get savedPlaces => 'saved places';

  @override
  String get openMapToSeeFavorites => 'Open the Map and tap the ♥ icon to see your favorites';

  @override
  String get itineraries => 'Itineraries';

  @override
  String get createFirstItinerary => 'Create your first itinerary';

  @override
  String get oneItinerary => 'itinerary';

  @override
  String get itinerariesCount => 'itineraries';

  @override
  String get planned => 'planned';

  @override
  String get createAccount => 'Create account';

  @override
  String get joinCommunity => 'Join the Algarve Explorer community';

  @override
  String get continueWithGitHub => 'Continue with GitHub';

  @override
  String get or => 'or';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Minimum 8 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get appLanguage => 'App language';

  @override
  String get alreadyHaveAccount => 'Already have an account?';
}
