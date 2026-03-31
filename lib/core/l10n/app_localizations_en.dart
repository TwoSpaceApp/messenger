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
  String get errorInitializationFull =>
      'Initialization error. Please restart the app.';

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get errorAuth => 'Authentication error.';

  @override
  String get errorInvalidArguments => 'Invalid arguments.';

  @override
  String get errorInvalidArgumentsProfile => 'Invalid arguments for profile.';

  @override
  String get errorInvalidArgumentsChat => 'Invalid arguments for chat.';

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

  @override
  String errorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get noData => 'No data';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get copyAction => 'Copy';

  @override
  String get shareAction => 'Share';

  @override
  String get textCopied => 'Text copied';

  @override
  String get onlineLabel => 'Online';

  @override
  String get offlineLabel => 'Offline';

  @override
  String get userDefault => 'User';

  @override
  String get lessThanMinuteAgo => 'less than a minute ago';

  @override
  String minutesAgo(int count) {
    return '$count min. ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h. ago';
  }

  @override
  String daysAgo(int count) {
    return '$count d. ago';
  }

  @override
  String get videoLabel => 'Video';

  @override
  String videoLoadError(String error) {
    return 'Video load error: $error';
  }

  @override
  String get saveFailed => 'Failed to save';

  @override
  String get shareSheetFailed => 'Could not open share sheet';

  @override
  String get speedLabel => 'Speed:';

  @override
  String get previewTitle => 'Preview';

  @override
  String fileDownloaded(String path) {
    return 'File downloaded: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return 'File saved temporarily: $path';
  }

  @override
  String get savedToGallery => 'Saved to gallery';

  @override
  String authorizationError(String message) {
    return 'Authorization error: $message';
  }

  @override
  String get loginTitle => 'Sign In';

  @override
  String get welcomeBack => 'Welcome';

  @override
  String get emailOrUsernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get orDivider => 'Or';

  @override
  String get validationEnterEmailOrUsername => 'Please enter username';

  @override
  String get validationEnterPassword => 'Please enter password';

  @override
  String get registerTitle => 'Register';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthMedium => 'Medium';

  @override
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get nicknameAtLabel => 'Nickname (@username)';

  @override
  String get uploadPhotoPrompt => 'Upload profile photo';

  @override
  String get photoLooksGreat => 'Looking great!';

  @override
  String get helpFriendsFind => 'Help friends find you';

  @override
  String get setupInterfaceTitle => 'Customize your interface';

  @override
  String get colorThemeLabel => 'Color theme';

  @override
  String get validationEnterEmail => 'Please enter email';

  @override
  String get validationInvalidEmail => 'Invalid email address';

  @override
  String get validationPasswordTooShort => 'Password is too short';

  @override
  String get backToLogin => 'Sign In';

  @override
  String get finishButton => 'Finish';

  @override
  String filePickError(String error) {
    return 'File pick error: $error';
  }

  @override
  String get chatsTitle => 'Chats';

  @override
  String get noChats => 'No chats';

  @override
  String get noMessages => '(no messages)';

  @override
  String get newChat => 'New chat';

  @override
  String get messageInputHint => 'Write a message...';

  @override
  String get addCaptionHint => 'Add a caption or message';

  @override
  String get unlockApp => 'Unlock App';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get dropFilesTitle => 'Drop files to attach';

  @override
  String get dropFilesSubtitle => 'They will appear above the message field.';

  @override
  String get videoUnavailable => 'Video unavailable';

  @override
  String get guestRole => 'Guest';

  @override
  String get replyAction => 'Reply';

  @override
  String get editShort => 'Edit';

  @override
  String get pinAction => 'Pin';

  @override
  String get moreReactions => 'More';

  @override
  String get replyDialogTitle => 'Reply';

  @override
  String get replyHint => 'Reply text';

  @override
  String get editMessageTitle => 'Edit message';

  @override
  String get editMessageHint => 'New text';

  @override
  String get deleteMessageTitle => 'Delete message?';

  @override
  String get pinsUpdated => 'Pins updated';

  @override
  String get messageEdited => 'Message edited';

  @override
  String get fileSent => 'File sent';

  @override
  String get voiceNotSupported =>
      'Voice recording is not supported on this platform';

  @override
  String get microphonePermRequired => 'Microphone permission is required';

  @override
  String get recordingError => 'Recording error';

  @override
  String sendFailedError(String error) {
    return 'Send failed: $error';
  }

  @override
  String attachmentSendError(String error) {
    return 'Attachment send error: $error';
  }

  @override
  String shareFailedError(String error) {
    return 'Share failed: $error';
  }

  @override
  String replyError(String error) {
    return 'Reply error: $error';
  }

  @override
  String pinError(String error) {
    return 'Pin error: $error';
  }

  @override
  String deleteError(String error) {
    return 'Delete error: $error';
  }

  @override
  String editMessageError(String error) {
    return 'Edit message error: $error';
  }

  @override
  String get userTyping => 'User is typing...';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusLastSeenRecently => 'Last seen recently';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get customizationLabel => 'Customization';

  @override
  String get customizationSubtitle => 'Colors, font and UI effects';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get soundLabel => 'Sound';

  @override
  String get accountSection => 'Account';

  @override
  String get profileLabel => 'Profile';

  @override
  String get profileSubtitle => 'Edit profile information';

  @override
  String get accountSettingsLabel => 'Account settings';

  @override
  String get accountSettingsSubtitle => 'Password, security, 2FA';

  @override
  String get privacyLabel => 'Privacy';

  @override
  String get privacySubtitle => 'Manage privacy';

  @override
  String get generalSection => 'General';

  @override
  String get languageLabel => 'Language';

  @override
  String get textSizeLabel => 'Text size';

  @override
  String get sendByEnterLabel => 'Send by Enter';

  @override
  String get sendByEnterSubtitle => 'Shift+Enter for new line';

  @override
  String get dataStorageSection => 'Data & Storage';

  @override
  String get autoDownloadLabel => 'Auto-download media';

  @override
  String get autoDownloadSubtitle => 'Download photos and videos automatically';

  @override
  String get storageManagementLabel => 'Storage management';

  @override
  String get storageManagementSubtitle => 'Clear cache and data';

  @override
  String get clearCacheTitle => 'Clear cache';

  @override
  String get clearCacheContent => 'Delete cached data?';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get developmentSection => 'Development';

  @override
  String get devMenuSubtitle => 'Floating debug button';

  @override
  String get aboutSection => 'About';

  @override
  String get suggestImprovementLabel => 'Suggest improvement';

  @override
  String get suggestImprovementSubtitle => 'Ideas and major feature requests';

  @override
  String get dangerZoneSection => 'Danger zone';

  @override
  String get logoutLabel => 'Sign out';

  @override
  String get logoutSubtitle => 'Sign out from this device';

  @override
  String get logoutDialogTitle => 'Sign out';

  @override
  String get logoutDialogContent => 'Are you sure you want to sign out?';

  @override
  String get logoutAction => 'Sign out';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get clientDescription => 'TwoSpace client built with Flutter/Dart';

  @override
  String errorLogout(String error) {
    return 'Error: $error';
  }

  @override
  String get accountSettingsTitle => 'Account settings';

  @override
  String get securitySection => 'Security';

  @override
  String get twoFactorLabel => 'Two-factor authentication';

  @override
  String get twoFactorSubtitle => 'Extra account protection';

  @override
  String get biometricLabel => 'Biometrics';

  @override
  String get biometricSubtitle => 'Sign in with fingerprint';

  @override
  String get activeSessionsLabel => 'Active sessions';

  @override
  String get activeSessionsSubtitle => 'Manage devices';

  @override
  String get currentDevice => 'Current device';

  @override
  String get changePasswordSection => 'Change password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get minPasswordHelper => 'Minimum 8 characters';

  @override
  String get changePasswordButton => 'Change password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordChangeSuccess => 'Password changed successfully';

  @override
  String get contactDataSection => 'Contact information';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get deleteAccountLabel => 'Delete account';

  @override
  String get deleteAccountSubtitle => 'Irreversible action';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountContent =>
      'Are you sure you want to delete your account? This action is irreversible.';

  @override
  String get deleteFeatureLater => 'Account deletion will be available later';

  @override
  String get profileTitle => 'Profile';

  @override
  String get saveTooltip => 'Save';

  @override
  String get editTooltip => 'Edit';

  @override
  String get writeMessageButton => 'Message';

  @override
  String get callButton => 'Call';

  @override
  String get aboutField => 'About me';

  @override
  String get nicknameField => 'Nickname';

  @override
  String get locationField => 'Location';

  @override
  String get birthdayField => 'Birthday';

  @override
  String get nameField => 'Name';

  @override
  String get avatarUploadLater => 'Avatar upload will be added later';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String createChatError(String error) {
    return 'Could not create chat: $error';
  }

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get hideFromSearch => 'Hide from search';

  @override
  String get hideFromSearchSubtitle => 'Do not show me in search results';

  @override
  String get hideLastSeen => 'Hide last seen status';

  @override
  String get hideLastSeenSubtitle =>
      'Others won\'t see when you were last online';

  @override
  String get sessionExpiry => 'Login session expiry';

  @override
  String sessionExpirySubtitle(int days) {
    return 'Auto re-login on this device: $days days';
  }

  @override
  String get sessionExpiryDaysTitle => 'Session expiry (days)';

  @override
  String get sessionExpiryDaysContent =>
      'Choose number of days (min: 7, max: 365).';

  @override
  String get daysLabel => 'Days';

  @override
  String get enterDaysError => 'Enter a number from 7 to 365';

  @override
  String sessionExpirySet(int days) {
    return 'Session expiry set: $days days';
  }

  @override
  String get changeEmailLabel => 'Change email';

  @override
  String get changeEmailSubtitle => 'Update your email address';

  @override
  String get twoFactorPrivacySubtitle =>
      'Enable or disable enhanced protection';

  @override
  String get changePhoneLabel => 'Change phone';

  @override
  String get changePhoneSubtitle => 'Update your phone number';

  @override
  String updatePrivacyError(String error) {
    return 'Could not update privacy: $error';
  }

  @override
  String updateSettingError(String error) {
    return 'Could not update setting: $error';
  }

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get searchContactsHint => 'Search contacts...';

  @override
  String get contactsAccessTitle => 'Contacts access';

  @override
  String get contactsPermDeniedPermanent =>
      'Permission permanently denied. Open settings to allow contacts access.';

  @override
  String get contactsPermRequired =>
      'Contacts permission is required to show contacts.';

  @override
  String get openSettingsButton => 'Open settings';

  @override
  String get requestPermissionButton => 'Request permission';

  @override
  String get noContacts => 'No contacts found';

  @override
  String get callAction => 'Call';

  @override
  String get writeMessageAction => 'Message';

  @override
  String callNotification(String number) {
    return 'Call: $number';
  }

  @override
  String messageNotification(String name) {
    return 'Message to: $name';
  }

  @override
  String get callsTitle => 'Calls';

  @override
  String get searchByNameHint => 'Search by name...';

  @override
  String get allFilter => 'All';

  @override
  String get incomingFilter => 'Incoming';

  @override
  String get outgoingFilter => 'Outgoing';

  @override
  String get missedFilter => 'Missed';

  @override
  String get noCallsFound => 'No calls';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get incomingCall => 'Incoming';

  @override
  String get outgoingCall => 'Outgoing';

  @override
  String get missedCall => 'Missed';

  @override
  String get videoCallLabel => 'Video call';

  @override
  String get voiceCallLabel => 'Voice call';

  @override
  String get sendMessageCallAction => 'Message';

  @override
  String get createRoomTitle => 'Create room';

  @override
  String get createButton => 'Create';

  @override
  String get roomNameLabel => 'Room name';

  @override
  String get roomNameHint => 'E.g. your project name';

  @override
  String get roomTopicLabel => 'Topic (optional)';

  @override
  String get roomTopicHint => 'What is this room about?';

  @override
  String get roomVisibilityLabel => 'Room visibility';

  @override
  String get privateRoomOption => 'Private room';

  @override
  String get privateRoomSubtitle => 'Only invited users can join';

  @override
  String get publicRoomOption => 'Public room';

  @override
  String get publicRoomSubtitle => 'Anyone can join';

  @override
  String get showHistoryLabel => 'Show message history';

  @override
  String get showHistorySubtitle => 'New members can see previous messages';

  @override
  String get enterRoomNameError => 'Please enter a room name';

  @override
  String get roomCreatedSuccess => 'Room created successfully!';

  @override
  String imagePickError(String error) {
    return 'Image pick error: $error';
  }

  @override
  String get groupInfoTab => 'Info';

  @override
  String get groupMembersTab => 'Members';

  @override
  String get groupRolesTab => 'Roles';

  @override
  String get groupBansTab => 'Bans';

  @override
  String get groupDeleteTab => 'Delete';

  @override
  String membersCount(int count) {
    return 'Members: $count';
  }

  @override
  String get messageHistoryToggle => 'Message history';

  @override
  String get showHistoryToggleLabel => 'Show history';

  @override
  String get settingSaved => 'Setting saved';

  @override
  String get backgroundColorLabel => 'Background color';

  @override
  String get noMembers => 'No members';

  @override
  String get roleAction => 'Role';

  @override
  String get freezeAction => 'Freeze';

  @override
  String get banAction => 'Ban';

  @override
  String get kickAction => 'Kick';

  @override
  String get noBannedUsers => 'No banned users';

  @override
  String get bannedLabel => 'Banned';

  @override
  String get userUnbanned => 'User unbanned';

  @override
  String get deleteGroupLabel => 'Delete group';

  @override
  String get deleteGroupWarning =>
      'This action is IRREVERSIBLE. The group will be permanently deleted.';

  @override
  String get confirmDeleteTitle => 'Confirm deletion';

  @override
  String get confirmDeleteContent =>
      'Are you sure? This action is irreversible.';

  @override
  String get changeRoleTitle => 'Change role';

  @override
  String get adminRole => 'Administrator';

  @override
  String get memberRole => 'Member';

  @override
  String get freezeUserTitle => 'Freeze user';

  @override
  String get userBanned => 'User banned';

  @override
  String get userKicked => 'User kicked';

  @override
  String get groupDeleted => 'Group deleted';

  @override
  String loadError(String error) {
    return 'Load error: $error';
  }

  @override
  String get publicLabel => 'Public';

  @override
  String get privateLabel => 'Private';

  @override
  String get noDescription => 'No description';

  @override
  String get membersLabel => 'Members';

  @override
  String get generalLabel => 'General';

  @override
  String get newChatTitle => 'New chat';

  @override
  String get directChatTab => 'Direct';

  @override
  String get groupChatTab => 'Group';

  @override
  String get startDirectChatTitle => 'Start a direct chat';

  @override
  String get contactIdDescription => 'Enter the user\'s username or Aegis ID';

  @override
  String get contactIdLabel => 'Username or Aegis ID';

  @override
  String get startChatButton => 'Start chat';

  @override
  String get hintCardTitle => 'Hint';

  @override
  String get contactIdExplanation =>
      'You can use a username or numeric Aegis user ID';

  @override
  String get enterUserIdError => 'Enter user ID';

  @override
  String get createNewRoomTitle => 'Create new room';

  @override
  String get descriptionOptionalLabel => 'Description (optional)';

  @override
  String get privateGroupLabel => 'Private group';

  @override
  String get privateGroupSubtitle => 'Only invited users can join';

  @override
  String get createRoomButton => 'Create room';

  @override
  String get customizationTitle => 'Customization';

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
  String get previewRoomsTitle => 'Morning brief';

  @override
  String get previewRoomsSubtitle =>
      'A compact room list with real-sounding snippets and cleaner status markers.';

  @override
  String get previewConversationTitle => 'Quick exchange';

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
  String get previewRoomDesignSyncSubtitle =>
      'Good morning. I left the fresh mockups in the pinned note.';

  @override
  String get previewRoomReleaseCheck => 'Release Check';

  @override
  String get previewRoomReleaseCheckSubtitle =>
      'Do you know what time the rollout starts? I am lining up the checklist.';

  @override
  String get previewRoomAlphaOps => 'Alpha Ops';

  @override
  String get previewRoomAlphaOpsSubtitle =>
      'Tokyo is already awake. The overnight logs look clean.';

  @override
  String get previewIncomingMessage =>
      'Good morning. Did the background finally stop feeling like a demo build?';

  @override
  String get previewOutgoingMessage =>
      'Almost. Now it reads like a real chat: calmer spacing, cleaner type, better rhythm.';

  @override
  String get previewTypingStatus =>
      'Typing, corners, and pacing react here immediately.';

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
  String get colorsTab => 'Colors';

  @override
  String get fontsTab => 'Fonts';

  @override
  String get effectsTab => 'Effects';

  @override
  String get selectColorTheme => 'Select color theme';

  @override
  String get themeAppliesEverywhere =>
      'The selected theme is applied throughout the app';

  @override
  String get fontSettingsTitle => 'Font settings';

  @override
  String get selectFontFamily => 'Select font family';

  @override
  String get appFontLabel => 'App font';

  @override
  String get fontWeightLabel => 'Font weight';

  @override
  String get fontPreview => 'Preview: Sample text';

  @override
  String get compactMode => 'Reduce padding and sizes';

  @override
  String get enableCircles => 'Enable circles';

  @override
  String get circlesDesc => 'Animated circles in the background';

  @override
  String get floatingCirclesLabel => 'Floating circles';

  @override
  String get reactOnTilt => 'React to phone tilt';

  @override
  String get parallaxEffect => 'Parallax effect';

  @override
  String get circlesSpeedLabel => 'Movement speed';

  @override
  String get staticMotion => 'Static';

  @override
  String get brightnessLabel => 'Brightness';

  @override
  String get dimOpacity => 'Dim';

  @override
  String get brightOpacity => 'Bright';

  @override
  String get performanceLabel => 'Performance';

  @override
  String get currentSpeedPrefix => 'Current: ';

  @override
  String get speedPrefix => 'Speed:';

  @override
  String get advancedSearchTitle => 'Advanced search';

  @override
  String get searchQueryHint => 'Enter query...';

  @override
  String get searchTypeLabel => 'Search type';

  @override
  String get searchTypeAll => 'All';

  @override
  String get searchTypeMessages => 'Messages';

  @override
  String get searchTypeMedia => 'Media';

  @override
  String get searchTypeUsers => 'Users';

  @override
  String get periodLabel => 'Period';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get searchButton => 'Search';

  @override
  String resultsCount(int count) {
    return 'Results ($count)';
  }

  @override
  String get noResultsFound => 'No results found';

  @override
  String get forgotPasswordTitle => 'Password recovery';

  @override
  String get forgotPasswordDescription =>
      'Enter your email to receive a reset link';

  @override
  String get sendResetButton => 'Send';

  @override
  String get forgotPasswordUnavailable => 'Password recovery is not available';

  @override
  String get changeEmailTitle => 'Change email';

  @override
  String get changeEmailDescription => 'Enter a new email address';

  @override
  String get currentPrefix => 'Current: ';

  @override
  String get newEmailLabel => 'New email';

  @override
  String get changeEmailButton => 'Change email';

  @override
  String changeEmailError(String error) {
    return 'Could not change email: $error';
  }

  @override
  String get changePhoneTitle => 'Change phone number';

  @override
  String get changePhoneDescription =>
      'Enter a new phone number and your current password.';

  @override
  String get newPhoneLabel => 'New number (+1...)';

  @override
  String get currentPasswordOptional => 'Current password (if required)';

  @override
  String get changePhoneButton => 'Change number';

  @override
  String get phoneCannotBeChanged => 'Phone number cannot be changed';

  @override
  String get emailCannotBeChanged => 'Email cannot be changed';

  @override
  String changePhoneError(String error) {
    return 'Could not change number: $error';
  }

  @override
  String get confirmCodeTitle => 'Confirm code';

  @override
  String codeSentTo(String phone) {
    return 'We sent a code to $phone';
  }

  @override
  String get enterCodeHint => 'Enter code';

  @override
  String get confirmButton => 'Confirm';

  @override
  String resendCountdown(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String get resendCodeButton => 'Resend code';

  @override
  String get biometricSetupTitle => 'Security';

  @override
  String get authMethodsLabel => 'Authentication methods';

  @override
  String get biometricAuthLabel => 'Biometric authentication';

  @override
  String get biometricAuthSubtitle => 'Fingerprint or Face ID';

  @override
  String get biometricEnabledLabel => 'Biometrics enabled';

  @override
  String get aboutSecurityLabel => 'About security';

  @override
  String get aboutSecurityContent =>
      'Choose a convenient authentication method to protect your account.';

  @override
  String get setPinCode => 'Set PIN code';

  @override
  String get updateAvailableTitle => 'Update available';

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
  String get whatsNewLabel => 'What\'s new';

  @override
  String get noUpdateDescription => 'No description';

  @override
  String downloadingProgress(int percent) {
    return 'Downloading... $percent%';
  }

  @override
  String get checkingIntegrity => 'Checking integrity...';

  @override
  String get requestingInstall => 'Requesting installation...';

  @override
  String get updateMandatory => 'Update is mandatory';

  @override
  String get laterButton => 'Later';

  @override
  String get downloadingLabel => 'Downloading...';

  @override
  String get installingLabel => 'Installing...';

  @override
  String get updateButton => 'Update';

  @override
  String get downloadFailed => 'Failed to download update';

  @override
  String get integrityCheckFailed =>
      'Downloaded file failed integrity check (sha256)';

  @override
  String get installPermissionTitle => 'Install permission';

  @override
  String get installPermissionContent =>
      'To install the update, allow installation from unknown sources.';

  @override
  String get installPermissionRequired => 'Install permission is required';

  @override
  String get installFailed => 'Installation failed';

  @override
  String get ssoFeatureRequired =>
      'This feature requires webview_flutter configuration';

  @override
  String ssoLoginVia(String idpId) {
    return 'SSO login via $idpId';
  }

  @override
  String get forwardMessageTitle => 'Forward message';

  @override
  String get searchChatHint => 'Search chat...';

  @override
  String forwardButton(int count) {
    return 'Forward ($count)';
  }

  @override
  String get roomAvatarUpdated => 'Room avatar updated';

  @override
  String roomAvatarUploadError(String error) {
    return 'Error uploading avatar: $error';
  }

  @override
  String get roomSettingsSaved => 'Room settings saved';

  @override
  String roomSettingsSaveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get uploadAvatarButton => 'Upload avatar';

  @override
  String loadMembersError(String error) {
    return 'Error loading members: $error';
  }

  @override
  String get leaveRoomTitle => 'Leave room?';

  @override
  String get leaveRoomContent =>
      'You won\'t be able to return to this room unless re-invited.';

  @override
  String get leaveAction => 'Leave';

  @override
  String get leftRoom => 'You left the room';

  @override
  String leaveRoomError(String error) {
    return 'Error leaving room: $error';
  }

  @override
  String get reportNotImplemented => 'Report feature not yet implemented';

  @override
  String get featureInDevelopmentLabel => 'In development';

  @override
  String featureInDevelopmentMessage(String feature) {
    return '$feature is in development and will appear here in a future update.';
  }

  @override
  String get inviteAction => 'Invite';

  @override
  String get threadsLabel => 'Threads';

  @override
  String get pinnedLabel => 'Pinned';

  @override
  String get filesLabel => 'Files';

  @override
  String get noSharedFiles => 'No shared files yet';

  @override
  String get mediaLabel => 'Media';

  @override
  String get noSharedMedia => 'No shared media yet';

  @override
  String get extensionsLabel => 'Extensions';

  @override
  String get copyLinkAction => 'Copy link';

  @override
  String get pollsLabel => 'Polls';

  @override
  String get exportChatAction => 'Export chat';

  @override
  String get reportAction => 'Report';

  @override
  String get leaveRoomAction => 'Leave room';

  @override
  String roomTitle(String name) {
    return 'Room — $name';
  }

  @override
  String get roomSettingsLabel => 'Room settings';

  @override
  String authError(String error) {
    return 'Authentication error: $error';
  }

  @override
  String get loginRequired => 'Login required';

  @override
  String get loginRequiredContent =>
      'You must be logged in to search contacts. Go to login?';

  @override
  String get loginAction => 'Sign In';

  @override
  String searchError(String error) {
    return 'Search error: $error';
  }

  @override
  String get searchContactsTitle => 'Search contacts';

  @override
  String get nicknameOrPhoneHint => 'Nickname or phone number';

  @override
  String selectContactError(String error) {
    return 'Could not select contact: $error';
  }

  @override
  String get categoryLabel => 'Category';

  @override
  String get feedbackCategoryFeatures => 'Features';

  @override
  String get feedbackCategoryPerformance => 'Performance';

  @override
  String get feedbackCategorySecurity => 'Security/Privacy';

  @override
  String get feedbackCategoryNetworkSync => 'Sync/Network';

  @override
  String get shortDescriptionLabel => 'Short description';

  @override
  String get shortDescriptionHint => 'E.g. \"Chat backup to cloud\"';

  @override
  String get feedbackValidation =>
      'Select at least one idea or write a description';

  @override
  String get detailsOptionalLabel => 'Details (optional)';

  @override
  String get detailsHint =>
      'What should work, how it works now and how you\'d like it?';

  @override
  String get bigFeaturesTitle =>
      'Major features (select what interests you most)';

  @override
  String get feedbackE2E =>
      'End-to-end E2E encryption (Olm/Megolm) + device verification';

  @override
  String get feedbackBackup =>
      'Chat backup (local/cloud) + transfer to new device';

  @override
  String get feedbackThreads =>
      'Threads, reactions, mentions, improved message search';

  @override
  String get feedbackCalls => 'Voice/video calls and quick voice rooms';

  @override
  String get feedbackFolders =>
      'Chat folders/categories and smart notification filters';

  @override
  String get feedbackBots =>
      'Bots and integrations (webhooks, GitHub/Jira, reminders)';

  @override
  String get feedbackSlowNet =>
      '\"Slow internet\" mode + aggressive media caching';

  @override
  String get startChatTitle => 'Start chat';

  @override
  String get createRoomSubtitle => 'Private or public group';

  @override
  String get inviteUserTitle => 'Invite user';

  @override
  String get inviteUserSubtitle => 'Find and message a user';

  @override
  String get joinByCodeTitle => 'Join by code';

  @override
  String get joinByCodeSubtitle => 'Join a room using an invite code';

  @override
  String get chatsSubtitle =>
      'Private messages, groups and invite links in one place';

  @override
  String get chatsQuickStartTitle => 'Start something new';

  @override
  String get chatsRecentTitle => 'Recent chats';

  @override
  String get joinLinkHint => 'Paste an invite link, alias or code';

  @override
  String get fontLabel => 'Font';

  @override
  String get pinCodeLabel => 'PIN code';

  @override
  String get pinCodeSubtitle => '4-6 digits for protection';

  @override
  String get pinHint => 'PIN (4-6 digits)';

  @override
  String get pinLengthError => 'PIN must be 4-6 digits';

  @override
  String get pinSetSuccess => 'PIN set';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get closeButton => 'Close';

  @override
  String get saveButton => 'Save';

  @override
  String get sendButton => 'Send';

  @override
  String get copyButton => 'Copy';

  @override
  String get shareButton => 'Share';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get feedbackCategoryUxDesign => 'UX/Design';

  @override
  String get feedbackShareSubject => 'TwoSpace — suggestion';

  @override
  String get feedbackMessageHeader => 'TwoSpace — suggestion/improvement';

  @override
  String feedbackVersion(String version) {
    return 'Version: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return 'Category: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return 'Brief: $title';
  }

  @override
  String get feedbackWishList => 'What would be especially great:';

  @override
  String get feedbackDetailsLine => 'Details:';

  @override
  String get circlesVisible => 'Circles displayed';

  @override
  String get circlesHidden => 'Circles hidden';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedFast => 'Fast';

  @override
  String get advancedSettingsLabel => 'Advanced settings';

  @override
  String get compactModeLabel => 'Compact mode';

  @override
  String get activeDeviceInfo => 'Android • Active';

  @override
  String stubPlaceholder(String key) {
    return 'Stub — $key';
  }

  @override
  String loadMessagesError(String error) {
    return 'Error loading messages: $error';
  }

  @override
  String get pinnedUpdated => 'Pins updated';

  @override
  String editError(String error) {
    return 'Edit error: $error';
  }

  @override
  String get moreButton => 'More';

  @override
  String shareError(String error) {
    return 'Could not share: $error';
  }

  @override
  String sendError(String error) {
    return 'Send failed: $error';
  }

  @override
  String get voiceRecordingUnsupported =>
      'Voice recording is not supported on this platform';

  @override
  String get microphonePermissionRequired => 'Microphone permission required';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get ownersLabel => '👑 Owners';

  @override
  String get administratorsLabel => '⚡ Administrators';

  @override
  String get oneHour => '1 hour';

  @override
  String get oneDay => '1 day';

  @override
  String get sevenDays => '7 days';

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
  String get storageMemoryTitle => 'Memory';

  @override
  String get storageTotalLabel => 'Total';

  @override
  String get storageSelectedLabel => 'Selected';

  @override
  String get storagePhotosLabel => 'Photos';

  @override
  String get storageVideosLabel => 'Videos';

  @override
  String get storageCacheLabel => 'Cache';

  @override
  String get storageAppDataLabel => 'App data';

  @override
  String get storageCleanupTitle => 'Selected to clear';

  @override
  String get storageCleanupSubtitle => 'Review what can be safely removed.';

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
  String get peopleTitle => 'People';

  @override
  String get peopleSubtitle =>
      'Contacts, favorites, search and invites in one place';

  @override
  String get peopleQuickNewChat => 'New chat';

  @override
  String get peopleQuickInvite => 'Invite';

  @override
  String get peopleQuickSync => 'Sync';

  @override
  String get peopleSearchHint => 'Search by name, nickname or phone';

  @override
  String get peopleSegmentAll => 'All';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => 'Phonebook';

  @override
  String get peopleSegmentRecent => 'Recent';

  @override
  String get peopleLoading => 'Loading people…';

  @override
  String get peopleNoPeopleTitle => 'No people yet';

  @override
  String get peopleNoPeopleMessage =>
      'Your favorites, recent conversations and contacts will appear here.';

  @override
  String get peoplePermissionCardTitle => 'Phonebook access is limited';

  @override
  String get peoplePermissionCardMessage =>
      'Allow contacts access to show your phonebook and invite people faster.';

  @override
  String get peoplePermissionCardMessageSettings =>
      'Enable contacts access in system settings to restore your phonebook section.';

  @override
  String get peopleFavoritesFrequentTitle => 'Favorites & frequent';

  @override
  String get peopleRecentTitle => 'Recent people';

  @override
  String get peopleTwoSpaceTitle => 'TwoSpace people';

  @override
  String get peopleInviteTitle => 'Invite to TwoSpace';

  @override
  String get peopleInviteSubtitle => 'Invite this contact to TwoSpace';

  @override
  String get peopleSearching => 'Searching people…';

  @override
  String get peopleSearchRemoteTitle => 'TwoSpace results';

  @override
  String get peopleSearchLocalTitle => 'Recent and saved';

  @override
  String get peopleSearchInviteTitle => 'Invite from phonebook';

  @override
  String get peopleSearchEmptyTitle => 'No matching people';

  @override
  String get peopleSearchEmptyMessage =>
      'Try another name, nickname or phone number.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => 'No extra details yet';

  @override
  String get peopleInviteShareText =>
      'Join me on TwoSpace — a secure messenger for chats and calls.';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return 'Join me on TwoSpace, $personName — let’s chat and call securely.';
  }

  @override
  String get peopleViewProfileAction => 'View profile';

  @override
  String get peopleRemoveFavoriteAction => 'Remove from favorites';

  @override
  String get peopleAddFavoriteAction => 'Add to favorites';

  @override
  String get callsSubtitle =>
      'Recent calls, quick redial and people-first history';

  @override
  String get callsStartCallAction => 'Start call';

  @override
  String get callsQuickStartTitle => 'Call someone now';

  @override
  String get callsQuickStartSubtitle =>
      'Open People, search for someone and start a secure voice or video call.';

  @override
  String get callsSearchHint => 'Search call history';

  @override
  String get callsVideoFilter => 'Video';

  @override
  String get callsTopContactsTitle => 'Top contacts';

  @override
  String get callsLoadingLabel => 'Loading calls…';

  @override
  String get callsEmptyTitle => 'No calls yet';

  @override
  String get callsEmptyMessage =>
      'Your call history will appear here after your first voice or video call.';

  @override
  String get callsEmptySearchMessage =>
      'No calls match the current search or filter.';

  @override
  String get callsTodaySection => 'Today';

  @override
  String get callsThisWeekSection => 'This week';

  @override
  String get callsEarlierSection => 'Earlier';

  @override
  String callsThreadCount(int count) {
    return '$count calls';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count missed';
  }

  @override
  String get callsMuteAction => 'Mute';

  @override
  String get callsSpeakerAction => 'Speaker';

  @override
  String get callsCameraAction => 'Camera';

  @override
  String get callsSwitchCameraAction => 'Switch';

  @override
  String get callsEndAction => 'End call';

  @override
  String get callsConnectingLabel => 'Connecting…';

  @override
  String get callsRingingLabel => 'Ringing…';

  @override
  String get callsConnectingDetail => 'Creating a secure call session.';

  @override
  String get callsRingingDetail => 'Waiting for the other person to answer.';

  @override
  String get callsVideoSecureDetail =>
      'Video is protected and routed through the current secure session.';

  @override
  String get callsVoiceSecureDetail =>
      'Voice is protected and routed through the current secure session.';

  @override
  String get timestampPrecisionLabel => 'Message time precision';

  @override
  String get timestampPrecisionSubtitle =>
      'Choose how detailed timestamps look in chats and chat list.';

  @override
  String get timestampPrecisionMinutes => 'Hours and minutes';

  @override
  String get timestampPrecisionSeconds => 'Hours, minutes and seconds';

  @override
  String get timestampPrecisionMilliseconds =>
      'Hours, minutes, seconds and milliseconds';

  @override
  String get startupTitle => 'Preparing TwoSpace';

  @override
  String get startupSubtitle =>
      'Checking the secure session and opening your chats.';

  @override
  String get startupFooter => 'This screen is only shown during app startup.';

  @override
  String get startupStepEnvironment => 'Loading configuration';

  @override
  String get startupStepDiagnostics => 'Starting diagnostics';

  @override
  String get startupStepValidation => 'Validating environment';

  @override
  String get startupStepSettings => 'Loading settings';

  @override
  String get startupStepSession => 'Restoring secure session';

  @override
  String get startupStepLaunch => 'Starting app';

  @override
  String get callsDemoBannerTitle => 'Demo, not a working call';

  @override
  String get callsDemoBannerVoiceMessage =>
      'Voice calls are shown as a visual prototype only. Audio transport is not connected yet.';

  @override
  String get callsDemoBannerVideoMessage =>
      'Video calls are shown as a visual prototype only. The remote stream is unavailable, but your local camera preview works.';

  @override
  String get callsCameraPermissionMessage =>
      'Allow camera access to show your local preview during a video call.';

  @override
  String get callsCameraPermissionSettingsMessage =>
      'Camera access is blocked. Open system settings to enable the local video preview.';

  @override
  String get callsCameraPermissionAction => 'Allow camera';

  @override
  String get callsCameraUnavailableTitle => 'Camera unavailable';

  @override
  String get callsCameraUnavailableMessage =>
      'The local camera preview could not be started on this device.';

  @override
  String get callsCameraUnsupportedMessage =>
      'This platform does not support the local video preview.';

  @override
  String get callsCameraOffMessage =>
      'Camera preview is turned off for this demo call.';

  @override
  String get callsFrontCameraLabel => 'Front camera';

  @override
  String get callsRearCameraLabel => 'Rear camera';

  @override
  String get backgroundOptimizationDisabledTitle =>
      'Background effects were simplified';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace detected sustained slow frames and turned off heavy background effects to keep scrolling and chat interactions smooth.';

  @override
  String get backgroundOptimizationOpenSettings => 'Open appearance settings';

  @override
  String get roomJoinRuleLabel => 'Who can join';

  @override
  String get roomJoinRulePublic => 'Open to everyone';

  @override
  String get roomJoinRulePublicDescription =>
      'Anyone can discover and join this room.';

  @override
  String get roomJoinRuleInviteOnly => 'Invite only';

  @override
  String get roomJoinRuleInviteOnlyDescription =>
      'Only invited users can join this room.';

  @override
  String get roomJoinRuleApproval => 'Approval required';

  @override
  String get roomJoinRuleApprovalDescription =>
      'Users can request access and must be approved before joining.';

  @override
  String get roomHistoryVisibilityLabel => 'Who can see history';

  @override
  String get roomHistoryVisibilityWorldReadable => 'Everyone';

  @override
  String get roomHistoryVisibilityWorldReadableDescription =>
      'Anyone can view earlier messages.';

  @override
  String get roomHistoryVisibilityJoined => 'Joined members';

  @override
  String get roomHistoryVisibilityJoinedDescription =>
      'Only joined members can view earlier messages.';

  @override
  String get roomHistoryVisibilityInvited => 'Invited users only';

  @override
  String get roomHistoryVisibilityInvitedDescription =>
      'Only invited users can view earlier messages.';
}
