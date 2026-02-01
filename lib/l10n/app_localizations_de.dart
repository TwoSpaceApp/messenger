// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get initializing => 'Initialisierung...';

  @override
  String get errorGeneric => 'Ein Fehler ist aufgetreten';

  @override
  String get errorInitialization => 'Initialisierungsfehler';

  @override
  String get errorInitializationFull => 'Initialisierungsfehler';

  @override
  String get errorNetwork => 'Netzwerkfehler';

  @override
  String get errorAuth => 'Authentifizierungsfehler';

  @override
  String get errorInvalidArguments => 'Ungültige Argumente';

  @override
  String get errorInvalidArgumentsProfile =>
      'Ungültige Argumente für das Profil';

  @override
  String get errorInvalidArgumentsChat => 'Ungültige Argumente für den Chat';

  @override
  String get retry => 'Wiederholen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get send => 'Senden';

  @override
  String get close => 'Schließen';
}
