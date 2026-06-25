// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Algarve Explorer';

  @override
  String get welcomeMessage => 'Welcome to the Algarve! 🌊';

  @override
  String get planNextAdventure => 'Plan your next adventure';

  @override
  String get myItinerary => 'My Itinerary';

  @override
  String stopsCount(Object count) {
    return '$count stops';
  }

  @override
  String get addToItinerary => 'Add to Itinerary';

  @override
  String get createItinerary => 'Create Itinerary';

  @override
  String get viewItinerary => 'View itinerary';

  @override
  String get allItineraries => 'All itineraries';

  @override
  String get noItinerariesYet => 'You have no itineraries yet';

  @override
  String get createFirstItineraryHint => 'Create your first itinerary to explore the Algarve';

  @override
  String get tapHeartToSave => 'Tap the ♥ on a place on the map to save it';

  @override
  String get allFavorites => 'All favorites';

  @override
  String get poiNotFound => 'POI not found';

  @override
  String get about => 'About';

  @override
  String get contacts => 'Contacts';

  @override
  String get cuisine => 'Cuisine';

  @override
  String get location => 'Location';

  @override
  String get discoverCoastalParadise => 'Discover the coastal paradise';

  @override
  String get featureInDevelopment => 'Feature under development';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get noAccountYet => 'Don\'t have an account yet?';

  @override
  String get myItineraries => 'My itineraries';

  @override
  String get newItinerary => 'New itinerary';

  @override
  String get itineraryTitle => 'Itinerary title';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get selectDate => 'Select date';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String firstStop(String poiName) {
    return 'First stop: $poiName';
  }

  @override
  String get itineraryCreatedSuccessfully => 'Itinerary created successfully!';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get openNow => 'Open now';

  @override
  String get closed => 'Closed';

  @override
  String opensAt(Object time) {
    return 'Opens at $time';
  }

  @override
  String closesAt(Object time) {
    return 'Closes at $time';
  }

  @override
  String distanceFromYou(Object distance) {
    return '$distance km away';
  }

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get address => 'Address';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get description => 'Description';

  @override
  String get readMore => 'Read more';

  @override
  String get showLess => 'Show less';

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get route => 'Route';

  @override
  String get currentRoute => 'Current Route';

  @override
  String get noActiveItinerary => 'No active itinerary';

  @override
  String get exploreToCreate => 'Explore places and create an itinerary';

  @override
  String get addTicket => 'Add ticket';

  @override
  String get attachments => 'Attachments';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get favorites => 'Favorites';

  @override
  String get recentFavorites => 'Recent Favorites';

  @override
  String get seeAll => 'See all';

  @override
  String get merchandising => 'Merchandising';

  @override
  String get comingSoon => 'Coming soon...';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get details => 'Details';

  @override
  String get navigate => 'Navigate';

  @override
  String get hide => 'Hide';

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
