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
  String get errorInitializationFull => 'Errore di inizializzazione. Riavviare l\'app.';

  @override
  String get errorNetwork => 'Errore di rete. Verificare la connessione.';

  @override
  String get errorAuth => 'Errore di autenticazione.';

  @override
  String get errorInvalidArguments => 'Argomenti non validi.';

  @override
  String get errorInvalidArgumentsProfile => 'Argomenti non validi per il profilo.';

  @override
  String get errorInvalidArgumentsChat => 'Argomenti non validi per la chat.';

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

  @override
  String errorWithDetail(String error) {
    return 'Errore: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Conferma';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get next => 'Avanti';

  @override
  String get back => 'Indietro';

  @override
  String get done => 'Fatto';

  @override
  String get noData => 'Nessun dato';

  @override
  String get nothingFound => 'Niente trovato';

  @override
  String get copyAction => 'Copia';

  @override
  String get shareAction => 'Condividi';

  @override
  String get textCopied => 'Testo copiato';

  @override
  String get authUsernameHint => 'username';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithYandex => 'Continue with Yandex';

  @override
  String get chooseAegisUsernamePrompt => 'Choose an Aegis username.';

  @override
  String get validationAegisUsernameFormat => 'Username must be 3-32 chars and use Latin letters, digits, ., _ or -.';

  @override
  String get aegisUsernameHelper => 'Aegis username: 3-32 chars, Latin letters, digits, ., _ or -';

  @override
  String loginCooldownMessage(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s.';
  }

  @override
  String get onlineLabel => 'Online';

  @override
  String get offlineLabel => 'Offline';

  @override
  String get userDefault => 'Utente';

  @override
  String get lessThanMinuteAgo => 'meno di un minuto fa';

  @override
  String minutesAgo(int count) {
    return '$count min. fa';
  }

  @override
  String hoursAgo(int count) {
    return '$count ore fa';
  }

  @override
  String daysAgo(int count) {
    return '$count giorni fa';
  }

  @override
  String get videoLabel => 'Video';

  @override
  String videoLoadError(String error) {
    return 'Errore video: $error';
  }

  @override
  String get saveFailed => 'Salvataggio non riuscito';

  @override
  String get shareSheetFailed => 'Impossibile aprire la condivisione';

  @override
  String get speedLabel => 'Velocità:';

  @override
  String get previewTitle => 'Anteprima';

  @override
  String fileDownloaded(String path) {
    return 'File scaricato: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return 'File salvato temporaneamente: $path';
  }

  @override
  String get savedToGallery => 'Salvato nella galleria';

  @override
  String authorizationError(String message) {
    return 'Errore di autorizzazione: $message';
  }

  @override
  String get loginTitle => 'Accedi';

  @override
  String get welcomeBack => 'Benvenuto';

  @override
  String get emailOrUsernameLabel => 'Nome utente';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Accedi';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get noAccount => 'Non hai un account?';

  @override
  String get orDivider => 'Oppure';

  @override
  String get validationEnterEmailOrUsername => 'Inserisci il nome utente';

  @override
  String get validationEnterPassword => 'Inserisci la password';

  @override
  String get registerTitle => 'Registrati';

  @override
  String get fillAllFields => 'Compila tutti i campi';

  @override
  String get passwordStrengthWeak => 'Debole';

  @override
  String get passwordStrengthMedium => 'Media';

  @override
  String get passwordStrengthGood => 'Buona';

  @override
  String get passwordStrengthStrong => 'Forte';

  @override
  String get fullNameLabel => 'Nome completo';

  @override
  String get nicknameAtLabel => 'Soprannome (@utente)';

  @override
  String get uploadPhotoPrompt => 'Carica la tua foto profilo';

  @override
  String get photoLooksGreat => 'Sembra fantastico!';

  @override
  String get helpFriendsFind => 'Aiuta gli amici a trovarti';

  @override
  String get setupInterfaceTitle => 'Personalizza l\'interfaccia';

  @override
  String get colorThemeLabel => 'Tema colore';

  @override
  String get validationEnterEmail => 'Inserisci email';

  @override
  String get validationInvalidEmail => 'Indirizzo email non valido';

  @override
  String get validationPasswordTooShort => 'Password troppo corta';

  @override
  String get backToLogin => 'Accedi';

  @override
  String get finishButton => 'Termina';

  @override
  String filePickError(String error) {
    return 'Errore selezione file: $error';
  }

  @override
  String get chatsTitle => 'Chat';

  @override
  String get noChats => 'Nessuna chat';

  @override
  String get noMessages => '(nessun messaggio)';

  @override
  String get newChat => 'Nuova chat';

  @override
  String get messageInputHint => 'Scrivi un messaggio...';

  @override
  String get addCaptionHint => 'Aggiungi una didascalia o un messaggio';

  @override
  String get unlockApp => 'Sblocca';

  @override
  String get unlockButton => 'Sblocca';

  @override
  String get dropFilesTitle => 'Trascina file da allegare';

  @override
  String get dropFilesSubtitle => 'Appariranno sopra il campo messaggio.';

  @override
  String get videoUnavailable => 'Video non disponibile';

  @override
  String get guestRole => 'Ospite';

  @override
  String get replyAction => 'Rispondi';

  @override
  String get editShort => 'Modif.';

  @override
  String get pinAction => 'Fissa';

  @override
  String get moreReactions => 'Altro';

  @override
  String get replyDialogTitle => 'Rispondi';

  @override
  String get replyHint => 'Testo risposta';

  @override
  String get editMessageTitle => 'Modifica messaggio';

  @override
  String get editMessageHint => 'Nuovo testo';

  @override
  String get deleteMessageTitle => 'Eliminare il messaggio?';

  @override
  String get pinsUpdated => 'Pin aggiornati';

  @override
  String get messageEdited => 'Messaggio modificato';

  @override
  String get fileSent => 'File inviato';

  @override
  String get voiceNotSupported => 'Registrazione vocale non supportata su questa piattaforma';

  @override
  String get microphonePermRequired => 'Permesso microfono richiesto';

  @override
  String get recordingError => 'Errore registrazione';

  @override
  String sendFailedError(String error) {
    return 'Invio non riuscito: $error';
  }

  @override
  String attachmentSendError(String error) {
    return 'Errore allegato: $error';
  }

  @override
  String shareFailedError(String error) {
    return 'Condivisione non riuscita: $error';
  }

  @override
  String replyError(String error) {
    return 'Errore risposta: $error';
  }

  @override
  String pinError(String error) {
    return 'Errore pin: $error';
  }

  @override
  String deleteError(String error) {
    return 'Errore eliminazione: $error';
  }

  @override
  String editMessageError(String error) {
    return 'Errore modifica: $error';
  }

  @override
  String get userTyping => 'L\'utente sta scrivendo...';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusLastSeenRecently => 'Visto di recente';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get appearanceSection => 'Aspetto';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get customizationLabel => 'Personalizzazione';

  @override
  String get customizationSubtitle => 'Colori, font ed effetti UI';

  @override
  String get notificationsSection => 'Notifiche';

  @override
  String get notificationsLabel => 'Notifiche';

  @override
  String get soundLabel => 'Suono';

  @override
  String get accountSection => 'Account';

  @override
  String get profileLabel => 'Profilo';

  @override
  String get accountProfileTitle => 'My account';

  @override
  String get accountProfileSubtitle => 'Manage your public profile data and contact details';

  @override
  String get accountProfileEditSubtitle => 'Edit your visible profile data and save the changes here';

  @override
  String get otherProfileSubtitle => 'Public profile and available contact information';

  @override
  String get profileSubtitle => 'Modifica informazioni profilo';

  @override
  String get accountSettingsLabel => 'Impostazioni account';

  @override
  String get accountSettingsSubtitle => 'Password, sicurezza, 2FA';

  @override
  String get privacyLabel => 'Privacy';

  @override
  String get privacySubtitle => 'Gestisci privacy';

  @override
  String get generalSection => 'Generale';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get textSizeLabel => 'Dimensione testo';

  @override
  String get sendByEnterLabel => 'Invia con Invio';

  @override
  String get sendByEnterSubtitle => 'Maiusc+Invio per nuova riga';

  @override
  String get dataStorageSection => 'Dati e archiviazione';

  @override
  String get autoDownloadLabel => 'Download automatico media';

  @override
  String get autoDownloadSubtitle => 'Scarica foto e video automaticamente';

  @override
  String get storageManagementLabel => 'Gestione archiviazione';

  @override
  String get storageManagementSubtitle => 'Svuota cache e dati';

  @override
  String get clearCacheTitle => 'Svuota cache';

  @override
  String get clearCacheContent => 'Eliminare i dati nella cache?';

  @override
  String get cacheCleared => 'Cache svuotata';

  @override
  String get developmentSection => 'Sviluppo';

  @override
  String get devMenuSubtitle => 'Pulsante debug flottante';

  @override
  String get aboutSection => 'Informazioni';

  @override
  String get suggestImprovementLabel => 'Suggerisci miglioramento';

  @override
  String get suggestImprovementSubtitle => 'Idee e richieste di nuove funzionalità';

  @override
  String get dangerZoneSection => 'Zona pericolosa';

  @override
  String get logoutLabel => 'Esci';

  @override
  String get logoutSubtitle => 'Disconnettersi da questo dispositivo';

  @override
  String get logoutDialogTitle => 'Disconnettersi';

  @override
  String get logoutDialogContent => 'Sei sicuro di voler uscire?';

  @override
  String get logoutAction => 'Esci';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageUkrainian => 'Ucraino';

  @override
  String get clientDescription => 'Client TwoSpace creato con Flutter/Dart';

  @override
  String errorLogout(String error) {
    return 'Errore: $error';
  }

  @override
  String get accountSettingsTitle => 'Impostazioni account';

  @override
  String get securitySection => 'Sicurezza';

  @override
  String get twoFactorLabel => 'Autenticazione a due fattori';

  @override
  String get twoFactorSubtitle => 'Protezione aggiuntiva dell\'account';

  @override
  String get biometricLabel => 'Biometria';

  @override
  String get biometricSubtitle => 'Usa Face ID, impronta o il codice del dispositivo';

  @override
  String get activeSessionsLabel => 'Sessioni attive';

  @override
  String get activeSessionsSubtitle => 'Gestisci dispositivi';

  @override
  String get currentDevice => 'Dispositivo corrente';

  @override
  String get changePasswordSection => 'Cambia password';

  @override
  String get currentPasswordLabel => 'Password attuale';

  @override
  String get newPasswordLabel => 'Nuova password';

  @override
  String get confirmPasswordLabel => 'Conferma password';

  @override
  String get minPasswordHelper => 'Minimo 8 caratteri';

  @override
  String get changePasswordButton => 'Cambia password';

  @override
  String get passwordMismatch => 'Le password non corrispondono';

  @override
  String get passwordTooShort => 'La password deve avere almeno 8 caratteri';

  @override
  String get passwordChangeSuccess => 'Password cambiata con successo';

  @override
  String get contactDataSection => 'Dati di contatto';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Telefono';

  @override
  String get deleteAccountLabel => 'Elimina account';

  @override
  String get deleteAccountSubtitle => 'Azione irreversibile';

  @override
  String get deleteAccountTitle => 'Elimina account';

  @override
  String get deleteAccountContent => 'Sei sicuro di voler eliminare il tuo account? Questa azione è irreversibile.';

  @override
  String get deleteFeatureLater => 'L\'eliminazione dell\'account sarà disponibile in seguito';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get editProfileButton => 'Edit profile';

  @override
  String get saveProfileButton => 'Save changes';

  @override
  String get copyAegisIdButton => 'Copy Aegis ID';

  @override
  String get saveTooltip => 'Salva';

  @override
  String get editTooltip => 'Modifica';

  @override
  String get mediaDownloadAction => 'Scarica';

  @override
  String get writeMessageButton => 'Messaggio';

  @override
  String get callButton => 'Chiama';

  @override
  String get aboutField => 'Su di me';

  @override
  String get nicknameField => 'Soprannome';

  @override
  String get locationField => 'Posizione';

  @override
  String get birthdayField => 'Compleanno';

  @override
  String get nameField => 'Nome';

  @override
  String get aegisIdLabel => 'Aegis ID';

  @override
  String get registeredAtLabel => 'Registered';

  @override
  String get profileStatusLabel => 'Status';

  @override
  String get profileModerationNoticeTitle => 'Safety actions are not ready yet';

  @override
  String get profileModerationNoticeMessage => 'Blocking and reporting will appear here after the moderation flow is completed.';

  @override
  String get blockUserAction => 'Block user';

  @override
  String get reportUserAction => 'Report user';

  @override
  String get avatarUploadLater => 'Il caricamento avatar verrà aggiunto in seguito';

  @override
  String get profileSaved => 'Profilo salvato';

  @override
  String createChatError(String error) {
    return 'Impossibile creare la chat: $error';
  }

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get hideFromSearch => 'Nascondi dalla ricerca';

  @override
  String get hideFromSearchSubtitle => 'Non mostrare nei risultati di ricerca';

  @override
  String get hideLastSeen => 'Nascondi ultimo accesso';

  @override
  String get hideLastSeenSubtitle => 'Gli altri non vedranno quando sei stato online';

  @override
  String get sessionExpiry => 'Scadenza sessione';

  @override
  String sessionExpirySubtitle(int days) {
    return 'Accesso automatico su questo dispositivo: $days giorni';
  }

  @override
  String get sessionExpiryDaysTitle => 'Scadenza sessione (giorni)';

  @override
  String get sessionExpiryDaysContent => 'Scegli il numero di giorni (min: 7, max: 365).';

  @override
  String get daysLabel => 'Giorni';

  @override
  String get enterDaysError => 'Inserisci un numero da 7 a 365';

  @override
  String sessionExpirySet(int days) {
    return 'Scadenza sessione: $days giorni';
  }

  @override
  String get changeEmailLabel => 'Cambia email';

  @override
  String get changeEmailSubtitle => 'Aggiorna indirizzo email';

  @override
  String get twoFactorPrivacySubtitle => 'Attiva o disattiva la protezione avanzata';

  @override
  String get changePhoneLabel => 'Cambia telefono';

  @override
  String get changePhoneSubtitle => 'Aggiorna numero di telefono';

  @override
  String updatePrivacyError(String error) {
    return 'Impossibile aggiornare la privacy: $error';
  }

  @override
  String updateSettingError(String error) {
    return 'Impossibile aggiornare l\'impostazione: $error';
  }

  @override
  String get contactsTitle => 'Contatti';

  @override
  String get searchContactsHint => 'Cerca contatti...';

  @override
  String get contactsAccessTitle => 'Accesso contatti';

  @override
  String get contactsPermDeniedPermanent => 'Permesso negato definitivamente. Apri le impostazioni.';

  @override
  String get contactsPermRequired => 'Permesso contatti richiesto.';

  @override
  String get openSettingsButton => 'Apri impostazioni';

  @override
  String get requestPermissionButton => 'Richiedi permesso';

  @override
  String get noContacts => 'Nessun contatto trovato';

  @override
  String get callAction => 'Chiama';

  @override
  String get writeMessageAction => 'Messaggio';

  @override
  String callNotification(String number) {
    return 'Chiamata: $number';
  }

  @override
  String messageNotification(String name) {
    return 'Messaggio a: $name';
  }

  @override
  String get callsTitle => 'Chiamate';

  @override
  String get widgetsTitle => 'Widgets';

  @override
  String get searchByNameHint => 'Cerca per nome...';

  @override
  String get allFilter => 'Tutte';

  @override
  String get incomingFilter => 'In entrata';

  @override
  String get outgoingFilter => 'In uscita';

  @override
  String get missedFilter => 'Perse';

  @override
  String get noCallsFound => 'Nessuna chiamata';

  @override
  String get yesterdayLabel => 'Ieri';

  @override
  String get incomingCall => 'In entrata';

  @override
  String get outgoingCall => 'In uscita';

  @override
  String get missedCall => 'Persa';

  @override
  String get videoCallLabel => 'Videochiamata';

  @override
  String get voiceCallLabel => 'Chiamata vocale';

  @override
  String get sendMessageCallAction => 'Messaggio';

  @override
  String get createRoomTitle => 'Crea stanza';

  @override
  String get createButton => 'Crea';

  @override
  String get roomNameLabel => 'Nome stanza';

  @override
  String get roomNameHint => 'Es. nome del tuo progetto';

  @override
  String get roomTopicLabel => 'Argomento (opzionale)';

  @override
  String get roomTopicHint => 'Di cosa tratta questa stanza?';

  @override
  String get roomVisibilityLabel => 'Visibilità stanza';

  @override
  String get privateRoomOption => 'Stanza privata';

  @override
  String get privateRoomSubtitle => 'Solo gli utenti invitati possono unirsi';

  @override
  String get publicRoomOption => 'Stanza pubblica';

  @override
  String get publicRoomSubtitle => 'Chiunque può unirsi';

  @override
  String get showHistoryLabel => 'Mostra cronologia messaggi';

  @override
  String get showHistorySubtitle => 'I nuovi membri possono vedere i messaggi precedenti';

  @override
  String get enterRoomNameError => 'Inserisci il nome della stanza';

  @override
  String get roomCreatedSuccess => 'Stanza creata con successo!';

  @override
  String imagePickError(String error) {
    return 'Errore selezione immagine: $error';
  }

  @override
  String get groupInfoTab => 'Info';

  @override
  String get groupMembersTab => 'Membri';

  @override
  String get groupRolesTab => 'Ruoli';

  @override
  String get groupBansTab => 'Ban';

  @override
  String get groupDeleteTab => 'Elimina';

  @override
  String membersCount(int count) {
    return 'Membri: $count';
  }

  @override
  String get messageHistoryToggle => 'Cronologia messaggi';

  @override
  String get showHistoryToggleLabel => 'Mostra cronologia';

  @override
  String get settingSaved => 'Impostazione salvata';

  @override
  String get backgroundColorLabel => 'Colore sfondo';

  @override
  String get noMembers => 'Nessun membro';

  @override
  String get roleAction => 'Ruolo';

  @override
  String get freezeAction => 'Congela';

  @override
  String get banAction => 'Banna';

  @override
  String get kickAction => 'Espelli';

  @override
  String get noBannedUsers => 'Nessun utente bannato';

  @override
  String get bannedLabel => 'Bannato';

  @override
  String get userUnbanned => 'Utente sbannato';

  @override
  String get deleteGroupLabel => 'Elimina gruppo';

  @override
  String get deleteGroupWarning => 'Questa azione è IRREVERSIBILE. Il gruppo verrà eliminato definitivamente.';

  @override
  String get confirmDeleteTitle => 'Conferma eliminazione';

  @override
  String get confirmDeleteContent => 'Sei sicuro? Questa azione è irreversibile.';

  @override
  String get changeRoleTitle => 'Cambia ruolo';

  @override
  String get adminRole => 'Amministratore';

  @override
  String get memberRole => 'Membro';

  @override
  String get freezeUserTitle => 'Congela utente';

  @override
  String get userBanned => 'Utente bannato';

  @override
  String get userKicked => 'Utente espulso';

  @override
  String get groupDeleted => 'Gruppo eliminato';

  @override
  String loadError(String error) {
    return 'Errore di caricamento: $error';
  }

  @override
  String get publicLabel => 'Pubblico';

  @override
  String get privateLabel => 'Privato';

  @override
  String get noDescription => 'Nessuna descrizione';

  @override
  String get membersLabel => 'Membri';

  @override
  String get generalLabel => 'Generale';

  @override
  String get newChatTitle => 'Nuova chat';

  @override
  String get newChatChooserTitle => 'Start a new conversation';

  @override
  String get newChatChooserSubtitle => 'Choose the kind of chat you want to create or join.';

  @override
  String get createDirectChatSubtitle => 'Search for a person or enter an Aegis ID manually.';

  @override
  String get directChatTab => 'Diretto';

  @override
  String get groupChatTab => 'Gruppo';

  @override
  String get channelChatTab => 'Channel';

  @override
  String get createGroupSubtitle => 'Set up a group, pick participants and share the invite link right away.';

  @override
  String get createChannelTitle => 'Create channel';

  @override
  String get createChannelSubtitle => 'Create a read-focused channel with avatar, description and shareable link.';

  @override
  String get startDirectChatTitle => 'Avvia chat diretta';

  @override
  String get contactIdDescription => 'Inserisci il nome utente o l\'ID Aegis';

  @override
  String get contactIdLabel => 'Nome utente o ID Aegis';

  @override
  String get startChatButton => 'Avvia chat';

  @override
  String get hintCardTitle => 'Suggerimento';

  @override
  String get contactIdExplanation => 'Puoi usare un nome utente o un ID Aegis numerico';

  @override
  String get enterUserIdError => 'Inserisci ID utente';

  @override
  String get createNewRoomTitle => 'Crea nuova stanza';

  @override
  String get descriptionOptionalLabel => 'Descrizione (opzionale)';

  @override
  String get privateGroupLabel => 'Gruppo privato';

  @override
  String get privateGroupSubtitle => 'Solo gli utenti invitati possono unirsi';

  @override
  String get createRoomButton => 'Crea stanza';

  @override
  String get customizationTitle => 'Personalizzazione';

  @override
  String get customizationHeroTitle => 'Shape the app around your rhythm';

  @override
  String get customizationHeroSubtitle => 'Build a distinct look with live preview, curated presets, motion, and density controls.';

  @override
  String get notificationsHeroSubtitle => 'Tune alerts, sound behavior, and custom previews so incoming activity feels calm and readable.';

  @override
  String get livePreviewBadge => 'Live preview';

  @override
  String get stylePresetsTitle => 'Style presets';

  @override
  String get stylePresetsSubtitle => 'Start with a strong visual direction, then tune the details.';

  @override
  String get moodSectionTitle => 'Mood';

  @override
  String get moodSectionSubtitle => 'Choose the accent that drives surfaces, highlights, and the background atmosphere.';

  @override
  String get typeSectionTitle => 'Type';

  @override
  String get typeSectionSubtitle => 'Pair a font family with the weight and size that feels right across the whole UI.';

  @override
  String get motionSectionTitle => 'Motion';

  @override
  String get motionSectionSubtitle => 'Control how much the interface breathes, drifts, and reacts in the background.';

  @override
  String get densitySectionTitle => 'Density';

  @override
  String get densitySectionSubtitle => 'Tighten spacing, bubble geometry, and navigation timing for a sharper layout.';

  @override
  String get themeModeLabel => 'Light balance';

  @override
  String get dynamicBubblesLabel => 'Dynamic bubbles';

  @override
  String get dynamicBubblesSubtitle => 'Give chat bubbles directional corners for a more conversational rhythm.';

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
  String get presetQuietGlassSubtitle => 'Balanced contrast with cool depth and steady motion.';

  @override
  String get presetNightSignal => 'Night Signal';

  @override
  String get presetNightSignalSubtitle => 'Tighter density, stronger highlights, and a darker pulse.';

  @override
  String get presetEditorial => 'Editorial';

  @override
  String get presetEditorialSubtitle => 'Calmer motion, restrained color, and a more reading-focused tone.';

  @override
  String get presetSolarFlare => 'Solar Flare';

  @override
  String get presetSolarFlareSubtitle => 'Warm highlights and brighter surfaces with energetic movement.';

  @override
  String get presetRetroPulse => 'Retro Pulse';

  @override
  String get presetRetroPulseSubtitle => 'Compact, playful, and intentionally stylized.';

  @override
  String get previewRoomsLabel => 'Rooms';

  @override
  String get previewConversationLabel => 'Conversation';

  @override
  String get previewSettingsLabel => 'Settings';

  @override
  String get previewRoomsTitle => 'Room list preview';

  @override
  String get previewRoomsSubtitle => 'A compact room list with real-sounding snippets and cleaner status markers.';

  @override
  String get previewConversationTitle => 'Chat bubble preview';

  @override
  String get previewConversationSubtitle => 'Check how tone, spacing, and bubble shape read in a short live dialog.';

  @override
  String get previewSettingsTitle => 'Controls at hand';

  @override
  String get previewSettingsSubtitle => 'Preview how the settings stack feels before applying anything globally.';

  @override
  String get previewLiveLabel => 'Live';

  @override
  String get previewRoomDesignSync => 'Design Sync';

  @override
  String get previewRoomDesignSyncSubtitle => 'Hero card is ready for review.';

  @override
  String get previewRoomReleaseCheck => 'Release Check';

  @override
  String get previewRoomReleaseCheckSubtitle => 'Notes are grouped by security and fixes.';

  @override
  String get previewRoomAlphaOps => 'Alpha Ops';

  @override
  String get previewRoomAlphaOpsSubtitle => 'Motion is tuned for a calmer startup.';

  @override
  String get previewIncomingMessage => 'The preview should feel like the real app, not a generic demo.';

  @override
  String get previewOutgoingMessage => 'Agreed. Let the color, density, and type speak immediately.';

  @override
  String get previewTypingStatus => 'Typing indicator, spacing, and corners update here in real time.';

  @override
  String get previewSettingsAppearanceSubtitle => 'Pick a template, adjust motion, and keep the whole shell consistent.';

  @override
  String get previewSettingsNotificationsSubtitle => 'Preview how secondary settings cards will stack.';

  @override
  String get previewSettingsPrivacySubtitle => 'Check hierarchy, contrast, and icon weight before applying.';

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
  String get themeColorAuroraMint => 'Aurora Mint';

  @override
  String get themeColorSlateMono => 'Slate Mono';

  @override
  String get backgroundMotionToggleLabel => 'Animated background';

  @override
  String get backgroundMotionOnSubtitle => 'The atmosphere layer stays alive behind the UI.';

  @override
  String get backgroundMotionOffSubtitle => 'Use a still backdrop for a quieter, flatter surface.';

  @override
  String get motionModeCircles => 'Orbit';

  @override
  String get motionModeCirclesSubtitle => 'Floating light blobs with soft parallax drift.';

  @override
  String get motionModeWaves => 'Waves';

  @override
  String get motionModeWavesSubtitle => 'Layered bottom waves that move more like ambient light.';

  @override
  String get colorsTab => 'Colori';

  @override
  String get fontsTab => 'Font';

  @override
  String get effectsTab => 'Effetti';

  @override
  String get selectColorTheme => 'Seleziona tema colore';

  @override
  String get themeAppliesEverywhere => 'Il tema selezionato viene applicato in tutta l\'app';

  @override
  String get fontSettingsTitle => 'Impostazioni font';

  @override
  String get selectFontFamily => 'Seleziona famiglia di font';

  @override
  String get appFontLabel => 'Font dell\'app';

  @override
  String get fontWeightLabel => 'Peso del font';

  @override
  String get fontPreview => 'Anteprima: Testo di esempio';

  @override
  String get compactMode => 'Riduci spaziatura e dimensioni';

  @override
  String get enableCircles => 'Abilita cerchi';

  @override
  String get circlesDesc => 'Cerchi animati nello sfondo';

  @override
  String get floatingCirclesLabel => 'Cerchi flottanti';

  @override
  String get reactOnTilt => 'Reagisci all\'inclinazione del telefono';

  @override
  String get parallaxEffect => 'Effetto parallasse';

  @override
  String get circlesSpeedLabel => 'Velocità di movimento';

  @override
  String get staticMotion => 'Statico';

  @override
  String get brightnessLabel => 'Luminosità';

  @override
  String get dimOpacity => 'Tenue';

  @override
  String get brightOpacity => 'Luminoso';

  @override
  String get performanceLabel => 'Prestazioni';

  @override
  String get currentSpeedPrefix => 'Attuale: ';

  @override
  String get speedPrefix => 'Velocità:';

  @override
  String get advancedSearchTitle => 'Ricerca avanzata';

  @override
  String get searchQueryHint => 'Inserisci query...';

  @override
  String get searchTypeLabel => 'Tipo di ricerca';

  @override
  String get searchTypeAll => 'Tutto';

  @override
  String get searchTypeMessages => 'Messaggi';

  @override
  String get searchTypeMedia => 'Media';

  @override
  String get searchTypeUsers => 'Utenti';

  @override
  String get periodLabel => 'Periodo';

  @override
  String get fromDate => 'Da';

  @override
  String get toDate => 'A';

  @override
  String get searchButton => 'Cerca';

  @override
  String resultsCount(int count) {
    return 'Risultati ($count)';
  }

  @override
  String get noResultsFound => 'Nessun risultato trovato';

  @override
  String get forgotPasswordTitle => 'Recupera password';

  @override
  String get forgotPasswordDescription => 'Inserisci l\'email per ricevere il link di reimpostazione';

  @override
  String get sendResetButton => 'Invia';

  @override
  String get forgotPasswordUnavailable => 'Recupero password non disponibile';

  @override
  String get changeEmailTitle => 'Cambia email';

  @override
  String get changeEmailDescription => 'Inserisci un nuovo indirizzo email';

  @override
  String get currentPrefix => 'Attuale: ';

  @override
  String get newEmailLabel => 'Nuova email';

  @override
  String get changeEmailButton => 'Cambia email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get emailUnchanged => 'New email is the same as current';

  @override
  String get changeEmailNotYetSupported => 'Email change is not yet supported';

  @override
  String get changeEmailNotAvailable => 'Email change is not yet available. Please contact support.';

  @override
  String get changeEmailRequiresServerSupport => 'This feature requires server-side support. The client is prepared but awaits protocol updates.';

  @override
  String get emailHintExample => 'user@example.com';

  @override
  String changeEmailError(String error) {
    return 'Impossibile cambiare email: $error';
  }

  @override
  String get changePhoneTitle => 'Cambia numero di telefono';

  @override
  String get changePhoneDescription => 'Inserisci un nuovo numero di telefono e la password attuale.';

  @override
  String get newPhoneLabel => 'Nuovo numero (+39...)';

  @override
  String get currentPasswordOptional => 'Password attuale (se necessario)';

  @override
  String get changePhoneButton => 'Cambia numero';

  @override
  String get phoneCannotBeChanged => 'Il numero di telefono non può essere modificato';

  @override
  String get emailCannotBeChanged => 'L\'email non può essere cambiata';

  @override
  String changePhoneError(String error) {
    return 'Impossibile cambiare il numero: $error';
  }

  @override
  String get confirmCodeTitle => 'Conferma codice';

  @override
  String codeSentTo(String phone) {
    return 'Abbiamo inviato un codice a $phone';
  }

  @override
  String get enterCodeHint => 'Inserisci codice';

  @override
  String get confirmButton => 'Conferma';

  @override
  String resendCountdown(int seconds) {
    return 'Reinvia tra $seconds s';
  }

  @override
  String get resendCodeButton => 'Reinvia codice';

  @override
  String get biometricSetupTitle => 'Sicurezza';

  @override
  String get authMethodsLabel => 'Metodi di autenticazione';

  @override
  String get biometricAuthLabel => 'Autenticazione del dispositivo';

  @override
  String get biometricAuthSubtitle => 'Face ID, impronta o codice del dispositivo';

  @override
  String get biometricEnabledLabel => 'Blocco app attivo';

  @override
  String get aboutSecurityLabel => 'Informazioni sulla sicurezza';

  @override
  String get aboutSecurityContent => 'TwoSpace usa il metodo di sblocco già configurato su questo dispositivo e lo richiede quando torni nell\'app.';

  @override
  String get lockScreenFailedTitle => 'Impossibile verificare la tua identità';

  @override
  String get lockScreenFailedMessage => 'Riprova o esci dall\'account su questo dispositivo.';

  @override
  String get deviceAuthUnavailableMessage => 'Configura prima Face ID, impronta o un codice del dispositivo nelle impostazioni di sistema.';

  @override
  String get authMethodFaceId => 'Face ID';

  @override
  String get authMethodFingerprint => 'Impronta';

  @override
  String get authMethodBiometric => 'Biometria';

  @override
  String get authMethodDevicePasscode => 'Codice del dispositivo';

  @override
  String get setPinCode => 'Imposta codice PIN';

  @override
  String get updateAvailableTitle => 'Aggiornamento disponibile';

  @override
  String get updateHeroTitle => 'Release ready to install';

  @override
  String get updateHeroSubtitle => 'Review the release, verify its integrity, and move through installation with a clear step-by-step flow.';

  @override
  String get updateStatusRequired => 'Required';

  @override
  String get updateStatusRecommended => 'Recommended';

  @override
  String get updatePipelineTitle => 'Update pipeline';

  @override
  String get updatePipelineSubtitle => 'Each stage exposes what is happening now and what comes next.';

  @override
  String get updateStageDownloadTitle => 'Download package';

  @override
  String get updateStageDownloadSubtitle => 'Fetch the installer package to local storage.';

  @override
  String get updateStageVerifyTitle => 'Verify integrity';

  @override
  String get updateStageVerifySubtitle => 'Check the downloaded file against the published SHA-256 digest.';

  @override
  String get updateStageInstallTitle => 'Install release';

  @override
  String get updateStageInstallSubtitle => 'Request permission if needed and hand the package to the system installer.';

  @override
  String get releaseSummaryTitle => 'Release summary';

  @override
  String get releaseSummarySubtitle => 'Important changes are grouped to make scanning faster than reading a raw changelog.';

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
  String get updateTrustSubtitle => 'See where the package comes from, how it is verified, and what build you are about to install.';

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
  String get updatePreviewModeTitle => 'Preview release card';

  @override
  String get updatePreviewModeSubtitle => 'This entry was opened from the debug catalog, so it shows a styled placeholder instead of real release notes.';

  @override
  String get updatePreviewModeEmptyNotes => 'Preview notes were not provided for this mock release.';

  @override
  String get updateCurrentVersionLabel => 'Current';

  @override
  String get updateIncomingVersionLabel => 'Incoming';

  @override
  String get whatsNewLabel => 'Novità';

  @override
  String get noUpdateDescription => 'Nessuna descrizione';

  @override
  String downloadingProgress(int percent) {
    return 'Scaricamento... $percent%';
  }

  @override
  String get checkingIntegrity => 'Verifica integrità...';

  @override
  String get requestingInstall => 'Richiesta installazione...';

  @override
  String get updateMandatory => 'Aggiornamento obbligatorio';

  @override
  String get laterButton => 'Dopo';

  @override
  String get downloadingLabel => 'Scaricamento...';

  @override
  String get installingLabel => 'Installazione...';

  @override
  String get updateButton => 'Aggiorna';

  @override
  String get downloadFailed => 'Impossibile scaricare l\'aggiornamento';

  @override
  String get integrityCheckFailed => 'Il file scaricato non ha superato il controllo di integrità (sha256)';

  @override
  String get installPermissionTitle => 'Permesso di installazione';

  @override
  String get installPermissionContent => 'Consenti l\'installazione da fonti sconosciute.';

  @override
  String get installPermissionRequired => 'Permesso di installazione richiesto';

  @override
  String get installFailed => 'Installazione non riuscita';

  @override
  String get ssoFeatureRequired => 'Questa funzione richiede la configurazione di webview_flutter';

  @override
  String ssoLoginVia(String idpId) {
    return 'Accesso SSO tramite $idpId';
  }

  @override
  String get forwardMessageTitle => 'Inoltra messaggio';

  @override
  String get searchChatHint => 'Cerca chat...';

  @override
  String forwardButton(int count) {
    return 'Inoltra ($count)';
  }

  @override
  String get roomAvatarUpdated => 'Avatar stanza aggiornato';

  @override
  String roomAvatarUploadError(String error) {
    return 'Errore caricamento avatar: $error';
  }

  @override
  String get roomSettingsSaved => 'Impostazioni stanza salvate';

  @override
  String roomSettingsSaveError(String error) {
    return 'Errore salvataggio: $error';
  }

  @override
  String get uploadAvatarButton => 'Carica avatar';

  @override
  String loadMembersError(String error) {
    return 'Errore caricamento membri: $error';
  }

  @override
  String get leaveRoomTitle => 'Abbandonare la stanza?';

  @override
  String get leaveRoomContent => 'Non potrai tornare senza essere nuovamente invitato.';

  @override
  String get leaveAction => 'Abbandona';

  @override
  String get leftRoom => 'Hai abbandonato la stanza';

  @override
  String leaveRoomError(String error) {
    return 'Errore nell\'abbandono: $error';
  }

  @override
  String get reportNotImplemented => 'Funzione di segnalazione non ancora implementata';

  @override
  String get featureInDevelopmentLabel => 'In sviluppo';

  @override
  String featureInDevelopmentMessage(String feature) {
    return 'Questa funzione è ancora in fase di sviluppo e sarà disponibile in una delle prossime versioni.';
  }

  @override
  String get inviteAction => 'Invita';

  @override
  String get threadsLabel => 'Thread';

  @override
  String get pinnedLabel => 'Fissati';

  @override
  String get filesLabel => 'File';

  @override
  String get noSharedFiles => 'Nessun file condiviso per ora';

  @override
  String get mediaLabel => 'Media';

  @override
  String get noSharedMedia => 'Nessun contenuto multimediale condiviso per ora';

  @override
  String get extensionsLabel => 'Estensioni';

  @override
  String get copyLinkAction => 'Copia link';

  @override
  String get pollsLabel => 'Sondaggi';

  @override
  String get exportChatAction => 'Esporta chat';

  @override
  String get reportAction => 'Segnala';

  @override
  String get leaveRoomAction => 'Abbandona stanza';

  @override
  String roomTitle(String name) {
    return 'Stanza — $name';
  }

  @override
  String get roomSettingsLabel => 'Impostazioni stanza';

  @override
  String authError(String error) {
    return 'Errore autenticazione: $error';
  }

  @override
  String get loginRequired => 'Accesso richiesto';

  @override
  String get loginRequiredContent => 'Devi essere connesso per cercare contatti. Vai all\'accesso?';

  @override
  String get loginAction => 'Accedi';

  @override
  String searchError(String error) {
    return 'Errore di ricerca: $error';
  }

  @override
  String get searchContactsTitle => 'Cerca contatti';

  @override
  String get nicknameOrPhoneHint => 'Soprannome o numero di telefono';

  @override
  String selectContactError(String error) {
    return 'Impossibile selezionare il contatto: $error';
  }

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get feedbackCategoryFeatures => 'Funzionalità';

  @override
  String get feedbackCategoryPerformance => 'Prestazioni';

  @override
  String get feedbackCategorySecurity => 'Sicurezza/Privacy';

  @override
  String get feedbackCategoryNetworkSync => 'Sync/Rete';

  @override
  String get shortDescriptionLabel => 'Descrizione breve';

  @override
  String get shortDescriptionHint => 'Es. \"Backup chat nel cloud\"';

  @override
  String get feedbackValidation => 'Seleziona almeno un\'idea o scrivi una descrizione';

  @override
  String get detailsOptionalLabel => 'Dettagli (opzionale)';

  @override
  String get detailsHint => 'Cosa dovrebbe funzionare, come funziona ora e come lo vorresti?';

  @override
  String get bigFeaturesTitle => 'Funzionalità principali (seleziona cosa ti interessa di più)';

  @override
  String get feedbackE2E => 'Cifratura E2E end-to-end (Olm/Megolm) + verifica dispositivi';

  @override
  String get feedbackBackup => 'Backup chat (locale/cloud) + trasferimento su nuovo dispositivo';

  @override
  String get feedbackThreads => 'Thread, reazioni, menzioni, ricerca messaggi migliorata';

  @override
  String get feedbackCalls => 'Chiamate vocali/video e stanze vocali rapide';

  @override
  String get feedbackFolders => 'Cartelle/categorie chat e filtri notifiche intelligenti';

  @override
  String get feedbackBots => 'Bot e integrazioni (webhook, GitHub/Jira, promemoria)';

  @override
  String get feedbackSlowNet => 'Modalità \"internet lento\" + cache media aggressiva';

  @override
  String get startChatTitle => 'Avvia chat';

  @override
  String get startDirectChatSubtitle => 'Open a private conversation with one person';

  @override
  String get createRoomSubtitle => 'Gruppo privato o pubblico';

  @override
  String get inviteUserTitle => 'Invita utente';

  @override
  String get inviteUserSubtitle => 'Trova e scrivi a un utente';

  @override
  String get addParticipantAction => 'Add participant';

  @override
  String get selectedParticipantsTitle => 'Participants';

  @override
  String get groupParticipantsOptionalHint => 'Participants are optional. You can create the group now and invite people later.';

  @override
  String get joinByCodeTitle => 'Unisciti con codice';

  @override
  String get joinByCodeSubtitle => 'Unisciti a una stanza con un codice di invito';

  @override
  String get joinRoomAction => 'Join';

  @override
  String get subscribeAction => 'Subscribe';

  @override
  String get chatsSubtitle => 'Messaggi privati, gruppi e link di invito in un unico posto';

  @override
  String get chatsQuickStartTitle => 'Inizia qualcosa di nuovo';

  @override
  String get chatsRecentTitle => 'Chat recenti';

  @override
  String get joinLinkHint => 'Incolla un link di invito, un alias o un codice';

  @override
  String get publicAliasLabel => 'Public alias';

  @override
  String get publicAliasHint => 'Short public name without spaces, for example newsroom';

  @override
  String get channelPublicLinkHelper => 'This link will be used in search and invitations when the channel is public.';

  @override
  String get channelLinkFormatError => 'Use only Latin letters, digits, dots, underscores or hyphens.';

  @override
  String get inviteLinkReadyTitle => 'Invite link is ready';

  @override
  String get inviteLinkReadySubtitle => 'Share it now or keep it for later. Selected people will receive it in direct messages when possible.';

  @override
  String get openChatAction => 'Open chat';

  @override
  String get fontLabel => 'Font';

  @override
  String get pinCodeLabel => 'Codice PIN';

  @override
  String get pinCodeSubtitle => '4-6 cifre per la protezione';

  @override
  String get pinHint => 'PIN (4-6 cifre)';

  @override
  String get pinLengthError => 'Il PIN deve avere 4-6 cifre';

  @override
  String get pinSetSuccess => 'PIN impostato';

  @override
  String get cancelButton => 'Annulla';

  @override
  String get deleteButton => 'Elimina';

  @override
  String get closeButton => 'Chiudi';

  @override
  String get saveButton => 'Salva';

  @override
  String get sendButton => 'Invia';

  @override
  String get copyButton => 'Copia';

  @override
  String get shareButton => 'Condividi';

  @override
  String get settingsLabel => 'Impostazioni';

  @override
  String get feedbackCategoryUxDesign => 'UX/Design';

  @override
  String get feedbackShareSubject => 'TwoSpace — suggerimento';

  @override
  String get feedbackMessageHeader => 'TwoSpace — suggerimento/miglioramento';

  @override
  String feedbackVersion(String version) {
    return 'Versione: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return 'Categoria: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return 'Breve: $title';
  }

  @override
  String get feedbackWishList => 'Cosa sarebbe particolarmente ottimo:';

  @override
  String get feedbackDetailsLine => 'Dettagli:';

  @override
  String get circlesVisible => 'Cerchi visualizzati';

  @override
  String get circlesHidden => 'Cerchi nascosti';

  @override
  String get speedSlow => 'Lento';

  @override
  String get speedFast => 'Veloce';

  @override
  String get advancedSettingsLabel => 'Impostazioni avanzate';

  @override
  String get compactModeLabel => 'Modalità compatta';

  @override
  String get activeDeviceInfo => 'Android • Attivo';

  @override
  String stubPlaceholder(String key) {
    return 'Segnaposto — $key';
  }

  @override
  String loadMessagesError(String error) {
    return 'Errore nel caricamento dei messaggi: $error';
  }

  @override
  String get pinnedUpdated => 'Fissati aggiornati';

  @override
  String editError(String error) {
    return 'Errore di modifica: $error';
  }

  @override
  String get moreButton => 'Altro';

  @override
  String shareError(String error) {
    return 'Impossibile condividere: $error';
  }

  @override
  String sendError(String error) {
    return 'Errore di invio: $error';
  }

  @override
  String get voiceRecordingUnsupported => 'La registrazione vocale non è supportata su questa piattaforma';

  @override
  String get microphonePermissionRequired => 'Autorizzazione microfono richiesta';

  @override
  String genericError(String error) {
    return 'Errore: $error';
  }

  @override
  String get ownersLabel => '👑 Proprietari';

  @override
  String get administratorsLabel => '⚡ Amministratori';

  @override
  String get oneHour => '1 ora';

  @override
  String get oneDay => '1 giorno';

  @override
  String get sevenDays => '7 giorni';

  @override
  String get settingsThemeSelection => 'Theme';

  @override
  String get settingsNotificationNew => 'Notifications';

  @override
  String get settingsDoNotDisturb => 'Do Not Disturb';

  @override
  String get settingsSoundOptions => 'Sound Settings';

  @override
  String get notificationToneTitle => 'Notification sound';

  @override
  String get notificationToneSubtitle => 'Choose a local audio file for message and alert previews.';

  @override
  String get ringtoneTitle => 'Ringtone';

  @override
  String get ringtoneSubtitle => 'Use a separate local audio file for incoming call previews.';

  @override
  String get chooseSoundLabel => 'Choose file';

  @override
  String get playPreviewLabel => 'Play preview';

  @override
  String get stopPreviewLabel => 'Stop preview';

  @override
  String get customSoundNotSelected => 'No custom file selected yet.';

  @override
  String get clearCustomSoundLabel => 'Reset custom file';

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
  String get storageTotalLabel => 'Totale';

  @override
  String get storageSelectedLabel => 'Selected';

  @override
  String get storagePhotosLabel => 'Foto';

  @override
  String get storageVideosLabel => 'Video';

  @override
  String get storageCacheLabel => 'Cache';

  @override
  String get storageAppDataLabel => 'Dati app';

  @override
  String get storageCleanupTitle => 'Da pulire';

  @override
  String get storageCleanupSubtitle => 'Controlla cosa può essere rimosso in sicurezza.';

  @override
  String get storageAutoCleanTitle => 'Auto-clean';

  @override
  String get storageAutoCleanSubtitle => 'Run cleanup automatically on a schedule or when storage grows beyond the selected limit.';

  @override
  String get storageAutoCleanPeriodLabel => 'Cleanup period';

  @override
  String get storageAutoCleanPeriodDaily => 'Daily';

  @override
  String get storageAutoCleanPeriodWeekly => 'Weekly';

  @override
  String get storageAutoCleanPeriodMonthly => 'Monthly';

  @override
  String get storageAutoCleanThresholdLabel => 'Run instantly above';

  @override
  String get storageAutoCleanTypesLabel => 'Clear data types';

  @override
  String get storageAutoCleanStatusTitle => 'Automation status';

  @override
  String get storageAutoCleanStatusEnabled => 'Auto-clean is active and will run when the schedule arrives or the storage threshold is exceeded.';

  @override
  String get storageAutoCleanStatusDisabled => 'Auto-clean is off. Only manual cleanup will run until you enable it again.';

  @override
  String get storageAutoCleanLastRunLabel => 'Last run';

  @override
  String get storageAutoCleanLastRunNever => 'Never';

  @override
  String get storageAutoCleanSelectAll => 'Select all';

  @override
  String get storageAutoCleanSelectNone => 'Clear selection';

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
  String get peopleTitle => 'Persone';

  @override
  String get peopleSubtitle => 'Contatti, preferiti, ricerca e inviti in un unico posto';

  @override
  String get peopleQuickNewChat => 'Nuova chat';

  @override
  String get peopleQuickInvite => 'Invita';

  @override
  String get peopleQuickSync => 'Sincronizza';

  @override
  String get peopleSearchHint => 'Cerca per nome, nickname o telefono';

  @override
  String get peopleSegmentAll => 'Tutti';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => 'Rubrica';

  @override
  String get peopleSegmentRecent => 'Recenti';

  @override
  String get peopleLoading => 'Caricamento persone…';

  @override
  String get peopleNoPeopleTitle => 'Ancora nessuna persona';

  @override
  String get peopleNoPeopleMessage => 'Qui appariranno i tuoi preferiti, le conversazioni recenti e i contatti.';

  @override
  String get peoplePermissionCardTitle => 'Accesso ai contatti limitato';

  @override
  String get peoplePermissionCardMessage => 'Consenti l’accesso ai contatti per mostrare la rubrica e invitare le persone più velocemente.';

  @override
  String get peoplePermissionCardMessageSettings => 'Abilita l’accesso ai contatti nelle impostazioni di sistema per ripristinare la sezione rubrica.';

  @override
  String get peopleFavoritesFrequentTitle => 'Preferiti e frequenti';

  @override
  String get peopleRecentTitle => 'Persone recenti';

  @override
  String get peopleTwoSpaceTitle => 'Persone su TwoSpace';

  @override
  String get peopleInviteTitle => 'Non è ancora su TwoSpace';

  @override
  String get peopleInviteSubtitle => 'Invita questo contatto su TwoSpace';

  @override
  String get peopleSearching => 'Ricerca persone…';

  @override
  String get peopleSearchRemoteTitle => 'Risultati TwoSpace';

  @override
  String get peopleSearchLocalTitle => 'Recenti e salvati';

  @override
  String get peopleSearchInviteTitle => 'Invita dalla rubrica';

  @override
  String get peopleSearchEmptyTitle => 'Nessuna persona trovata';

  @override
  String get peopleSearchEmptyMessage => 'Prova un altro nome, nickname o numero di telefono.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => 'Nessun dettaglio aggiuntivo per ora';

  @override
  String get peopleInviteShareText => 'Unisciti a me su TwoSpace, un messenger sicuro per chat e chiamate.';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return 'Unisciti a me su TwoSpace, $personName: chattiamo e chiamiamoci in modo sicuro.';
  }

  @override
  String get peopleViewProfileAction => 'Apri profilo';

  @override
  String get peopleRemoveFavoriteAction => 'Rimuovi dai preferiti';

  @override
  String get peopleAddFavoriteAction => 'Aggiungi ai preferiti';

  @override
  String get callsSubtitle => 'Chiamate recenti, richiamo rapido e cronologia centrata sulle persone';

  @override
  String get widgetsSubtitle => 'Home, lock-screen, and glanceable surfaces for your conversations';

  @override
  String get widgetsComingTitle => 'Widgets are on the way';

  @override
  String get widgetsComingBody => 'We are preparing flexible widget layouts for quick actions, unread counters, and compact conversation previews.';

  @override
  String get callsStartCallAction => 'Avvia chiamata';

  @override
  String get callsQuickStartTitle => 'Chiama ora';

  @override
  String get callsQuickStartSubtitle => 'Apri Persone, cerca qualcuno e avvia una chiamata vocale o video sicura.';

  @override
  String get callsSearchHint => 'Cerca nella cronologia chiamate';

  @override
  String get callsVideoFilter => 'Video';

  @override
  String get callsTopContactsTitle => 'Contatti frequenti';

  @override
  String get callsLoadingLabel => 'Caricamento chiamate…';

  @override
  String get callsEmptyTitle => 'Nessuna chiamata per ora';

  @override
  String get callsEmptyMessage => 'La cronologia chiamate apparirà qui dopo la tua prima chiamata vocale o video.';

  @override
  String get callsEmptySearchMessage => 'Nessuna chiamata corrisponde alla ricerca o al filtro corrente.';

  @override
  String get callsTodaySection => 'Oggi';

  @override
  String get callsThisWeekSection => 'Questa settimana';

  @override
  String get callsEarlierSection => 'Prima';

  @override
  String callsThreadCount(int count) {
    return '$count chiamate';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count perse';
  }

  @override
  String get callsMuteAction => 'Muto';

  @override
  String get callsSpeakerAction => 'Altoparlante';

  @override
  String get callsCameraAction => 'Fotocamera';

  @override
  String get callsSwitchCameraAction => 'Cambia';

  @override
  String get callsEndAction => 'Termina chiamata';

  @override
  String get callsConnectingLabel => 'Connessione…';

  @override
  String get callsRingingLabel => 'Sta squillando…';

  @override
  String get callsConnectingDetail => 'Creazione di una sessione di chiamata sicura.';

  @override
  String get callsRingingDetail => 'In attesa che l’altra persona risponda.';

  @override
  String get callsVideoSecureDetail => 'Il video è protetto e instradato tramite la sessione sicura corrente.';

  @override
  String get callsVoiceSecureDetail => 'La voce è protetta e instradata tramite la sessione sicura corrente.';

  @override
  String get timestampPrecisionLabel => 'Precisione orario dei messaggi';

  @override
  String get timestampPrecisionSubtitle => 'Scegli quanto dettaglio mostrare nell\'orario dei messaggi.';

  @override
  String get timestampPrecisionMinutes => 'Ore e minuti';

  @override
  String get timestampPrecisionSeconds => 'Ore, minuti e secondi';

  @override
  String get timestampPrecisionMilliseconds => 'Ore, minuti, secondi e millisecondi';

  @override
  String get startupTitle => 'Preparazione di TwoSpace';

  @override
  String get startupSubtitle => 'Controllo della sessione protetta e apertura delle tue chat.';

  @override
  String get startupFooter => 'Questa schermata viene mostrata solo durante l\'avvio dell\'app.';

  @override
  String get startupStepEnvironment => 'Caricamento configurazione';

  @override
  String get startupStepDiagnostics => 'Avvio diagnostica';

  @override
  String get startupStepValidation => 'Verifica ambiente';

  @override
  String get startupStepSettings => 'Caricamento impostazioni';

  @override
  String get startupStepSession => 'Ripristino sessione protetta';

  @override
  String get startupStepLaunch => 'Avvio applicazione';

  @override
  String get callsDemoBannerTitle => 'Esempio, funzionalità non operativa';

  @override
  String get callsDemoBannerVoiceMessage => 'Le chiamate vocali sono mostrate solo come prototipo visivo. Il trasporto audio non è ancora collegato.';

  @override
  String get callsDemoBannerVideoMessage => 'Le videochiamate sono mostrate solo come prototipo visivo. Il flusso remoto non è disponibile, ma l\'anteprima locale della fotocamera funziona.';

  @override
  String get callsCameraPermissionMessage => 'Consenti l\'accesso alla fotocamera per mostrare l\'anteprima locale durante una videochiamata.';

  @override
  String get callsCameraPermissionSettingsMessage => 'L\'accesso alla fotocamera è bloccato. Apri le impostazioni di sistema per attivare l\'anteprima video locale.';

  @override
  String get callsCameraPermissionAction => 'Consenti fotocamera';

  @override
  String get callsCameraUnavailableTitle => 'Fotocamera non disponibile';

  @override
  String get callsCameraUnavailableMessage => 'Non è stato possibile avviare l\'anteprima locale della fotocamera su questo dispositivo.';

  @override
  String get callsCameraUnsupportedMessage => 'Questa piattaforma non supporta l\'anteprima video locale.';

  @override
  String get callsCameraOffMessage => 'L\'anteprima della fotocamera è disattivata per questa chiamata dimostrativa.';

  @override
  String get callsFrontCameraLabel => 'Fotocamera anteriore';

  @override
  String get callsRearCameraLabel => 'Fotocamera posteriore';

  @override
  String get backgroundOptimizationDisabledTitle => 'Gli effetti di sfondo sono stati semplificati';

  @override
  String get backgroundOptimizationDisabledMessage => 'TwoSpace ha rilevato rallentamenti costanti dei frame e ha disattivato gli effetti di sfondo più pesanti per mantenere fluido lo scorrimento e l\'uso delle chat.';

  @override
  String get backgroundOptimizationOpenSettings => 'Apri le impostazioni dell\'aspetto';

  @override
  String get roomJoinRuleLabel => 'Chi può partecipare';

  @override
  String get roomJoinRulePublic => 'Aperta a tutti';

  @override
  String get roomJoinRulePublicDescription => 'Chiunque può trovare ed entrare in questa stanza.';

  @override
  String get roomJoinRuleInviteOnly => 'Solo su invito';

  @override
  String get roomJoinRuleInviteOnlyDescription => 'Solo gli utenti invitati possono entrare in questa stanza.';

  @override
  String get roomJoinRuleApproval => 'Approvazione richiesta';

  @override
  String get roomJoinRuleApprovalDescription => 'Gli utenti possono richiedere l\'accesso e devono essere approvati prima di entrare.';

  @override
  String get roomHistoryVisibilityLabel => 'Chi può vedere la cronologia';

  @override
  String get roomHistoryVisibilityWorldReadable => 'Tutti';

  @override
  String get roomHistoryVisibilityWorldReadableDescription => 'Chiunque può vedere i messaggi precedenti.';

  @override
  String get roomHistoryVisibilityJoined => 'Membri entrati';

  @override
  String get roomHistoryVisibilityJoinedDescription => 'Solo i membri che hanno già aderito possono vedere i messaggi precedenti.';

  @override
  String get roomHistoryVisibilityInvited => 'Solo utenti invitati';

  @override
  String get roomHistoryVisibilityInvitedDescription => 'Solo gli utenti invitati possono vedere i messaggi precedenti.';

  @override
  String get loginUsernameOnlyError => 'Usa il tuo nome utente TwoSpace per accedere.';

  @override
  String get twoFactorInvalidCodeMessage => 'Il codice 2FA o la frase di recupero non sono validi. Riprova.';

  @override
  String get twoFactorCodeRequiredMessage => 'Inserisci un codice dalla tua app di autenticazione oppure usa la frase di recupero.';

  @override
  String get twoFactorEnabledMessage => 'L\'autenticazione a due fattori è attiva.';

  @override
  String twoFactorEnableFailed(String error) {
    return 'Impossibile attivare 2FA: $error';
  }

  @override
  String get twoFactorSetupTitle => 'Configura l\'autenticazione a due fattori';

  @override
  String get twoFactorSetupDescription => 'Scansiona il codice QR nella tua app di autenticazione, salva la frase di recupero e poi conferma con un codice TOTP aggiornato.';

  @override
  String get twoFactorSecretTitle => 'Oppure inserisci manualmente questa chiave segreta';

  @override
  String get twoFactorRecoveryPhraseTitle => 'Frase di recupero. Salvala in un luogo sicuro prima di attivare la 2FA.';

  @override
  String get twoFactorVerificationCodeLabel => 'Codice di verifica';

  @override
  String get twoFactorVerificationCodeHint => 'Inserisci il codice attuale della tua app di autenticazione';

  @override
  String get twoFactorVerifyEnableAction => 'Verifica e attiva 2FA';

  @override
  String get twoFactorDisableSectionTitle => 'Disattiva autenticazione a due fattori';

  @override
  String get twoFactorDisableSectionDescription => 'Disattiva la 2FA con un codice valido dell\'autenticatore o con la tua frase di recupero monouso.';

  @override
  String get twoFactorDisableCodeHint => 'Inserisci un codice attuale dell\'autenticatore';

  @override
  String get twoFactorRecoveryPhraseFieldLabel => 'Frase di recupero';

  @override
  String get twoFactorRecoveryPhraseFieldHint => 'Incolla la frase di recupero se non hai più accesso all\'app di autenticazione';

  @override
  String get twoFactorDisableAction => 'Disattiva 2FA';

  @override
  String get twoFactorDisableCredentialsRequired => 'Inserisci un codice dell\'autenticatore o una frase di recupero per disattivare la 2FA.';

  @override
  String get twoFactorDisabledMessage => 'L\'autenticazione a due fattori è disattivata.';

  @override
  String twoFactorDisableFailed(String error) {
    return 'Impossibile disattivare 2FA: $error';
  }

  @override
  String get twoFactorLoginRecoveryHint => 'Oppure incolla la frase di recupero invece del codice';

  @override
  String get chatListTimeoutTitle => 'The server is taking too long to respond';

  @override
  String chatListTimeoutMessage(String error) {
    return 'Saved chats are still available. Try refreshing again.\n$error';
  }

  @override
  String get chatListOfflineTitle => 'No connection to the server';

  @override
  String chatListOfflineMessage(String error) {
    return 'Your local cache is still available. The list will refresh automatically when the connection returns.\n$error';
  }

  @override
  String get groupAvatarTitle => 'Group avatar';

  @override
  String get groupAvatarSubtitle => 'You can add an avatar right when creating the group.';

  @override
  String get chooseFileButton => 'Choose file';

  @override
  String get groupHistoryTitle => 'Keep history for new members';

  @override
  String get fileAccessDeniedMessage => 'Access to the selected file is blocked.';

  @override
  String get avatarFileAccessDeniedMessage => 'Access to the avatar file is blocked. Try another file.';

  @override
  String get profileEmptySelfHint => 'Your profile is still sparse. Add a name, bio, or location so it looks complete.';

  @override
  String get profileEmptyOtherHint => 'This user has not filled out their profile yet, or the server did not return the detailed fields.';

  @override
  String get twoFactorDisableConfirmContent => 'Disable two-factor authentication for this account? You will need to set it up again to restore extra protection.';

  @override
  String get betaTestLabel => 'Beta test';

  @override
  String get homeBetaWelcomeTitle => 'Welcome to the TwoSpace beta test';

  @override
  String get homeBetaWelcomeBody => 'Features may change often. Send us your suggestions.';

  @override
  String get devMenuInfoLoading => 'Collecting device information…';

  @override
  String get devMenuAppNameLabel => 'App name';

  @override
  String get devMenuVersionLabel => 'Version';

  @override
  String get devMenuPackageNameLabel => 'Package name';

  @override
  String get devMenuDeviceLabel => 'Device';

  @override
  String get authRegisterVerifyEmailBeforeLogin => 'Registration is complete. Verify your email before signing in.';

  @override
  String authRegisterAutoLoginFailed(Object error) {
    return 'Account created, but automatic sign-in failed: $error';
  }

  @override
  String get authProfileUpdateFailed => 'Failed to update profile';

  @override
  String get authAvatarUpdateFailed => 'Failed to update avatar';

  @override
  String get authLoginAppCredentialsRejected => 'The server rejected the app credentials. Check server configuration or handshake compatibility.';

  @override
  String get authSessionTokenMissing => 'The server did not return a session token';

  @override
  String get authTotpSetupFailed => 'Failed to prepare two-factor authentication';

  @override
  String get authTotpDisableFailed => 'Failed to disable two-factor authentication';

  @override
  String get authTotpVerifyFailed => 'Failed to verify two-factor authentication';

  @override
  String get authSessionsLoadFailed => 'Failed to load active sessions';

  @override
  String get authSessionsRevokeFailed => 'Failed to end the session';

  @override
  String get authRegisterNotLoggedIn => 'Registration completed, but sign-in was not completed';

  @override
  String get devMenuTitle => 'Developer menu';

  @override
  String get devMenuTabActions => 'Actions';

  @override
  String get devMenuTabUiInspect => 'UI inspect';

  @override
  String get devMenuTabLogs => 'Logs';

  @override
  String get devMenuTabNetwork => 'Network';

  @override
  String get devMenuTabFeatures => 'Features';

  @override
  String get devMenuTabInfo => 'Info';

  @override
  String get devMenuLogsEmptyTitle => 'No application logs yet';

  @override
  String get devMenuLogsEmptyMessage => 'Open the problematic screen or repeat the action. New records will appear here.';

  @override
  String get devMenuShowAll => 'Show all';

  @override
  String get devMenuOnlyErrors => 'Only errors';

  @override
  String devMenuAllEntries(Object count) {
    return 'All entries ($count)';
  }

  @override
  String get devMenuClearAction => 'Clear';

  @override
  String get devMenuScreenExplorerTitle => 'Screen explorer';

  @override
  String get devMenuScreenSearchHint => 'Search by screen name, group, or file';

  @override
  String devMenuAllScreens(Object count) {
    return 'All ($count)';
  }

  @override
  String get devMenuScreensNotFoundTitle => 'Screens not found';

  @override
  String get devMenuScreensNotFoundMessage => 'Change the search query or clear the group filter.';

  @override
  String get devMenuUtilitiesTitle => 'Utilities';

  @override
  String get devMenuForceCrash => 'Force crash';

  @override
  String get devMenuClearSecureStorage => 'Clear secure storage';

  @override
  String get devMenuClearCacheProfile => 'Clear profile cache';

  @override
  String get devMenuCheckOta => 'Check OTA';

  @override
  String get devMenuOpenScreen => 'Open screen';

  @override
  String get devMenuShowBounds => 'Show bounds (debugPaintSize)';

  @override
  String get devMenuShowBoundsSubtitle => 'Displays paddings and borders of all widgets';

  @override
  String get devMenuRepaintRainbow => 'Highlight repaints (RepaintRainbow)';

  @override
  String get devMenuRepaintRainbowSubtitle => 'Highlights elements that are being repainted';

  @override
  String get devMenuSlowAnimations => 'Slow animations (timeDilation = 5.0)';

  @override
  String get devMenuSlowAnimationsSubtitle => 'Slows down all animations in the app';

  @override
  String get devMenuPerformanceOverlay => 'Performance profiling';

  @override
  String get devMenuPerformanceOverlaySubtitle => 'Shows the Performance Overlay on top of the app';

  @override
  String get devMenuSensitiveDialogTitle => 'Sensitive data visibility';

  @override
  String get devMenuSensitiveDialogMessage => 'After enabling this option, new debug and network logs may contain tokens, keys, and other secrets in plain text. Existing records will not change. Continue?';

  @override
  String get devMenuEnable => 'Enable';

  @override
  String get devMenuSensitiveEnableDescription => 'Keys, tokens, and passwords are masked by default. This switch affects only new logs.';

  @override
  String get devMenuSensitiveDisabledDescription => 'Sensitive data is always hidden in this build.';

  @override
  String get devMenuRevealSensitiveData => 'Show sensitive data in new logs';

  @override
  String get devMenuFlagNewChatUi => 'Enable new chat UI';

  @override
  String get devMenuFlagForceVideoCompression => 'Force video compression';

  @override
  String get devMenuFlagAggressiveCaching => 'Enable aggressive caching';

  @override
  String get devMenuFlagIgnoreServerOffline => 'Ignore server offline state';

  @override
  String get devMenuFlagIgnoreServerOfflineSubtitle => 'Keeps the current session and avoids returning to the sign-in screen when the server is unavailable.';

  @override
  String get devMenuReleaseHiddenTitle => 'Sensitive data is hidden';

  @override
  String get devMenuReleaseHiddenSubtitle => 'Public release and profile builds always show debug data only in masked form.';

  @override
  String get devMenuNetworkEmptyTitle => 'No network logs yet';

  @override
  String get devMenuNetworkEmptyMessage => 'Open any screen that performs requests and logs will appear here.';

  @override
  String devMenuAllRequests(Object count) {
    return 'All requests ($count)';
  }

  @override
  String get devMenuNetworkProblemDetected => 'problem detected';

  @override
  String get devMenuNetworkCompleted => 'completed';

  @override
  String get devMenuRequestHeaders => 'Request headers';

  @override
  String devMenuRequestBody(Object type) {
    return 'Request body · $type';
  }

  @override
  String get devMenuResponseHeaders => 'Response headers';

  @override
  String devMenuResponseBody(Object type) {
    return 'Response body · $type';
  }

  @override
  String devMenuVersionWithBuild(Object buildNumber, Object version) {
    return '$version (Build $buildNumber)';
  }

  @override
  String get notificationsInDevelopmentSubtitle => 'I controlli avanzati delle notifiche arriveranno in uno dei prossimi aggiornamenti.';

  @override
  String get devMenuCopyVisible => 'Copia elementi visibili';

  @override
  String get devMenuExportLogFile => 'Esporta file di log';

  @override
  String get devMenuNewestFirst => 'Più recenti prima';

  @override
  String get devMenuOldestFirst => 'Più vecchi prima';

  @override
  String get feedbackAttachLogsLabel => 'Allegare i log?';

  @override
  String get feedbackAttachLogsSubtitle => 'Aggiunge un file diagnostico con informazioni sul dispositivo, log dell\'applicazione e log di rete.';

  @override
  String get notificationsForegroundServiceTitle => 'Servizio in Background';

  @override
  String get notificationsForegroundServiceSubtitle => 'Mantieni l\'app in esecuzione in background';

  @override
  String get notificationsForegroundServiceEnabled => 'Abilita Servizio in Background';

  @override
  String get notificationsForegroundServiceDescription => 'Ascolta continuamente i messaggi con notifica persistente';

  @override
  String get notificationsTypesSection => 'Tipi di Notifiche';

  @override
  String get notificationsTypesSectionSubtitle => 'Scegli quali eventi ti notificano';

  @override
  String get notificationsMessagesTitle => 'Messaggi';

  @override
  String get notificationsMessagesDescription => 'Nuovi messaggi nelle chat';

  @override
  String get notificationsChatTitle => 'Chat e Gruppi';

  @override
  String get notificationsChatDescription => 'Nuove chat e inviti ai gruppi';

  @override
  String get notificationsPostTitle => 'Post';

  @override
  String get notificationsPostDescription => 'Nuovi post nei canali';

  @override
  String get notificationsReactionTitle => 'Reazioni';

  @override
  String get notificationsReactionDescription => 'Reazioni ai tuoi messaggi';

  @override
  String get imageTooLarge => 'Image too large';

  @override
  String get imageCompressed => 'Image was compressed to fit protocol limits';
}
