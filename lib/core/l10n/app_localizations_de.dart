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
  String get validationAegisUsernameFormat =>
      'Username must be 3-32 chars and use Latin letters, digits, ., _ or -.';

  @override
  String get aegisUsernameHelper =>
      'Aegis username: 3-32 chars, Latin letters, digits, ., _ or -';

  @override
  String loginCooldownMessage(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s.';
  }

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
  String get emailOrUsernameLabel => 'Benutzername';

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
  String get validationEnterEmailOrUsername => 'Bitte Benutzernamen eingeben';

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
  String get addCaptionHint => 'Bildunterschrift oder Nachricht hinzufügen';

  @override
  String get unlockApp => 'App entsperren';

  @override
  String get unlockButton => 'Entsperren';

  @override
  String get dropFilesTitle => 'Dateien zum Anhängen ablegen';

  @override
  String get dropFilesSubtitle =>
      'Sie werden über dem Nachrichtenfeld angezeigt.';

  @override
  String get videoUnavailable => 'Video nicht verfügbar';

  @override
  String get guestRole => 'Gast';

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
  String get accountProfileTitle => 'My account';

  @override
  String get accountProfileSubtitle =>
      'Manage your public profile data and contact details';

  @override
  String get accountProfileEditSubtitle =>
      'Edit your visible profile data and save the changes here';

  @override
  String get otherProfileSubtitle =>
      'Public profile and available contact information';

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
  String get biometricSubtitle =>
      'Verwende Face ID, Fingerabdruck oder den Gerätecode';

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
  String get editProfileButton => 'Edit profile';

  @override
  String get saveProfileButton => 'Save changes';

  @override
  String get copyAegisIdButton => 'Copy Aegis ID';

  @override
  String get saveTooltip => 'Speichern';

  @override
  String get editTooltip => 'Bearbeiten';

  @override
  String get mediaDownloadAction => 'Herunterladen';

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
  String get aegisIdLabel => 'Aegis ID';

  @override
  String get registeredAtLabel => 'Registered';

  @override
  String get profileStatusLabel => 'Status';

  @override
  String get profileModerationNoticeTitle => 'Safety actions are not ready yet';

  @override
  String get profileModerationNoticeMessage =>
      'Blocking and reporting will appear here after the moderation flow is completed.';

  @override
  String get blockUserAction => 'Block user';

  @override
  String get reportUserAction => 'Report user';

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
  String get widgetsTitle => 'Widgets';

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
  String get newChatChooserTitle => 'Start a new conversation';

  @override
  String get newChatChooserSubtitle =>
      'Choose the kind of chat you want to create or join.';

  @override
  String get createDirectChatSubtitle =>
      'Search for a person or enter an Aegis ID manually.';

  @override
  String get directChatTab => 'Direkt';

  @override
  String get groupChatTab => 'Gruppe';

  @override
  String get channelChatTab => 'Channel';

  @override
  String get createGroupSubtitle =>
      'Set up a group, pick participants and share the invite link right away.';

  @override
  String get createChannelTitle => 'Create channel';

  @override
  String get createChannelSubtitle =>
      'Create a read-focused channel with avatar, description and shareable link.';

  @override
  String get startDirectChatTitle => 'Direktchat starten';

  @override
  String get contactIdDescription => 'Benutzernamen oder Aegis-ID eingeben';

  @override
  String get contactIdLabel => 'Benutzername oder Aegis-ID';

  @override
  String get startChatButton => 'Chat starten';

  @override
  String get hintCardTitle => 'Hinweis';

  @override
  String get contactIdExplanation =>
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
  String get customizationHeroTitle => 'Shape the app around your rhythm';

  @override
  String get customizationHeroSubtitle =>
      'Build a distinct look with live preview, curated presets, motion, and density controls.';

  @override
  String get notificationsHeroSubtitle =>
      'Tune alerts, sound behavior, and custom previews so incoming activity feels calm and readable.';

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
  String get themeModeLabel => 'Light balance';

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
  String get previewRoomsSubtitle =>
      'A compact room list with real-sounding snippets and cleaner status markers.';

  @override
  String get previewConversationTitle => 'Chat bubble preview';

  @override
  String get previewConversationSubtitle =>
      'Check how tone, spacing, and bubble shape read in a short live dialog.';

  @override
  String get previewSettingsTitle => 'Controls at hand';

  @override
  String get previewSettingsSubtitle =>
      'Preview how the settings stack feels before applying anything globally.';

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
  String get previewSettingsAppearanceSubtitle =>
      'Pick a template, adjust motion, and keep the whole shell consistent.';

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
  String get themeColorAuroraMint => 'Aurora Mint';

  @override
  String get themeColorSlateMono => 'Slate Mono';

  @override
  String get backgroundMotionToggleLabel => 'Animated background';

  @override
  String get backgroundMotionOnSubtitle =>
      'The atmosphere layer stays alive behind the UI.';

  @override
  String get backgroundMotionOffSubtitle =>
      'Use a still backdrop for a quieter, flatter surface.';

  @override
  String get motionModeCircles => 'Orbit';

  @override
  String get motionModeCirclesSubtitle =>
      'Floating light blobs with soft parallax drift.';

  @override
  String get motionModeWaves => 'Waves';

  @override
  String get motionModeWavesSubtitle =>
      'Layered bottom waves that move more like ambient light.';

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
  String get biometricAuthLabel => 'Geräteauthentifizierung';

  @override
  String get biometricAuthSubtitle => 'Face ID, Fingerabdruck oder Gerätecode';

  @override
  String get biometricEnabledLabel => 'App-Sperre aktiviert';

  @override
  String get aboutSecurityLabel => 'Über Sicherheit';

  @override
  String get aboutSecurityContent =>
      'TwoSpace verwendet die Entsperrmethode, die bereits auf diesem Gerät eingerichtet ist, und fragt sie beim Zurückkehren in die App ab.';

  @override
  String get lockScreenFailedTitle => 'Identität konnte nicht bestätigt werden';

  @override
  String get lockScreenFailedMessage =>
      'Versuche es erneut oder melde dich auf diesem Gerät ab.';

  @override
  String get deviceAuthUnavailableMessage =>
      'Richte zuerst Face ID, Fingerabdruck oder einen Gerätecode in den Systemeinstellungen ein.';

  @override
  String get authMethodFaceId => 'Face ID';

  @override
  String get authMethodFingerprint => 'Fingerabdruck';

  @override
  String get authMethodBiometric => 'Biometrie';

  @override
  String get authMethodDevicePasscode => 'Gerätecode';

  @override
  String get setPinCode => 'PIN-Code festlegen';

  @override
  String get updateAvailableTitle => 'Update verfügbar';

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
  String get updatePreviewModeTitle => 'Preview release card';

  @override
  String get updatePreviewModeSubtitle =>
      'This entry was opened from the debug catalog, so it shows a styled placeholder instead of real release notes.';

  @override
  String get updatePreviewModeEmptyNotes =>
      'Preview notes were not provided for this mock release.';

  @override
  String get updateCurrentVersionLabel => 'Current';

  @override
  String get updateIncomingVersionLabel => 'Incoming';

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
  String get featureInDevelopmentLabel => 'In Entwicklung';

  @override
  String featureInDevelopmentMessage(String feature) {
    return 'Diese Funktion wird noch entwickelt und wird in einer der nächsten Versionen verfügbar sein.';
  }

  @override
  String get inviteAction => 'Einladen';

  @override
  String get threadsLabel => 'Threads';

  @override
  String get pinnedLabel => 'Angeheftet';

  @override
  String get filesLabel => 'Dateien';

  @override
  String get noSharedFiles => 'Noch keine geteilten Dateien';

  @override
  String get mediaLabel => 'Medien';

  @override
  String get noSharedMedia => 'Noch keine geteilten Medien';

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
  String get startDirectChatSubtitle =>
      'Open a private conversation with one person';

  @override
  String get createRoomSubtitle => 'Private oder öffentliche Gruppe';

  @override
  String get inviteUserTitle => 'Benutzer einladen';

  @override
  String get inviteUserSubtitle => 'Benutzer finden und schreiben';

  @override
  String get addParticipantAction => 'Add participant';

  @override
  String get selectedParticipantsTitle => 'Participants';

  @override
  String get groupParticipantsOptionalHint =>
      'Participants are optional. You can create the group now and invite people later.';

  @override
  String get joinByCodeTitle => 'Per Code beitreten';

  @override
  String get joinByCodeSubtitle => 'Einem Raum mit Einladungscode beitreten';

  @override
  String get joinRoomAction => 'Join';

  @override
  String get subscribeAction => 'Subscribe';

  @override
  String get chatsSubtitle =>
      'Private Nachrichten, Gruppen und Einladungslinks an einem Ort';

  @override
  String get chatsQuickStartTitle => 'Etwas Neues starten';

  @override
  String get chatsRecentTitle => 'Letzte Chats';

  @override
  String get joinLinkHint => 'Einladungslink, Alias oder Code einfügen';

  @override
  String get publicAliasLabel => 'Public alias';

  @override
  String get publicAliasHint =>
      'Short public name without spaces, for example newsroom';

  @override
  String get channelPublicLinkHelper =>
      'This link will be used in search and invitations when the channel is public.';

  @override
  String get channelLinkFormatError =>
      'Use only Latin letters, digits, dots, underscores or hyphens.';

  @override
  String get inviteLinkReadyTitle => 'Invite link is ready';

  @override
  String get inviteLinkReadySubtitle =>
      'Share it now or keep it for later. Selected people will receive it in direct messages when possible.';

  @override
  String get openChatAction => 'Open chat';

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
  String get notificationToneTitle => 'Notification sound';

  @override
  String get notificationToneSubtitle =>
      'Choose a local audio file for message and alert previews.';

  @override
  String get ringtoneTitle => 'Ringtone';

  @override
  String get ringtoneSubtitle =>
      'Use a separate local audio file for incoming call previews.';

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
  String get storageMemoryTitle => 'Speicher';

  @override
  String get storageTotalLabel => 'Gesamt';

  @override
  String get storageSelectedLabel => 'Selected';

  @override
  String get storagePhotosLabel => 'Fotos';

  @override
  String get storageVideosLabel => 'Videos';

  @override
  String get storageCacheLabel => 'Cache';

  @override
  String get storageAppDataLabel => 'App-Daten';

  @override
  String get storageCleanupTitle => 'Wird bereinigt';

  @override
  String get storageCleanupSubtitle =>
      'Prüfe, was sicher entfernt werden kann.';

  @override
  String get storageAutoCleanTitle => 'Auto-clean';

  @override
  String get storageAutoCleanSubtitle =>
      'Run cleanup automatically on a schedule or when storage grows beyond the selected limit.';

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
  String get storageAutoCleanStatusEnabled =>
      'Auto-clean is active and will run when the schedule arrives or the storage threshold is exceeded.';

  @override
  String get storageAutoCleanStatusDisabled =>
      'Auto-clean is off. Only manual cleanup will run until you enable it again.';

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
  String get peopleTitle => 'Personen';

  @override
  String get peopleSubtitle =>
      'Kontakte, Favoriten, Suche und Einladungen an einem Ort';

  @override
  String get peopleQuickNewChat => 'Neuer Chat';

  @override
  String get peopleQuickInvite => 'Einladen';

  @override
  String get peopleQuickSync => 'Synchronisieren';

  @override
  String get peopleSearchHint =>
      'Nach Name, Nickname oder Telefonnummer suchen';

  @override
  String get peopleSegmentAll => 'Alle';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => 'Telefonbuch';

  @override
  String get peopleSegmentRecent => 'Zuletzt';

  @override
  String get peopleLoading => 'Personen werden geladen…';

  @override
  String get peopleNoPeopleTitle => 'Noch keine Personen';

  @override
  String get peopleNoPeopleMessage =>
      'Hier erscheinen Ihre Favoriten, letzten Unterhaltungen und Kontakte.';

  @override
  String get peoplePermissionCardTitle => 'Zugriff auf Kontakte eingeschränkt';

  @override
  String get peoplePermissionCardMessage =>
      'Erlauben Sie den Zugriff auf Kontakte, um Ihr Telefonbuch anzuzeigen und Personen schneller einzuladen.';

  @override
  String get peoplePermissionCardMessageSettings =>
      'Aktivieren Sie den Zugriff auf Kontakte in den Systemeinstellungen, um den Telefonbuchbereich wiederherzustellen.';

  @override
  String get peopleFavoritesFrequentTitle => 'Favoriten & häufig';

  @override
  String get peopleRecentTitle => 'Zuletzt verwendete Personen';

  @override
  String get peopleTwoSpaceTitle => 'Personen in TwoSpace';

  @override
  String get peopleInviteTitle => 'Noch nicht bei TwoSpace';

  @override
  String get peopleInviteSubtitle => 'Diesen Kontakt zu TwoSpace einladen';

  @override
  String get peopleSearching => 'Suche nach Personen…';

  @override
  String get peopleSearchRemoteTitle => 'TwoSpace-Ergebnisse';

  @override
  String get peopleSearchLocalTitle => 'Zuletzt und gespeichert';

  @override
  String get peopleSearchInviteTitle => 'Aus dem Telefonbuch einladen';

  @override
  String get peopleSearchEmptyTitle => 'Keine passenden Personen';

  @override
  String get peopleSearchEmptyMessage =>
      'Versuchen Sie einen anderen Namen, Nickname oder eine andere Telefonnummer.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => 'Noch keine zusätzlichen Details';

  @override
  String get peopleInviteShareText =>
      'Komm zu mir auf TwoSpace — ein sicherer Messenger für Chats und Anrufe.';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return 'Komm zu mir auf TwoSpace, $personName — lass uns sicher chatten und telefonieren.';
  }

  @override
  String get peopleViewProfileAction => 'Profil anzeigen';

  @override
  String get peopleRemoveFavoriteAction => 'Aus Favoriten entfernen';

  @override
  String get peopleAddFavoriteAction => 'Zu Favoriten hinzufügen';

  @override
  String get callsSubtitle =>
      'Letzte Anrufe, schnelles Rückrufen und verlaufsbasierte Personenansicht';

  @override
  String get widgetsSubtitle =>
      'Home, lock-screen, and glanceable surfaces for your conversations';

  @override
  String get widgetsComingTitle => 'Widgets are on the way';

  @override
  String get widgetsComingBody =>
      'We are preparing flexible widget layouts for quick actions, unread counters, and compact conversation previews.';

  @override
  String get callsStartCallAction => 'Anruf starten';

  @override
  String get callsQuickStartTitle => 'Jetzt jemanden anrufen';

  @override
  String get callsQuickStartSubtitle =>
      'Öffnen Sie Personen, suchen Sie jemanden und starten Sie einen sicheren Sprach- oder Videoanruf.';

  @override
  String get callsSearchHint => 'Anrufverlauf durchsuchen';

  @override
  String get callsVideoFilter => 'Video';

  @override
  String get callsTopContactsTitle => 'Häufige Kontakte';

  @override
  String get callsLoadingLabel => 'Anrufe werden geladen…';

  @override
  String get callsEmptyTitle => 'Noch keine Anrufe';

  @override
  String get callsEmptyMessage =>
      'Ihr Anrufverlauf erscheint hier nach Ihrem ersten Sprach- oder Videoanruf.';

  @override
  String get callsEmptySearchMessage =>
      'Keine Anrufe passen zur aktuellen Suche oder zum Filter.';

  @override
  String get callsTodaySection => 'Heute';

  @override
  String get callsThisWeekSection => 'Diese Woche';

  @override
  String get callsEarlierSection => 'Früher';

  @override
  String callsThreadCount(int count) {
    return '$count Anrufe';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count verpasst';
  }

  @override
  String get callsMuteAction => 'Stumm';

  @override
  String get callsSpeakerAction => 'Lautsprecher';

  @override
  String get callsCameraAction => 'Kamera';

  @override
  String get callsSwitchCameraAction => 'Wechseln';

  @override
  String get callsEndAction => 'Anruf beenden';

  @override
  String get callsConnectingLabel => 'Verbinden…';

  @override
  String get callsRingingLabel => 'Klingelt…';

  @override
  String get callsConnectingDetail => 'Sichere Anrufsitzung wird erstellt.';

  @override
  String get callsRingingDetail => 'Warten auf Antwort der anderen Person.';

  @override
  String get callsVideoSecureDetail =>
      'Video ist geschützt und wird über die aktuelle sichere Sitzung übertragen.';

  @override
  String get callsVoiceSecureDetail =>
      'Audio ist geschützt und wird über die aktuelle sichere Sitzung übertragen.';

  @override
  String get timestampPrecisionLabel => 'Genauigkeit der Nachrichtenzeit';

  @override
  String get timestampPrecisionSubtitle =>
      'Wähle, wie genau Nachrichtenzeiten angezeigt werden.';

  @override
  String get timestampPrecisionMinutes => 'Stunden und Minuten';

  @override
  String get timestampPrecisionSeconds => 'Stunden, Minuten und Sekunden';

  @override
  String get timestampPrecisionMilliseconds =>
      'Stunden, Minuten, Sekunden und Millisekunden';

  @override
  String get startupTitle => 'TwoSpace wird vorbereitet';

  @override
  String get startupSubtitle =>
      'Die sichere Sitzung wird geprüft und Ihre Chats werden geöffnet.';

  @override
  String get startupFooter =>
      'Dieser Bildschirm wird nur beim Start der App angezeigt.';

  @override
  String get startupStepEnvironment => 'Konfiguration wird geladen';

  @override
  String get startupStepDiagnostics => 'Diagnose wird gestartet';

  @override
  String get startupStepValidation => 'Umgebung wird geprüft';

  @override
  String get startupStepSettings => 'Einstellungen werden geladen';

  @override
  String get startupStepSession => 'Sichere Sitzung wird wiederhergestellt';

  @override
  String get startupStepLaunch => 'App wird gestartet';

  @override
  String get callsDemoBannerTitle =>
      'Beispiel, keine funktionsfähige Anruffunktion';

  @override
  String get callsDemoBannerVoiceMessage =>
      'Sprachanrufe werden derzeit nur als visueller Prototyp angezeigt. Die Audioübertragung ist noch nicht verbunden.';

  @override
  String get callsDemoBannerVideoMessage =>
      'Videoanrufe werden derzeit nur als visueller Prototyp angezeigt. Der entfernte Videostream ist noch nicht verfügbar, aber Ihre lokale Kameravorschau funktioniert.';

  @override
  String get callsCameraPermissionMessage =>
      'Erlauben Sie den Kamerazugriff, damit Ihre lokale Vorschau während eines Videoanrufs angezeigt werden kann.';

  @override
  String get callsCameraPermissionSettingsMessage =>
      'Der Kamerazugriff ist blockiert. Öffnen Sie die Systemeinstellungen, um die lokale Videovorschau zu aktivieren.';

  @override
  String get callsCameraPermissionAction => 'Kamera erlauben';

  @override
  String get callsCameraUnavailableTitle => 'Kamera nicht verfügbar';

  @override
  String get callsCameraUnavailableMessage =>
      'Die lokale Kameravorschau konnte auf diesem Gerät nicht gestartet werden.';

  @override
  String get callsCameraUnsupportedMessage =>
      'Diese Plattform unterstützt keine lokale Videovorschau.';

  @override
  String get callsCameraOffMessage =>
      'Die Kameravorschau ist für diesen Demo-Anruf ausgeschaltet.';

  @override
  String get callsFrontCameraLabel => 'Frontkamera';

  @override
  String get callsRearCameraLabel => 'Rückkamera';

  @override
  String get backgroundOptimizationDisabledTitle =>
      'Hintergrundeffekte wurden vereinfacht';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace hat anhaltend langsame Frames erkannt und aufwendige Hintergrundeffekte deaktiviert, damit Scrollen und Chats flüssig bleiben.';

  @override
  String get backgroundOptimizationOpenSettings =>
      'Darstellungseinstellungen öffnen';

  @override
  String get roomJoinRuleLabel => 'Wer beitreten kann';

  @override
  String get roomJoinRulePublic => 'Offen für alle';

  @override
  String get roomJoinRulePublicDescription =>
      'Jeder kann diesen Raum finden und ihm beitreten.';

  @override
  String get roomJoinRuleInviteOnly => 'Nur per Einladung';

  @override
  String get roomJoinRuleInviteOnlyDescription =>
      'Nur eingeladene Nutzer können diesem Raum beitreten.';

  @override
  String get roomJoinRuleApproval => 'Genehmigung erforderlich';

  @override
  String get roomJoinRuleApprovalDescription =>
      'Nutzer können Zugriff anfragen und müssen vor dem Beitritt genehmigt werden.';

  @override
  String get roomHistoryVisibilityLabel => 'Wer den Verlauf sehen kann';

  @override
  String get roomHistoryVisibilityWorldReadable => 'Alle';

  @override
  String get roomHistoryVisibilityWorldReadableDescription =>
      'Jeder kann frühere Nachrichten sehen.';

  @override
  String get roomHistoryVisibilityJoined => 'Beigetretene Mitglieder';

  @override
  String get roomHistoryVisibilityJoinedDescription =>
      'Nur beigetretene Mitglieder können frühere Nachrichten sehen.';

  @override
  String get roomHistoryVisibilityInvited => 'Nur eingeladene Nutzer';

  @override
  String get roomHistoryVisibilityInvitedDescription =>
      'Nur eingeladene Nutzer können frühere Nachrichten sehen.';

  @override
  String get loginUsernameOnlyError =>
      'Verwende zum Anmelden deinen TwoSpace-Benutzernamen.';

  @override
  String get twoFactorInvalidCodeMessage =>
      'Der 2FA-Code oder die Wiederherstellungsphrase ist ungültig. Versuche es erneut.';

  @override
  String get twoFactorCodeRequiredMessage =>
      'Gib einen Code aus deiner Authenticator-App ein oder verwende die Wiederherstellungsphrase.';

  @override
  String get twoFactorEnabledMessage =>
      'Die Zwei-Faktor-Authentifizierung ist aktiviert.';

  @override
  String twoFactorEnableFailed(String error) {
    return '2FA konnte nicht aktiviert werden: $error';
  }

  @override
  String get twoFactorSetupTitle => 'Zwei-Faktor-Authentifizierung einrichten';

  @override
  String get twoFactorSetupDescription =>
      'Scanne den QR-Code in deiner Authenticator-App, speichere die Wiederherstellungsphrase und bestätige dann mit einem frischen TOTP-Code.';

  @override
  String get twoFactorSecretTitle =>
      'Oder diesen geheimen Schlüssel manuell eingeben';

  @override
  String get twoFactorRecoveryPhraseTitle =>
      'Wiederherstellungsphrase. Speichere sie an einem sicheren Ort, bevor du 2FA aktivierst.';

  @override
  String get twoFactorVerificationCodeLabel => 'Bestätigungscode';

  @override
  String get twoFactorVerificationCodeHint =>
      'Gib den aktuellen Code aus deiner Authenticator-App ein';

  @override
  String get twoFactorVerifyEnableAction => 'Prüfen und 2FA aktivieren';

  @override
  String get twoFactorDisableSectionTitle =>
      'Zwei-Faktor-Authentifizierung deaktivieren';

  @override
  String get twoFactorDisableSectionDescription =>
      'Deaktiviere 2FA mit einem gültigen Authenticator-Code oder deiner einmaligen Wiederherstellungsphrase.';

  @override
  String get twoFactorDisableCodeHint =>
      'Gib einen aktuellen Authenticator-Code ein';

  @override
  String get twoFactorRecoveryPhraseFieldLabel => 'Wiederherstellungsphrase';

  @override
  String get twoFactorRecoveryPhraseFieldHint =>
      'Füge die Wiederherstellungsphrase ein, wenn du keinen Zugriff mehr auf die Authenticator-App hast';

  @override
  String get twoFactorDisableAction => '2FA deaktivieren';

  @override
  String get twoFactorDisableCredentialsRequired =>
      'Gib einen Authenticator-Code oder eine Wiederherstellungsphrase ein, um 2FA zu deaktivieren.';

  @override
  String get twoFactorDisabledMessage =>
      'Die Zwei-Faktor-Authentifizierung ist deaktiviert.';

  @override
  String twoFactorDisableFailed(String error) {
    return '2FA konnte nicht deaktiviert werden: $error';
  }

  @override
  String get twoFactorLoginRecoveryHint =>
      'Oder füge statt eines Codes die Wiederherstellungsphrase ein';

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
  String get groupAvatarSubtitle =>
      'You can add an avatar right when creating the group.';

  @override
  String get chooseFileButton => 'Choose file';

  @override
  String get groupHistoryTitle => 'Keep history for new members';

  @override
  String get fileAccessDeniedMessage =>
      'Access to the selected file is blocked.';

  @override
  String get avatarFileAccessDeniedMessage =>
      'Access to the avatar file is blocked. Try another file.';

  @override
  String get profileEmptySelfHint =>
      'Your profile is still sparse. Add a name, bio, or location so it looks complete.';

  @override
  String get profileEmptyOtherHint =>
      'This user has not filled out their profile yet, or the server did not return the detailed fields.';

  @override
  String get twoFactorDisableConfirmContent =>
      'Disable two-factor authentication for this account? You will need to set it up again to restore extra protection.';

  @override
  String get betaTestLabel => 'Beta test';

  @override
  String get homeBetaWelcomeTitle => 'Welcome to the TwoSpace beta test';

  @override
  String get homeBetaWelcomeBody =>
      'Features may change often. Send us your suggestions.';

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
  String get authRegisterVerifyEmailBeforeLogin =>
      'Registration is complete. Verify your email before signing in.';

  @override
  String authRegisterAutoLoginFailed(Object error) {
    return 'Account created, but automatic sign-in failed: $error';
  }

  @override
  String get authProfileUpdateFailed => 'Failed to update profile';

  @override
  String get authAvatarUpdateFailed => 'Failed to update avatar';

  @override
  String get authLoginAppCredentialsRejected =>
      'The server rejected the app credentials. Check server configuration or handshake compatibility.';

  @override
  String get authSessionTokenMissing =>
      'The server did not return a session token';

  @override
  String get authTotpSetupFailed =>
      'Failed to prepare two-factor authentication';

  @override
  String get authTotpDisableFailed =>
      'Failed to disable two-factor authentication';

  @override
  String get authTotpVerifyFailed =>
      'Failed to verify two-factor authentication';

  @override
  String get authSessionsLoadFailed => 'Failed to load active sessions';

  @override
  String get authSessionsRevokeFailed => 'Failed to end the session';

  @override
  String get authRegisterNotLoggedIn =>
      'Registration completed, but sign-in was not completed';

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
  String get devMenuLogsEmptyMessage =>
      'Open the problematic screen or repeat the action. New records will appear here.';

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
  String get devMenuScreensNotFoundMessage =>
      'Change the search query or clear the group filter.';

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
  String get devMenuShowBoundsSubtitle =>
      'Displays paddings and borders of all widgets';

  @override
  String get devMenuRepaintRainbow => 'Highlight repaints (RepaintRainbow)';

  @override
  String get devMenuRepaintRainbowSubtitle =>
      'Highlights elements that are being repainted';

  @override
  String get devMenuSlowAnimations => 'Slow animations (timeDilation = 5.0)';

  @override
  String get devMenuSlowAnimationsSubtitle =>
      'Slows down all animations in the app';

  @override
  String get devMenuPerformanceOverlay => 'Performance profiling';

  @override
  String get devMenuPerformanceOverlaySubtitle =>
      'Shows the Performance Overlay on top of the app';

  @override
  String get devMenuSensitiveDialogTitle => 'Sensitive data visibility';

  @override
  String get devMenuSensitiveDialogMessage =>
      'After enabling this option, new debug and network logs may contain tokens, keys, and other secrets in plain text. Existing records will not change. Continue?';

  @override
  String get devMenuEnable => 'Enable';

  @override
  String get devMenuSensitiveEnableDescription =>
      'Keys, tokens, and passwords are masked by default. This switch affects only new logs.';

  @override
  String get devMenuSensitiveDisabledDescription =>
      'Sensitive data is always hidden in this build.';

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
  String get devMenuFlagIgnoreServerOfflineSubtitle =>
      'Keeps the current session and avoids returning to the sign-in screen when the server is unavailable.';

  @override
  String get devMenuReleaseHiddenTitle => 'Sensitive data is hidden';

  @override
  String get devMenuReleaseHiddenSubtitle =>
      'Public release and profile builds always show debug data only in masked form.';

  @override
  String get devMenuNetworkEmptyTitle => 'No network logs yet';

  @override
  String get devMenuNetworkEmptyMessage =>
      'Open any screen that performs requests and logs will appear here.';

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
  String get notificationsInDevelopmentSubtitle =>
      'Detaillierte Benachrichtigungseinstellungen kommen in einem der nächsten Updates.';

  @override
  String get devMenuCopyVisible => 'Sichtbare Einträge kopieren';

  @override
  String get devMenuExportLogFile => 'Logdatei exportieren';

  @override
  String get devMenuNewestFirst => 'Neueste zuerst';

  @override
  String get devMenuOldestFirst => 'Älteste zuerst';

  @override
  String get feedbackAttachLogsLabel => 'Logs anhängen?';

  @override
  String get feedbackAttachLogsSubtitle =>
      'Eine Diagnosedatei mit Geräteinfos, App-Logs und Netzwerk-Logs anhängen.';
}
