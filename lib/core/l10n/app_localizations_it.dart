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
  String get errorInitializationFull =>
      'Errore di inizializzazione. Riavviare l\'app.';

  @override
  String get errorNetwork => 'Errore di rete. Verificare la connessione.';

  @override
  String get errorAuth => 'Errore di autenticazione.';

  @override
  String get errorInvalidArguments => 'Argomenti non validi.';

  @override
  String get errorInvalidArgumentsProfile =>
      'Argomenti non validi per il profilo.';

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
  String get voiceNotSupported =>
      'Registrazione vocale non supportata su questa piattaforma';

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
  String get suggestImprovementSubtitle =>
      'Idee e richieste di nuove funzionalità';

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
  String get biometricSubtitle => 'Accedi con impronta digitale';

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
  String get deleteAccountContent =>
      'Sei sicuro di voler eliminare il tuo account? Questa azione è irreversibile.';

  @override
  String get deleteFeatureLater =>
      'L\'eliminazione dell\'account sarà disponibile in seguito';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get saveTooltip => 'Salva';

  @override
  String get editTooltip => 'Modifica';

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
  String get avatarUploadLater =>
      'Il caricamento avatar verrà aggiunto in seguito';

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
  String get hideLastSeenSubtitle =>
      'Gli altri non vedranno quando sei stato online';

  @override
  String get sessionExpiry => 'Scadenza sessione';

  @override
  String sessionExpirySubtitle(int days) {
    return 'Accesso automatico su questo dispositivo: $days giorni';
  }

  @override
  String get sessionExpiryDaysTitle => 'Scadenza sessione (giorni)';

  @override
  String get sessionExpiryDaysContent =>
      'Scegli il numero di giorni (min: 7, max: 365).';

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
  String get twoFactorPrivacySubtitle =>
      'Attiva o disattiva la protezione avanzata';

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
  String get contactsPermDeniedPermanent =>
      'Permesso negato definitivamente. Apri le impostazioni.';

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
  String get showHistorySubtitle =>
      'I nuovi membri possono vedere i messaggi precedenti';

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
  String get deleteGroupWarning =>
      'Questa azione è IRREVERSIBILE. Il gruppo verrà eliminato definitivamente.';

  @override
  String get confirmDeleteTitle => 'Conferma eliminazione';

  @override
  String get confirmDeleteContent =>
      'Sei sicuro? Questa azione è irreversibile.';

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
  String get directChatTab => 'Diretto';

  @override
  String get groupChatTab => 'Gruppo';

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
  String get contactIdExplanation =>
      'Puoi usare un nome utente o un ID Aegis numerico';

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
  String get colorsTab => 'Colori';

  @override
  String get fontsTab => 'Font';

  @override
  String get effectsTab => 'Effetti';

  @override
  String get selectColorTheme => 'Seleziona tema colore';

  @override
  String get themeAppliesEverywhere =>
      'Il tema selezionato viene applicato in tutta l\'app';

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
  String get forgotPasswordDescription =>
      'Inserisci l\'email per ricevere il link di reimpostazione';

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
  String changeEmailError(String error) {
    return 'Impossibile cambiare email: $error';
  }

  @override
  String get changePhoneTitle => 'Cambia numero di telefono';

  @override
  String get changePhoneDescription =>
      'Inserisci un nuovo numero di telefono e la password attuale.';

  @override
  String get newPhoneLabel => 'Nuovo numero (+39...)';

  @override
  String get currentPasswordOptional => 'Password attuale (se necessario)';

  @override
  String get changePhoneButton => 'Cambia numero';

  @override
  String get phoneCannotBeChanged =>
      'Il numero di telefono non può essere modificato';

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
  String get biometricAuthLabel => 'Autenticazione biometrica';

  @override
  String get biometricAuthSubtitle => 'Impronta digitale o Face ID';

  @override
  String get biometricEnabledLabel => 'Biometria abilitata';

  @override
  String get aboutSecurityLabel => 'Informazioni sulla sicurezza';

  @override
  String get aboutSecurityContent =>
      'Scegli un metodo di autenticazione comodo.';

  @override
  String get setPinCode => 'Imposta codice PIN';

  @override
  String get updateAvailableTitle => 'Aggiornamento disponibile';

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
  String get integrityCheckFailed =>
      'Il file scaricato non ha superato il controllo di integrità (sha256)';

  @override
  String get installPermissionTitle => 'Permesso di installazione';

  @override
  String get installPermissionContent =>
      'Consenti l\'installazione da fonti sconosciute.';

  @override
  String get installPermissionRequired => 'Permesso di installazione richiesto';

  @override
  String get installFailed => 'Installazione non riuscita';

  @override
  String get ssoFeatureRequired =>
      'Questa funzione richiede la configurazione di webview_flutter';

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
  String get leaveRoomContent =>
      'Non potrai tornare senza essere nuovamente invitato.';

  @override
  String get leaveAction => 'Abbandona';

  @override
  String get leftRoom => 'Hai abbandonato la stanza';

  @override
  String leaveRoomError(String error) {
    return 'Errore nell\'abbandono: $error';
  }

  @override
  String get reportNotImplemented =>
      'Funzione di segnalazione non ancora implementata';

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
  String get loginRequiredContent =>
      'Devi essere connesso per cercare contatti. Vai all\'accesso?';

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
  String get feedbackValidation =>
      'Seleziona almeno un\'idea o scrivi una descrizione';

  @override
  String get detailsOptionalLabel => 'Dettagli (opzionale)';

  @override
  String get detailsHint =>
      'Cosa dovrebbe funzionare, come funziona ora e come lo vorresti?';

  @override
  String get bigFeaturesTitle =>
      'Funzionalità principali (seleziona cosa ti interessa di più)';

  @override
  String get feedbackE2E =>
      'Cifratura E2E end-to-end (Olm/Megolm) + verifica dispositivi';

  @override
  String get feedbackBackup =>
      'Backup chat (locale/cloud) + trasferimento su nuovo dispositivo';

  @override
  String get feedbackThreads =>
      'Thread, reazioni, menzioni, ricerca messaggi migliorata';

  @override
  String get feedbackCalls => 'Chiamate vocali/video e stanze vocali rapide';

  @override
  String get feedbackFolders =>
      'Cartelle/categorie chat e filtri notifiche intelligenti';

  @override
  String get feedbackBots =>
      'Bot e integrazioni (webhook, GitHub/Jira, promemoria)';

  @override
  String get feedbackSlowNet =>
      'Modalità \"internet lento\" + cache media aggressiva';

  @override
  String get startChatTitle => 'Avvia chat';

  @override
  String get createRoomSubtitle => 'Gruppo privato o pubblico';

  @override
  String get inviteUserTitle => 'Invita utente';

  @override
  String get inviteUserSubtitle => 'Trova e scrivi a un utente';

  @override
  String get joinByCodeTitle => 'Unisciti con codice';

  @override
  String get joinByCodeSubtitle =>
      'Unisciti a una stanza con un codice di invito';

  @override
  String get chatsSubtitle =>
      'Messaggi privati, gruppi e link di invito in un unico posto';

  @override
  String get chatsQuickStartTitle => 'Inizia qualcosa di nuovo';

  @override
  String get chatsRecentTitle => 'Chat recenti';

  @override
  String get joinLinkHint => 'Incolla un link di invito, un alias o un codice';

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
  String get voiceRecordingUnsupported =>
      'La registrazione vocale non è supportata su questa piattaforma';

  @override
  String get microphonePermissionRequired =>
      'Autorizzazione microfono richiesta';

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
  String get settingsStorageManagement => 'Storage Management';

  @override
  String get settingsStorageUsage => 'Storage Usage';

  @override
  String get settingsStorageAppSize => 'App Size';

  @override
  String get settingsStorageClearBtn => 'Clear Selected';

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
  String get peopleSubtitle =>
      'Contatti, preferiti, ricerca e inviti in un unico posto';

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
  String get peopleNoPeopleMessage =>
      'Qui appariranno i tuoi preferiti, le conversazioni recenti e i contatti.';

  @override
  String get peoplePermissionCardTitle => 'Accesso ai contatti limitato';

  @override
  String get peoplePermissionCardMessage =>
      'Consenti l’accesso ai contatti per mostrare la rubrica e invitare le persone più velocemente.';

  @override
  String get peoplePermissionCardMessageSettings =>
      'Abilita l’accesso ai contatti nelle impostazioni di sistema per ripristinare la sezione rubrica.';

  @override
  String get peopleFavoritesFrequentTitle => 'Preferiti e frequenti';

  @override
  String get peopleRecentTitle => 'Persone recenti';

  @override
  String get peopleTwoSpaceTitle => 'Persone su TwoSpace';

  @override
  String get peopleInviteTitle => 'Invita su TwoSpace';

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
  String get peopleSearchEmptyMessage =>
      'Prova un altro nome, nickname o numero di telefono.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => 'Nessun dettaglio aggiuntivo per ora';

  @override
  String get peopleInviteShareText =>
      'Unisciti a me su TwoSpace, un messenger sicuro per chat e chiamate.';

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
  String get callsSubtitle =>
      'Chiamate recenti, richiamo rapido e cronologia centrata sulle persone';

  @override
  String get callsStartCallAction => 'Avvia chiamata';

  @override
  String get callsQuickStartTitle => 'Chiama ora';

  @override
  String get callsQuickStartSubtitle =>
      'Apri Persone, cerca qualcuno e avvia una chiamata vocale o video sicura.';

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
  String get callsEmptyMessage =>
      'La cronologia chiamate apparirà qui dopo la tua prima chiamata vocale o video.';

  @override
  String get callsEmptySearchMessage =>
      'Nessuna chiamata corrisponde alla ricerca o al filtro corrente.';

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
  String get callsConnectingDetail =>
      'Creazione di una sessione di chiamata sicura.';

  @override
  String get callsRingingDetail => 'In attesa che l’altra persona risponda.';

  @override
  String get callsVideoSecureDetail =>
      'Il video è protetto e instradato tramite la sessione sicura corrente.';

  @override
  String get callsVoiceSecureDetail =>
      'La voce è protetta e instradata tramite la sessione sicura corrente.';

  @override
  String get timestampPrecisionLabel => 'Precisione orario dei messaggi';

  @override
  String get timestampPrecisionSubtitle =>
      'Scegli quanto dettaglio mostrare nell\'orario dentro i chat e nell\'elenco chat.';

  @override
  String get timestampPrecisionMinutes => 'Ore e minuti';

  @override
  String get timestampPrecisionSeconds => 'Ore, minuti e secondi';

  @override
  String get timestampPrecisionMilliseconds =>
      'Ore, minuti, secondi e millisecondi';

  @override
  String get startupTitle => 'Preparazione di TwoSpace';

  @override
  String get startupSubtitle =>
      'Controllo della sessione protetta e apertura delle tue chat.';

  @override
  String get startupFooter =>
      'Questa schermata viene mostrata solo durante l\'avvio dell\'app.';

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
  String get callsDemoBannerVoiceMessage =>
      'Le chiamate vocali sono mostrate solo come prototipo visivo. Il trasporto audio non è ancora collegato.';

  @override
  String get callsDemoBannerVideoMessage =>
      'Le videochiamate sono mostrate solo come prototipo visivo. Il flusso remoto non è disponibile, ma l\'anteprima locale della fotocamera funziona.';

  @override
  String get callsCameraPermissionMessage =>
      'Consenti l\'accesso alla fotocamera per mostrare l\'anteprima locale durante una videochiamata.';

  @override
  String get callsCameraPermissionSettingsMessage =>
      'L\'accesso alla fotocamera è bloccato. Apri le impostazioni di sistema per attivare l\'anteprima video locale.';

  @override
  String get callsCameraPermissionAction => 'Consenti fotocamera';

  @override
  String get callsCameraUnavailableTitle => 'Fotocamera non disponibile';

  @override
  String get callsCameraUnavailableMessage =>
      'Non è stato possibile avviare l\'anteprima locale della fotocamera su questo dispositivo.';

  @override
  String get callsCameraUnsupportedMessage =>
      'Questa piattaforma non supporta l\'anteprima video locale.';

  @override
  String get callsCameraOffMessage =>
      'L\'anteprima della fotocamera è disattivata per questa chiamata dimostrativa.';

  @override
  String get callsFrontCameraLabel => 'Fotocamera anteriore';

  @override
  String get callsRearCameraLabel => 'Fotocamera posteriore';

  @override
  String get backgroundOptimizationDisabledTitle =>
      'Gli effetti di sfondo sono stati semplificati';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace ha rilevato rallentamenti costanti dei frame e ha disattivato gli effetti di sfondo più pesanti per mantenere fluido lo scorrimento e l\'uso delle chat.';

  @override
  String get backgroundOptimizationOpenSettings =>
      'Apri le impostazioni dell\'aspetto';
}
