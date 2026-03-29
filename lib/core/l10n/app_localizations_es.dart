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
  String get errorInitializationFull =>
      'Error de inicialización. Por favor reinicie la app.';

  @override
  String get errorNetwork => 'Error de red. Verifique su conexión.';

  @override
  String get errorAuth => 'Error de autenticación.';

  @override
  String get errorInvalidArguments => 'Argumentos inválidos.';

  @override
  String get errorInvalidArgumentsProfile =>
      'Argumentos inválidos para el perfil.';

  @override
  String get errorInvalidArgumentsChat => 'Argumentos inválidos para el chat.';

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

  @override
  String errorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirmar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get done => 'Listo';

  @override
  String get noData => 'Sin datos';

  @override
  String get nothingFound => 'Nada encontrado';

  @override
  String get copyAction => 'Copiar';

  @override
  String get shareAction => 'Compartir';

  @override
  String get textCopied => 'Texto copiado';

  @override
  String get onlineLabel => 'En línea';

  @override
  String get offlineLabel => 'Desconectado';

  @override
  String get userDefault => 'Usuario';

  @override
  String get lessThanMinuteAgo => 'hace menos de un minuto';

  @override
  String minutesAgo(int count) {
    return 'Hace $count min.';
  }

  @override
  String hoursAgo(int count) {
    return 'Hace $count h.';
  }

  @override
  String daysAgo(int count) {
    return 'Hace $count días';
  }

  @override
  String get videoLabel => 'Video';

  @override
  String videoLoadError(String error) {
    return 'Error de video: $error';
  }

  @override
  String get saveFailed => 'Error al guardar';

  @override
  String get shareSheetFailed => 'No se pudo abrir para compartir';

  @override
  String get speedLabel => 'Velocidad:';

  @override
  String get previewTitle => 'Vista previa';

  @override
  String fileDownloaded(String path) {
    return 'Archivo descargado: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return 'Archivo guardado temporalmente: $path';
  }

  @override
  String get savedToGallery => 'Guardado en galería';

  @override
  String authorizationError(String message) {
    return 'Error de autorización: $message';
  }

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get welcomeBack => 'Bienvenido';

  @override
  String get emailOrUsernameLabel => 'Nombre de usuario';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get forgotPassword => '¿Olvidó su contraseña?';

  @override
  String get noAccount => '¿No tiene cuenta?';

  @override
  String get orDivider => 'O';

  @override
  String get validationEnterEmailOrUsername => 'Ingrese nombre de usuario';

  @override
  String get validationEnterPassword => 'Ingrese la contraseña';

  @override
  String get registerTitle => 'Registrarse';

  @override
  String get fillAllFields => 'Por favor complete todos los campos';

  @override
  String get passwordStrengthWeak => 'Débil';

  @override
  String get passwordStrengthMedium => 'Media';

  @override
  String get passwordStrengthGood => 'Buena';

  @override
  String get passwordStrengthStrong => 'Fuerte';

  @override
  String get fullNameLabel => 'Nombre completo';

  @override
  String get nicknameAtLabel => 'Apodo (@usuario)';

  @override
  String get uploadPhotoPrompt => 'Sube tu foto de perfil';

  @override
  String get photoLooksGreat => '¡Se ve genial!';

  @override
  String get helpFriendsFind => 'Ayuda a tus amigos a encontrarte';

  @override
  String get setupInterfaceTitle => 'Personaliza tu interfaz';

  @override
  String get colorThemeLabel => 'Tema de color';

  @override
  String get validationEnterEmail => 'Ingrese correo electrónico';

  @override
  String get validationInvalidEmail => 'Correo electrónico inválido';

  @override
  String get validationPasswordTooShort => 'Contraseña muy corta';

  @override
  String get backToLogin => 'Iniciar sesión';

  @override
  String get finishButton => 'Finalizar';

  @override
  String filePickError(String error) {
    return 'Error al seleccionar archivo: $error';
  }

  @override
  String get chatsTitle => 'Chats';

  @override
  String get noChats => 'Sin chats';

  @override
  String get noMessages => '(sin mensajes)';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get messageInputHint => 'Escribe un mensaje...';

  @override
  String get addCaptionHint => 'Añadir un pie de foto o mensaje';

  @override
  String get unlockApp => 'Desbloquear';

  @override
  String get unlockButton => 'Desbloquear';

  @override
  String get dropFilesTitle => 'Suelta archivos para adjuntar';

  @override
  String get dropFilesSubtitle => 'Aparecerán sobre el campo de mensaje.';

  @override
  String get videoUnavailable => 'Vídeo no disponible';

  @override
  String get guestRole => 'Invitado';

  @override
  String get replyAction => 'Responder';

  @override
  String get editShort => 'Editar';

  @override
  String get pinAction => 'Fijar';

  @override
  String get moreReactions => 'Más';

  @override
  String get replyDialogTitle => 'Responder';

  @override
  String get replyHint => 'Texto de respuesta';

  @override
  String get editMessageTitle => 'Editar mensaje';

  @override
  String get editMessageHint => 'Nuevo texto';

  @override
  String get deleteMessageTitle => '¿Eliminar mensaje?';

  @override
  String get pinsUpdated => 'Fijados actualizados';

  @override
  String get messageEdited => 'Mensaje editado';

  @override
  String get fileSent => 'Archivo enviado';

  @override
  String get voiceNotSupported =>
      'Grabación de voz no soportada en esta plataforma';

  @override
  String get microphonePermRequired => 'Se requiere permiso del micrófono';

  @override
  String get recordingError => 'Error de grabación';

  @override
  String sendFailedError(String error) {
    return 'Envío fallido: $error';
  }

  @override
  String attachmentSendError(String error) {
    return 'Error al enviar adjunto: $error';
  }

  @override
  String shareFailedError(String error) {
    return 'Error al compartir: $error';
  }

  @override
  String replyError(String error) {
    return 'Error de respuesta: $error';
  }

  @override
  String pinError(String error) {
    return 'Error al fijar: $error';
  }

  @override
  String deleteError(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String editMessageError(String error) {
    return 'Error al editar: $error';
  }

  @override
  String get userTyping => 'Usuario escribiendo...';

  @override
  String get statusOnline => 'En línea';

  @override
  String get statusLastSeenRecently => 'Visto recientemente';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get customizationLabel => 'Personalización';

  @override
  String get customizationSubtitle => 'Colores, fuente y efectos UI';

  @override
  String get notificationsSection => 'Notificaciones';

  @override
  String get notificationsLabel => 'Notificaciones';

  @override
  String get soundLabel => 'Sonido';

  @override
  String get accountSection => 'Cuenta';

  @override
  String get profileLabel => 'Perfil';

  @override
  String get profileSubtitle => 'Editar información del perfil';

  @override
  String get accountSettingsLabel => 'Configuración de cuenta';

  @override
  String get accountSettingsSubtitle => 'Contraseña, seguridad, 2FA';

  @override
  String get privacyLabel => 'Privacidad';

  @override
  String get privacySubtitle => 'Gestionar privacidad';

  @override
  String get generalSection => 'General';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get textSizeLabel => 'Tamaño de texto';

  @override
  String get sendByEnterLabel => 'Enviar con Enter';

  @override
  String get sendByEnterSubtitle => 'Shift+Enter para nueva línea';

  @override
  String get dataStorageSection => 'Datos y almacenamiento';

  @override
  String get autoDownloadLabel => 'Descarga automática de medios';

  @override
  String get autoDownloadSubtitle => 'Descargar fotos y videos automáticamente';

  @override
  String get storageManagementLabel => 'Gestión de almacenamiento';

  @override
  String get storageManagementSubtitle => 'Limpiar caché y datos';

  @override
  String get clearCacheTitle => 'Limpiar caché';

  @override
  String get clearCacheContent => '¿Eliminar datos en caché?';

  @override
  String get cacheCleared => 'Caché limpiada';

  @override
  String get developmentSection => 'Desarrollo';

  @override
  String get devMenuSubtitle => 'Botón de depuración flotante';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String get suggestImprovementLabel => 'Sugerir mejora';

  @override
  String get suggestImprovementSubtitle =>
      'Ideas y solicitudes de nuevas funciones';

  @override
  String get dangerZoneSection => 'Zona peligrosa';

  @override
  String get logoutLabel => 'Cerrar sesión';

  @override
  String get logoutSubtitle => 'Cerrar sesión en este dispositivo';

  @override
  String get logoutDialogTitle => 'Cerrar sesión';

  @override
  String get logoutDialogContent => '¿Seguro que desea cerrar sesión?';

  @override
  String get logoutAction => 'Cerrar sesión';

  @override
  String get languageRussian => 'Ruso';

  @override
  String get languageUkrainian => 'Ucraniano';

  @override
  String get clientDescription => 'Cliente TwoSpace creado con Flutter/Dart';

  @override
  String errorLogout(String error) {
    return 'Error: $error';
  }

  @override
  String get accountSettingsTitle => 'Configuración de cuenta';

  @override
  String get securitySection => 'Seguridad';

  @override
  String get twoFactorLabel => 'Autenticación de dos factores';

  @override
  String get twoFactorSubtitle => 'Protección adicional de la cuenta';

  @override
  String get biometricLabel => 'Biometría';

  @override
  String get biometricSubtitle => 'Iniciar sesión con huella digital';

  @override
  String get activeSessionsLabel => 'Sesiones activas';

  @override
  String get activeSessionsSubtitle => 'Gestionar dispositivos';

  @override
  String get currentDevice => 'Dispositivo actual';

  @override
  String get changePasswordSection => 'Cambiar contraseña';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get minPasswordHelper => 'Mínimo 8 caracteres';

  @override
  String get changePasswordButton => 'Cambiar contraseña';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordChangeSuccess => 'Contraseña cambiada exitosamente';

  @override
  String get contactDataSection => 'Datos de contacto';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get deleteAccountLabel => 'Eliminar cuenta';

  @override
  String get deleteAccountSubtitle => 'Acción irreversible';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountContent =>
      '¿Seguro que desea eliminar su cuenta? Esta acción es irreversible.';

  @override
  String get deleteFeatureLater =>
      'La eliminación de cuenta estará disponible más tarde';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get saveTooltip => 'Guardar';

  @override
  String get editTooltip => 'Editar';

  @override
  String get writeMessageButton => 'Mensaje';

  @override
  String get callButton => 'Llamar';

  @override
  String get aboutField => 'Sobre mí';

  @override
  String get nicknameField => 'Apodo';

  @override
  String get locationField => 'Ubicación';

  @override
  String get birthdayField => 'Cumpleaños';

  @override
  String get nameField => 'Nombre';

  @override
  String get avatarUploadLater => 'La carga de avatar se añadirá más tarde';

  @override
  String get profileSaved => 'Perfil guardado';

  @override
  String createChatError(String error) {
    return 'No se pudo crear el chat: $error';
  }

  @override
  String get privacyTitle => 'Privacidad';

  @override
  String get hideFromSearch => 'Ocultar de búsqueda';

  @override
  String get hideFromSearchSubtitle => 'No mostrarme en resultados de búsqueda';

  @override
  String get hideLastSeen => 'Ocultar última conexión';

  @override
  String get hideLastSeenSubtitle => 'Otros no verán cuándo estuvo en línea';

  @override
  String get sessionExpiry => 'Expiración de sesión';

  @override
  String sessionExpirySubtitle(int days) {
    return 'Auto inicio de sesión en este dispositivo: $days días';
  }

  @override
  String get sessionExpiryDaysTitle => 'Expiración de sesión (días)';

  @override
  String get sessionExpiryDaysContent =>
      'Elija el número de días (min: 7, máx: 365).';

  @override
  String get daysLabel => 'Días';

  @override
  String get enterDaysError => 'Ingrese un número de 7 a 365';

  @override
  String sessionExpirySet(int days) {
    return 'Expiración de sesión: $days días';
  }

  @override
  String get changeEmailLabel => 'Cambiar correo';

  @override
  String get changeEmailSubtitle => 'Actualizar correo electrónico';

  @override
  String get twoFactorPrivacySubtitle =>
      'Activar o desactivar protección mejorada';

  @override
  String get changePhoneLabel => 'Cambiar teléfono';

  @override
  String get changePhoneSubtitle => 'Actualizar número de teléfono';

  @override
  String updatePrivacyError(String error) {
    return 'No se pudo actualizar la privacidad: $error';
  }

  @override
  String updateSettingError(String error) {
    return 'No se pudo actualizar la configuración: $error';
  }

  @override
  String get contactsTitle => 'Contactos';

  @override
  String get searchContactsHint => 'Buscar contactos...';

  @override
  String get contactsAccessTitle => 'Acceso a contactos';

  @override
  String get contactsPermDeniedPermanent =>
      'Permiso denegado permanentemente. Abra la configuración.';

  @override
  String get contactsPermRequired => 'Se requiere permiso de contactos.';

  @override
  String get openSettingsButton => 'Abrir configuración';

  @override
  String get requestPermissionButton => 'Solicitar permiso';

  @override
  String get noContacts => 'No se encontraron contactos';

  @override
  String get callAction => 'Llamar';

  @override
  String get writeMessageAction => 'Mensaje';

  @override
  String callNotification(String number) {
    return 'Llamada: $number';
  }

  @override
  String messageNotification(String name) {
    return 'Mensaje para: $name';
  }

  @override
  String get callsTitle => 'Llamadas';

  @override
  String get searchByNameHint => 'Buscar por nombre...';

  @override
  String get allFilter => 'Todas';

  @override
  String get incomingFilter => 'Entrantes';

  @override
  String get outgoingFilter => 'Salientes';

  @override
  String get missedFilter => 'Perdidas';

  @override
  String get noCallsFound => 'Sin llamadas';

  @override
  String get yesterdayLabel => 'Ayer';

  @override
  String get incomingCall => 'Entrante';

  @override
  String get outgoingCall => 'Saliente';

  @override
  String get missedCall => 'Perdida';

  @override
  String get videoCallLabel => 'Videollamada';

  @override
  String get voiceCallLabel => 'Llamada de voz';

  @override
  String get sendMessageCallAction => 'Mensaje';

  @override
  String get createRoomTitle => 'Crear sala';

  @override
  String get createButton => 'Crear';

  @override
  String get roomNameLabel => 'Nombre de sala';

  @override
  String get roomNameHint => 'Ej. nombre de su proyecto';

  @override
  String get roomTopicLabel => 'Tema (opcional)';

  @override
  String get roomTopicHint => '¿De qué trata esta sala?';

  @override
  String get roomVisibilityLabel => 'Visibilidad de sala';

  @override
  String get privateRoomOption => 'Sala privada';

  @override
  String get privateRoomSubtitle => 'Solo usuarios invitados pueden unirse';

  @override
  String get publicRoomOption => 'Sala pública';

  @override
  String get publicRoomSubtitle => 'Cualquiera puede unirse';

  @override
  String get showHistoryLabel => 'Mostrar historial de mensajes';

  @override
  String get showHistorySubtitle =>
      'Los nuevos miembros pueden ver mensajes anteriores';

  @override
  String get enterRoomNameError => 'Por favor ingrese el nombre de la sala';

  @override
  String get roomCreatedSuccess => '¡Sala creada exitosamente!';

  @override
  String imagePickError(String error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String get groupInfoTab => 'Info';

  @override
  String get groupMembersTab => 'Miembros';

  @override
  String get groupRolesTab => 'Roles';

  @override
  String get groupBansTab => 'Bans';

  @override
  String get groupDeleteTab => 'Eliminar';

  @override
  String membersCount(int count) {
    return 'Miembros: $count';
  }

  @override
  String get messageHistoryToggle => 'Historial de mensajes';

  @override
  String get showHistoryToggleLabel => 'Mostrar historial';

  @override
  String get settingSaved => 'Configuración guardada';

  @override
  String get backgroundColorLabel => 'Color de fondo';

  @override
  String get noMembers => 'Sin miembros';

  @override
  String get roleAction => 'Rol';

  @override
  String get freezeAction => 'Congelar';

  @override
  String get banAction => 'Banear';

  @override
  String get kickAction => 'Expulsar';

  @override
  String get noBannedUsers => 'Sin usuarios baneados';

  @override
  String get bannedLabel => 'Baneado';

  @override
  String get userUnbanned => 'Usuario desbaneado';

  @override
  String get deleteGroupLabel => 'Eliminar grupo';

  @override
  String get deleteGroupWarning =>
      'Esta acción es IRREVERSIBLE. El grupo será eliminado permanentemente.';

  @override
  String get confirmDeleteTitle => 'Confirmar eliminación';

  @override
  String get confirmDeleteContent =>
      '¿Está seguro? Esta acción es irreversible.';

  @override
  String get changeRoleTitle => 'Cambiar rol';

  @override
  String get adminRole => 'Administrador';

  @override
  String get memberRole => 'Miembro';

  @override
  String get freezeUserTitle => 'Congelar usuario';

  @override
  String get userBanned => 'Usuario baneado';

  @override
  String get userKicked => 'Usuario expulsado';

  @override
  String get groupDeleted => 'Grupo eliminado';

  @override
  String loadError(String error) {
    return 'Error de carga: $error';
  }

  @override
  String get publicLabel => 'Público';

  @override
  String get privateLabel => 'Privado';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get membersLabel => 'Miembros';

  @override
  String get generalLabel => 'General';

  @override
  String get newChatTitle => 'Nuevo chat';

  @override
  String get directChatTab => 'Directo';

  @override
  String get groupChatTab => 'Grupo';

  @override
  String get startDirectChatTitle => 'Iniciar chat directo';

  @override
  String get contactIdDescription =>
      'Ingrese el nombre de usuario o el ID de Aegis';

  @override
  String get contactIdLabel => 'Nombre de usuario o ID de Aegis';

  @override
  String get startChatButton => 'Iniciar chat';

  @override
  String get hintCardTitle => 'Sugerencia';

  @override
  String get contactIdExplanation =>
      'Puede usar un nombre de usuario o un ID numérico de Aegis';

  @override
  String get enterUserIdError => 'Ingrese ID de usuario';

  @override
  String get createNewRoomTitle => 'Crear nueva sala';

  @override
  String get descriptionOptionalLabel => 'Descripción (opcional)';

  @override
  String get privateGroupLabel => 'Grupo privado';

  @override
  String get privateGroupSubtitle => 'Solo usuarios invitados pueden unirse';

  @override
  String get createRoomButton => 'Crear sala';

  @override
  String get customizationTitle => 'Personalización';

  @override
  String get customizationHeroTitle => 'Shape the app around your rhythm';

  @override
  String get customizationHeroSubtitle =>
      'Build a distinct look with live preview, curated presets, motion, and density controls.';

  @override
  String get livePreviewBadge => 'Live preview';

  @override
  String get stylePresetsTitle => 'Style presets';

  @override
  String get stylePresetsSubtitle =>
      'Start with a strong visual direction, then tune the details.';

  @override
  String get moodSectionTitle => 'Mood';

  @override
  String get moodSectionSubtitle =>
      'Choose the accent that drives surfaces, highlights, and the background atmosphere.';

  @override
  String get typeSectionTitle => 'Type';

  @override
  String get typeSectionSubtitle =>
      'Pair a font family with the weight and size that feels right across the whole UI.';

  @override
  String get motionSectionTitle => 'Motion';

  @override
  String get motionSectionSubtitle =>
      'Control how much the interface breathes, drifts, and reacts in the background.';

  @override
  String get densitySectionTitle => 'Density';

  @override
  String get densitySectionSubtitle =>
      'Tighten spacing, bubble geometry, and navigation timing for a sharper layout.';

  @override
  String get dynamicBubblesLabel => 'Dynamic bubbles';

  @override
  String get dynamicBubblesSubtitle =>
      'Give chat bubbles directional corners for a more conversational rhythm.';

  @override
  String get bubbleRoundingLabel => 'Bubble rounding';

  @override
  String get bubbleRoundingCompact => 'Sharper';

  @override
  String get bubbleRoundingSoft => 'Softer';

  @override
  String get navBarTimeoutLabel => 'Navigation auto-hide';

  @override
  String navBarTimeoutValue(int seconds) {
    return '${seconds}s';
  }

  @override
  String get navBarTimeoutShort => 'Fast';

  @override
  String get navBarTimeoutLong => 'Relaxed';

  @override
  String get presetQuietGlass => 'Quiet Glass';

  @override
  String get presetQuietGlassSubtitle =>
      'Balanced contrast with cool depth and steady motion.';

  @override
  String get presetNightSignal => 'Night Signal';

  @override
  String get presetNightSignalSubtitle =>
      'Tighter density, stronger highlights, and a darker pulse.';

  @override
  String get presetEditorial => 'Editorial';

  @override
  String get presetEditorialSubtitle =>
      'Calmer motion, restrained color, and a more reading-focused tone.';

  @override
  String get presetSolarFlare => 'Solar Flare';

  @override
  String get presetSolarFlareSubtitle =>
      'Warm highlights and brighter surfaces with energetic movement.';

  @override
  String get presetRetroPulse => 'Retro Pulse';

  @override
  String get presetRetroPulseSubtitle =>
      'Compact, playful, and intentionally stylized.';

  @override
  String get previewRoomsLabel => 'Rooms';

  @override
  String get previewConversationLabel => 'Conversation';

  @override
  String get previewSettingsLabel => 'Settings';

  @override
  String get previewRoomsTitle => 'Room list preview';

  @override
  String get previewConversationTitle => 'Chat bubble preview';

  @override
  String get previewLiveLabel => 'Live';

  @override
  String get previewRoomDesignSync => 'Design Sync';

  @override
  String get previewRoomDesignSyncSubtitle => 'Hero card is ready for review.';

  @override
  String get previewRoomReleaseCheck => 'Release Check';

  @override
  String get previewRoomReleaseCheckSubtitle =>
      'Notes are grouped by security and fixes.';

  @override
  String get previewRoomAlphaOps => 'Alpha Ops';

  @override
  String get previewRoomAlphaOpsSubtitle =>
      'Motion is tuned for a calmer startup.';

  @override
  String get previewIncomingMessage =>
      'The preview should feel like the real app, not a generic demo.';

  @override
  String get previewOutgoingMessage =>
      'Agreed. Let the color, density, and type speak immediately.';

  @override
  String get previewTypingStatus =>
      'Typing indicator, spacing, and corners update here in real time.';

  @override
  String get previewSettingsNotificationsSubtitle =>
      'Preview how secondary settings cards will stack.';

  @override
  String get previewSettingsPrivacySubtitle =>
      'Check hierarchy, contrast, and icon weight before applying.';

  @override
  String get themeColorAegisViolet => 'Aegis Violet';

  @override
  String get themeColorIndigoSignal => 'Indigo Signal';

  @override
  String get themeColorAmethyst => 'Amethyst';

  @override
  String get themeColorRosePulse => 'Rose Pulse';

  @override
  String get themeColorSolarAmber => 'Solar Amber';

  @override
  String get themeColorPaleViolet => 'Pale Violet';

  @override
  String get themeColorSignalCoral => 'Signal Coral';

  @override
  String get themeColorMintRelay => 'Mint Relay';

  @override
  String get themeColorCyanAir => 'Cyan Air';

  @override
  String get themeColorLimeCurrent => 'Lime Current';

  @override
  String get themeColorSlateMono => 'Slate Mono';

  @override
  String get colorsTab => 'Colores';

  @override
  String get fontsTab => 'Fuentes';

  @override
  String get effectsTab => 'Efectos';

  @override
  String get selectColorTheme => 'Seleccionar tema de color';

  @override
  String get themeAppliesEverywhere =>
      'El tema seleccionado se aplica en toda la app';

  @override
  String get fontSettingsTitle => 'Configuración de fuente';

  @override
  String get selectFontFamily => 'Seleccionar familia de fuente';

  @override
  String get appFontLabel => 'Fuente de la app';

  @override
  String get fontWeightLabel => 'Peso de fuente';

  @override
  String get fontPreview => 'Vista previa: Texto de ejemplo';

  @override
  String get compactMode => 'Reducir espaciado y tamaños';

  @override
  String get enableCircles => 'Activar círculos';

  @override
  String get circlesDesc => 'Círculos animados en el fondo';

  @override
  String get floatingCirclesLabel => 'Círculos flotantes';

  @override
  String get reactOnTilt => 'Reaccionar al inclinar el teléfono';

  @override
  String get parallaxEffect => 'Efecto parallax';

  @override
  String get circlesSpeedLabel => 'Velocidad de movimiento';

  @override
  String get staticMotion => 'Estático';

  @override
  String get brightnessLabel => 'Brillo';

  @override
  String get dimOpacity => 'Tenue';

  @override
  String get brightOpacity => 'Brillante';

  @override
  String get performanceLabel => 'Rendimiento';

  @override
  String get currentSpeedPrefix => 'Actual: ';

  @override
  String get speedPrefix => 'Velocidad:';

  @override
  String get advancedSearchTitle => 'Búsqueda avanzada';

  @override
  String get searchQueryHint => 'Ingrese consulta...';

  @override
  String get searchTypeLabel => 'Tipo de búsqueda';

  @override
  String get searchTypeAll => 'Todo';

  @override
  String get searchTypeMessages => 'Mensajes';

  @override
  String get searchTypeMedia => 'Medios';

  @override
  String get searchTypeUsers => 'Usuarios';

  @override
  String get periodLabel => 'Período';

  @override
  String get fromDate => 'Desde';

  @override
  String get toDate => 'Hasta';

  @override
  String get searchButton => 'Buscar';

  @override
  String resultsCount(int count) {
    return 'Resultados ($count)';
  }

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get forgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get forgotPasswordDescription =>
      'Ingrese su correo para recibir un enlace de restablecimiento';

  @override
  String get sendResetButton => 'Enviar';

  @override
  String get forgotPasswordUnavailable =>
      'Recuperación de contraseña no disponible';

  @override
  String get changeEmailTitle => 'Cambiar correo';

  @override
  String get changeEmailDescription => 'Ingrese un nuevo correo electrónico';

  @override
  String get currentPrefix => 'Actual: ';

  @override
  String get newEmailLabel => 'Nuevo correo';

  @override
  String get changeEmailButton => 'Cambiar correo';

  @override
  String changeEmailError(String error) {
    return 'No se pudo cambiar el correo: $error';
  }

  @override
  String get changePhoneTitle => 'Cambiar número de teléfono';

  @override
  String get changePhoneDescription =>
      'Ingrese un nuevo número de teléfono y su contraseña actual.';

  @override
  String get newPhoneLabel => 'Nuevo número (+34...)';

  @override
  String get currentPasswordOptional => 'Contraseña actual (si es necesario)';

  @override
  String get changePhoneButton => 'Cambiar número';

  @override
  String get phoneCannotBeChanged => 'El número de teléfono no puede cambiarse';

  @override
  String get emailCannotBeChanged => 'El email no puede ser cambiado';

  @override
  String changePhoneError(String error) {
    return 'No se pudo cambiar el número: $error';
  }

  @override
  String get confirmCodeTitle => 'Confirmar código';

  @override
  String codeSentTo(String phone) {
    return 'Enviamos un código a $phone';
  }

  @override
  String get enterCodeHint => 'Ingrese código';

  @override
  String get confirmButton => 'Confirmar';

  @override
  String resendCountdown(int seconds) {
    return 'Reenviar en $seconds s';
  }

  @override
  String get resendCodeButton => 'Reenviar código';

  @override
  String get biometricSetupTitle => 'Seguridad';

  @override
  String get authMethodsLabel => 'Métodos de autenticación';

  @override
  String get biometricAuthLabel => 'Autenticación biométrica';

  @override
  String get biometricAuthSubtitle => 'Huella digital o Face ID';

  @override
  String get biometricEnabledLabel => 'Biometría activada';

  @override
  String get aboutSecurityLabel => 'Sobre seguridad';

  @override
  String get aboutSecurityContent =>
      'Elija un método de autenticación conveniente.';

  @override
  String get setPinCode => 'Establecer código PIN';

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String get updateHeroTitle => 'Release ready to install';

  @override
  String get updateHeroSubtitle =>
      'Review the release, verify its integrity, and move through installation with a clear step-by-step flow.';

  @override
  String get updateStatusRequired => 'Required';

  @override
  String get updateStatusRecommended => 'Recommended';

  @override
  String get updatePipelineTitle => 'Update pipeline';

  @override
  String get updatePipelineSubtitle =>
      'Each stage exposes what is happening now and what comes next.';

  @override
  String get updateStageDownloadTitle => 'Download package';

  @override
  String get updateStageDownloadSubtitle =>
      'Fetch the installer package to local storage.';

  @override
  String get updateStageVerifyTitle => 'Verify integrity';

  @override
  String get updateStageVerifySubtitle =>
      'Check the downloaded file against the published SHA-256 digest.';

  @override
  String get updateStageInstallTitle => 'Install release';

  @override
  String get updateStageInstallSubtitle =>
      'Request permission if needed and hand the package to the system installer.';

  @override
  String get releaseSummaryTitle => 'Release summary';

  @override
  String get releaseSummarySubtitle =>
      'Important changes are grouped to make scanning faster than reading a raw changelog.';

  @override
  String get releaseSectionNew => 'New';

  @override
  String get releaseSectionImproved => 'Improved';

  @override
  String get releaseSectionFixed => 'Fixed';

  @override
  String get releaseSectionSecurity => 'Security';

  @override
  String get updateTrustTitle => 'Trust and compatibility';

  @override
  String get updateTrustSubtitle =>
      'See where the package comes from, how it is verified, and what build you are about to install.';

  @override
  String get updateTrustSource => 'Source';

  @override
  String get updateTrustIntegrity => 'Integrity';

  @override
  String get updateTrustPlatform => 'Platform';

  @override
  String get updateTrustAbi => 'ABI';

  @override
  String get updateTrustVerified => 'Verified';

  @override
  String get updateTrustPending => 'Pending';

  @override
  String get updateTrustFailed => 'Failed';

  @override
  String get updateTrustUnavailable => 'Unavailable';

  @override
  String get updateTrustUnknown => 'Unknown';

  @override
  String get updateCurrentVersionLabel => 'Current';

  @override
  String get updateIncomingVersionLabel => 'Incoming';

  @override
  String get whatsNewLabel => 'Novedades';

  @override
  String get noUpdateDescription => 'Sin descripción';

  @override
  String downloadingProgress(int percent) {
    return 'Descargando... $percent%';
  }

  @override
  String get checkingIntegrity => 'Verificando integridad...';

  @override
  String get requestingInstall => 'Solicitando instalación...';

  @override
  String get updateMandatory => 'Actualización obligatoria';

  @override
  String get laterButton => 'Después';

  @override
  String get downloadingLabel => 'Descargando...';

  @override
  String get installingLabel => 'Instalando...';

  @override
  String get updateButton => 'Actualizar';

  @override
  String get downloadFailed => 'Error al descargar actualización';

  @override
  String get integrityCheckFailed =>
      'El archivo descargado no pasó la verificación de integridad (sha256)';

  @override
  String get installPermissionTitle => 'Permiso de instalación';

  @override
  String get installPermissionContent =>
      'Permita la instalación desde fuentes desconocidas.';

  @override
  String get installPermissionRequired => 'Se requiere permiso de instalación';

  @override
  String get installFailed => 'Instalación fallida';

  @override
  String get ssoFeatureRequired =>
      'Esta función requiere configuración de webview_flutter';

  @override
  String ssoLoginVia(String idpId) {
    return 'Inicio de sesión SSO a través de $idpId';
  }

  @override
  String get forwardMessageTitle => 'Reenviar mensaje';

  @override
  String get searchChatHint => 'Buscar chat...';

  @override
  String forwardButton(int count) {
    return 'Reenviar ($count)';
  }

  @override
  String get roomAvatarUpdated => 'Avatar de sala actualizado';

  @override
  String roomAvatarUploadError(String error) {
    return 'Error al subir avatar: $error';
  }

  @override
  String get roomSettingsSaved => 'Configuración de sala guardada';

  @override
  String roomSettingsSaveError(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get uploadAvatarButton => 'Subir avatar';

  @override
  String loadMembersError(String error) {
    return 'Error al cargar miembros: $error';
  }

  @override
  String get leaveRoomTitle => '¿Abandonar sala?';

  @override
  String get leaveRoomContent => 'No podrá volver sin ser re-invitado.';

  @override
  String get leaveAction => 'Abandonar';

  @override
  String get leftRoom => 'Abandonaste la sala';

  @override
  String leaveRoomError(String error) {
    return 'Error al abandonar: $error';
  }

  @override
  String get reportNotImplemented => 'Función de reporte no implementada aún';

  @override
  String get featureInDevelopmentLabel => 'En desarrollo';

  @override
  String featureInDevelopmentMessage(String feature) {
    return 'Esta función sigue en desarrollo y estará disponible en una de las próximas versiones.';
  }

  @override
  String get inviteAction => 'Invitar';

  @override
  String get threadsLabel => 'Hilos';

  @override
  String get pinnedLabel => 'Fijados';

  @override
  String get filesLabel => 'Archivos';

  @override
  String get noSharedFiles => 'Aún no hay archivos compartidos';

  @override
  String get mediaLabel => 'Medios';

  @override
  String get noSharedMedia => 'Aún no hay medios compartidos';

  @override
  String get extensionsLabel => 'Extensiones';

  @override
  String get copyLinkAction => 'Copiar enlace';

  @override
  String get pollsLabel => 'Encuestas';

  @override
  String get exportChatAction => 'Exportar chat';

  @override
  String get reportAction => 'Reportar';

  @override
  String get leaveRoomAction => 'Abandonar sala';

  @override
  String roomTitle(String name) {
    return 'Sala — $name';
  }

  @override
  String get roomSettingsLabel => 'Configuración de sala';

  @override
  String authError(String error) {
    return 'Error de autenticación: $error';
  }

  @override
  String get loginRequired => 'Inicio de sesión requerido';

  @override
  String get loginRequiredContent =>
      'Debe iniciar sesión para buscar contactos. ¿Ir al inicio de sesión?';

  @override
  String get loginAction => 'Iniciar sesión';

  @override
  String searchError(String error) {
    return 'Error de búsqueda: $error';
  }

  @override
  String get searchContactsTitle => 'Buscar contactos';

  @override
  String get nicknameOrPhoneHint => 'Apodo o número de teléfono';

  @override
  String selectContactError(String error) {
    return 'No se pudo seleccionar el contacto: $error';
  }

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get feedbackCategoryFeatures => 'Funciones';

  @override
  String get feedbackCategoryPerformance => 'Rendimiento';

  @override
  String get feedbackCategorySecurity => 'Seguridad/Privacidad';

  @override
  String get feedbackCategoryNetworkSync => 'Sync/Red';

  @override
  String get shortDescriptionLabel => 'Descripción corta';

  @override
  String get shortDescriptionHint =>
      'Ej. \"Copia de seguridad de chats en la nube\"';

  @override
  String get feedbackValidation =>
      'Seleccione al menos una idea o escriba una descripción';

  @override
  String get detailsOptionalLabel => 'Detalles (opcional)';

  @override
  String get detailsHint =>
      '¿Qué debería funcionar, cómo funciona ahora y cómo le gustaría?';

  @override
  String get bigFeaturesTitle =>
      'Funciones principales (seleccione lo que más le interesa)';

  @override
  String get feedbackE2E =>
      'Cifrado E2E de extremo a extremo (Olm/Megolm) + verificación de dispositivos';

  @override
  String get feedbackBackup =>
      'Copia de seguridad de chats (local/nube) + transferencia a nuevo dispositivo';

  @override
  String get feedbackThreads =>
      'Hilos, reacciones, menciones, búsqueda de mensajes mejorada';

  @override
  String get feedbackCalls => 'Llamadas de voz/video y salas de voz rápidas';

  @override
  String get feedbackFolders =>
      'Carpetas/categorías de chat y filtros de notificaciones inteligentes';

  @override
  String get feedbackBots =>
      'Bots e integraciones (webhooks, GitHub/Jira, recordatorios)';

  @override
  String get feedbackSlowNet =>
      'Modo \"internet lento\" + caché agresivo de medios';

  @override
  String get startChatTitle => 'Iniciar chat';

  @override
  String get createRoomSubtitle => 'Grupo privado o público';

  @override
  String get inviteUserTitle => 'Invitar usuario';

  @override
  String get inviteUserSubtitle => 'Buscar y escribir a un usuario';

  @override
  String get joinByCodeTitle => 'Unirse por código';

  @override
  String get joinByCodeSubtitle =>
      'Unirse a una sala usando un código de invitación';

  @override
  String get chatsSubtitle =>
      'Mensajes privados, grupos y enlaces de invitación en un solo lugar';

  @override
  String get chatsQuickStartTitle => 'Empieza algo nuevo';

  @override
  String get chatsRecentTitle => 'Chats recientes';

  @override
  String get joinLinkHint => 'Pega un enlace de invitación, alias o código';

  @override
  String get fontLabel => 'Fuente';

  @override
  String get pinCodeLabel => 'Código PIN';

  @override
  String get pinCodeSubtitle => '4-6 dígitos para protección';

  @override
  String get pinHint => 'PIN (4-6 dígitos)';

  @override
  String get pinLengthError => 'El PIN debe tener 4-6 dígitos';

  @override
  String get pinSetSuccess => 'PIN establecido';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get sendButton => 'Enviar';

  @override
  String get copyButton => 'Copiar';

  @override
  String get shareButton => 'Compartir';

  @override
  String get settingsLabel => 'Configuración';

  @override
  String get feedbackCategoryUxDesign => 'UX/Diseño';

  @override
  String get feedbackShareSubject => 'TwoSpace — sugerencia';

  @override
  String get feedbackMessageHeader => 'TwoSpace — sugerencia/mejora';

  @override
  String feedbackVersion(String version) {
    return 'Versión: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return 'Categoría: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return 'Breve: $title';
  }

  @override
  String get feedbackWishList => 'Lo que sería especialmente genial:';

  @override
  String get feedbackDetailsLine => 'Detalles:';

  @override
  String get circlesVisible => 'Círculos visibles';

  @override
  String get circlesHidden => 'Círculos ocultos';

  @override
  String get speedSlow => 'Lento';

  @override
  String get speedFast => 'Rápido';

  @override
  String get advancedSettingsLabel => 'Configuración avanzada';

  @override
  String get compactModeLabel => 'Modo compacto';

  @override
  String get activeDeviceInfo => 'Android • Activo';

  @override
  String stubPlaceholder(String key) {
    return 'Marcador — $key';
  }

  @override
  String loadMessagesError(String error) {
    return 'Error al cargar mensajes: $error';
  }

  @override
  String get pinnedUpdated => 'Anclados actualizados';

  @override
  String editError(String error) {
    return 'Error al editar: $error';
  }

  @override
  String get moreButton => 'Más';

  @override
  String shareError(String error) {
    return 'No se pudo compartir: $error';
  }

  @override
  String sendError(String error) {
    return 'Error al enviar: $error';
  }

  @override
  String get voiceRecordingUnsupported =>
      'La grabación de voz no es compatible en esta plataforma';

  @override
  String get microphonePermissionRequired =>
      'Se requiere permiso del micrófono';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get ownersLabel => '👑 Propietarios';

  @override
  String get administratorsLabel => '⚡ Administradores';

  @override
  String get oneHour => '1 hora';

  @override
  String get oneDay => '1 día';

  @override
  String get sevenDays => '7 días';

  @override
  String get settingsThemeSelection => 'Theme';

  @override
  String get settingsNotificationNew => 'Notifications';

  @override
  String get settingsDoNotDisturb => 'Do Not Disturb';

  @override
  String get settingsSoundOptions => 'Sound Settings';

  @override
  String get settingsStorageManagement => 'Storage Management';

  @override
  String get settingsStorageUsage => 'Storage Usage';

  @override
  String get settingsStorageAppSize => 'App Size';

  @override
  String get settingsStorageClearBtn => 'Clear Selected';

  @override
  String get storageMemoryTitle => 'Memoria';

  @override
  String get storageTotalLabel => 'Total';

  @override
  String get storagePhotosLabel => 'Fotos';

  @override
  String get storageVideosLabel => 'Vídeos';

  @override
  String get storageCacheLabel => 'Caché';

  @override
  String get storageAppDataLabel => 'Datos de la app';

  @override
  String get storageCleanupTitle => 'Se borrará';

  @override
  String get storageCleanupSubtitle =>
      'Revisa qué se puede eliminar con seguridad.';

  @override
  String get settingsStorageKeepChat => 'Keep Chat Data';

  @override
  String get settingsStorageKeepChannel => 'Keep Channel Data';

  @override
  String get settingsStorageKeepGroup => 'Keep Group Data';

  @override
  String get settingsAboutPropose => 'Propose Improvement';

  @override
  String get settingsAboutCheckUpdate => 'Check for Updates';

  @override
  String get biometricsEnable => 'App Lock (Biometrics/PIN)';

  @override
  String get biometricsSetup => 'Setup App Lock';

  @override
  String get contactsTwoSpaceYes => 'Uses TwoSpace';

  @override
  String get contactsTwoSpaceNo => 'Not in TwoSpace';

  @override
  String get peopleTitle => 'Personas';

  @override
  String get peopleSubtitle =>
      'Contactos, favoritos, búsqueda e invitaciones en un solo lugar';

  @override
  String get peopleQuickNewChat => 'Nuevo chat';

  @override
  String get peopleQuickInvite => 'Invitar';

  @override
  String get peopleQuickSync => 'Sincronizar';

  @override
  String get peopleSearchHint => 'Buscar por nombre, alias o teléfono';

  @override
  String get peopleSegmentAll => 'Todos';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => 'Agenda';

  @override
  String get peopleSegmentRecent => 'Recientes';

  @override
  String get peopleLoading => 'Cargando personas…';

  @override
  String get peopleNoPeopleTitle => 'Aún no hay personas';

  @override
  String get peopleNoPeopleMessage =>
      'Aquí aparecerán tus favoritos, conversaciones recientes y contactos.';

  @override
  String get peoplePermissionCardTitle => 'Acceso a contactos limitado';

  @override
  String get peoplePermissionCardMessage =>
      'Permite el acceso a contactos para mostrar tu agenda e invitar personas más rápido.';

  @override
  String get peoplePermissionCardMessageSettings =>
      'Activa el acceso a contactos en la configuración del sistema para restaurar la sección de agenda.';

  @override
  String get peopleFavoritesFrequentTitle => 'Favoritos y frecuentes';

  @override
  String get peopleRecentTitle => 'Personas recientes';

  @override
  String get peopleTwoSpaceTitle => 'Personas en TwoSpace';

  @override
  String get peopleInviteTitle => 'Invitar a TwoSpace';

  @override
  String get peopleInviteSubtitle => 'Invitar este contacto a TwoSpace';

  @override
  String get peopleSearching => 'Buscando personas…';

  @override
  String get peopleSearchRemoteTitle => 'Resultados de TwoSpace';

  @override
  String get peopleSearchLocalTitle => 'Recientes y guardados';

  @override
  String get peopleSearchInviteTitle => 'Invitar desde la agenda';

  @override
  String get peopleSearchEmptyTitle => 'No hay personas coincidentes';

  @override
  String get peopleSearchEmptyMessage =>
      'Prueba con otro nombre, alias o número de teléfono.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => 'Todavía no hay detalles adicionales';

  @override
  String get peopleInviteShareText =>
      'Únete conmigo a TwoSpace, un mensajero seguro para chats y llamadas.';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return 'Únete conmigo a TwoSpace, $personName; chateemos y llamemos con seguridad.';
  }

  @override
  String get peopleViewProfileAction => 'Ver perfil';

  @override
  String get peopleRemoveFavoriteAction => 'Quitar de favoritos';

  @override
  String get peopleAddFavoriteAction => 'Añadir a favoritos';

  @override
  String get callsSubtitle =>
      'Llamadas recientes, rellamada rápida e historial centrado en personas';

  @override
  String get callsStartCallAction => 'Iniciar llamada';

  @override
  String get callsQuickStartTitle => 'Llamar ahora';

  @override
  String get callsQuickStartSubtitle =>
      'Abre Personas, busca a alguien e inicia una llamada segura de voz o video.';

  @override
  String get callsSearchHint => 'Buscar en el historial de llamadas';

  @override
  String get callsVideoFilter => 'Video';

  @override
  String get callsTopContactsTitle => 'Contactos frecuentes';

  @override
  String get callsLoadingLabel => 'Cargando llamadas…';

  @override
  String get callsEmptyTitle => 'Aún no hay llamadas';

  @override
  String get callsEmptyMessage =>
      'Tu historial de llamadas aparecerá aquí después de tu primera llamada de voz o video.';

  @override
  String get callsEmptySearchMessage =>
      'Ninguna llamada coincide con la búsqueda o el filtro actual.';

  @override
  String get callsTodaySection => 'Hoy';

  @override
  String get callsThisWeekSection => 'Esta semana';

  @override
  String get callsEarlierSection => 'Antes';

  @override
  String callsThreadCount(int count) {
    return '$count llamadas';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count perdidas';
  }

  @override
  String get callsMuteAction => 'Silencio';

  @override
  String get callsSpeakerAction => 'Altavoz';

  @override
  String get callsCameraAction => 'Cámara';

  @override
  String get callsSwitchCameraAction => 'Cambiar';

  @override
  String get callsEndAction => 'Finalizar llamada';

  @override
  String get callsConnectingLabel => 'Conectando…';

  @override
  String get callsRingingLabel => 'Llamando…';

  @override
  String get callsConnectingDetail => 'Creando una sesión de llamada segura.';

  @override
  String get callsRingingDetail => 'Esperando a que la otra persona responda.';

  @override
  String get callsVideoSecureDetail =>
      'El video está protegido y se enruta por la sesión segura actual.';

  @override
  String get callsVoiceSecureDetail =>
      'La voz está protegida y se enruta por la sesión segura actual.';

  @override
  String get timestampPrecisionLabel => 'Precisión de hora en mensajes';

  @override
  String get timestampPrecisionSubtitle =>
      'Elige cuánto detalle mostrar en la hora dentro de los chats y en la lista de chats.';

  @override
  String get timestampPrecisionMinutes => 'Horas y minutos';

  @override
  String get timestampPrecisionSeconds => 'Horas, minutos y segundos';

  @override
  String get timestampPrecisionMilliseconds =>
      'Horas, minutos, segundos y milisegundos';

  @override
  String get startupTitle => 'Preparando TwoSpace';

  @override
  String get startupSubtitle =>
      'Comprobando la sesión segura y abriendo tus chats.';

  @override
  String get startupFooter =>
      'Esta pantalla solo se muestra durante el inicio de la aplicación.';

  @override
  String get startupStepEnvironment => 'Cargando configuración';

  @override
  String get startupStepDiagnostics => 'Iniciando diagnóstico';

  @override
  String get startupStepValidation => 'Validando entorno';

  @override
  String get startupStepSettings => 'Cargando ajustes';

  @override
  String get startupStepSession => 'Restaurando sesión segura';

  @override
  String get startupStepLaunch => 'Iniciando aplicación';

  @override
  String get callsDemoBannerTitle => 'Ejemplo, función no operativa';

  @override
  String get callsDemoBannerVoiceMessage =>
      'Las llamadas de voz se muestran solo como un prototipo visual. La transmisión de audio todavía no está conectada.';

  @override
  String get callsDemoBannerVideoMessage =>
      'Las videollamadas se muestran solo como un prototipo visual. El video remoto no está disponible todavía, pero tu vista previa local de cámara sí funciona.';

  @override
  String get callsCameraPermissionMessage =>
      'Permite el acceso a la cámara para mostrar tu vista previa local durante una videollamada.';

  @override
  String get callsCameraPermissionSettingsMessage =>
      'El acceso a la cámara está bloqueado. Abre los ajustes del sistema para activar la vista previa local.';

  @override
  String get callsCameraPermissionAction => 'Permitir cámara';

  @override
  String get callsCameraUnavailableTitle => 'Cámara no disponible';

  @override
  String get callsCameraUnavailableMessage =>
      'No se pudo iniciar la vista previa local de la cámara en este dispositivo.';

  @override
  String get callsCameraUnsupportedMessage =>
      'Esta plataforma no admite la vista previa local de video.';

  @override
  String get callsCameraOffMessage =>
      'La vista previa de la cámara está desactivada para esta llamada de demostración.';

  @override
  String get callsFrontCameraLabel => 'Cámara frontal';

  @override
  String get callsRearCameraLabel => 'Cámara trasera';

  @override
  String get backgroundOptimizationDisabledTitle =>
      'Los efectos de fondo se simplificaron';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace detectó fotogramas lentos de forma continua y desactivó los efectos de fondo pesados para mantener fluido el desplazamiento y el uso de los chats.';

  @override
  String get backgroundOptimizationOpenSettings =>
      'Abrir ajustes de apariencia';
}
