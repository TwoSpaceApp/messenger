// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Chargement...';

  @override
  String get initializing => 'Initialisation...';

  @override
  String get errorGeneric => 'Une erreur est survenue';

  @override
  String get errorInitialization => 'Erreur d\'initialisation';

  @override
  String get errorInitializationFull => 'Erreur d\'initialisation';

  @override
  String get errorNetwork => 'Erreur réseau';

  @override
  String get errorAuth => 'Erreur d\'authentification';

  @override
  String get errorInvalidArguments => 'Arguments invalides';

  @override
  String get errorInvalidArgumentsProfile =>
      'Arguments invalides pour le profil';

  @override
  String get errorInvalidArgumentsChat => 'Arguments invalides pour le chat';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get send => 'Envoyer';

  @override
  String get close => 'Fermer';
}
