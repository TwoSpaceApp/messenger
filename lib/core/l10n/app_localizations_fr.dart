// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Chargement...';

  @override
  String get initializing => 'Initialisation...';

  @override
  String get errorGeneric => 'Une erreur s\'est produite';

  @override
  String get errorInitialization => 'Erreur d\'initialisation';

  @override
  String get errorInitializationFull =>
      'Erreur d\'initialisation. Veuillez redémarrer l\'application.';

  @override
  String get errorNetwork => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get errorAuth => 'Erreur d\'authentification.';

  @override
  String get errorInvalidArguments => 'Arguments invalides.';

  @override
  String get errorInvalidArgumentsProfile =>
      'Arguments invalides pour le profil.';

  @override
  String get errorInvalidArgumentsChat => 'Arguments invalides pour le chat.';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get send => 'Envoyer';

  @override
  String get close => 'Fermer';

  @override
  String errorWithDetail(String error) {
    return 'Erreur : $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get done => 'Terminé';

  @override
  String get noData => 'Pas de données';

  @override
  String get nothingFound => 'Rien trouvé';

  @override
  String get copyAction => 'Copier';

  @override
  String get shareAction => 'Partager';

  @override
  String get textCopied => 'Texte copié';

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
  String get onlineLabel => 'En ligne';

  @override
  String get offlineLabel => 'Hors ligne';

  @override
  String get userDefault => 'Utilisateur';

  @override
  String get lessThanMinuteAgo => 'il y a moins d\'une minute';

  @override
  String minutesAgo(int count) {
    return 'Il y a $count min.';
  }

  @override
  String hoursAgo(int count) {
    return 'Il y a $count h.';
  }

  @override
  String daysAgo(int count) {
    return 'Il y a $count j.';
  }

  @override
  String get videoLabel => 'Vidéo';

  @override
  String videoLoadError(String error) {
    return 'Erreur vidéo : $error';
  }

  @override
  String get saveFailed => 'Échec de l\'enregistrement';

  @override
  String get shareSheetFailed => 'Impossible d\'ouvrir le partage';

  @override
  String get speedLabel => 'Vitesse :';

  @override
  String get previewTitle => 'Aperçu';

  @override
  String fileDownloaded(String path) {
    return 'Fichier téléchargé : $path';
  }

  @override
  String fileSavedTemp(String path) {
    return 'Fichier temporairement enregistré : $path';
  }

  @override
  String get savedToGallery => 'Enregistré dans la galerie';

  @override
  String authorizationError(String message) {
    return 'Erreur d\'autorisation : $message';
  }

  @override
  String get loginTitle => 'Connexion';

  @override
  String get welcomeBack => 'Bienvenue';

  @override
  String get emailOrUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get noAccount => 'Pas de compte ?';

  @override
  String get orDivider => 'Ou';

  @override
  String get validationEnterEmailOrUsername => 'Entrez le nom d\'utilisateur';

  @override
  String get validationEnterPassword => 'Entrez le mot de passe';

  @override
  String get registerTitle => 'S\'inscrire';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get passwordStrengthWeak => 'Faible';

  @override
  String get passwordStrengthMedium => 'Moyen';

  @override
  String get passwordStrengthGood => 'Bon';

  @override
  String get passwordStrengthStrong => 'Fort';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get nicknameAtLabel => 'Surnom (@utilisateur)';

  @override
  String get uploadPhotoPrompt => 'Téléchargez votre photo de profil';

  @override
  String get photoLooksGreat => 'Vous avez l\'air super !';

  @override
  String get helpFriendsFind => 'Aidez vos amis à vous trouver';

  @override
  String get setupInterfaceTitle => 'Personnalisez votre interface';

  @override
  String get colorThemeLabel => 'Thème de couleur';

  @override
  String get validationEnterEmail => 'Entrez l\'e-mail';

  @override
  String get validationInvalidEmail => 'Adresse e-mail invalide';

  @override
  String get validationPasswordTooShort => 'Mot de passe trop court';

  @override
  String get backToLogin => 'Connexion';

  @override
  String get finishButton => 'Terminer';

  @override
  String filePickError(String error) {
    return 'Erreur de sélection de fichier : $error';
  }

  @override
  String get chatsTitle => 'Discussions';

  @override
  String get noChats => 'Aucune discussion';

  @override
  String get noMessages => '(aucun message)';

  @override
  String get newChat => 'Nouvelle discussion';

  @override
  String get messageInputHint => 'Écrire un message...';

  @override
  String get addCaptionHint => 'Ajouter une légende ou un message';

  @override
  String get unlockApp => 'Déverrouiller';

  @override
  String get unlockButton => 'Déverrouiller';

  @override
  String get dropFilesTitle => 'Déposez des fichiers à joindre';

  @override
  String get dropFilesSubtitle =>
      'Ils apparaîtront au-dessus du champ de message.';

  @override
  String get videoUnavailable => 'Vidéo indisponible';

  @override
  String get guestRole => 'Invité';

  @override
  String get replyAction => 'Répondre';

  @override
  String get editShort => 'Modifier';

  @override
  String get pinAction => 'Épingler';

  @override
  String get moreReactions => 'Plus';

  @override
  String get replyDialogTitle => 'Répondre';

  @override
  String get replyHint => 'Texte de réponse';

  @override
  String get editMessageTitle => 'Modifier le message';

  @override
  String get editMessageHint => 'Nouveau texte';

  @override
  String get deleteMessageTitle => 'Supprimer le message ?';

  @override
  String get pinsUpdated => 'Épingles mises à jour';

  @override
  String get messageEdited => 'Message modifié';

  @override
  String get fileSent => 'Fichier envoyé';

  @override
  String get voiceNotSupported =>
      'Enregistrement vocal non supporté sur cette plateforme';

  @override
  String get microphonePermRequired => 'Permission du microphone requise';

  @override
  String get recordingError => 'Erreur d\'enregistrement';

  @override
  String sendFailedError(String error) {
    return 'Échec d\'envoi : $error';
  }

  @override
  String attachmentSendError(String error) {
    return 'Erreur d\'envoi de pièce jointe : $error';
  }

  @override
  String shareFailedError(String error) {
    return 'Échec du partage : $error';
  }

  @override
  String replyError(String error) {
    return 'Erreur de réponse : $error';
  }

  @override
  String pinError(String error) {
    return 'Erreur d\'épingle : $error';
  }

  @override
  String deleteError(String error) {
    return 'Erreur de suppression : $error';
  }

  @override
  String editMessageError(String error) {
    return 'Erreur de modification : $error';
  }

  @override
  String get userTyping => 'L\'utilisateur tape...';

  @override
  String get statusOnline => 'En ligne';

  @override
  String get statusLastSeenRecently => 'Vu récemment';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get customizationLabel => 'Personnalisation';

  @override
  String get customizationSubtitle => 'Couleurs, police et effets UI';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get soundLabel => 'Son';

  @override
  String get accountSection => 'Compte';

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
  String get profileSubtitle => 'Modifier les informations du profil';

  @override
  String get accountSettingsLabel => 'Paramètres du compte';

  @override
  String get accountSettingsSubtitle => 'Mot de passe, sécurité, 2FA';

  @override
  String get privacyLabel => 'Confidentialité';

  @override
  String get privacySubtitle => 'Gérer la confidentialité';

  @override
  String get generalSection => 'Général';

  @override
  String get languageLabel => 'Langue';

  @override
  String get textSizeLabel => 'Taille du texte';

  @override
  String get sendByEnterLabel => 'Envoyer avec Entrée';

  @override
  String get sendByEnterSubtitle => 'Maj+Entrée pour nouvelle ligne';

  @override
  String get dataStorageSection => 'Données et stockage';

  @override
  String get autoDownloadLabel => 'Téléchargement automatique des médias';

  @override
  String get autoDownloadSubtitle =>
      'Télécharger photos et vidéos automatiquement';

  @override
  String get storageManagementLabel => 'Gestion du stockage';

  @override
  String get storageManagementSubtitle => 'Vider le cache et les données';

  @override
  String get clearCacheTitle => 'Vider le cache';

  @override
  String get clearCacheContent => 'Supprimer les données en cache ?';

  @override
  String get cacheCleared => 'Cache vidé';

  @override
  String get developmentSection => 'Développement';

  @override
  String get devMenuSubtitle => 'Bouton de débogage flottant';

  @override
  String get aboutSection => 'À propos';

  @override
  String get suggestImprovementLabel => 'Suggérer une amélioration';

  @override
  String get suggestImprovementSubtitle =>
      'Idées et demandes de nouvelles fonctionnalités';

  @override
  String get dangerZoneSection => 'Zone dangereuse';

  @override
  String get logoutLabel => 'Se déconnecter';

  @override
  String get logoutSubtitle => 'Se déconnecter de cet appareil';

  @override
  String get logoutDialogTitle => 'Se déconnecter';

  @override
  String get logoutDialogContent =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get logoutAction => 'Se déconnecter';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languageUkrainian => 'Ukrainien';

  @override
  String get clientDescription => 'Client TwoSpace créé avec Flutter/Dart';

  @override
  String errorLogout(String error) {
    return 'Erreur : $error';
  }

  @override
  String get accountSettingsTitle => 'Paramètres du compte';

  @override
  String get securitySection => 'Sécurité';

  @override
  String get twoFactorLabel => 'Authentification à deux facteurs';

  @override
  String get twoFactorSubtitle => 'Protection supplémentaire du compte';

  @override
  String get biometricLabel => 'Biométrie';

  @override
  String get biometricSubtitle => 'Se connecter avec empreinte digitale';

  @override
  String get activeSessionsLabel => 'Sessions actives';

  @override
  String get activeSessionsSubtitle => 'Gérer les appareils';

  @override
  String get currentDevice => 'Appareil actuel';

  @override
  String get changePasswordSection => 'Changer le mot de passe';

  @override
  String get currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get minPasswordHelper => 'Minimum 8 caractères';

  @override
  String get changePasswordButton => 'Changer le mot de passe';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit avoir au moins 8 caractères';

  @override
  String get passwordChangeSuccess => 'Mot de passe changé avec succès';

  @override
  String get contactDataSection => 'Coordonnées';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get deleteAccountLabel => 'Supprimer le compte';

  @override
  String get deleteAccountSubtitle => 'Action irréversible';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountContent =>
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';

  @override
  String get deleteFeatureLater =>
      'La suppression du compte sera disponible plus tard';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfileButton => 'Edit profile';

  @override
  String get saveProfileButton => 'Save changes';

  @override
  String get copyAegisIdButton => 'Copy Aegis ID';

  @override
  String get saveTooltip => 'Enregistrer';

  @override
  String get editTooltip => 'Modifier';

  @override
  String get writeMessageButton => 'Message';

  @override
  String get callButton => 'Appeler';

  @override
  String get aboutField => 'À propos de moi';

  @override
  String get nicknameField => 'Surnom';

  @override
  String get locationField => 'Lieu';

  @override
  String get birthdayField => 'Anniversaire';

  @override
  String get nameField => 'Nom';

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
  String get avatarUploadLater =>
      'Le téléchargement d\'avatar sera ajouté plus tard';

  @override
  String get profileSaved => 'Profil enregistré';

  @override
  String createChatError(String error) {
    return 'Impossible de créer le chat : $error';
  }

  @override
  String get privacyTitle => 'Confidentialité';

  @override
  String get hideFromSearch => 'Masquer de la recherche';

  @override
  String get hideFromSearchSubtitle =>
      'Ne pas m\'afficher dans les résultats de recherche';

  @override
  String get hideLastSeen => 'Masquer le statut en ligne';

  @override
  String get hideLastSeenSubtitle =>
      'Les autres ne verront pas quand vous étiez en ligne';

  @override
  String get sessionExpiry => 'Expiration de session';

  @override
  String sessionExpirySubtitle(int days) {
    return 'Reconnexion automatique sur cet appareil : $days jours';
  }

  @override
  String get sessionExpiryDaysTitle => 'Expiration de session (jours)';

  @override
  String get sessionExpiryDaysContent =>
      'Choisissez le nombre de jours (min : 7, max : 365).';

  @override
  String get daysLabel => 'Jours';

  @override
  String get enterDaysError => 'Entrez un nombre de 7 à 365';

  @override
  String sessionExpirySet(int days) {
    return 'Expiration de session : $days jours';
  }

  @override
  String get changeEmailLabel => 'Changer l\'e-mail';

  @override
  String get changeEmailSubtitle => 'Mettre à jour l\'adresse e-mail';

  @override
  String get twoFactorPrivacySubtitle =>
      'Activer ou désactiver la protection renforcée';

  @override
  String get changePhoneLabel => 'Changer le téléphone';

  @override
  String get changePhoneSubtitle => 'Mettre à jour le numéro de téléphone';

  @override
  String updatePrivacyError(String error) {
    return 'Impossible de mettre à jour la confidentialité : $error';
  }

  @override
  String updateSettingError(String error) {
    return 'Impossible de mettre à jour le paramètre : $error';
  }

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get searchContactsHint => 'Rechercher des contacts...';

  @override
  String get contactsAccessTitle => 'Accès aux contacts';

  @override
  String get contactsPermDeniedPermanent =>
      'Permission définitivement refusée. Ouvrez les paramètres.';

  @override
  String get contactsPermRequired =>
      'Permission d\'accès aux contacts requise.';

  @override
  String get openSettingsButton => 'Ouvrir les paramètres';

  @override
  String get requestPermissionButton => 'Demander la permission';

  @override
  String get noContacts => 'Aucun contact trouvé';

  @override
  String get callAction => 'Appeler';

  @override
  String get writeMessageAction => 'Message';

  @override
  String callNotification(String number) {
    return 'Appel : $number';
  }

  @override
  String messageNotification(String name) {
    return 'Message pour : $name';
  }

  @override
  String get callsTitle => 'Appels';

  @override
  String get widgetsTitle => 'Widgets';

  @override
  String get searchByNameHint => 'Rechercher par nom...';

  @override
  String get allFilter => 'Tous';

  @override
  String get incomingFilter => 'Entrants';

  @override
  String get outgoingFilter => 'Sortants';

  @override
  String get missedFilter => 'Manqués';

  @override
  String get noCallsFound => 'Aucun appel';

  @override
  String get yesterdayLabel => 'Hier';

  @override
  String get incomingCall => 'Entrant';

  @override
  String get outgoingCall => 'Sortant';

  @override
  String get missedCall => 'Manqué';

  @override
  String get videoCallLabel => 'Appel vidéo';

  @override
  String get voiceCallLabel => 'Appel vocal';

  @override
  String get sendMessageCallAction => 'Message';

  @override
  String get createRoomTitle => 'Créer un salon';

  @override
  String get createButton => 'Créer';

  @override
  String get roomNameLabel => 'Nom du salon';

  @override
  String get roomNameHint => 'Ex. nom de votre projet';

  @override
  String get roomTopicLabel => 'Sujet (optionnel)';

  @override
  String get roomTopicHint => 'De quoi traite ce salon ?';

  @override
  String get roomVisibilityLabel => 'Visibilité du salon';

  @override
  String get privateRoomOption => 'Salon privé';

  @override
  String get privateRoomSubtitle =>
      'Seuls les utilisateurs invités peuvent rejoindre';

  @override
  String get publicRoomOption => 'Salon public';

  @override
  String get publicRoomSubtitle => 'Tout le monde peut rejoindre';

  @override
  String get showHistoryLabel => 'Afficher l\'historique des messages';

  @override
  String get showHistorySubtitle =>
      'Les nouveaux membres peuvent voir les messages précédents';

  @override
  String get enterRoomNameError => 'Veuillez entrer le nom du salon';

  @override
  String get roomCreatedSuccess => 'Salon créé avec succès !';

  @override
  String imagePickError(String error) {
    return 'Erreur de sélection d\'image : $error';
  }

  @override
  String get groupInfoTab => 'Info';

  @override
  String get groupMembersTab => 'Membres';

  @override
  String get groupRolesTab => 'Rôles';

  @override
  String get groupBansTab => 'Bans';

  @override
  String get groupDeleteTab => 'Supprimer';

  @override
  String membersCount(int count) {
    return 'Membres : $count';
  }

  @override
  String get messageHistoryToggle => 'Historique des messages';

  @override
  String get showHistoryToggleLabel => 'Afficher l\'historique';

  @override
  String get settingSaved => 'Paramètre enregistré';

  @override
  String get backgroundColorLabel => 'Couleur de fond';

  @override
  String get noMembers => 'Aucun membre';

  @override
  String get roleAction => 'Rôle';

  @override
  String get freezeAction => 'Geler';

  @override
  String get banAction => 'Bannir';

  @override
  String get kickAction => 'Expulser';

  @override
  String get noBannedUsers => 'Aucun utilisateur banni';

  @override
  String get bannedLabel => 'Banni';

  @override
  String get userUnbanned => 'Utilisateur débanni';

  @override
  String get deleteGroupLabel => 'Supprimer le groupe';

  @override
  String get deleteGroupWarning =>
      'Cette action est IRRÉVERSIBLE. Le groupe sera supprimé définitivement.';

  @override
  String get confirmDeleteTitle => 'Confirmer la suppression';

  @override
  String get confirmDeleteContent =>
      'Êtes-vous sûr ? Cette action est irréversible.';

  @override
  String get changeRoleTitle => 'Changer le rôle';

  @override
  String get adminRole => 'Administrateur';

  @override
  String get memberRole => 'Membre';

  @override
  String get freezeUserTitle => 'Geler l\'utilisateur';

  @override
  String get userBanned => 'Utilisateur banni';

  @override
  String get userKicked => 'Utilisateur expulsé';

  @override
  String get groupDeleted => 'Groupe supprimé';

  @override
  String loadError(String error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get publicLabel => 'Public';

  @override
  String get privateLabel => 'Privé';

  @override
  String get noDescription => 'Aucune description';

  @override
  String get membersLabel => 'Membres';

  @override
  String get generalLabel => 'Général';

  @override
  String get newChatTitle => 'Nouvelle discussion';

  @override
  String get newChatChooserTitle => 'Start a new conversation';

  @override
  String get newChatChooserSubtitle =>
      'Choose the kind of chat you want to create or join.';

  @override
  String get createDirectChatSubtitle =>
      'Search for a person or enter an Aegis ID manually.';

  @override
  String get directChatTab => 'Direct';

  @override
  String get groupChatTab => 'Groupe';

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
  String get startDirectChatTitle => 'Démarrer une discussion directe';

  @override
  String get contactIdDescription =>
      'Entrez le nom d\'utilisateur ou l\'identifiant Aegis';

  @override
  String get contactIdLabel => 'Nom d\'utilisateur ou identifiant Aegis';

  @override
  String get startChatButton => 'Démarrer la discussion';

  @override
  String get hintCardTitle => 'Astuce';

  @override
  String get contactIdExplanation =>
      'Vous pouvez utiliser un nom d\'utilisateur ou un identifiant Aegis numérique';

  @override
  String get enterUserIdError => 'Entrez l\'ID utilisateur';

  @override
  String get createNewRoomTitle => 'Créer un nouveau salon';

  @override
  String get descriptionOptionalLabel => 'Description (optionnel)';

  @override
  String get privateGroupLabel => 'Groupe privé';

  @override
  String get privateGroupSubtitle =>
      'Seuls les utilisateurs invités peuvent rejoindre';

  @override
  String get createRoomButton => 'Créer le salon';

  @override
  String get customizationTitle => 'Personnalisation';

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
  String get colorsTab => 'Couleurs';

  @override
  String get fontsTab => 'Polices';

  @override
  String get effectsTab => 'Effets';

  @override
  String get selectColorTheme => 'Sélectionner le thème de couleur';

  @override
  String get themeAppliesEverywhere =>
      'Le thème sélectionné s\'applique dans toute l\'application';

  @override
  String get fontSettingsTitle => 'Paramètres de police';

  @override
  String get selectFontFamily => 'Sélectionner la famille de police';

  @override
  String get appFontLabel => 'Police de l\'application';

  @override
  String get fontWeightLabel => 'Épaisseur de police';

  @override
  String get fontPreview => 'Aperçu : Texte d\'exemple';

  @override
  String get compactMode => 'Réduire les marges et tailles';

  @override
  String get enableCircles => 'Activer les cercles';

  @override
  String get circlesDesc => 'Cercles animés en arrière-plan';

  @override
  String get floatingCirclesLabel => 'Cercles flottants';

  @override
  String get reactOnTilt => 'Réagir à l\'inclinaison du téléphone';

  @override
  String get parallaxEffect => 'Effet parallaxe';

  @override
  String get circlesSpeedLabel => 'Vitesse de mouvement';

  @override
  String get staticMotion => 'Statique';

  @override
  String get brightnessLabel => 'Luminosité';

  @override
  String get dimOpacity => 'Tamisé';

  @override
  String get brightOpacity => 'Lumineux';

  @override
  String get performanceLabel => 'Performance';

  @override
  String get currentSpeedPrefix => 'Actuel : ';

  @override
  String get speedPrefix => 'Vitesse :';

  @override
  String get advancedSearchTitle => 'Recherche avancée';

  @override
  String get searchQueryHint => 'Entrez une requête...';

  @override
  String get searchTypeLabel => 'Type de recherche';

  @override
  String get searchTypeAll => 'Tout';

  @override
  String get searchTypeMessages => 'Messages';

  @override
  String get searchTypeMedia => 'Médias';

  @override
  String get searchTypeUsers => 'Utilisateurs';

  @override
  String get periodLabel => 'Période';

  @override
  String get fromDate => 'De';

  @override
  String get toDate => 'À';

  @override
  String get searchButton => 'Rechercher';

  @override
  String resultsCount(int count) {
    return 'Résultats ($count)';
  }

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get forgotPasswordTitle => 'Récupération du mot de passe';

  @override
  String get forgotPasswordDescription =>
      'Entrez votre e-mail pour recevoir un lien de réinitialisation';

  @override
  String get sendResetButton => 'Envoyer';

  @override
  String get forgotPasswordUnavailable =>
      'Récupération du mot de passe non disponible';

  @override
  String get changeEmailTitle => 'Changer l\'e-mail';

  @override
  String get changeEmailDescription => 'Entrez une nouvelle adresse e-mail';

  @override
  String get currentPrefix => 'Actuel : ';

  @override
  String get newEmailLabel => 'Nouvel e-mail';

  @override
  String get changeEmailButton => 'Changer l\'e-mail';

  @override
  String changeEmailError(String error) {
    return 'Impossible de changer l\'e-mail : $error';
  }

  @override
  String get changePhoneTitle => 'Changer le numéro de téléphone';

  @override
  String get changePhoneDescription =>
      'Entrez un nouveau numéro de téléphone et votre mot de passe actuel.';

  @override
  String get newPhoneLabel => 'Nouveau numéro (+33...)';

  @override
  String get currentPasswordOptional => 'Mot de passe actuel (si requis)';

  @override
  String get changePhoneButton => 'Changer le numéro';

  @override
  String get phoneCannotBeChanged =>
      'Le numéro de téléphone ne peut pas être modifié';

  @override
  String get emailCannotBeChanged => 'L\'email ne peut pas être modifié';

  @override
  String changePhoneError(String error) {
    return 'Impossible de changer le numéro : $error';
  }

  @override
  String get confirmCodeTitle => 'Confirmer le code';

  @override
  String codeSentTo(String phone) {
    return 'Nous avons envoyé un code à $phone';
  }

  @override
  String get enterCodeHint => 'Entrez le code';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String resendCountdown(int seconds) {
    return 'Renvoyer dans $seconds s';
  }

  @override
  String get resendCodeButton => 'Renvoyer le code';

  @override
  String get biometricSetupTitle => 'Sécurité';

  @override
  String get authMethodsLabel => 'Méthodes d\'authentification';

  @override
  String get biometricAuthLabel => 'Authentification biométrique';

  @override
  String get biometricAuthSubtitle => 'Empreinte digitale ou Face ID';

  @override
  String get biometricEnabledLabel => 'Biométrie activée';

  @override
  String get aboutSecurityLabel => 'À propos de la sécurité';

  @override
  String get aboutSecurityContent =>
      'Choisissez une méthode d\'authentification pratique.';

  @override
  String get setPinCode => 'Définir le code PIN';

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

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
  String get whatsNewLabel => 'Nouveautés';

  @override
  String get noUpdateDescription => 'Aucune description';

  @override
  String downloadingProgress(int percent) {
    return 'Téléchargement... $percent%';
  }

  @override
  String get checkingIntegrity => 'Vérification de l\'intégrité...';

  @override
  String get requestingInstall => 'Demande d\'installation...';

  @override
  String get updateMandatory => 'Mise à jour obligatoire';

  @override
  String get laterButton => 'Plus tard';

  @override
  String get downloadingLabel => 'Téléchargement...';

  @override
  String get installingLabel => 'Installation...';

  @override
  String get updateButton => 'Mettre à jour';

  @override
  String get downloadFailed => 'Échec du téléchargement de la mise à jour';

  @override
  String get integrityCheckFailed =>
      'Le fichier téléchargé n\'a pas passé la vérification d\'intégrité (sha256)';

  @override
  String get installPermissionTitle => 'Permission d\'installation';

  @override
  String get installPermissionContent =>
      'Autorisez l\'installation depuis des sources inconnues.';

  @override
  String get installPermissionRequired => 'Permission d\'installation requise';

  @override
  String get installFailed => 'Échec de l\'installation';

  @override
  String get ssoFeatureRequired =>
      'Cette fonctionnalité nécessite la configuration de webview_flutter';

  @override
  String ssoLoginVia(String idpId) {
    return 'Connexion SSO via $idpId';
  }

  @override
  String get forwardMessageTitle => 'Transférer le message';

  @override
  String get searchChatHint => 'Rechercher un chat...';

  @override
  String forwardButton(int count) {
    return 'Transférer ($count)';
  }

  @override
  String get roomAvatarUpdated => 'Avatar du salon mis à jour';

  @override
  String roomAvatarUploadError(String error) {
    return 'Erreur lors du téléchargement de l\'avatar : $error';
  }

  @override
  String get roomSettingsSaved => 'Paramètres du salon enregistrés';

  @override
  String roomSettingsSaveError(String error) {
    return 'Erreur d\'enregistrement : $error';
  }

  @override
  String get uploadAvatarButton => 'Télécharger l\'avatar';

  @override
  String loadMembersError(String error) {
    return 'Erreur de chargement des membres : $error';
  }

  @override
  String get leaveRoomTitle => 'Quitter le salon ?';

  @override
  String get leaveRoomContent =>
      'Vous ne pourrez pas revenir sans être réinvité.';

  @override
  String get leaveAction => 'Quitter';

  @override
  String get leftRoom => 'Vous avez quitté le salon';

  @override
  String leaveRoomError(String error) {
    return 'Erreur lors de la sortie : $error';
  }

  @override
  String get reportNotImplemented =>
      'Fonction de signalement pas encore implémentée';

  @override
  String get featureInDevelopmentLabel => 'En développement';

  @override
  String featureInDevelopmentMessage(String feature) {
    return 'Cette fonctionnalité est encore en cours de développement et sera disponible dans l\'une des prochaines versions.';
  }

  @override
  String get inviteAction => 'Inviter';

  @override
  String get threadsLabel => 'Fils';

  @override
  String get pinnedLabel => 'Épinglés';

  @override
  String get filesLabel => 'Fichiers';

  @override
  String get noSharedFiles => 'Aucun fichier partagé pour le moment';

  @override
  String get mediaLabel => 'Médias';

  @override
  String get noSharedMedia => 'Aucun média partagé pour le moment';

  @override
  String get extensionsLabel => 'Extensions';

  @override
  String get copyLinkAction => 'Copier le lien';

  @override
  String get pollsLabel => 'Sondages';

  @override
  String get exportChatAction => 'Exporter le chat';

  @override
  String get reportAction => 'Signaler';

  @override
  String get leaveRoomAction => 'Quitter le salon';

  @override
  String roomTitle(String name) {
    return 'Salon — $name';
  }

  @override
  String get roomSettingsLabel => 'Paramètres du salon';

  @override
  String authError(String error) {
    return 'Erreur d\'authentification : $error';
  }

  @override
  String get loginRequired => 'Connexion requise';

  @override
  String get loginRequiredContent =>
      'Vous devez être connecté pour rechercher des contacts. Aller à la connexion ?';

  @override
  String get loginAction => 'Se connecter';

  @override
  String searchError(String error) {
    return 'Erreur de recherche : $error';
  }

  @override
  String get searchContactsTitle => 'Rechercher des contacts';

  @override
  String get nicknameOrPhoneHint => 'Surnom ou numéro de téléphone';

  @override
  String selectContactError(String error) {
    return 'Impossible de sélectionner le contact : $error';
  }

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get feedbackCategoryFeatures => 'Fonctionnalités';

  @override
  String get feedbackCategoryPerformance => 'Performance';

  @override
  String get feedbackCategorySecurity => 'Sécurité/Confidentialité';

  @override
  String get feedbackCategoryNetworkSync => 'Sync/Réseau';

  @override
  String get shortDescriptionLabel => 'Description courte';

  @override
  String get shortDescriptionHint =>
      'Ex. \"Sauvegarde des chats dans le cloud\"';

  @override
  String get feedbackValidation =>
      'Sélectionnez au moins une idée ou écrivez une description';

  @override
  String get detailsOptionalLabel => 'Détails (optionnel)';

  @override
  String get detailsHint =>
      'Que devrait fonctionner, comment ça fonctionne maintenant et comment vous le souhaitez ?';

  @override
  String get bigFeaturesTitle =>
      'Principales fonctionnalités (sélectionnez ce qui vous intéresse le plus)';

  @override
  String get feedbackE2E =>
      'Chiffrement E2E de bout en bout (Olm/Megolm) + vérification des appareils';

  @override
  String get feedbackBackup =>
      'Sauvegarde des chats (local/cloud) + transfert vers un nouvel appareil';

  @override
  String get feedbackThreads =>
      'Fils, réactions, mentions, recherche de messages améliorée';

  @override
  String get feedbackCalls => 'Appels vocaux/vidéo et salons vocaux rapides';

  @override
  String get feedbackFolders =>
      'Dossiers/catégories de chats et filtres de notifications intelligents';

  @override
  String get feedbackBots =>
      'Bots et intégrations (webhooks, GitHub/Jira, rappels)';

  @override
  String get feedbackSlowNet =>
      'Mode \"internet lent\" + mise en cache agressive des médias';

  @override
  String get startChatTitle => 'Démarrer le chat';

  @override
  String get startDirectChatSubtitle =>
      'Open a private conversation with one person';

  @override
  String get createRoomSubtitle => 'Groupe privé ou public';

  @override
  String get inviteUserTitle => 'Inviter un utilisateur';

  @override
  String get inviteUserSubtitle => 'Trouver et écrire à un utilisateur';

  @override
  String get addParticipantAction => 'Add participant';

  @override
  String get selectedParticipantsTitle => 'Participants';

  @override
  String get groupParticipantsOptionalHint =>
      'Participants are optional. You can create the group now and invite people later.';

  @override
  String get joinByCodeTitle => 'Rejoindre par code';

  @override
  String get joinByCodeSubtitle =>
      'Rejoindre un salon avec un code d\'invitation';

  @override
  String get joinRoomAction => 'Join';

  @override
  String get subscribeAction => 'Subscribe';

  @override
  String get chatsSubtitle =>
      'Messages privés, groupes et liens d\'invitation au même endroit';

  @override
  String get chatsQuickStartTitle => 'Commencer quelque chose de nouveau';

  @override
  String get chatsRecentTitle => 'Discussions récentes';

  @override
  String get joinLinkHint =>
      'Collez un lien d\'invitation, un alias ou un code';

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
  String get fontLabel => 'Police';

  @override
  String get pinCodeLabel => 'Code PIN';

  @override
  String get pinCodeSubtitle => '4-6 chiffres pour la protection';

  @override
  String get pinHint => 'PIN (4-6 chiffres)';

  @override
  String get pinLengthError => 'Le PIN doit avoir 4-6 chiffres';

  @override
  String get pinSetSuccess => 'PIN défini';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get closeButton => 'Fermer';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get sendButton => 'Envoyer';

  @override
  String get copyButton => 'Copier';

  @override
  String get shareButton => 'Partager';

  @override
  String get settingsLabel => 'Paramètres';

  @override
  String get feedbackCategoryUxDesign => 'UX/Design';

  @override
  String get feedbackShareSubject => 'TwoSpace — suggestion';

  @override
  String get feedbackMessageHeader => 'TwoSpace — suggestion/amélioration';

  @override
  String feedbackVersion(String version) {
    return 'Version: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return 'Catégorie: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return 'Bref: $title';
  }

  @override
  String get feedbackWishList => 'Ce qui serait particulièrement génial:';

  @override
  String get feedbackDetailsLine => 'Détails:';

  @override
  String get circlesVisible => 'Cercles affichés';

  @override
  String get circlesHidden => 'Cercles masqués';

  @override
  String get speedSlow => 'Lent';

  @override
  String get speedFast => 'Rapide';

  @override
  String get advancedSettingsLabel => 'Paramètres avancés';

  @override
  String get compactModeLabel => 'Mode compact';

  @override
  String get activeDeviceInfo => 'Android • Actif';

  @override
  String stubPlaceholder(String key) {
    return 'Espace réservé — $key';
  }

  @override
  String loadMessagesError(String error) {
    return 'Erreur de chargement des messages: $error';
  }

  @override
  String get pinnedUpdated => 'Épinglés mis à jour';

  @override
  String editError(String error) {
    return 'Erreur d\'édition: $error';
  }

  @override
  String get moreButton => 'Plus';

  @override
  String shareError(String error) {
    return 'Impossible de partager: $error';
  }

  @override
  String sendError(String error) {
    return 'Erreur d\'envoi: $error';
  }

  @override
  String get voiceRecordingUnsupported =>
      'L\'enregistrement vocal n\'est pas pris en charge sur cette plateforme';

  @override
  String get microphonePermissionRequired => 'Permission du microphone requise';

  @override
  String genericError(String error) {
    return 'Erreur: $error';
  }

  @override
  String get ownersLabel => '👑 Propriétaires';

  @override
  String get administratorsLabel => '⚡ Administrateurs';

  @override
  String get oneHour => '1 heure';

  @override
  String get oneDay => '1 jour';

  @override
  String get sevenDays => '7 jours';

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
  String get storageMemoryTitle => 'Mémoire';

  @override
  String get storageTotalLabel => 'Total';

  @override
  String get storageSelectedLabel => 'Selected';

  @override
  String get storagePhotosLabel => 'Photos';

  @override
  String get storageVideosLabel => 'Vidéos';

  @override
  String get storageCacheLabel => 'Cache';

  @override
  String get storageAppDataLabel => 'Données de l\'app';

  @override
  String get storageCleanupTitle => 'À supprimer';

  @override
  String get storageCleanupSubtitle =>
      'Vérifiez ce qui peut être supprimé sans risque.';

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
  String get peopleTitle => 'Personnes';

  @override
  String get peopleSubtitle =>
      'Contacts, favoris, recherche et invitations au même endroit';

  @override
  String get peopleQuickNewChat => 'Nouveau chat';

  @override
  String get peopleQuickInvite => 'Inviter';

  @override
  String get peopleQuickSync => 'Synchroniser';

  @override
  String get peopleSearchHint => 'Rechercher par nom, pseudo ou téléphone';

  @override
  String get peopleSegmentAll => 'Tous';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => 'Carnet';

  @override
  String get peopleSegmentRecent => 'Récents';

  @override
  String get peopleLoading => 'Chargement des personnes…';

  @override
  String get peopleNoPeopleTitle => 'Aucune personne pour le moment';

  @override
  String get peopleNoPeopleMessage =>
      'Vos favoris, conversations récentes et contacts apparaîtront ici.';

  @override
  String get peoplePermissionCardTitle => 'Accès aux contacts limité';

  @override
  String get peoplePermissionCardMessage =>
      'Autorisez l’accès aux contacts pour afficher votre carnet et inviter des personnes plus rapidement.';

  @override
  String get peoplePermissionCardMessageSettings =>
      'Activez l’accès aux contacts dans les réglages système pour restaurer la section carnet.';

  @override
  String get peopleFavoritesFrequentTitle => 'Favoris et fréquents';

  @override
  String get peopleRecentTitle => 'Personnes récentes';

  @override
  String get peopleTwoSpaceTitle => 'Personnes sur TwoSpace';

  @override
  String get peopleInviteTitle => 'Inviter sur TwoSpace';

  @override
  String get peopleInviteSubtitle => 'Inviter ce contact sur TwoSpace';

  @override
  String get peopleSearching => 'Recherche de personnes…';

  @override
  String get peopleSearchRemoteTitle => 'Résultats TwoSpace';

  @override
  String get peopleSearchLocalTitle => 'Récents et enregistrés';

  @override
  String get peopleSearchInviteTitle => 'Inviter depuis le carnet';

  @override
  String get peopleSearchEmptyTitle => 'Aucune personne correspondante';

  @override
  String get peopleSearchEmptyMessage =>
      'Essayez un autre nom, pseudo ou numéro de téléphone.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => 'Pas encore de détails supplémentaires';

  @override
  String get peopleInviteShareText =>
      'Rejoignez-moi sur TwoSpace, une messagerie sécurisée pour les chats et les appels.';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return 'Rejoignez-moi sur TwoSpace, $personName — discutons et appelons en toute sécurité.';
  }

  @override
  String get peopleViewProfileAction => 'Voir le profil';

  @override
  String get peopleRemoveFavoriteAction => 'Retirer des favoris';

  @override
  String get peopleAddFavoriteAction => 'Ajouter aux favoris';

  @override
  String get callsSubtitle =>
      'Appels récents, rappel rapide et historique centré sur les personnes';

  @override
  String get widgetsSubtitle =>
      'Home, lock-screen, and glanceable surfaces for your conversations';

  @override
  String get widgetsComingTitle => 'Widgets are on the way';

  @override
  String get widgetsComingBody =>
      'We are preparing flexible widget layouts for quick actions, unread counters, and compact conversation previews.';

  @override
  String get callsStartCallAction => 'Démarrer un appel';

  @override
  String get callsQuickStartTitle => 'Appeler maintenant';

  @override
  String get callsQuickStartSubtitle =>
      'Ouvrez Personnes, trouvez quelqu’un et démarrez un appel vocal ou vidéo sécurisé.';

  @override
  String get callsSearchHint => 'Rechercher dans l’historique des appels';

  @override
  String get callsVideoFilter => 'Vidéo';

  @override
  String get callsTopContactsTitle => 'Contacts fréquents';

  @override
  String get callsLoadingLabel => 'Chargement des appels…';

  @override
  String get callsEmptyTitle => 'Aucun appel pour le moment';

  @override
  String get callsEmptyMessage =>
      'Votre historique d’appels apparaîtra ici après votre premier appel vocal ou vidéo.';

  @override
  String get callsEmptySearchMessage =>
      'Aucun appel ne correspond à la recherche ou au filtre actuel.';

  @override
  String get callsTodaySection => 'Aujourd’hui';

  @override
  String get callsThisWeekSection => 'Cette semaine';

  @override
  String get callsEarlierSection => 'Plus tôt';

  @override
  String callsThreadCount(int count) {
    return '$count appels';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count manqués';
  }

  @override
  String get callsMuteAction => 'Muet';

  @override
  String get callsSpeakerAction => 'Haut-parleur';

  @override
  String get callsCameraAction => 'Caméra';

  @override
  String get callsSwitchCameraAction => 'Changer';

  @override
  String get callsEndAction => 'Terminer l’appel';

  @override
  String get callsConnectingLabel => 'Connexion…';

  @override
  String get callsRingingLabel => 'Sonnerie…';

  @override
  String get callsConnectingDetail =>
      'Création d’une session d’appel sécurisée.';

  @override
  String get callsRingingDetail =>
      'En attente de la réponse de l’autre personne.';

  @override
  String get callsVideoSecureDetail =>
      'La vidéo est protégée et transite par la session sécurisée actuelle.';

  @override
  String get callsVoiceSecureDetail =>
      'La voix est protégée et transite par la session sécurisée actuelle.';

  @override
  String get timestampPrecisionLabel => 'Précision de l\'heure des messages';

  @override
  String get timestampPrecisionSubtitle =>
      'Choisissez le niveau de détail des horodatages dans les chats et dans la liste des chats.';

  @override
  String get timestampPrecisionMinutes => 'Heures et minutes';

  @override
  String get timestampPrecisionSeconds => 'Heures, minutes et secondes';

  @override
  String get timestampPrecisionMilliseconds =>
      'Heures, minutes, secondes et millisecondes';

  @override
  String get startupTitle => 'Préparation de TwoSpace';

  @override
  String get startupSubtitle =>
      'Vérification de la session sécurisée et ouverture de vos chats.';

  @override
  String get startupFooter =>
      'Cet écran s\'affiche uniquement au démarrage de l\'application.';

  @override
  String get startupStepEnvironment => 'Chargement de la configuration';

  @override
  String get startupStepDiagnostics => 'Démarrage du diagnostic';

  @override
  String get startupStepValidation => 'Validation de l\'environnement';

  @override
  String get startupStepSettings => 'Chargement des réglages';

  @override
  String get startupStepSession => 'Restauration de la session sécurisée';

  @override
  String get startupStepLaunch => 'Démarrage de l\'application';

  @override
  String get callsDemoBannerTitle =>
      'Exemple, fonctionnalité non opérationnelle';

  @override
  String get callsDemoBannerVoiceMessage =>
      'Les appels vocaux sont pour l\'instant affichés uniquement comme un prototype visuel. Le transport audio n\'est pas encore connecté.';

  @override
  String get callsDemoBannerVideoMessage =>
      'Les appels vidéo sont pour l\'instant affichés uniquement comme un prototype visuel. Le flux vidéo distant n\'est pas disponible, mais l\'aperçu local de votre caméra fonctionne.';

  @override
  String get callsCameraPermissionMessage =>
      'Autorisez l\'accès à la caméra pour afficher votre aperçu local pendant un appel vidéo.';

  @override
  String get callsCameraPermissionSettingsMessage =>
      'L\'accès à la caméra est bloqué. Ouvrez les réglages système pour activer l\'aperçu vidéo local.';

  @override
  String get callsCameraPermissionAction => 'Autoriser la caméra';

  @override
  String get callsCameraUnavailableTitle => 'Caméra indisponible';

  @override
  String get callsCameraUnavailableMessage =>
      'Impossible de démarrer l\'aperçu local de la caméra sur cet appareil.';

  @override
  String get callsCameraUnsupportedMessage =>
      'Cette plateforme ne prend pas en charge l\'aperçu vidéo local.';

  @override
  String get callsCameraOffMessage =>
      'L\'aperçu caméra est désactivé pour cet appel de démonstration.';

  @override
  String get callsFrontCameraLabel => 'Caméra avant';

  @override
  String get callsRearCameraLabel => 'Caméra arrière';

  @override
  String get backgroundOptimizationDisabledTitle =>
      'Les effets d\'arrière-plan ont été allégés';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace a détecté des ralentissements persistants et a désactivé les effets d\'arrière-plan les plus lourds pour garder le défilement et les chats fluides.';

  @override
  String get backgroundOptimizationOpenSettings =>
      'Ouvrir les réglages d\'apparence';

  @override
  String get roomJoinRuleLabel => 'Qui peut rejoindre';

  @override
  String get roomJoinRulePublic => 'Ouvert à tous';

  @override
  String get roomJoinRulePublicDescription =>
      'Tout le monde peut découvrir et rejoindre ce salon.';

  @override
  String get roomJoinRuleInviteOnly => 'Sur invitation uniquement';

  @override
  String get roomJoinRuleInviteOnlyDescription =>
      'Seuls les utilisateurs invités peuvent rejoindre ce salon.';

  @override
  String get roomJoinRuleApproval => 'Approbation requise';

  @override
  String get roomJoinRuleApprovalDescription =>
      'Les utilisateurs peuvent demander l\'accès et doivent être approuvés avant de rejoindre.';

  @override
  String get roomHistoryVisibilityLabel => 'Qui peut voir l\'historique';

  @override
  String get roomHistoryVisibilityWorldReadable => 'Tout le monde';

  @override
  String get roomHistoryVisibilityWorldReadableDescription =>
      'Tout le monde peut voir les messages précédents.';

  @override
  String get roomHistoryVisibilityJoined => 'Membres ayant rejoint';

  @override
  String get roomHistoryVisibilityJoinedDescription =>
      'Seuls les membres ayant rejoint peuvent voir les messages précédents.';

  @override
  String get roomHistoryVisibilityInvited => 'Utilisateurs invités uniquement';

  @override
  String get roomHistoryVisibilityInvitedDescription =>
      'Seuls les utilisateurs invités peuvent voir les messages précédents.';

  @override
  String get loginUsernameOnlyError =>
      'Utilisez votre nom d\'utilisateur TwoSpace pour vous connecter.';

  @override
  String get twoFactorInvalidCodeMessage =>
      'Le code 2FA ou la phrase de récupération est invalide. Réessayez.';

  @override
  String get twoFactorCodeRequiredMessage =>
      'Saisissez un code depuis votre application d\'authentification ou utilisez la phrase de récupération.';

  @override
  String get twoFactorEnabledMessage =>
      'L\'authentification à deux facteurs est activée.';

  @override
  String twoFactorEnableFailed(String error) {
    return 'Impossible d\'activer la 2FA : $error';
  }

  @override
  String get twoFactorSetupTitle =>
      'Configurer l\'authentification à deux facteurs';

  @override
  String get twoFactorSetupDescription =>
      'Scannez le QR code dans votre application d\'authentification, enregistrez la phrase de récupération, puis confirmez avec un code TOTP récent.';

  @override
  String get twoFactorSecretTitle => 'Ou saisir cette clé secrète manuellement';

  @override
  String get twoFactorRecoveryPhraseTitle =>
      'Phrase de récupération. Enregistrez-la dans un endroit sûr avant d\'activer la 2FA.';

  @override
  String get twoFactorVerificationCodeLabel => 'Code de vérification';

  @override
  String get twoFactorVerificationCodeHint =>
      'Saisissez le code actuel de votre application d\'authentification';

  @override
  String get twoFactorVerifyEnableAction => 'Vérifier et activer la 2FA';

  @override
  String get twoFactorDisableSectionTitle =>
      'Désactiver l\'authentification à deux facteurs';

  @override
  String get twoFactorDisableSectionDescription =>
      'Désactivez la 2FA avec un code valide de l\'application d\'authentification ou votre phrase de récupération à usage unique.';

  @override
  String get twoFactorDisableCodeHint =>
      'Saisissez un code actuel de l\'application d\'authentification';

  @override
  String get twoFactorRecoveryPhraseFieldLabel => 'Phrase de récupération';

  @override
  String get twoFactorRecoveryPhraseFieldHint =>
      'Collez la phrase de récupération si vous n\'avez plus accès à l\'application d\'authentification';

  @override
  String get twoFactorDisableAction => 'Désactiver la 2FA';

  @override
  String get twoFactorDisableCredentialsRequired =>
      'Saisissez un code d\'authentification ou une phrase de récupération pour désactiver la 2FA.';

  @override
  String get twoFactorDisabledMessage =>
      'L\'authentification à deux facteurs est désactivée.';

  @override
  String twoFactorDisableFailed(String error) {
    return 'Impossible de désactiver la 2FA : $error';
  }

  @override
  String get twoFactorLoginRecoveryHint =>
      'Ou collez la phrase de récupération à la place du code';

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
}
