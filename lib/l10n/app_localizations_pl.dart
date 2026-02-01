// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Ładowanie...';

  @override
  String get initializing => 'Inicjalizacja...';

  @override
  String get errorGeneric => 'Wystąpił błąd';

  @override
  String get errorInitialization => 'Błąd inicjalizacji';

  @override
  String get errorInitializationFull => 'Błąd inicjalizacji';

  @override
  String get errorNetwork => 'Błąd sieci';

  @override
  String get errorAuth => 'Błąd uwierzytelniania';

  @override
  String get errorInvalidArguments => 'Nieprawidłowe argumenty';

  @override
  String get errorInvalidArgumentsProfile =>
      'Nieprawidłowe argumenty dla profilu';

  @override
  String get errorInvalidArgumentsChat => 'Nieprawidłowe argumenty dla czatu';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get delete => 'Usuń';

  @override
  String get edit => 'Edytuj';

  @override
  String get send => 'Wyślij';

  @override
  String get close => 'Zamknij';
}
