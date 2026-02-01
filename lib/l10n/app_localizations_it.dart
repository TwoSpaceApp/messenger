// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Caricamento...';

  @override
  String get initializing => 'Inizializzazione...';

  @override
  String get errorGeneric => 'Si è verificato un errore';

  @override
  String get errorInitialization => 'Errore di inizializzazione';

  @override
  String get errorInitializationFull => 'Errore di inizializzazione';

  @override
  String get errorNetwork => 'Errore di rete';

  @override
  String get errorAuth => 'Errore di autenticazione';

  @override
  String get errorInvalidArguments => 'Argomenti non validi';

  @override
  String get errorInvalidArgumentsProfile =>
      'Argomenti non validi per il profilo';

  @override
  String get errorInvalidArgumentsChat => 'Argomenti non validi per la chat';

  @override
  String get retry => 'Riprova';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get send => 'Invia';

  @override
  String get close => 'Chiudi';
}
