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
  String get loading => 'Laden...';

  @override
  String get initializing => 'Initialisierung...';

  @override
  String get errorGeneric => 'Ein Fehler ist aufgetreten';

  @override
  String get errorInitialization => 'Initialisierungsfehler';

  @override
  String get errorInitializationFull =>
      'Initialisierungsfehler. Bitte starten Sie die App neu.';

  @override
  String get errorNetwork => 'Netzwerkfehler. Überprüfen Sie Ihre Verbindung.';

  @override
  String get errorAuth => 'Authentifizierungsfehler.';

  @override
  String get errorInvalidArguments => 'Ungültige Argumente.';

  @override
  String get errorInvalidArgumentsProfile =>
      'Ungültige Argumente für das Profil.';

  @override
  String get errorInvalidArgumentsChat => 'Ungültige Argumente für den Chat.';

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

  @override
  String errorWithDetail(String error) {
    return 'Fehler: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get done => 'Fertig';

  @override
  String get noData => 'Keine Daten';

  @override
  String get nothingFound => 'Nichts gefunden';

  @override
  String get copyAction => 'Kopieren';

  @override
  String get shareAction => 'Teilen';

  @override
  String get textCopied => 'Text kopiert';

  @override
  String get onlineLabel => 'Online';

  @override
  String get offlineLabel => 'Offline';

  @override
  String get userDefault => 'Benutzer';

  @override
  String get lessThanMinuteAgo => 'vor weniger als einer Minute';

  @override
  String minutesAgo(int count) {
    return 'Vor $count Min.';
  }

  @override
  String hoursAgo(int count) {
    return 'Vor $count Std.';
  }

  @override
  String daysAgo(int count) {
    return 'Vor $count Tagen';
  }

  @override
  String get videoLabel => 'Video';

  @override
  String videoLoadError(String error) {
    return 'Videofehler: $error';
  }

  @override
  String get saveFailed => 'Speichern fehlgeschlagen';

  @override
  String get shareSheetFailed => 'Freigabe nicht möglich';

  @override
  String get speedLabel => 'Geschwindigkeit:';

  @override
  String get previewTitle => 'Vorschau';

  @override
  String fileDownloaded(String path) {
    return 'Datei heruntergeladen: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return 'Datei temporär gespeichert: $path';
  }

  @override
  String get savedToGallery => 'In Galerie gespeichert';

  @override
  String authorizationError(String message) {
    return 'Autorisierungsfehler: $message';
  }

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get welcomeBack => 'Willkommen';

  @override
  String get emailOrUsernameLabel => 'E-Mail oder Benutzername';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get noAccount => 'Kein Konto?';

  @override
  String get orDivider => 'Oder';

  @override
  String get validationEnterEmailOrUsername =>
      'Bitte E-Mail oder Benutzername eingeben';

  @override
  String get validationEnterPassword => 'Bitte Passwort eingeben';

  @override
  String get registerTitle => 'Registrieren';

  @override
  String get fillAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String get passwordStrengthWeak => 'Schwach';

  @override
  String get passwordStrengthMedium => 'Mittel';

  @override
  String get passwordStrengthGood => 'Gut';

  @override
  String get passwordStrengthStrong => 'Stark';

  @override
  String get fullNameLabel => 'Vollständiger Name';

  @override
  String get nicknameAtLabel => 'Spitzname (@benutzername)';

  @override
  String get uploadPhotoPrompt => 'Profilbild hochladen';

  @override
  String get photoLooksGreat => 'Sieht super aus!';

  @override
  String get helpFriendsFind => 'Helfen Sie Freunden, Sie zu finden';

  @override
  String get setupInterfaceTitle => 'Oberfläche anpassen';

  @override
  String get colorThemeLabel => 'Farbthema';

  @override
  String get validationEnterEmail => 'Bitte E-Mail eingeben';

  @override
  String get validationInvalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get validationPasswordTooShort => 'Passwort zu kurz';

  @override
  String get backToLogin => 'Anmelden';

  @override
  String get finishButton => 'Fertigstellen';

  @override
  String filePickError(String error) {
    return 'Dateiauswahlfehler: $error';
  }

  @override
  String get chatsTitle => 'Chats';

  @override
  String get noChats => 'Keine Chats';

  @override
  String get noMessages => '(keine Nachrichten)';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String get messageInputHint => 'Nachricht schreiben...';

  @override
  String get replyAction => 'Antworten';

  @override
  String get editShort => 'Bearb.';

  @override
  String get pinAction => 'Anheften';

  @override
  String get moreReactions => 'Mehr';

  @override
  String get replyDialogTitle => 'Antworten';

  @override
  String get replyHint => 'Antworttext';

  @override
  String get editMessageTitle => 'Nachricht bearbeiten';

  @override
  String get editMessageHint => 'Neuer Text';

  @override
  String get deleteMessageTitle => 'Nachricht löschen?';

  @override
  String get pinsUpdated => 'Pins aktualisiert';

  @override
  String get messageEdited => 'Nachricht bearbeitet';

  @override
  String get fileSent => 'Datei gesendet';

  @override
  String get voiceNotSupported =>
      'Sprachaufnahme wird auf dieser Plattform nicht unterstützt';

  @override
  String get microphonePermRequired => 'Mikrofon-Berechtigung erforderlich';

  @override
  String get recordingError => 'Aufnahmefehler';

  @override
  String sendFailedError(String error) {
    return 'Senden fehlgeschlagen: $error';
  }

  @override
  String attachmentSendError(String error) {
    return 'Anhangfehler: $error';
  }

  @override
  String shareFailedError(String error) {
    return 'Teilen fehlgeschlagen: $error';
  }

  @override
  String replyError(String error) {
    return 'Antwortfehler: $error';
  }

  @override
  String pinError(String error) {
    return 'Pin-Fehler: $error';
  }

  @override
  String deleteError(String error) {
    return 'Löschfehler: $error';
  }

  @override
  String editMessageError(String error) {
    return 'Bearbeitungsfehler: $error';
  }

  @override
  String get userTyping => 'Benutzer tippt...';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusLastSeenRecently => 'Zuletzt kürzlich gesehen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get appearanceSection => 'Erscheinungsbild';

  @override
  String get themeLabel => 'Thema';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get customizationLabel => 'Anpassung';

  @override
  String get customizationSubtitle => 'Farben, Schrift und UI-Effekte';

  @override
  String get notificationsSection => 'Benachrichtigungen';

  @override
  String get notificationsLabel => 'Benachrichtigungen';

  @override
  String get soundLabel => 'Ton';

  @override
  String get accountSection => 'Konto';

  @override
  String get profileLabel => 'Profil';

  @override
  String get profileSubtitle => 'Profilinformationen bearbeiten';

  @override
  String get accountSettingsLabel => 'Kontoeinstellungen';

  @override
  String get accountSettingsSubtitle => 'Passwort, Sicherheit, 2FA';

  @override
  String get privacyLabel => 'Datenschutz';

  @override
  String get privacySubtitle => 'Datenschutz verwalten';

  @override
  String get generalSection => 'Allgemein';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get textSizeLabel => 'Textgröße';

  @override
  String get sendByEnterLabel => 'Per Enter senden';

  @override
  String get sendByEnterSubtitle => 'Shift+Enter für neue Zeile';

  @override
  String get dataStorageSection => 'Daten & Speicher';

  @override
  String get autoDownloadLabel => 'Medien automatisch laden';

  @override
  String get autoDownloadSubtitle =>
      'Fotos und Videos automatisch herunterladen';

  @override
  String get storageManagementLabel => 'Speicherverwaltung';

  @override
  String get storageManagementSubtitle => 'Cache und Daten löschen';

  @override
  String get clearCacheTitle => 'Cache leeren';

  @override
  String get clearCacheContent => 'Zwischengespeicherte Daten löschen?';

  @override
  String get cacheCleared => 'Cache geleert';

  @override
  String get developmentSection => 'Entwicklung';

  @override
  String get devMenuSubtitle => 'Schwebende Debug-Schaltfläche';

  @override
  String get aboutSection => 'Über';

  @override
  String get suggestImprovementLabel => 'Verbesserung vorschlagen';

  @override
  String get suggestImprovementSubtitle => 'Ideen und großen Funktionswünsche';

  @override
  String get dangerZoneSection => 'Gefahrenzone';

  @override
  String get logoutLabel => 'Abmelden';

  @override
  String get logoutSubtitle => 'Von diesem Gerät abmelden';

  @override
  String get logoutDialogTitle => 'Abmelden';

  @override
  String get logoutDialogContent =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get logoutAction => 'Abmelden';

  @override
  String get languageRussian => 'Russisch';

  @override
  String get languageUkrainian => 'Ukrainisch';

  @override
  String get matrixTooltip =>
      'Matrix ist ein offenes Protokoll für föderiertes Messaging';

  @override
  String get clientDescription => 'TwoSpace-Client mit Flutter/Dart erstellt';

  @override
  String errorLogout(String error) {
    return 'Fehler: $error';
  }

  @override
  String get accountSettingsTitle => 'Kontoeinstellungen';

  @override
  String get securitySection => 'Sicherheit';

  @override
  String get twoFactorLabel => 'Zwei-Faktor-Authentifizierung';

  @override
  String get twoFactorSubtitle => 'Zusätzlicher Kontoschutz';

  @override
  String get biometricLabel => 'Biometrie';

  @override
  String get biometricSubtitle => 'Mit Fingerabdruck anmelden';

  @override
  String get activeSessionsLabel => 'Aktive Sitzungen';

  @override
  String get activeSessionsSubtitle => 'Geräte verwalten';

  @override
  String get currentDevice => 'Aktuelles Gerät';

  @override
  String get changePasswordSection => 'Passwort ändern';

  @override
  String get currentPasswordLabel => 'Aktuelles Passwort';

  @override
  String get newPasswordLabel => 'Neues Passwort';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get minPasswordHelper => 'Mindestens 8 Zeichen';

  @override
  String get changePasswordButton => 'Passwort ändern';

  @override
  String get passwordMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordTooShort => 'Passwort muss mindestens 8 Zeichen haben';

  @override
  String get passwordChangeSuccess => 'Passwort erfolgreich geändert';

  @override
  String get contactDataSection => 'Kontaktdaten';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get deleteAccountLabel => 'Konto löschen';

  @override
  String get deleteAccountSubtitle => 'Unumkehrbare Aktion';

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String get deleteAccountContent =>
      'Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Diese Aktion ist unumkehrbar.';

  @override
  String get deleteFeatureLater => 'Kontolöschung wird später verfügbar sein';

  @override
  String get profileTitle => 'Profil';

  @override
  String get saveTooltip => 'Speichern';

  @override
  String get editTooltip => 'Bearbeiten';

  @override
  String get writeMessageButton => 'Nachricht';

  @override
  String get callButton => 'Anrufen';

  @override
  String get aboutField => 'Über mich';

  @override
  String get nicknameField => 'Spitzname';

  @override
  String get locationField => 'Ort';

  @override
  String get birthdayField => 'Geburtstag';

  @override
  String get nameField => 'Name';

  @override
  String get avatarUploadLater => 'Avatar-Upload wird später hinzugefügt';

  @override
  String get profileSaved => 'Profil gespeichert';

  @override
  String createChatError(String error) {
    return 'Chat konnte nicht erstellt werden: $error';
  }

  @override
  String get privacyTitle => 'Datenschutz';

  @override
  String get hideFromSearch => 'Aus Suche ausblenden';

  @override
  String get hideFromSearchSubtitle => 'Nicht in Suchergebnissen anzeigen';

  @override
  String get hideLastSeen => 'Zuletzt gesehen ausblenden';

  @override
  String get hideLastSeenSubtitle =>
      'Andere sehen nicht, wann Sie zuletzt online waren';

  @override
  String get sessionExpiry => 'Sitzungsablauf';

  @override
  String sessionExpirySubtitle(int days) {
    return 'Automatische Anmeldung auf diesem Gerät: $days Tage';
  }

  @override
  String get sessionExpiryDaysTitle => 'Sitzungsablauf (Tage)';

  @override
  String get sessionExpiryDaysContent =>
      'Wählen Sie die Anzahl der Tage (min: 7, max: 365).';

  @override
  String get daysLabel => 'Tage';

  @override
  String get enterDaysError => 'Geben Sie eine Zahl von 7 bis 365 ein';

  @override
  String sessionExpirySet(int days) {
    return 'Sitzungsablauf festgelegt: $days Tage';
  }

  @override
  String get changeEmailLabel => 'E-Mail ändern';

  @override
  String get changeEmailSubtitle => 'E-Mail-Adresse aktualisieren';

  @override
  String get twoFactorPrivacySubtitle =>
      'Erweiterten Schutz aktivieren oder deaktivieren';

  @override
  String get changePhoneLabel => 'Telefon ändern';

  @override
  String get changePhoneSubtitle => 'Telefonnummer aktualisieren';

  @override
  String updatePrivacyError(String error) {
    return 'Datenschutz konnte nicht aktualisiert werden: $error';
  }

  @override
  String updateSettingError(String error) {
    return 'Einstellung konnte nicht aktualisiert werden: $error';
  }

  @override
  String get contactsTitle => 'Kontakte';

  @override
  String get searchContactsHint => 'Kontakte suchen...';

  @override
  String get contactsAccessTitle => 'Kontaktzugriff';

  @override
  String get contactsPermDeniedPermanent =>
      'Berechtigung dauerhaft verweigert. Öffnen Sie die Einstellungen.';

  @override
  String get contactsPermRequired => 'Kontaktberechtigung erforderlich.';

  @override
  String get openSettingsButton => 'Einstellungen öffnen';

  @override
  String get requestPermissionButton => 'Berechtigung anfordern';

  @override
  String get noContacts => 'Keine Kontakte gefunden';

  @override
  String get callAction => 'Anrufen';

  @override
  String get writeMessageAction => 'Nachricht';

  @override
  String callNotification(String number) {
    return 'Anruf: $number';
  }

  @override
  String messageNotification(String name) {
    return 'Nachricht an: $name';
  }

  @override
  String get callsTitle => 'Anrufe';

  @override
  String get searchByNameHint => 'Nach Name suchen...';

  @override
  String get allFilter => 'Alle';

  @override
  String get incomingFilter => 'Eingehend';

  @override
  String get outgoingFilter => 'Ausgehend';

  @override
  String get missedFilter => 'Verpasst';

  @override
  String get noCallsFound => 'Keine Anrufe';

  @override
  String get yesterdayLabel => 'Gestern';

  @override
  String get incomingCall => 'Eingehend';

  @override
  String get outgoingCall => 'Ausgehend';

  @override
  String get missedCall => 'Verpasst';

  @override
  String get videoCallLabel => 'Videoanruf';

  @override
  String get voiceCallLabel => 'Sprachanruf';

  @override
  String get sendMessageCallAction => 'Nachricht';

  @override
  String get createRoomTitle => 'Raum erstellen';

  @override
  String get createButton => 'Erstellen';

  @override
  String get roomNameLabel => 'Raumname';

  @override
  String get roomNameHint => 'z.B. Ihr Projektname';

  @override
  String get roomTopicLabel => 'Thema (optional)';

  @override
  String get roomTopicHint => 'Worum geht es in diesem Raum?';

  @override
  String get roomVisibilityLabel => 'Raumsichtbarkeit';

  @override
  String get privateRoomOption => 'Privater Raum';

  @override
  String get privateRoomSubtitle => 'Nur eingeladene Benutzer können beitreten';

  @override
  String get publicRoomOption => 'Öffentlicher Raum';

  @override
  String get publicRoomSubtitle => 'Jeder kann beitreten';

  @override
  String get showHistoryLabel => 'Nachrichtenverlauf anzeigen';

  @override
  String get showHistorySubtitle =>
      'Neue Mitglieder können frühere Nachrichten sehen';

  @override
  String get enterRoomNameError => 'Bitte Raumname eingeben';

  @override
  String get roomCreatedSuccess => 'Raum erfolgreich erstellt!';

  @override
  String imagePickError(String error) {
    return 'Bildauswahlfehler: $error';
  }

  @override
  String get groupInfoTab => 'Info';

  @override
  String get groupMembersTab => 'Mitglieder';

  @override
  String get groupRolesTab => 'Rollen';

  @override
  String get groupBansTab => 'Sperren';

  @override
  String get groupDeleteTab => 'Löschen';

  @override
  String membersCount(int count) {
    return 'Mitglieder: $count';
  }

  @override
  String get messageHistoryToggle => 'Nachrichtenverlauf';

  @override
  String get showHistoryToggleLabel => 'Verlauf anzeigen';

  @override
  String get settingSaved => 'Einstellung gespeichert';

  @override
  String get backgroundColorLabel => 'Hintergrundfarbe';

  @override
  String get noMembers => 'Keine Mitglieder';

  @override
  String get roleAction => 'Rolle';

  @override
  String get freezeAction => 'Einfrieren';

  @override
  String get banAction => 'Sperren';

  @override
  String get kickAction => 'Entfernen';

  @override
  String get noBannedUsers => 'Keine gesperrten Benutzer';

  @override
  String get bannedLabel => 'Gesperrt';

  @override
  String get userUnbanned => 'Benutzer entsperrt';

  @override
  String get deleteGroupLabel => 'Gruppe löschen';

  @override
  String get deleteGroupWarning =>
      'Diese Aktion ist UNUMKEHRBAR. Die Gruppe wird permanent gelöscht.';

  @override
  String get confirmDeleteTitle => 'Löschen bestätigen';

  @override
  String get confirmDeleteContent =>
      'Sind Sie sicher? Diese Aktion ist unumkehrbar.';

  @override
  String get changeRoleTitle => 'Rolle ändern';

  @override
  String get adminRole => 'Administrator';

  @override
  String get memberRole => 'Mitglied';

  @override
  String get freezeUserTitle => 'Benutzer einfrieren';

  @override
  String get userBanned => 'Benutzer gesperrt';

  @override
  String get userKicked => 'Benutzer entfernt';

  @override
  String get groupDeleted => 'Gruppe gelöscht';

  @override
  String loadError(String error) {
    return 'Ladefehler: $error';
  }

  @override
  String get publicLabel => 'Öffentlich';

  @override
  String get privateLabel => 'Privat';

  @override
  String get noDescription => 'Keine Beschreibung';

  @override
  String get membersLabel => 'Mitglieder';

  @override
  String get generalLabel => 'Allgemein';

  @override
  String get newChatTitle => 'Neuer Chat';

  @override
  String get directChatTab => 'Direkt';

  @override
  String get groupChatTab => 'Gruppe';

  @override
  String get startDirectChatTitle => 'Direktchat starten';

  @override
  String get matrixIdDescription => 'Benutzernamen oder Aegis-ID eingeben';

  @override
  String get matrixIdLabel => 'Benutzername oder Aegis-ID';

  @override
  String get startChatButton => 'Chat starten';

  @override
  String get hintCardTitle => 'Hinweis';

  @override
  String get matrixIdExplanation =>
      'Sie können einen Benutzernamen oder eine numerische Aegis-ID verwenden';

  @override
  String get enterUserIdError => 'Benutzer-ID eingeben';

  @override
  String get createNewRoomTitle => 'Neuen Raum erstellen';

  @override
  String get descriptionOptionalLabel => 'Beschreibung (optional)';

  @override
  String get privateGroupLabel => 'Private Gruppe';

  @override
  String get privateGroupSubtitle =>
      'Nur eingeladene Benutzer können beitreten';

  @override
  String get createRoomButton => 'Raum erstellen';

  @override
  String get customizationTitle => 'Anpassung';

  @override
  String get colorsTab => 'Farben';

  @override
  String get fontsTab => 'Schriften';

  @override
  String get effectsTab => 'Effekte';

  @override
  String get selectColorTheme => 'Farbthema auswählen';

  @override
  String get themeAppliesEverywhere =>
      'Das gewählte Thema wird in der gesamten App angewendet';

  @override
  String get fontSettingsTitle => 'Schrifteinstellungen';

  @override
  String get selectFontFamily => 'Schriftfamilie auswählen';

  @override
  String get appFontLabel => 'App-Schrift';

  @override
  String get fontWeightLabel => 'Schriftstärke';

  @override
  String get fontPreview => 'Vorschau: Beispieltext';

  @override
  String get compactMode => 'Abstände und Größen reduzieren';

  @override
  String get enableCircles => 'Kreise aktivieren';

  @override
  String get circlesDesc => 'Animierte Kreise im Hintergrund';

  @override
  String get floatingCirclesLabel => 'Schwebende Kreise';

  @override
  String get reactOnTilt => 'Auf Neigung reagieren';

  @override
  String get parallaxEffect => 'Parallax-Effekt';

  @override
  String get circlesSpeedLabel => 'Bewegungsgeschwindigkeit';

  @override
  String get staticMotion => 'Statisch';

  @override
  String get brightnessLabel => 'Helligkeit';

  @override
  String get dimOpacity => 'Gedimmt';

  @override
  String get brightOpacity => 'Hell';

  @override
  String get performanceLabel => 'Leistung';

  @override
  String get currentSpeedPrefix => 'Aktuell: ';

  @override
  String get speedPrefix => 'Geschwindigkeit:';

  @override
  String get advancedSearchTitle => 'Erweiterte Suche';

  @override
  String get searchQueryHint => 'Suchanfrage eingeben...';

  @override
  String get searchTypeLabel => 'Suchtyp';

  @override
  String get searchTypeAll => 'Alle';

  @override
  String get searchTypeMessages => 'Nachrichten';

  @override
  String get searchTypeMedia => 'Medien';

  @override
  String get searchTypeUsers => 'Benutzer';

  @override
  String get periodLabel => 'Zeitraum';

  @override
  String get fromDate => 'Von';

  @override
  String get toDate => 'Bis';

  @override
  String get searchButton => 'Suchen';

  @override
  String resultsCount(int count) {
    return 'Ergebnisse ($count)';
  }

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get forgotPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get forgotPasswordDescription =>
      'E-Mail für Link zum Zurücksetzen eingeben';

  @override
  String get sendResetButton => 'Senden';

  @override
  String get forgotPasswordUnavailable =>
      'Passwort-Wiederherstellung nicht verfügbar';

  @override
  String get changeEmailTitle => 'E-Mail ändern';

  @override
  String get changeEmailDescription => 'Neue E-Mail-Adresse eingeben';

  @override
  String get currentPrefix => 'Aktuell: ';

  @override
  String get newEmailLabel => 'Neue E-Mail';

  @override
  String get changeEmailButton => 'E-Mail ändern';

  @override
  String changeEmailError(String error) {
    return 'E-Mail konnte nicht geändert werden: $error';
  }

  @override
  String get changePhoneTitle => 'Telefonnummer ändern';

  @override
  String get changePhoneDescription =>
      'Neue Telefonnummer und aktuelles Passwort eingeben.';

  @override
  String get newPhoneLabel => 'Neue Nummer (+49...)';

  @override
  String get currentPasswordOptional =>
      'Aktuelles Passwort (falls erforderlich)';

  @override
  String get changePhoneButton => 'Nummer ändern';

  @override
  String get phoneCannotBeChanged => 'Telefonnummer kann nicht geändert werden';

  @override
  String get emailCannotBeChanged => 'E-Mail kann nicht geändert werden';

  @override
  String changePhoneError(String error) {
    return 'Nummer konnte nicht geändert werden: $error';
  }

  @override
  String get confirmCodeTitle => 'Code bestätigen';

  @override
  String codeSentTo(String phone) {
    return 'Wir haben einen Code an $phone gesendet';
  }

  @override
  String get enterCodeHint => 'Code eingeben';

  @override
  String get confirmButton => 'Bestätigen';

  @override
  String resendCountdown(int seconds) {
    return 'Erneut senden in $seconds s';
  }

  @override
  String get resendCodeButton => 'Code erneut senden';

  @override
  String get biometricSetupTitle => 'Sicherheit';

  @override
  String get authMethodsLabel => 'Authentifizierungsmethoden';

  @override
  String get biometricAuthLabel => 'Biometrische Authentifizierung';

  @override
  String get biometricAuthSubtitle => 'Fingerabdruck oder Face ID';

  @override
  String get biometricEnabledLabel => 'Biometrie aktiviert';

  @override
  String get aboutSecurityLabel => 'Über Sicherheit';

  @override
  String get aboutSecurityContent =>
      'Wählen Sie eine bequeme Authentifizierungsmethode.';

  @override
  String get setPinCode => 'PIN-Code festlegen';

  @override
  String get updateAvailableTitle => 'Update verfügbar';

  @override
  String get whatsNewLabel => 'Was ist neu';

  @override
  String get noUpdateDescription => 'Keine Beschreibung';

  @override
  String downloadingProgress(int percent) {
    return 'Herunterladen... $percent%';
  }

  @override
  String get checkingIntegrity => 'Integrität prüfen...';

  @override
  String get requestingInstall => 'Installation anfordern...';

  @override
  String get updateMandatory => 'Update ist obligatorisch';

  @override
  String get laterButton => 'Später';

  @override
  String get downloadingLabel => 'Herunterladen...';

  @override
  String get installingLabel => 'Installieren...';

  @override
  String get updateButton => 'Aktualisieren';

  @override
  String get downloadFailed => 'Update konnte nicht heruntergeladen werden';

  @override
  String get integrityCheckFailed =>
      'Datei hat Integritätsprüfung nicht bestanden (sha256)';

  @override
  String get installPermissionTitle => 'Installationsberechtigung';

  @override
  String get installPermissionContent =>
      'Erlauben Sie die Installation aus unbekannten Quellen.';

  @override
  String get installPermissionRequired =>
      'Installationsberechtigung erforderlich';

  @override
  String get installFailed => 'Installation fehlgeschlagen';

  @override
  String get ssoFeatureRequired =>
      'Diese Funktion erfordert webview_flutter-Konfiguration';

  @override
  String ssoLoginVia(String idpId) {
    return 'SSO-Anmeldung über $idpId';
  }

  @override
  String get forwardMessageTitle => 'Nachricht weiterleiten';

  @override
  String get searchChatHint => 'Chat suchen...';

  @override
  String forwardButton(int count) {
    return 'Weiterleiten ($count)';
  }

  @override
  String get roomAvatarUpdated => 'Raum-Avatar aktualisiert';

  @override
  String roomAvatarUploadError(String error) {
    return 'Fehler beim Hochladen des Avatars: $error';
  }

  @override
  String get roomSettingsSaved => 'Raumeinstellungen gespeichert';

  @override
  String roomSettingsSaveError(String error) {
    return 'Speicherfehler: $error';
  }

  @override
  String get uploadAvatarButton => 'Avatar hochladen';

  @override
  String loadMembersError(String error) {
    return 'Fehler beim Laden der Mitglieder: $error';
  }

  @override
  String get leaveRoomTitle => 'Raum verlassen?';

  @override
  String get leaveRoomContent =>
      'Sie können nicht zurückkehren, ohne erneut eingeladen zu werden.';

  @override
  String get leaveAction => 'Verlassen';

  @override
  String get leftRoom => 'Sie haben den Raum verlassen';

  @override
  String leaveRoomError(String error) {
    return 'Fehler beim Verlassen: $error';
  }

  @override
  String get reportNotImplemented => 'Meldefunktion noch nicht implementiert';

  @override
  String get inviteAction => 'Einladen';

  @override
  String get threadsLabel => 'Threads';

  @override
  String get pinnedLabel => 'Angeheftet';

  @override
  String get filesLabel => 'Dateien';

  @override
  String get mediaLabel => 'Medien';

  @override
  String get extensionsLabel => 'Erweiterungen';

  @override
  String get copyLinkAction => 'Link kopieren';

  @override
  String get pollsLabel => 'Umfragen';

  @override
  String get exportChatAction => 'Chat exportieren';

  @override
  String get reportAction => 'Melden';

  @override
  String get leaveRoomAction => 'Raum verlassen';

  @override
  String roomTitle(String name) {
    return 'Raum — $name';
  }

  @override
  String get roomSettingsLabel => 'Raumeinstellungen';

  @override
  String authError(String error) {
    return 'Authentifizierungsfehler: $error';
  }

  @override
  String get loginRequired => 'Anmeldung erforderlich';

  @override
  String get loginRequiredContent =>
      'Sie müssen angemeldet sein, um Kontakte zu suchen. Zur Anmeldung?';

  @override
  String get loginAction => 'Anmelden';

  @override
  String searchError(String error) {
    return 'Suchfehler: $error';
  }

  @override
  String get searchContactsTitle => 'Kontakte suchen';

  @override
  String get nicknameOrPhoneHint => 'Spitzname oder Telefonnummer';

  @override
  String selectContactError(String error) {
    return 'Kontakt konnte nicht ausgewählt werden: $error';
  }

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get feedbackCategoryFeatures => 'Funktionen';

  @override
  String get feedbackCategoryPerformance => 'Leistung';

  @override
  String get feedbackCategorySecurity => 'Sicherheit/Datenschutz';

  @override
  String get feedbackCategoryNetworkSync => 'Sync/Netzwerk';

  @override
  String get shortDescriptionLabel => 'Kurzbeschreibung';

  @override
  String get shortDescriptionHint => 'Z.B. \"Chat-Backup in der Cloud\"';

  @override
  String get feedbackValidation =>
      'Wählen Sie mindestens eine Idee oder schreiben Sie eine Beschreibung';

  @override
  String get detailsOptionalLabel => 'Details (optional)';

  @override
  String get detailsHint =>
      'Was soll funktionieren, wie es jetzt ist und wie Sie es möchten?';

  @override
  String get bigFeaturesTitle =>
      'Hauptfunktionen (was interessiert Sie am meisten)';

  @override
  String get feedbackE2E =>
      'Ende-zu-Ende-Verschlüsselung (Olm/Megolm) + Geräteverifizierung';

  @override
  String get feedbackBackup =>
      'Chat-Backup (lokal/Cloud) + Übertragung auf neues Gerät';

  @override
  String get feedbackThreads =>
      'Threads, Reaktionen, Erwähnungen, verbesserte Nachrichtensuche';

  @override
  String get feedbackCalls => 'Sprach-/Videoanrufe und schnelle Sprachräume';

  @override
  String get feedbackFolders =>
      'Chat-Ordner/Kategorien und intelligente Benachrichtigungsfilter';

  @override
  String get feedbackBots =>
      'Bots und Integrationen (Webhooks, GitHub/Jira, Erinnerungen)';

  @override
  String get feedbackSlowNet =>
      '\"Langsames Internet\"-Modus + aggressives Medien-Caching';

  @override
  String get startChatTitle => 'Chat starten';

  @override
  String get createRoomSubtitle => 'Private oder öffentliche Gruppe';

  @override
  String get inviteUserTitle => 'Benutzer einladen';

  @override
  String get inviteUserSubtitle => 'Benutzer finden und schreiben';

  @override
  String get joinByCodeTitle => 'Per Code beitreten';

  @override
  String get joinByCodeSubtitle => 'Einem Raum mit Einladungscode beitreten';

  @override
  String get fontLabel => 'Schrift';

  @override
  String get pinCodeLabel => 'PIN-Code';

  @override
  String get pinCodeSubtitle => '4-6 Ziffern zum Schutz';

  @override
  String get pinHint => 'PIN (4-6 Ziffern)';

  @override
  String get pinLengthError => 'PIN muss 4-6 Ziffern haben';

  @override
  String get pinSetSuccess => 'PIN gesetzt';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get deleteButton => 'Löschen';

  @override
  String get closeButton => 'Schließen';

  @override
  String get saveButton => 'Speichern';

  @override
  String get sendButton => 'Senden';

  @override
  String get copyButton => 'Kopieren';

  @override
  String get shareButton => 'Teilen';

  @override
  String get settingsLabel => 'Einstellungen';

  @override
  String get feedbackCategoryUxDesign => 'UX/Design';

  @override
  String get feedbackShareSubject => 'TwoSpace — Vorschlag';

  @override
  String get feedbackMessageHeader => 'TwoSpace — Vorschlag/Verbesserung';

  @override
  String feedbackVersion(String version) {
    return 'Version: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return 'Kategorie: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return 'Kurz: $title';
  }

  @override
  String get feedbackWishList => 'Was besonders toll wäre:';

  @override
  String get feedbackDetailsLine => 'Details:';

  @override
  String get circlesVisible => 'Kreise angezeigt';

  @override
  String get circlesHidden => 'Kreise ausgeblendet';

  @override
  String get speedSlow => 'Langsam';

  @override
  String get speedFast => 'Schnell';

  @override
  String get advancedSettingsLabel => 'Erweiterte Einstellungen';

  @override
  String get compactModeLabel => 'Kompakter Modus';

  @override
  String get activeDeviceInfo => 'Android • Aktiv';

  @override
  String stubPlaceholder(String key) {
    return 'Platzhalter — $key';
  }

  @override
  String loadMessagesError(String error) {
    return 'Fehler beim Laden der Nachrichten: $error';
  }

  @override
  String get pinnedUpdated => 'Angeheftete aktualisiert';

  @override
  String editError(String error) {
    return 'Bearbeitungsfehler: $error';
  }

  @override
  String get moreButton => 'Mehr';

  @override
  String shareError(String error) {
    return 'Konnte nicht teilen: $error';
  }

  @override
  String sendError(String error) {
    return 'Sendefehler: $error';
  }

  @override
  String get voiceRecordingUnsupported =>
      'Sprachaufnahme wird auf dieser Plattform nicht unterstützt';

  @override
  String get microphonePermissionRequired =>
      'Mikrofonberechtigung erforderlich';

  @override
  String genericError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get ownersLabel => '👑 Eigentümer';

  @override
  String get administratorsLabel => '⚡ Administratoren';

  @override
  String get oneHour => '1 Stunde';

  @override
  String get oneDay => '1 Tag';

  @override
  String get sevenDays => '7 Tage';

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
}
