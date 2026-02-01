// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Cargando...';

  @override
  String get initializing => 'Inicializando...';

  @override
  String get errorGeneric => 'Ocurrió un error';

  @override
  String get errorInitialization => 'Error de inicialización';

  @override
  String get errorInitializationFull => 'Error de inicialización';

  @override
  String get errorNetwork => 'Error de red';

  @override
  String get errorAuth => 'Error de autenticación';

  @override
  String get errorInvalidArguments => 'Argumentos inválidos';

  @override
  String get errorInvalidArgumentsProfile =>
      'Argumentos inválidos para el perfil';

  @override
  String get errorInvalidArgumentsChat => 'Argumentos inválidos para el chat';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get send => 'Enviar';

  @override
  String get close => 'Cerrar';
}
