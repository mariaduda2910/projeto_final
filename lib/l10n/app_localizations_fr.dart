// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Algarve Explorer';

  @override
  String get welcomeMessage => 'Bienvenue en Algarve! 🌊';

  @override
  String get planNextAdventure => 'Planifiez votre prochaine aventure';

  @override
  String get myItinerary => 'Mon Itinéraire';

  @override
  String stopsCount(Object count) {
    return '$count arrêts';
  }

  @override
  String get addToItinerary => 'Ajouter à l\'Itinéraire';

  @override
  String get createItinerary => 'Créer un Itinéraire';
  @override
  String get viewItinerary => 'Voir l\'itinéraire';

  @override
  String get allItineraries => 'Tous les itinéraires';

  @override
  String get noItinerariesYet => 'Vous n\'avez pas encore d\'itinéraires';

  @override
  String get createFirstItineraryHint => 'Créez votre premier itinéraire pour explorer l\'Algarve';

  @override
  String get tapHeartToSave => 'Appuyez sur le ♥ sur un lieu sur la carte pour l\'enregistrer';

  @override
  String get allFavorites => 'Tous les favoris';

  @override
  String get poiNotFound => 'POI introuvable';

  @override
  String get about => 'À propos';

  @override
  String get contacts => 'Contacts';

  @override
  String get cuisine => 'Cuisine';

  @override
  String get location => 'Emplacement';

  @override
  String get discoverCoastalParadise => 'Découvrez le paradis côtier';

  @override
  String get featureInDevelopment => 'Fonctionnalité en cours de développement';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get noAccountYet => 'Vous n\'avez pas encore de compte ?';

  @override
  String get myItineraries => 'Mes itinéraires';

  @override
  String get newItinerary => 'Nouvel itinéraire';
  @override
  String get itineraryTitle => 'Titre de l\'itinéraire';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get fillAllFields => 'Remplis tous les champs';

  @override
  String firstStop(String poiName) {
    return 'Première étape : $poiName';
  }

  @override
  String get itineraryCreatedSuccessfully => 'Itinéraire créé avec succès !';

  @override
  String get morning => 'Matin';

  @override
  String get afternoon => 'Après-midi';

  @override
  String get evening => 'Soir';

  @override
  String get openNow => 'Ouvert maintenant';

  @override
  String get closed => 'Fermé';

  @override
  String opensAt(Object time) {
    return 'Ouvre à $time';
  }

  @override
  String closesAt(Object time) {
    return 'Ferme à $time';
  }

  @override
  String distanceFromYou(Object distance) {
    return 'À $distance km de vous';
  }

  @override
  String get phone => 'Téléphone';

  @override
  String get email => 'Email';

  @override
  String get website => 'Site web';

  @override
  String get address => 'Adresse';

  @override
  String get openingHours => 'Horaires';

  @override
  String get description => 'Description';

  @override
  String get readMore => 'Lire plus';

  @override
  String get showLess => 'Montrer moins';

  @override
  String get viewOnMap => 'Voir sur la Carte';

  @override
  String get route => 'Itinéraire';

  @override
  String get currentRoute => 'Itinéraire Actuel';

  @override
  String get noActiveItinerary => 'Aucun itinéraire actif';

  @override
  String get exploreToCreate => 'Explorez des lieux et créez un itinéraire';

  @override
  String get addTicket => 'Ajouter un billet';

  @override
  String get attachments => 'Pièces jointes';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get favorites => 'Favoris';

  @override
  String get recentFavorites => 'Favoris Récents';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get merchandising => 'Merchandising';

  @override
  String get comingSoon => 'Bientôt...';

  @override
  String get login => 'Connexion';

  @override
  String get logout => 'Déconnexion';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get details => 'Détails';

  @override
  String get navigate => 'Naviguer';

  @override
  String get hide => 'Masquer';

  @override
  String get profile => 'Profil';

  @override
  String get languageChanged => 'Langue modifiée';

  @override
  String get noFavoritesYet => 'Aucun favori sauvegardé pour l\'instant';

  @override
  String get oneSavedPlace => 'lieu enregistré';

  @override
  String get savedPlaces => 'lieux enregistrés';

  @override
  String get openMapToSeeFavorites => 'Ouvre la carte et appuie sur l\'icône ♥ pour voir tes favoris';

  @override
  String get itineraries => 'Itinéraires';

  @override
  String get createFirstItinerary => 'Crée ton premier itinéraire';

  @override
  String get oneItinerary => 'itinéraire';

  @override
  String get itinerariesCount => 'itinéraires';

  @override
  String get planned => 'prévu';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinCommunity => 'Rejoins la communauté Algarve Explorer';

  @override
  String get continueWithGitHub => 'Continuer avec GitHub';

  @override
  String get or => 'ou';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordHint => 'Minimum 8 caractères';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmPasswordHint => 'Confirme ton mot de passe';

  @override
  String get appLanguage => 'Langue de l\'app';

  @override
  String get alreadyHaveAccount => 'Tu as déjà un compte ?';
}
