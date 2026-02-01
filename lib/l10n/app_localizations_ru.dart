// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Загрузка...';

  @override
  String get initializing => 'Инициализация...';

  @override
  String get errorGeneric => 'Произошла ошибка';

  @override
  String get errorInitialization => 'Ошибка при инициализации';

  @override
  String get errorInitializationFull => 'Ошибка инициализации';

  @override
  String get errorNetwork => 'Ошибка сети';

  @override
  String get errorAuth => 'Ошибка аутентификации';

  @override
  String get errorInvalidArguments => 'Неверные аргументы';

  @override
  String get errorInvalidArgumentsProfile => 'Неверные аргументы для профиля';

  @override
  String get errorInvalidArgumentsChat => 'Неверные аргументы для чата';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get send => 'Отправить';

  @override
  String get close => 'Закрыть';
}
