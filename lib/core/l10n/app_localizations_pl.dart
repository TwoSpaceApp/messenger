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
  String get errorInitializationFull =>
      'Błąd inicjalizacji. Uruchom ponownie aplikację.';

  @override
  String get errorNetwork => 'Błąd sieci. Sprawdź połączenie.';

  @override
  String get errorAuth => 'Błąd uwierzytelniania.';

  @override
  String get errorInvalidArguments => 'Nieprawidłowe argumenty.';

  @override
  String get errorInvalidArgumentsProfile => 'Nieprawidłowe argumenty profilu.';

  @override
  String get errorInvalidArgumentsChat => 'Nieprawidłowe argumenty czatu.';

  @override
  String get retry => 'Ponów';

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

  @override
  String errorWithDetail(String error) {
    return 'Błąd: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get next => 'Dalej';

  @override
  String get back => 'Wstecz';

  @override
  String get done => 'Gotowe';

  @override
  String get noData => 'Brak danych';

  @override
  String get nothingFound => 'Nic nie znaleziono';

  @override
  String get copyAction => 'Kopiuj';

  @override
  String get shareAction => 'Udostępnij';

  @override
  String get textCopied => 'Tekst skopiowany';

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
  String get userDefault => 'Użytkownik';

  @override
  String get lessThanMinuteAgo => 'mniej niż minutę temu';

  @override
  String minutesAgo(int count) {
    return '$count min. temu';
  }

  @override
  String hoursAgo(int count) {
    return '$count godz. temu';
  }

  @override
  String daysAgo(int count) {
    return '$count dni temu';
  }

  @override
  String get videoLabel => 'Wideo';

  @override
  String videoLoadError(String error) {
    return 'Błąd wideo: $error';
  }

  @override
  String get saveFailed => 'Zapisywanie nie powiodło się';

  @override
  String get shareSheetFailed => 'Nie można otworzyć udostępniania';

  @override
  String get speedLabel => 'Prędkość:';

  @override
  String get previewTitle => 'Podgląd';

  @override
  String fileDownloaded(String path) {
    return 'Plik pobrany: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return 'Plik tymczasowo zapisany: $path';
  }

  @override
  String get savedToGallery => 'Zapisano w galerii';

  @override
  String authorizationError(String message) {
    return 'Błąd autoryzacji: $message';
  }

  @override
  String get loginTitle => 'Zaloguj się';

  @override
  String get welcomeBack => 'Witaj';

  @override
  String get emailOrUsernameLabel => 'Nazwa użytkownika';

  @override
  String get passwordLabel => 'Hasło';

  @override
  String get loginButton => 'Zaloguj się';

  @override
  String get forgotPassword => 'Zapomniałeś hasła?';

  @override
  String get noAccount => 'Nie masz konta?';

  @override
  String get orDivider => 'Lub';

  @override
  String get validationEnterEmailOrUsername => 'Wpisz nazwę użytkownika';

  @override
  String get validationEnterPassword => 'Wpisz hasło';

  @override
  String get registerTitle => 'Zarejestruj się';

  @override
  String get fillAllFields => 'Wypełnij wszystkie pola';

  @override
  String get passwordStrengthWeak => 'Słabe';

  @override
  String get passwordStrengthMedium => 'Średnie';

  @override
  String get passwordStrengthGood => 'Dobre';

  @override
  String get passwordStrengthStrong => 'Silne';

  @override
  String get fullNameLabel => 'Imię i nazwisko';

  @override
  String get nicknameAtLabel => 'Pseudonim (@użytkownik)';

  @override
  String get uploadPhotoPrompt => 'Prześlij zdjęcie profilowe';

  @override
  String get photoLooksGreat => 'Wygląda świetnie!';

  @override
  String get helpFriendsFind => 'Pomóż znajomym cię znaleźć';

  @override
  String get setupInterfaceTitle => 'Dostosuj interfejs';

  @override
  String get colorThemeLabel => 'Motyw kolorów';

  @override
  String get validationEnterEmail => 'Wpisz e-mail';

  @override
  String get validationInvalidEmail => 'Nieprawidłowy adres e-mail';

  @override
  String get validationPasswordTooShort => 'Hasło zbyt krótkie';

  @override
  String get backToLogin => 'Zaloguj się';

  @override
  String get finishButton => 'Zakończ';

  @override
  String filePickError(String error) {
    return 'Błąd wyboru pliku: $error';
  }

  @override
  String get chatsTitle => 'Czaty';

  @override
  String get noChats => 'Brak czatów';

  @override
  String get noMessages => '(brak wiadomości)';

  @override
  String get newChat => 'Nowy czat';

  @override
  String get messageInputHint => 'Napisz wiadomość...';

  @override
  String get addCaptionHint => 'Dodaj podpis lub wiadomość';

  @override
  String get unlockApp => 'Odblokuj';

  @override
  String get unlockButton => 'Odblokuj';

  @override
  String get dropFilesTitle => 'Upuść pliki do załączenia';

  @override
  String get dropFilesSubtitle => 'Pojawią się nad polem wiadomości.';

  @override
  String get videoUnavailable => 'Film niedostępny';

  @override
  String get guestRole => 'Gość';

  @override
  String get replyAction => 'Odpowiedz';

  @override
  String get editShort => 'Edytuj';

  @override
  String get pinAction => 'Przypnij';

  @override
  String get moreReactions => 'Więcej';

  @override
  String get replyDialogTitle => 'Odpowiedź';

  @override
  String get replyHint => 'Tekst odpowiedzi';

  @override
  String get editMessageTitle => 'Edytuj wiadomość';

  @override
  String get editMessageHint => 'Nowy tekst';

  @override
  String get deleteMessageTitle => 'Usunąć wiadomość?';

  @override
  String get pinsUpdated => 'Pinezki zaktualizowane';

  @override
  String get messageEdited => 'Wiadomość edytowana';

  @override
  String get fileSent => 'Plik wysłany';

  @override
  String get voiceNotSupported =>
      'Nagrywanie głosu nie jest obsługiwane na tej platformie';

  @override
  String get microphonePermRequired => 'Wymagane uprawnienie do mikrofonu';

  @override
  String get recordingError => 'Błąd nagrywania';

  @override
  String sendFailedError(String error) {
    return 'Wysyłanie nie powiodło się: $error';
  }

  @override
  String attachmentSendError(String error) {
    return 'Błąd załącznika: $error';
  }

  @override
  String shareFailedError(String error) {
    return 'Udostępnianie nie powiodło się: $error';
  }

  @override
  String replyError(String error) {
    return 'Błąd odpowiedzi: $error';
  }

  @override
  String pinError(String error) {
    return 'Błąd pinezki: $error';
  }

  @override
  String deleteError(String error) {
    return 'Błąd usuwania: $error';
  }

  @override
  String editMessageError(String error) {
    return 'Błąd edycji: $error';
  }

  @override
  String get userTyping => 'Użytkownik pisze...';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusLastSeenRecently => 'Widziany ostatnio';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get appearanceSection => 'Wygląd';

  @override
  String get themeLabel => 'Motyw';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get customizationLabel => 'Personalizacja';

  @override
  String get customizationSubtitle => 'Kolory, czcionka i efekty UI';

  @override
  String get notificationsSection => 'Powiadomienia';

  @override
  String get notificationsLabel => 'Powiadomienia';

  @override
  String get soundLabel => 'Dźwięk';

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
  String get profileSubtitle => 'Edytuj informacje profilowe';

  @override
  String get accountSettingsLabel => 'Ustawienia konta';

  @override
  String get accountSettingsSubtitle => 'Hasło, bezpieczeństwo, 2FA';

  @override
  String get privacyLabel => 'Prywatność';

  @override
  String get privacySubtitle => 'Zarządzaj prywatnością';

  @override
  String get generalSection => 'Ogólne';

  @override
  String get languageLabel => 'Język';

  @override
  String get textSizeLabel => 'Rozmiar tekstu';

  @override
  String get sendByEnterLabel => 'Wyślij Enterem';

  @override
  String get sendByEnterSubtitle => 'Shift+Enter dla nowej linii';

  @override
  String get dataStorageSection => 'Dane i pamięć';

  @override
  String get autoDownloadLabel => 'Automatyczne pobieranie mediów';

  @override
  String get autoDownloadSubtitle => 'Automatycznie pobierz zdjęcia i filmy';

  @override
  String get storageManagementLabel => 'Zarządzanie pamięcią';

  @override
  String get storageManagementSubtitle => 'Wyczyść pamięć podręczną i dane';

  @override
  String get clearCacheTitle => 'Wyczyść pamięć podręczną';

  @override
  String get clearCacheContent => 'Usunąć dane z pamięci podręcznej?';

  @override
  String get cacheCleared => 'Pamięć podręczna wyczyszczona';

  @override
  String get developmentSection => 'Programowanie';

  @override
  String get devMenuSubtitle => 'Pływający przycisk debugowania';

  @override
  String get aboutSection => 'O aplikacji';

  @override
  String get suggestImprovementLabel => 'Zaproponuj ulepszenie';

  @override
  String get suggestImprovementSubtitle => 'Pomysły i prośby o nowe funkcje';

  @override
  String get dangerZoneSection => 'Strefa niebezpieczna';

  @override
  String get logoutLabel => 'Wyloguj się';

  @override
  String get logoutSubtitle => 'Wyloguj z tego urządzenia';

  @override
  String get logoutDialogTitle => 'Wyloguj się';

  @override
  String get logoutDialogContent => 'Czy na pewno chcesz się wylogować?';

  @override
  String get logoutAction => 'Wyloguj się';

  @override
  String get languageRussian => 'Rosyjski';

  @override
  String get languageUkrainian => 'Ukraiński';

  @override
  String get clientDescription =>
      'Klient TwoSpace stworzony za pomocą Flutter/Dart';

  @override
  String errorLogout(String error) {
    return 'Błąd: $error';
  }

  @override
  String get accountSettingsTitle => 'Ustawienia konta';

  @override
  String get securitySection => 'Bezpieczeństwo';

  @override
  String get twoFactorLabel => 'Uwierzytelnianie dwuskładnikowe';

  @override
  String get twoFactorSubtitle => 'Dodatkowa ochrona konta';

  @override
  String get biometricLabel => 'Biometria';

  @override
  String get biometricSubtitle => 'Logowanie odciskiem palca';

  @override
  String get activeSessionsLabel => 'Aktywne sesje';

  @override
  String get activeSessionsSubtitle => 'Zarządzaj urządzeniami';

  @override
  String get currentDevice => 'Bieżące urządzenie';

  @override
  String get changePasswordSection => 'Zmień hasło';

  @override
  String get currentPasswordLabel => 'Aktualne hasło';

  @override
  String get newPasswordLabel => 'Nowe hasło';

  @override
  String get confirmPasswordLabel => 'Potwierdź hasło';

  @override
  String get minPasswordHelper => 'Minimum 8 znaków';

  @override
  String get changePasswordButton => 'Zmień hasło';

  @override
  String get passwordMismatch => 'Hasła nie są zgodne';

  @override
  String get passwordTooShort => 'Hasło musi mieć co najmniej 8 znaków';

  @override
  String get passwordChangeSuccess => 'Hasło zmienione pomyślnie';

  @override
  String get contactDataSection => 'Dane kontaktowe';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get deleteAccountLabel => 'Usuń konto';

  @override
  String get deleteAccountSubtitle => 'Nieodwracalna operacja';

  @override
  String get deleteAccountTitle => 'Usuń konto';

  @override
  String get deleteAccountContent =>
      'Czy na pewno chcesz usunąć konto? Ta operacja jest nieodwracalna.';

  @override
  String get deleteFeatureLater => 'Usuwanie konta będzie dostępne później';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfileButton => 'Edit profile';

  @override
  String get saveProfileButton => 'Save changes';

  @override
  String get copyAegisIdButton => 'Copy Aegis ID';

  @override
  String get saveTooltip => 'Zapisz';

  @override
  String get editTooltip => 'Edytuj';

  @override
  String get writeMessageButton => 'Wiadomość';

  @override
  String get callButton => 'Zadzwoń';

  @override
  String get aboutField => 'O mnie';

  @override
  String get nicknameField => 'Pseudonim';

  @override
  String get locationField => 'Lokalizacja';

  @override
  String get birthdayField => 'Urodziny';

  @override
  String get nameField => 'Imię';

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
  String get avatarUploadLater => 'Przesyłanie awatara zostanie dodane później';

  @override
  String get profileSaved => 'Profil zapisany';

  @override
  String createChatError(String error) {
    return 'Nie można utworzyć czatu: $error';
  }

  @override
  String get privacyTitle => 'Prywatność';

  @override
  String get hideFromSearch => 'Ukryj z wyszukiwania';

  @override
  String get hideFromSearchSubtitle =>
      'Nie pokazuj mnie w wynikach wyszukiwania';

  @override
  String get hideLastSeen => 'Ukryj ostatnią aktywność';

  @override
  String get hideLastSeenSubtitle => 'Inni nie zobaczą kiedy byłeś online';

  @override
  String get sessionExpiry => 'Wygaśnięcie sesji';

  @override
  String sessionExpirySubtitle(int days) {
    return 'Automatyczne logowanie na tym urządzeniu: $days dni';
  }

  @override
  String get sessionExpiryDaysTitle => 'Wygaśnięcie sesji (dni)';

  @override
  String get sessionExpiryDaysContent =>
      'Wybierz liczbę dni (min: 7, maks: 365).';

  @override
  String get daysLabel => 'Dni';

  @override
  String get enterDaysError => 'Wpisz liczbę od 7 do 365';

  @override
  String sessionExpirySet(int days) {
    return 'Wygaśnięcie sesji: $days dni';
  }

  @override
  String get changeEmailLabel => 'Zmień e-mail';

  @override
  String get changeEmailSubtitle => 'Zaktualizuj adres e-mail';

  @override
  String get twoFactorPrivacySubtitle =>
      'Włącz lub wyłącz zaawansowaną ochronę';

  @override
  String get changePhoneLabel => 'Zmień telefon';

  @override
  String get changePhoneSubtitle => 'Zaktualizuj numer telefonu';

  @override
  String updatePrivacyError(String error) {
    return 'Nie można zaktualizować prywatności: $error';
  }

  @override
  String updateSettingError(String error) {
    return 'Nie można zaktualizować ustawienia: $error';
  }

  @override
  String get contactsTitle => 'Kontakty';

  @override
  String get searchContactsHint => 'Szukaj kontaktów...';

  @override
  String get contactsAccessTitle => 'Dostęp do kontaktów';

  @override
  String get contactsPermDeniedPermanent =>
      'Uprawnienie trwale odmówione. Otwórz ustawienia.';

  @override
  String get contactsPermRequired => 'Wymagane uprawnienie do kontaktów.';

  @override
  String get openSettingsButton => 'Otwórz ustawienia';

  @override
  String get requestPermissionButton => 'Poproś o uprawnienie';

  @override
  String get noContacts => 'Nie znaleziono kontaktów';

  @override
  String get callAction => 'Zadzwoń';

  @override
  String get writeMessageAction => 'Wiadomość';

  @override
  String callNotification(String number) {
    return 'Połączenie: $number';
  }

  @override
  String messageNotification(String name) {
    return 'Wiadomość do: $name';
  }

  @override
  String get callsTitle => 'Połączenia';

  @override
  String get widgetsTitle => 'Widgets';

  @override
  String get searchByNameHint => 'Szukaj po nazwie...';

  @override
  String get allFilter => 'Wszystkie';

  @override
  String get incomingFilter => 'Przychodzące';

  @override
  String get outgoingFilter => 'Wychodzące';

  @override
  String get missedFilter => 'Nieodebrane';

  @override
  String get noCallsFound => 'Brak połączeń';

  @override
  String get yesterdayLabel => 'Wczoraj';

  @override
  String get incomingCall => 'Przychodzące';

  @override
  String get outgoingCall => 'Wychodzące';

  @override
  String get missedCall => 'Nieodebrane';

  @override
  String get videoCallLabel => 'Połączenie wideo';

  @override
  String get voiceCallLabel => 'Połączenie głosowe';

  @override
  String get sendMessageCallAction => 'Wiadomość';

  @override
  String get createRoomTitle => 'Utwórz pokój';

  @override
  String get createButton => 'Utwórz';

  @override
  String get roomNameLabel => 'Nazwa pokoju';

  @override
  String get roomNameHint => 'Np. nazwa projektu';

  @override
  String get roomTopicLabel => 'Temat (opcjonalnie)';

  @override
  String get roomTopicHint => 'O czym jest ten pokój?';

  @override
  String get roomVisibilityLabel => 'Widoczność pokoju';

  @override
  String get privateRoomOption => 'Prywatny pokój';

  @override
  String get privateRoomSubtitle =>
      'Tylko zaproszeni użytkownicy mogą dołączyć';

  @override
  String get publicRoomOption => 'Publiczny pokój';

  @override
  String get publicRoomSubtitle => 'Każdy może dołączyć';

  @override
  String get showHistoryLabel => 'Pokaż historię wiadomości';

  @override
  String get showHistorySubtitle =>
      'Nowi członkowie mogą zobaczyć poprzednie wiadomości';

  @override
  String get enterRoomNameError => 'Wpisz nazwę pokoju';

  @override
  String get roomCreatedSuccess => 'Pokój utworzony pomyślnie!';

  @override
  String imagePickError(String error) {
    return 'Błąd wyboru obrazu: $error';
  }

  @override
  String get groupInfoTab => 'Info';

  @override
  String get groupMembersTab => 'Członkowie';

  @override
  String get groupRolesTab => 'Role';

  @override
  String get groupBansTab => 'Bany';

  @override
  String get groupDeleteTab => 'Usuń';

  @override
  String membersCount(int count) {
    return 'Członkowie: $count';
  }

  @override
  String get messageHistoryToggle => 'Historia wiadomości';

  @override
  String get showHistoryToggleLabel => 'Pokaż historię';

  @override
  String get settingSaved => 'Ustawienie zapisane';

  @override
  String get backgroundColorLabel => 'Kolor tła';

  @override
  String get noMembers => 'Brak członków';

  @override
  String get roleAction => 'Rola';

  @override
  String get freezeAction => 'Zamroź';

  @override
  String get banAction => 'Zbanuj';

  @override
  String get kickAction => 'Wyrzuć';

  @override
  String get noBannedUsers => 'Brak zbanowanych użytkowników';

  @override
  String get bannedLabel => 'Zbanowany';

  @override
  String get userUnbanned => 'Użytkownik odbanowany';

  @override
  String get deleteGroupLabel => 'Usuń grupę';

  @override
  String get deleteGroupWarning =>
      'Ta akcja jest NIEODWRACALNA. Grupa zostanie trwale usunięta.';

  @override
  String get confirmDeleteTitle => 'Potwierdź usunięcie';

  @override
  String get confirmDeleteContent =>
      'Jesteś pewny? Ta akcja jest nieodwracalna.';

  @override
  String get changeRoleTitle => 'Zmień rolę';

  @override
  String get adminRole => 'Administrator';

  @override
  String get memberRole => 'Członek';

  @override
  String get freezeUserTitle => 'Zamroź użytkownika';

  @override
  String get userBanned => 'Użytkownik zbanowany';

  @override
  String get userKicked => 'Użytkownik wyrzucony';

  @override
  String get groupDeleted => 'Grupa usunięta';

  @override
  String loadError(String error) {
    return 'Błąd ładowania: $error';
  }

  @override
  String get publicLabel => 'Publiczny';

  @override
  String get privateLabel => 'Prywatny';

  @override
  String get noDescription => 'Brak opisu';

  @override
  String get membersLabel => 'Członkowie';

  @override
  String get generalLabel => 'Ogólne';

  @override
  String get newChatTitle => 'Nowy czat';

  @override
  String get newChatChooserTitle => 'Start a new conversation';

  @override
  String get newChatChooserSubtitle =>
      'Choose the kind of chat you want to create or join.';

  @override
  String get createDirectChatSubtitle =>
      'Search for a person or enter an Aegis ID manually.';

  @override
  String get directChatTab => 'Bezpośredni';

  @override
  String get groupChatTab => 'Grupa';

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
  String get startDirectChatTitle => 'Rozpocznij czat bezpośredni';

  @override
  String get contactIdDescription =>
      'Wpisz nazwę użytkownika lub identyfikator Aegis';

  @override
  String get contactIdLabel => 'Nazwa użytkownika lub ID Aegis';

  @override
  String get startChatButton => 'Rozpocznij czat';

  @override
  String get hintCardTitle => 'Wskazówka';

  @override
  String get contactIdExplanation =>
      'Możesz użyć nazwy użytkownika lub numerycznego identyfikatora Aegis';

  @override
  String get enterUserIdError => 'Wpisz ID użytkownika';

  @override
  String get createNewRoomTitle => 'Utwórz nowy pokój';

  @override
  String get descriptionOptionalLabel => 'Opis (opcjonalnie)';

  @override
  String get privateGroupLabel => 'Prywatna grupa';

  @override
  String get privateGroupSubtitle =>
      'Tylko zaproszeni użytkownicy mogą dołączyć';

  @override
  String get createRoomButton => 'Utwórz pokój';

  @override
  String get customizationTitle => 'Personalizacja';

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
  String get colorsTab => 'Kolory';

  @override
  String get fontsTab => 'Czcionki';

  @override
  String get effectsTab => 'Efekty';

  @override
  String get selectColorTheme => 'Wybierz motyw kolorów';

  @override
  String get themeAppliesEverywhere =>
      'Wybrany motyw jest stosowany w całej aplikacji';

  @override
  String get fontSettingsTitle => 'Ustawienia czcionki';

  @override
  String get selectFontFamily => 'Wybierz rodzinę czcionek';

  @override
  String get appFontLabel => 'Czcionka aplikacji';

  @override
  String get fontWeightLabel => 'Grubość czcionki';

  @override
  String get fontPreview => 'Podgląd: Przykładowy tekst';

  @override
  String get compactMode => 'Zmniejsz odstępy i rozmiary';

  @override
  String get enableCircles => 'Włącz okręgi';

  @override
  String get circlesDesc => 'Animowane okręgi w tle';

  @override
  String get floatingCirclesLabel => 'Pływające okręgi';

  @override
  String get reactOnTilt => 'Reaguj na pochylenie telefonu';

  @override
  String get parallaxEffect => 'Efekt paralaksy';

  @override
  String get circlesSpeedLabel => 'Prędkość ruchu';

  @override
  String get staticMotion => 'Statyczny';

  @override
  String get brightnessLabel => 'Jasność';

  @override
  String get dimOpacity => 'Przyciemniony';

  @override
  String get brightOpacity => 'Jasny';

  @override
  String get performanceLabel => 'Wydajność';

  @override
  String get currentSpeedPrefix => 'Aktualnie: ';

  @override
  String get speedPrefix => 'Prędkość:';

  @override
  String get advancedSearchTitle => 'Zaawansowane wyszukiwanie';

  @override
  String get searchQueryHint => 'Wpisz zapytanie...';

  @override
  String get searchTypeLabel => 'Typ wyszukiwania';

  @override
  String get searchTypeAll => 'Wszystko';

  @override
  String get searchTypeMessages => 'Wiadomości';

  @override
  String get searchTypeMedia => 'Media';

  @override
  String get searchTypeUsers => 'Użytkownicy';

  @override
  String get periodLabel => 'Okres';

  @override
  String get fromDate => 'Od';

  @override
  String get toDate => 'Do';

  @override
  String get searchButton => 'Szukaj';

  @override
  String resultsCount(int count) {
    return 'Wyniki ($count)';
  }

  @override
  String get noResultsFound => 'Nie znaleziono wyników';

  @override
  String get forgotPasswordTitle => 'Odzyskaj hasło';

  @override
  String get forgotPasswordDescription =>
      'Wpisz e-mail, aby otrzymać link resetowania';

  @override
  String get sendResetButton => 'Wyślij';

  @override
  String get forgotPasswordUnavailable => 'Odzyskiwanie hasła niedostępne';

  @override
  String get changeEmailTitle => 'Zmień e-mail';

  @override
  String get changeEmailDescription => 'Wpisz nowy adres e-mail';

  @override
  String get currentPrefix => 'Aktualnie: ';

  @override
  String get newEmailLabel => 'Nowy e-mail';

  @override
  String get changeEmailButton => 'Zmień e-mail';

  @override
  String changeEmailError(String error) {
    return 'Nie można zmienić e-maila: $error';
  }

  @override
  String get changePhoneTitle => 'Zmień numer telefonu';

  @override
  String get changePhoneDescription =>
      'Wpisz nowy numer telefonu i aktualne hasło.';

  @override
  String get newPhoneLabel => 'Nowy numer (+48...)';

  @override
  String get currentPasswordOptional => 'Aktualne hasło (jeśli wymagane)';

  @override
  String get changePhoneButton => 'Zmień numer';

  @override
  String get phoneCannotBeChanged => 'Numer telefonu nie może być zmieniony';

  @override
  String get emailCannotBeChanged => 'Adres email nie może zostać zmieniony';

  @override
  String changePhoneError(String error) {
    return 'Nie można zmienić numeru: $error';
  }

  @override
  String get confirmCodeTitle => 'Potwierdź kod';

  @override
  String codeSentTo(String phone) {
    return 'Wysłaliśmy kod na $phone';
  }

  @override
  String get enterCodeHint => 'Wpisz kod';

  @override
  String get confirmButton => 'Potwierdź';

  @override
  String resendCountdown(int seconds) {
    return 'Wyślij ponownie za $seconds s';
  }

  @override
  String get resendCodeButton => 'Wyślij kod ponownie';

  @override
  String get biometricSetupTitle => 'Bezpieczeństwo';

  @override
  String get authMethodsLabel => 'Metody uwierzytelniania';

  @override
  String get biometricAuthLabel => 'Uwierzytelnianie biometryczne';

  @override
  String get biometricAuthSubtitle => 'Odcisk palca lub Face ID';

  @override
  String get biometricEnabledLabel => 'Biometria włączona';

  @override
  String get aboutSecurityLabel => 'O bezpieczeństwie';

  @override
  String get aboutSecurityContent => 'Wybierz wygodną metodę uwierzytelniania.';

  @override
  String get setPinCode => 'Ustaw kod PIN';

  @override
  String get updateAvailableTitle => 'Dostępna aktualizacja';

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
  String get whatsNewLabel => 'Co nowego';

  @override
  String get noUpdateDescription => 'Brak opisu';

  @override
  String downloadingProgress(int percent) {
    return 'Pobieranie... $percent%';
  }

  @override
  String get checkingIntegrity => 'Sprawdzanie integralności...';

  @override
  String get requestingInstall => 'Żądanie instalacji...';

  @override
  String get updateMandatory => 'Aktualizacja obowiązkowa';

  @override
  String get laterButton => 'Później';

  @override
  String get downloadingLabel => 'Pobieranie...';

  @override
  String get installingLabel => 'Instalowanie...';

  @override
  String get updateButton => 'Aktualizuj';

  @override
  String get downloadFailed => 'Nie można pobrać aktualizacji';

  @override
  String get integrityCheckFailed =>
      'Pobrany plik nie przeszedł kontroli integralności (sha256)';

  @override
  String get installPermissionTitle => 'Uprawnienie instalacji';

  @override
  String get installPermissionContent =>
      'Zezwól na instalację z nieznanych źródeł.';

  @override
  String get installPermissionRequired => 'Wymagane uprawnienie do instalacji';

  @override
  String get installFailed => 'Instalacja nie powiodła się';

  @override
  String get ssoFeatureRequired =>
      'Ta funkcja wymaga konfiguracji webview_flutter';

  @override
  String ssoLoginVia(String idpId) {
    return 'Logowanie SSO przez $idpId';
  }

  @override
  String get forwardMessageTitle => 'Przekaż wiadomość';

  @override
  String get searchChatHint => 'Szukaj czatu...';

  @override
  String forwardButton(int count) {
    return 'Przekaż ($count)';
  }

  @override
  String get roomAvatarUpdated => 'Awatar pokoju zaktualizowany';

  @override
  String roomAvatarUploadError(String error) {
    return 'Błąd przesyłania awatara: $error';
  }

  @override
  String get roomSettingsSaved => 'Ustawienia pokoju zapisane';

  @override
  String roomSettingsSaveError(String error) {
    return 'Błąd zapisywania: $error';
  }

  @override
  String get uploadAvatarButton => 'Prześlij awatar';

  @override
  String loadMembersError(String error) {
    return 'Błąd ładowania członków: $error';
  }

  @override
  String get leaveRoomTitle => 'Opuścić pokój?';

  @override
  String get leaveRoomContent =>
      'Nie będziesz mógł wrócić bez ponownego zaproszenia.';

  @override
  String get leaveAction => 'Opuść';

  @override
  String get leftRoom => 'Opuściłeś pokój';

  @override
  String leaveRoomError(String error) {
    return 'Błąd podczas opuszczania: $error';
  }

  @override
  String get reportNotImplemented =>
      'Funkcja zgłaszania nie jest jeszcze zaimplementowana';

  @override
  String get featureInDevelopmentLabel => 'W przygotowaniu';

  @override
  String featureInDevelopmentMessage(String feature) {
    return 'Ta funkcja jest nadal rozwijana i będzie dostępna w jednej z kolejnych wersji.';
  }

  @override
  String get inviteAction => 'Zaproś';

  @override
  String get threadsLabel => 'Wątki';

  @override
  String get pinnedLabel => 'Przypięte';

  @override
  String get filesLabel => 'Pliki';

  @override
  String get noSharedFiles => 'Brak udostępnionych plików';

  @override
  String get mediaLabel => 'Media';

  @override
  String get noSharedMedia => 'Brak udostępnionych multimediów';

  @override
  String get extensionsLabel => 'Rozszerzenia';

  @override
  String get copyLinkAction => 'Kopiuj link';

  @override
  String get pollsLabel => 'Ankiety';

  @override
  String get exportChatAction => 'Eksportuj czat';

  @override
  String get reportAction => 'Zgłoś';

  @override
  String get leaveRoomAction => 'Opuść pokój';

  @override
  String roomTitle(String name) {
    return 'Pokój — $name';
  }

  @override
  String get roomSettingsLabel => 'Ustawienia pokoju';

  @override
  String authError(String error) {
    return 'Błąd uwierzytelniania: $error';
  }

  @override
  String get loginRequired => 'Wymagane logowanie';

  @override
  String get loginRequiredContent =>
      'Musisz być zalogowany, aby szukać kontaktów. Przejść do logowania?';

  @override
  String get loginAction => 'Zaloguj się';

  @override
  String searchError(String error) {
    return 'Błąd wyszukiwania: $error';
  }

  @override
  String get searchContactsTitle => 'Szukaj kontaktów';

  @override
  String get nicknameOrPhoneHint => 'Pseudonim lub numer telefonu';

  @override
  String selectContactError(String error) {
    return 'Nie można wybrać kontaktu: $error';
  }

  @override
  String get categoryLabel => 'Kategoria';

  @override
  String get feedbackCategoryFeatures => 'Funkcje';

  @override
  String get feedbackCategoryPerformance => 'Wydajność';

  @override
  String get feedbackCategorySecurity => 'Bezpieczeństwo/Prywatność';

  @override
  String get feedbackCategoryNetworkSync => 'Synchronizacja/Sieć';

  @override
  String get shortDescriptionLabel => 'Krótki opis';

  @override
  String get shortDescriptionHint => 'Np. \"Kopia zapasowa czatów w chmurze\"';

  @override
  String get feedbackValidation =>
      'Wybierz co najmniej jeden pomysł lub wpisz opis';

  @override
  String get detailsOptionalLabel => 'Szczegóły (opcjonalnie)';

  @override
  String get detailsHint =>
      'Co powinno działać, jak to działa teraz i jak chciałbyś?';

  @override
  String get bigFeaturesTitle =>
      'Główne funkcje (zaznacz co Cię najbardziej interesuje)';

  @override
  String get feedbackE2E =>
      'Szyfrowanie E2E end-to-end (Olm/Megolm) + weryfikacja urządzeń';

  @override
  String get feedbackBackup =>
      'Kopia zapasowa czatów (lokalna/chmura) + przeniesienie na nowe urządzenie';

  @override
  String get feedbackThreads =>
      'Wątki, reakcje, wzmianki, ulepszone wyszukiwanie wiadomości';

  @override
  String get feedbackCalls => 'Rozmowy głosowe/wideo i szybkie pokoje głosowe';

  @override
  String get feedbackFolders =>
      'Foldery/kategorie czatów i inteligentne filtry powiadomień';

  @override
  String get feedbackBots =>
      'Boty i integracje (webhook, GitHub/Jira, przypomnienia)';

  @override
  String get feedbackSlowNet =>
      'Tryb \"powolny internet\" + agresywne buforowanie multimediów';

  @override
  String get startChatTitle => 'Rozpocznij czat';

  @override
  String get startDirectChatSubtitle =>
      'Open a private conversation with one person';

  @override
  String get createRoomSubtitle => 'Prywatna lub publiczna grupa';

  @override
  String get inviteUserTitle => 'Zaproś użytkownika';

  @override
  String get inviteUserSubtitle => 'Znajdź i napisz do użytkownika';

  @override
  String get addParticipantAction => 'Add participant';

  @override
  String get selectedParticipantsTitle => 'Participants';

  @override
  String get groupParticipantsOptionalHint =>
      'Participants are optional. You can create the group now and invite people later.';

  @override
  String get joinByCodeTitle => 'Dołącz przez kod';

  @override
  String get joinByCodeSubtitle => 'Dołącz do pokoju używając kodu zaproszenia';

  @override
  String get joinRoomAction => 'Join';

  @override
  String get subscribeAction => 'Subscribe';

  @override
  String get chatsSubtitle =>
      'Wiadomości prywatne, grupy i linki zaproszeń w jednym miejscu';

  @override
  String get chatsQuickStartTitle => 'Zacznij coś nowego';

  @override
  String get chatsRecentTitle => 'Ostatnie czaty';

  @override
  String get joinLinkHint => 'Wklej link zaproszenia, alias lub kod';

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
  String get fontLabel => 'Czcionka';

  @override
  String get pinCodeLabel => 'Kod PIN';

  @override
  String get pinCodeSubtitle => '4-6 cyfr dla ochrony';

  @override
  String get pinHint => 'PIN (4-6 cyfr)';

  @override
  String get pinLengthError => 'PIN musi mieć 4-6 cyfr';

  @override
  String get pinSetSuccess => 'PIN ustawiony';

  @override
  String get cancelButton => 'Anuluj';

  @override
  String get deleteButton => 'Usuń';

  @override
  String get closeButton => 'Zamknij';

  @override
  String get saveButton => 'Zapisz';

  @override
  String get sendButton => 'Wyślij';

  @override
  String get copyButton => 'Kopiuj';

  @override
  String get shareButton => 'Udostępnij';

  @override
  String get settingsLabel => 'Ustawienia';

  @override
  String get feedbackCategoryUxDesign => 'UX/Design';

  @override
  String get feedbackShareSubject => 'TwoSpace — sugestia';

  @override
  String get feedbackMessageHeader => 'TwoSpace — sugestia/ulepszenie';

  @override
  String feedbackVersion(String version) {
    return 'Wersja: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return 'Kategoria: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return 'Krótko: $title';
  }

  @override
  String get feedbackWishList => 'Co byłoby szczególnie świetne:';

  @override
  String get feedbackDetailsLine => 'Szczegóły:';

  @override
  String get circlesVisible => 'Kółka widoczne';

  @override
  String get circlesHidden => 'Kółka ukryte';

  @override
  String get speedSlow => 'Wolno';

  @override
  String get speedFast => 'Szybko';

  @override
  String get advancedSettingsLabel => 'Zaawansowane ustawienia';

  @override
  String get compactModeLabel => 'Tryb kompaktowy';

  @override
  String get activeDeviceInfo => 'Android • Aktywny';

  @override
  String stubPlaceholder(String key) {
    return 'Stub — $key';
  }

  @override
  String loadMessagesError(String error) {
    return 'Błąd ładowania wiadomości: $error';
  }

  @override
  String get pinnedUpdated => 'Przypięte zaktualizowane';

  @override
  String editError(String error) {
    return 'Błąd edycji: $error';
  }

  @override
  String get moreButton => 'Więcej';

  @override
  String shareError(String error) {
    return 'Nie można udostępnić: $error';
  }

  @override
  String sendError(String error) {
    return 'Błąd wysyłania: $error';
  }

  @override
  String get voiceRecordingUnsupported =>
      'Nagrywanie głosu nie jest obsługiwane na tej platformie';

  @override
  String get microphonePermissionRequired =>
      'Wymagane uprawnienie do mikrofonu';

  @override
  String genericError(String error) {
    return 'Błąd: $error';
  }

  @override
  String get ownersLabel => '👑 Właściciele';

  @override
  String get administratorsLabel => '⚡ Administratorzy';

  @override
  String get oneHour => '1 godzina';

  @override
  String get oneDay => '1 dzień';

  @override
  String get sevenDays => '7 dni';

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
  String get storageMemoryTitle => 'Pamięć';

  @override
  String get storageTotalLabel => 'Razem';

  @override
  String get storageSelectedLabel => 'Selected';

  @override
  String get storagePhotosLabel => 'Zdjęcia';

  @override
  String get storageVideosLabel => 'Wideo';

  @override
  String get storageCacheLabel => 'Pamięć podręczna';

  @override
  String get storageAppDataLabel => 'Dane aplikacji';

  @override
  String get storageCleanupTitle => 'Do wyczyszczenia';

  @override
  String get storageCleanupSubtitle => 'Sprawdź, co można bezpiecznie usunąć.';

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
  String get peopleTitle => 'Ludzie';

  @override
  String get peopleSubtitle =>
      'Kontakty, ulubione, wyszukiwanie i zaproszenia w jednym miejscu';

  @override
  String get peopleQuickNewChat => 'Nowy czat';

  @override
  String get peopleQuickInvite => 'Zaproś';

  @override
  String get peopleQuickSync => 'Synchronizuj';

  @override
  String get peopleSearchHint => 'Szukaj po nazwie, nicku lub numerze telefonu';

  @override
  String get peopleSegmentAll => 'Wszyscy';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => 'Książka kontaktów';

  @override
  String get peopleSegmentRecent => 'Ostatnie';

  @override
  String get peopleLoading => 'Ładowanie osób…';

  @override
  String get peopleNoPeopleTitle => 'Jeszcze nikogo nie ma';

  @override
  String get peopleNoPeopleMessage =>
      'Tutaj pojawią się ulubione, ostatnie rozmowy i kontakty.';

  @override
  String get peoplePermissionCardTitle => 'Ograniczony dostęp do kontaktów';

  @override
  String get peoplePermissionCardMessage =>
      'Zezwól na dostęp do kontaktów, aby wyświetlać książkę kontaktów i szybciej zapraszać osoby.';

  @override
  String get peoplePermissionCardMessageSettings =>
      'Włącz dostęp do kontaktów w ustawieniach systemowych, aby przywrócić sekcję książki kontaktów.';

  @override
  String get peopleFavoritesFrequentTitle => 'Ulubione i częste';

  @override
  String get peopleRecentTitle => 'Ostatnie osoby';

  @override
  String get peopleTwoSpaceTitle => 'Osoby w TwoSpace';

  @override
  String get peopleInviteTitle => 'Zaproś do TwoSpace';

  @override
  String get peopleInviteSubtitle => 'Zaproś ten kontakt do TwoSpace';

  @override
  String get peopleSearching => 'Wyszukiwanie osób…';

  @override
  String get peopleSearchRemoteTitle => 'Wyniki TwoSpace';

  @override
  String get peopleSearchLocalTitle => 'Ostatnie i zapisane';

  @override
  String get peopleSearchInviteTitle => 'Zaproś z książki kontaktów';

  @override
  String get peopleSearchEmptyTitle => 'Brak pasujących osób';

  @override
  String get peopleSearchEmptyMessage =>
      'Spróbuj innej nazwy, nicku lub numeru telefonu.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => 'Brak dodatkowych szczegółów';

  @override
  String get peopleInviteShareText =>
      'Dołącz do mnie na TwoSpace — bezpiecznym komunikatorze do czatów i rozmów.';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return 'Dołącz do mnie na TwoSpace, $personName — rozmawiajmy i dzwońmy bezpiecznie.';
  }

  @override
  String get peopleViewProfileAction => 'Pokaż profil';

  @override
  String get peopleRemoveFavoriteAction => 'Usuń z ulubionych';

  @override
  String get peopleAddFavoriteAction => 'Dodaj do ulubionych';

  @override
  String get callsSubtitle =>
      'Ostatnie połączenia, szybkie oddzwanianie i historia skupiona na osobach';

  @override
  String get widgetsSubtitle =>
      'Home, lock-screen, and glanceable surfaces for your conversations';

  @override
  String get widgetsComingTitle => 'Widgets are on the way';

  @override
  String get widgetsComingBody =>
      'We are preparing flexible widget layouts for quick actions, unread counters, and compact conversation previews.';

  @override
  String get callsStartCallAction => 'Rozpocznij połączenie';

  @override
  String get callsQuickStartTitle => 'Zadzwoń teraz';

  @override
  String get callsQuickStartSubtitle =>
      'Otwórz Ludzie, znajdź osobę i rozpocznij bezpieczne połączenie głosowe lub wideo.';

  @override
  String get callsSearchHint => 'Szukaj w historii połączeń';

  @override
  String get callsVideoFilter => 'Wideo';

  @override
  String get callsTopContactsTitle => 'Częste kontakty';

  @override
  String get callsLoadingLabel => 'Ładowanie połączeń…';

  @override
  String get callsEmptyTitle => 'Brak połączeń';

  @override
  String get callsEmptyMessage =>
      'Historia połączeń pojawi się tutaj po pierwszym połączeniu głosowym lub wideo.';

  @override
  String get callsEmptySearchMessage =>
      'Żadne połączenie nie pasuje do bieżącego wyszukiwania lub filtra.';

  @override
  String get callsTodaySection => 'Dzisiaj';

  @override
  String get callsThisWeekSection => 'W tym tygodniu';

  @override
  String get callsEarlierSection => 'Wcześniej';

  @override
  String callsThreadCount(int count) {
    return '$count połączeń';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count nieodebranych';
  }

  @override
  String get callsMuteAction => 'Wycisz';

  @override
  String get callsSpeakerAction => 'Głośnik';

  @override
  String get callsCameraAction => 'Kamera';

  @override
  String get callsSwitchCameraAction => 'Przełącz';

  @override
  String get callsEndAction => 'Zakończ połączenie';

  @override
  String get callsConnectingLabel => 'Łączenie…';

  @override
  String get callsRingingLabel => 'Dzwoni…';

  @override
  String get callsConnectingDetail => 'Tworzenie bezpiecznej sesji połączenia.';

  @override
  String get callsRingingDetail => 'Oczekiwanie na odpowiedź drugiej osoby.';

  @override
  String get callsVideoSecureDetail =>
      'Wideo jest chronione i przesyłane przez bieżącą bezpieczną sesję.';

  @override
  String get callsVoiceSecureDetail =>
      'Głos jest chroniony i przesyłany przez bieżącą bezpieczną sesję.';

  @override
  String get timestampPrecisionLabel => 'Dokładność czasu wiadomości';

  @override
  String get timestampPrecisionSubtitle =>
      'Wybierz, jak szczegółowo pokazywać czas w czatach i na liście czatów.';

  @override
  String get timestampPrecisionMinutes => 'Godziny i minuty';

  @override
  String get timestampPrecisionSeconds => 'Godziny, minuty i sekundy';

  @override
  String get timestampPrecisionMilliseconds =>
      'Godziny, minuty, sekundy i milisekundy';

  @override
  String get startupTitle => 'Przygotowywanie TwoSpace';

  @override
  String get startupSubtitle =>
      'Sprawdzamy bezpieczną sesję i otwieramy Twoje czaty.';

  @override
  String get startupFooter =>
      'Ten ekran jest wyświetlany tylko podczas uruchamiania aplikacji.';

  @override
  String get startupStepEnvironment => 'Ładowanie konfiguracji';

  @override
  String get startupStepDiagnostics => 'Uruchamianie diagnostyki';

  @override
  String get startupStepValidation => 'Sprawdzanie środowiska';

  @override
  String get startupStepSettings => 'Ładowanie ustawień';

  @override
  String get startupStepSession => 'Przywracanie bezpiecznej sesji';

  @override
  String get startupStepLaunch => 'Uruchamianie aplikacji';

  @override
  String get callsDemoBannerTitle => 'Przykład, niedziałająca funkcja';

  @override
  String get callsDemoBannerVoiceMessage =>
      'Połączenia głosowe są obecnie pokazane tylko jako wizualny prototyp. Transmisja audio nie jest jeszcze podłączona.';

  @override
  String get callsDemoBannerVideoMessage =>
      'Połączenia wideo są obecnie pokazane tylko jako wizualny prototyp. Zdalny obraz nie jest jeszcze dostępny, ale lokalny podgląd kamery działa.';

  @override
  String get callsCameraPermissionMessage =>
      'Zezwól na dostęp do kamery, aby wyświetlać lokalny podgląd podczas połączenia wideo.';

  @override
  String get callsCameraPermissionSettingsMessage =>
      'Dostęp do kamery jest zablokowany. Otwórz ustawienia systemowe, aby włączyć lokalny podgląd wideo.';

  @override
  String get callsCameraPermissionAction => 'Zezwól na kamerę';

  @override
  String get callsCameraUnavailableTitle => 'Kamera niedostępna';

  @override
  String get callsCameraUnavailableMessage =>
      'Nie udało się uruchomić lokalnego podglądu kamery na tym urządzeniu.';

  @override
  String get callsCameraUnsupportedMessage =>
      'Ta platforma nie obsługuje lokalnego podglądu wideo.';

  @override
  String get callsCameraOffMessage =>
      'Podgląd kamery jest wyłączony dla tego połączenia demonstracyjnego.';

  @override
  String get callsFrontCameraLabel => 'Przednia kamera';

  @override
  String get callsRearCameraLabel => 'Tylna kamera';

  @override
  String get backgroundOptimizationDisabledTitle =>
      'Efekty tła zostały uproszczone';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace wykrył długotrwałe spadki płynności i wyłączył ciężkie efekty tła, aby przewijanie i obsługa czatów pozostały płynne.';

  @override
  String get backgroundOptimizationOpenSettings => 'Otwórz ustawienia wyglądu';

  @override
  String get roomJoinRuleLabel => 'Kto może dołączyć';

  @override
  String get roomJoinRulePublic => 'Otwarte dla wszystkich';

  @override
  String get roomJoinRulePublicDescription =>
      'Każdy może znaleźć i dołączyć do tego pokoju.';

  @override
  String get roomJoinRuleInviteOnly => 'Tylko na zaproszenie';

  @override
  String get roomJoinRuleInviteOnlyDescription =>
      'Tylko zaproszeni użytkownicy mogą dołączyć do tego pokoju.';

  @override
  String get roomJoinRuleApproval => 'Wymagana akceptacja';

  @override
  String get roomJoinRuleApprovalDescription =>
      'Użytkownicy mogą poprosić o dostęp i muszą zostać zaakceptowani przed dołączeniem.';

  @override
  String get roomHistoryVisibilityLabel => 'Kto może zobaczyć historię';

  @override
  String get roomHistoryVisibilityWorldReadable => 'Wszyscy';

  @override
  String get roomHistoryVisibilityWorldReadableDescription =>
      'Każdy może zobaczyć wcześniejsze wiadomości.';

  @override
  String get roomHistoryVisibilityJoined => 'Dołączeni członkowie';

  @override
  String get roomHistoryVisibilityJoinedDescription =>
      'Tylko członkowie, którzy już dołączyli, mogą zobaczyć wcześniejsze wiadomości.';

  @override
  String get roomHistoryVisibilityInvited => 'Tylko zaproszeni użytkownicy';

  @override
  String get roomHistoryVisibilityInvitedDescription =>
      'Tylko zaproszeni użytkownicy mogą zobaczyć wcześniejsze wiadomości.';

  @override
  String get loginUsernameOnlyError =>
      'Do logowania użyj swojej nazwy użytkownika TwoSpace.';

  @override
  String get twoFactorInvalidCodeMessage =>
      'Kod 2FA lub fraza odzyskiwania są nieprawidłowe. Spróbuj ponownie.';

  @override
  String get twoFactorCodeRequiredMessage =>
      'Wpisz kod z aplikacji uwierzytelniającej lub użyj frazy odzyskiwania.';

  @override
  String get twoFactorEnabledMessage =>
      'Uwierzytelnianie dwuskładnikowe zostało włączone.';

  @override
  String twoFactorEnableFailed(String error) {
    return 'Nie udało się włączyć 2FA: $error';
  }

  @override
  String get twoFactorSetupTitle =>
      'Skonfiguruj uwierzytelnianie dwuskładnikowe';

  @override
  String get twoFactorSetupDescription =>
      'Zeskanuj kod QR w aplikacji uwierzytelniającej, zapisz frazę odzyskiwania, a następnie potwierdź świeżym kodem TOTP.';

  @override
  String get twoFactorSecretTitle => 'Lub wpisz ten tajny klucz ręcznie';

  @override
  String get twoFactorRecoveryPhraseTitle =>
      'Fraza odzyskiwania. Zapisz ją w bezpiecznym miejscu przed włączeniem 2FA.';

  @override
  String get twoFactorVerificationCodeLabel => 'Kod weryfikacyjny';

  @override
  String get twoFactorVerificationCodeHint =>
      'Wpisz bieżący kod z aplikacji uwierzytelniającej';

  @override
  String get twoFactorVerifyEnableAction => 'Zweryfikuj i włącz 2FA';

  @override
  String get twoFactorDisableSectionTitle =>
      'Wyłącz uwierzytelnianie dwuskładnikowe';

  @override
  String get twoFactorDisableSectionDescription =>
      'Wyłącz 2FA za pomocą poprawnego kodu z aplikacji uwierzytelniającej lub jednorazowej frazy odzyskiwania.';

  @override
  String get twoFactorDisableCodeHint =>
      'Wpisz bieżący kod z aplikacji uwierzytelniającej';

  @override
  String get twoFactorRecoveryPhraseFieldLabel => 'Fraza odzyskiwania';

  @override
  String get twoFactorRecoveryPhraseFieldHint =>
      'Wklej frazę odzyskiwania, jeśli nie masz już dostępu do aplikacji uwierzytelniającej';

  @override
  String get twoFactorDisableAction => 'Wyłącz 2FA';

  @override
  String get twoFactorDisableCredentialsRequired =>
      'Aby wyłączyć 2FA, wpisz kod z aplikacji uwierzytelniającej lub frazę odzyskiwania.';

  @override
  String get twoFactorDisabledMessage =>
      'Uwierzytelnianie dwuskładnikowe zostało wyłączone.';

  @override
  String twoFactorDisableFailed(String error) {
    return 'Nie udało się wyłączyć 2FA: $error';
  }

  @override
  String get twoFactorLoginRecoveryHint =>
      'Lub wklej frazę odzyskiwania zamiast kodu';

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
      'Dostarczanie powiadomień i zaawansowane ustawienia są jeszcze dopracowywane.';

  @override
  String get devMenuCopyVisible => 'Kopiuj widoczne';

  @override
  String get devMenuExportLogFile => 'Eksportuj plik logów';

  @override
  String get devMenuNewestFirst => 'Najnowsze najpierw';

  @override
  String get devMenuOldestFirst => 'Najstarsze najpierw';

  @override
  String get feedbackAttachLogsLabel => 'Dołączyć logi?';

  @override
  String get feedbackAttachLogsSubtitle =>
      'Dołącza plik diagnostyczny z informacjami o urządzeniu, logami aplikacji i logami sieci.';
}
