// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Loading...';

  @override
  String get initializing => 'Initializing...';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorInitialization => 'Initialization error';

  @override
  String get errorInitializationFull => 'Initialization Error';

  @override
  String get errorNetwork => 'Network error';

  @override
  String get errorAuth => 'Authentication error';

  @override
  String get errorInvalidArguments => 'Invalid arguments';

  @override
  String get errorInvalidArgumentsProfile => 'Invalid arguments for profile';

  @override
  String get errorInvalidArgumentsChat => 'Invalid arguments for chat';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get send => 'Send';

  @override
  String get close => 'Close';
}
