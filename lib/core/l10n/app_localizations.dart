import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'TwoSpace'**
  String get appTitle;

  /// Generic loading indicator
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// App initialization label
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorGeneric;

  /// Short init error label
  ///
  /// In en, this message translates to:
  /// **'Initialization error'**
  String get errorInitialization;

  /// Full init error message
  ///
  /// In en, this message translates to:
  /// **'Initialization error. Please restart the app.'**
  String get errorInitializationFull;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetwork;

  /// Auth error message
  ///
  /// In en, this message translates to:
  /// **'Authentication error.'**
  String get errorAuth;

  /// Invalid arguments error
  ///
  /// In en, this message translates to:
  /// **'Invalid arguments.'**
  String get errorInvalidArguments;

  /// Profile invalid args
  ///
  /// In en, this message translates to:
  /// **'Invalid arguments for profile.'**
  String get errorInvalidArgumentsProfile;

  /// Chat invalid args
  ///
  /// In en, this message translates to:
  /// **'Invalid arguments for chat.'**
  String get errorInvalidArgumentsChat;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Error with detail
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetail(String error);

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No data label
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Empty search result
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// Copy action
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// Share action in message bubble
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// Snackbar text when text is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get textCopied;

  /// Online status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineLabel;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineLabel;

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userDefault;

  /// Relative time string
  ///
  /// In en, this message translates to:
  /// **'less than a minute ago'**
  String get lessThanMinuteAgo;

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count} min. ago'**
  String minutesAgo(int count);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'{count} h. ago'**
  String hoursAgo(int count);

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'{count} d. ago'**
  String daysAgo(int count);

  /// Video label
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoLabel;

  /// Video load error
  ///
  /// In en, this message translates to:
  /// **'Video load error: {error}'**
  String videoLoadError(String error);

  /// Save failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get saveFailed;

  /// Share sheet error
  ///
  /// In en, this message translates to:
  /// **'Could not open share sheet'**
  String get shareSheetFailed;

  /// Speed label in audio player
  ///
  /// In en, this message translates to:
  /// **'Speed:'**
  String get speedLabel;

  /// Media viewer default title
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewTitle;

  /// File downloaded notification
  ///
  /// In en, this message translates to:
  /// **'File downloaded: {path}'**
  String fileDownloaded(String path);

  /// File saved temporarily
  ///
  /// In en, this message translates to:
  /// **'File saved temporarily: {path}'**
  String fileSavedTemp(String path);

  /// Saved to gallery notification
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get savedToGallery;

  /// Authorization error with message
  ///
  /// In en, this message translates to:
  /// **'Authorization error: {message}'**
  String authorizationError(String message);

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// Login screen welcome text
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeBack;

  /// Login email/username field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get emailOrUsernameLabel;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No account prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// Or divider in login
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get orDivider;

  /// Validation: enter email or username
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get validationEnterEmailOrUsername;

  /// Validation: enter password
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get validationEnterPassword;

  /// Register screen title
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// Validation: fill all fields
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// Password strength: weak
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// Password strength: medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordStrengthMedium;

  /// Password strength: good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// Password strength: strong
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// Full name field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// Nickname field with @ hint
  ///
  /// In en, this message translates to:
  /// **'Nickname (@username)'**
  String get nicknameAtLabel;

  /// Photo upload prompt
  ///
  /// In en, this message translates to:
  /// **'Upload profile photo'**
  String get uploadPhotoPrompt;

  /// Photo upload positive feedback
  ///
  /// In en, this message translates to:
  /// **'Looking great!'**
  String get photoLooksGreat;

  /// Register: help friends find you
  ///
  /// In en, this message translates to:
  /// **'Help friends find you'**
  String get helpFriendsFind;

  /// Register: setup interface step title
  ///
  /// In en, this message translates to:
  /// **'Customize your interface'**
  String get setupInterfaceTitle;

  /// Color theme label
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get colorThemeLabel;

  /// Validation: enter email
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get validationEnterEmail;

  /// Validation: invalid email
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get validationInvalidEmail;

  /// Validation: password too short
  ///
  /// In en, this message translates to:
  /// **'Password is too short'**
  String get validationPasswordTooShort;

  /// Back to login link
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get backToLogin;

  /// Finish registration button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// File pick error
  ///
  /// In en, this message translates to:
  /// **'File pick error: {error}'**
  String filePickError(String error);

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// Empty chats list
  ///
  /// In en, this message translates to:
  /// **'No chats'**
  String get noChats;

  /// No messages in chat
  ///
  /// In en, this message translates to:
  /// **'(no messages)'**
  String get noMessages;

  /// New chat button
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get messageInputHint;

  /// Hint shown when attachments are pending
  ///
  /// In en, this message translates to:
  /// **'Add a caption or message'**
  String get addCaptionHint;

  /// Biometric prompt title
  ///
  /// In en, this message translates to:
  /// **'Unlock App'**
  String get unlockApp;

  /// Button to unlock app with biometrics
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// Drag-and-drop overlay heading
  ///
  /// In en, this message translates to:
  /// **'Drop files to attach'**
  String get dropFilesTitle;

  /// Drag-and-drop overlay description
  ///
  /// In en, this message translates to:
  /// **'They will appear above the message field.'**
  String get dropFilesSubtitle;

  /// Shown when video cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get videoUnavailable;

  /// Guest role label
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestRole;

  /// Reply action label
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyAction;

  /// Short edit label in message action bar
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editShort;

  /// Pin message action
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pinAction;

  /// More reactions button
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreReactions;

  /// Reply dialog title
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyDialogTitle;

  /// Reply text field hint
  ///
  /// In en, this message translates to:
  /// **'Reply text'**
  String get replyHint;

  /// Edit message dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editMessageTitle;

  /// Edit message text field hint
  ///
  /// In en, this message translates to:
  /// **'New text'**
  String get editMessageHint;

  /// Delete message dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete message?'**
  String get deleteMessageTitle;

  /// Pins updated notification
  ///
  /// In en, this message translates to:
  /// **'Pins updated'**
  String get pinsUpdated;

  /// Message edited snackbar
  ///
  /// In en, this message translates to:
  /// **'Message edited'**
  String get messageEdited;

  /// File sent confirmation snackbar
  ///
  /// In en, this message translates to:
  /// **'File sent'**
  String get fileSent;

  /// Voice recording not supported
  ///
  /// In en, this message translates to:
  /// **'Voice recording is not supported on this platform'**
  String get voiceNotSupported;

  /// Microphone permission required
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required'**
  String get microphonePermRequired;

  /// Recording error message
  ///
  /// In en, this message translates to:
  /// **'Recording error'**
  String get recordingError;

  /// Send failed error
  ///
  /// In en, this message translates to:
  /// **'Send failed: {error}'**
  String sendFailedError(String error);

  /// Attachment send error
  ///
  /// In en, this message translates to:
  /// **'Attachment send error: {error}'**
  String attachmentSendError(String error);

  /// Share failed error
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailedError(String error);

  /// Reply error message
  ///
  /// In en, this message translates to:
  /// **'Reply error: {error}'**
  String replyError(String error);

  /// Pin/unpin error message
  ///
  /// In en, this message translates to:
  /// **'Pin error: {error}'**
  String pinError(String error);

  /// Delete error message
  ///
  /// In en, this message translates to:
  /// **'Delete error: {error}'**
  String deleteError(String error);

  /// Edit message error
  ///
  /// In en, this message translates to:
  /// **'Edit message error: {error}'**
  String editMessageError(String error);

  /// User typing indicator
  ///
  /// In en, this message translates to:
  /// **'User is typing...'**
  String get userTyping;

  /// Online status label
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// Last seen recently status
  ///
  /// In en, this message translates to:
  /// **'Last seen recently'**
  String get statusLastSeenRecently;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings: appearance section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// Theme label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Customization label
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get customizationLabel;

  /// Customization subtitle
  ///
  /// In en, this message translates to:
  /// **'Colors, font and UI effects'**
  String get customizationSubtitle;

  /// Notifications section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// Notifications label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// Sound label
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundLabel;

  /// Account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// Profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// Profile subtitle
  ///
  /// In en, this message translates to:
  /// **'Edit profile information'**
  String get profileSubtitle;

  /// Account settings label
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettingsLabel;

  /// Account settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Password, security, 2FA'**
  String get accountSettingsSubtitle;

  /// Privacy label
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyLabel;

  /// Privacy subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage privacy'**
  String get privacySubtitle;

  /// General section
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// Language label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// Text size setting label
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSizeLabel;

  /// Send by enter label
  ///
  /// In en, this message translates to:
  /// **'Send by Enter'**
  String get sendByEnterLabel;

  /// Send by enter subtitle
  ///
  /// In en, this message translates to:
  /// **'Shift+Enter for new line'**
  String get sendByEnterSubtitle;

  /// Data and storage section
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataStorageSection;

  /// Auto download label
  ///
  /// In en, this message translates to:
  /// **'Auto-download media'**
  String get autoDownloadLabel;

  /// Auto download subtitle
  ///
  /// In en, this message translates to:
  /// **'Download photos and videos automatically'**
  String get autoDownloadSubtitle;

  /// Storage management label
  ///
  /// In en, this message translates to:
  /// **'Storage management'**
  String get storageManagementLabel;

  /// Storage management subtitle
  ///
  /// In en, this message translates to:
  /// **'Clear cache and data'**
  String get storageManagementSubtitle;

  /// Clear cache dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCacheTitle;

  /// Clear cache dialog content
  ///
  /// In en, this message translates to:
  /// **'Delete cached data?'**
  String get clearCacheContent;

  /// Cache cleared notification
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// Development section
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get developmentSection;

  /// Dev menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Floating debug button'**
  String get devMenuSubtitle;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// Suggest improvement label
  ///
  /// In en, this message translates to:
  /// **'Suggest improvement'**
  String get suggestImprovementLabel;

  /// Suggest improvement subtitle
  ///
  /// In en, this message translates to:
  /// **'Ideas and major feature requests'**
  String get suggestImprovementSubtitle;

  /// Danger zone section
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZoneSection;

  /// Logout label
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutLabel;

  /// Logout subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign out from this device'**
  String get logoutSubtitle;

  /// Logout dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutDialogTitle;

  /// Logout dialog content
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutDialogContent;

  /// Logout action button
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutAction;

  /// Russian language option
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// Ukrainian language option
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageUkrainian;

  /// Client description
  ///
  /// In en, this message translates to:
  /// **'TwoSpace client built with Flutter/Dart'**
  String get clientDescription;

  /// Logout error
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLogout(String error);

  /// Account settings screen title
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettingsTitle;

  /// Security section
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// 2FA label
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get twoFactorLabel;

  /// 2FA subtitle
  ///
  /// In en, this message translates to:
  /// **'Extra account protection'**
  String get twoFactorSubtitle;

  /// Biometrics label
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometricLabel;

  /// Biometrics subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in with fingerprint'**
  String get biometricSubtitle;

  /// Active sessions label
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get activeSessionsLabel;

  /// Active sessions subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage devices'**
  String get activeSessionsSubtitle;

  /// Current device label
  ///
  /// In en, this message translates to:
  /// **'Current device'**
  String get currentDevice;

  /// Change password section
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordSection;

  /// Current password field
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// New password field
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// Confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// Minimum password helper
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get minPasswordHelper;

  /// Change password button
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordButton;

  /// Password mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// Password too short error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// Password change success
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangeSuccess;

  /// Contact data section
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactDataSection;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// Delete account label
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountLabel;

  /// Delete account subtitle
  ///
  /// In en, this message translates to:
  /// **'Irreversible action'**
  String get deleteAccountSubtitle;

  /// Delete account dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// Delete account dialog content
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is irreversible.'**
  String get deleteAccountContent;

  /// Delete feature not yet available
  ///
  /// In en, this message translates to:
  /// **'Account deletion will be available later'**
  String get deleteFeatureLater;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Save tooltip
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveTooltip;

  /// Edit tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// Write message button
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get writeMessageButton;

  /// Call button
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButton;

  /// About me field
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get aboutField;

  /// Nickname field
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameField;

  /// Location field
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationField;

  /// Birthday field
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthdayField;

  /// Name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameField;

  /// Avatar upload not yet available
  ///
  /// In en, this message translates to:
  /// **'Avatar upload will be added later'**
  String get avatarUploadLater;

  /// Profile saved notification
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// Create chat error
  ///
  /// In en, this message translates to:
  /// **'Could not create chat: {error}'**
  String createChatError(String error);

  /// Privacy screen title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// Hide from search toggle
  ///
  /// In en, this message translates to:
  /// **'Hide from search'**
  String get hideFromSearch;

  /// Hide from search subtitle
  ///
  /// In en, this message translates to:
  /// **'Do not show me in search results'**
  String get hideFromSearchSubtitle;

  /// Hide last seen toggle
  ///
  /// In en, this message translates to:
  /// **'Hide last seen status'**
  String get hideLastSeen;

  /// Hide last seen subtitle
  ///
  /// In en, this message translates to:
  /// **'Others won\'t see when you were last online'**
  String get hideLastSeenSubtitle;

  /// Session expiry label
  ///
  /// In en, this message translates to:
  /// **'Login session expiry'**
  String get sessionExpiry;

  /// Session expiry subtitle
  ///
  /// In en, this message translates to:
  /// **'Auto re-login on this device: {days} days'**
  String sessionExpirySubtitle(int days);

  /// Session expiry days dialog title
  ///
  /// In en, this message translates to:
  /// **'Session expiry (days)'**
  String get sessionExpiryDaysTitle;

  /// Session expiry days dialog content
  ///
  /// In en, this message translates to:
  /// **'Choose number of days (min: 7, max: 365).'**
  String get sessionExpiryDaysContent;

  /// Days label
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysLabel;

  /// Days validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 7 to 365'**
  String get enterDaysError;

  /// Session expiry set notification
  ///
  /// In en, this message translates to:
  /// **'Session expiry set: {days} days'**
  String sessionExpirySet(int days);

  /// Change email label
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmailLabel;

  /// Change email subtitle
  ///
  /// In en, this message translates to:
  /// **'Update your email address'**
  String get changeEmailSubtitle;

  /// 2FA privacy subtitle
  ///
  /// In en, this message translates to:
  /// **'Enable or disable enhanced protection'**
  String get twoFactorPrivacySubtitle;

  /// Change phone label
  ///
  /// In en, this message translates to:
  /// **'Change phone'**
  String get changePhoneLabel;

  /// Change phone subtitle
  ///
  /// In en, this message translates to:
  /// **'Update your phone number'**
  String get changePhoneSubtitle;

  /// Update privacy error
  ///
  /// In en, this message translates to:
  /// **'Could not update privacy: {error}'**
  String updatePrivacyError(String error);

  /// Update setting error
  ///
  /// In en, this message translates to:
  /// **'Could not update setting: {error}'**
  String updateSettingError(String error);

  /// Contacts screen title
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// Search contacts hint
  ///
  /// In en, this message translates to:
  /// **'Search contacts...'**
  String get searchContactsHint;

  /// Contacts access title
  ///
  /// In en, this message translates to:
  /// **'Contacts access'**
  String get contactsAccessTitle;

  /// Contacts permission permanently denied
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. Open settings to allow contacts access.'**
  String get contactsPermDeniedPermanent;

  /// Contacts permission required
  ///
  /// In en, this message translates to:
  /// **'Contacts permission is required to show contacts.'**
  String get contactsPermRequired;

  /// Open settings button
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsButton;

  /// Request permission button
  ///
  /// In en, this message translates to:
  /// **'Request permission'**
  String get requestPermissionButton;

  /// Empty contacts list
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContacts;

  /// Call action
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// Write message action
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get writeMessageAction;

  /// Call notification
  ///
  /// In en, this message translates to:
  /// **'Call: {number}'**
  String callNotification(String number);

  /// Message notification
  ///
  /// In en, this message translates to:
  /// **'Message to: {name}'**
  String messageNotification(String name);

  /// Calls screen title
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get callsTitle;

  /// Search by name hint
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByNameHint;

  /// All calls filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// Incoming calls filter
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incomingFilter;

  /// Outgoing calls filter
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get outgoingFilter;

  /// Missed calls filter
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missedFilter;

  /// Empty calls list
  ///
  /// In en, this message translates to:
  /// **'No calls'**
  String get noCallsFound;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// Incoming call label
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incomingCall;

  /// Outgoing call label
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get outgoingCall;

  /// Missed call label
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missedCall;

  /// Video call label
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get videoCallLabel;

  /// Voice call label
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get voiceCallLabel;

  /// Send message from call list
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get sendMessageCallAction;

  /// Create room title
  ///
  /// In en, this message translates to:
  /// **'Create room'**
  String get createRoomTitle;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// Room name field
  ///
  /// In en, this message translates to:
  /// **'Room name'**
  String get roomNameLabel;

  /// Room name hint
  ///
  /// In en, this message translates to:
  /// **'E.g. your project name'**
  String get roomNameHint;

  /// Room topic label
  ///
  /// In en, this message translates to:
  /// **'Topic (optional)'**
  String get roomTopicLabel;

  /// Room topic hint
  ///
  /// In en, this message translates to:
  /// **'What is this room about?'**
  String get roomTopicHint;

  /// Room visibility label
  ///
  /// In en, this message translates to:
  /// **'Room visibility'**
  String get roomVisibilityLabel;

  /// Private room option
  ///
  /// In en, this message translates to:
  /// **'Private room'**
  String get privateRoomOption;

  /// Private room subtitle
  ///
  /// In en, this message translates to:
  /// **'Only invited users can join'**
  String get privateRoomSubtitle;

  /// Public room option
  ///
  /// In en, this message translates to:
  /// **'Public room'**
  String get publicRoomOption;

  /// Public room subtitle
  ///
  /// In en, this message translates to:
  /// **'Anyone can join'**
  String get publicRoomSubtitle;

  /// Show history label
  ///
  /// In en, this message translates to:
  /// **'Show message history'**
  String get showHistoryLabel;

  /// Show history subtitle
  ///
  /// In en, this message translates to:
  /// **'New members can see previous messages'**
  String get showHistorySubtitle;

  /// Enter room name validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a room name'**
  String get enterRoomNameError;

  /// Room created success
  ///
  /// In en, this message translates to:
  /// **'Room created successfully!'**
  String get roomCreatedSuccess;

  /// Image pick error
  ///
  /// In en, this message translates to:
  /// **'Image pick error: {error}'**
  String imagePickError(String error);

  /// Group settings info tab
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get groupInfoTab;

  /// Group settings members tab
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembersTab;

  /// Group settings roles tab
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get groupRolesTab;

  /// Group settings bans tab
  ///
  /// In en, this message translates to:
  /// **'Bans'**
  String get groupBansTab;

  /// Group settings delete tab
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get groupDeleteTab;

  /// Members count
  ///
  /// In en, this message translates to:
  /// **'Members: {count}'**
  String membersCount(int count);

  /// Message history toggle
  ///
  /// In en, this message translates to:
  /// **'Message history'**
  String get messageHistoryToggle;

  /// Show history toggle label
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get showHistoryToggleLabel;

  /// Setting saved notification
  ///
  /// In en, this message translates to:
  /// **'Setting saved'**
  String get settingSaved;

  /// Background color label
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get backgroundColorLabel;

  /// No members label
  ///
  /// In en, this message translates to:
  /// **'No members'**
  String get noMembers;

  /// Role action
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleAction;

  /// Freeze action
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get freezeAction;

  /// Ban action
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get banAction;

  /// Kick action
  ///
  /// In en, this message translates to:
  /// **'Kick'**
  String get kickAction;

  /// No banned users label
  ///
  /// In en, this message translates to:
  /// **'No banned users'**
  String get noBannedUsers;

  /// Banned label
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get bannedLabel;

  /// User unbanned notification
  ///
  /// In en, this message translates to:
  /// **'User unbanned'**
  String get userUnbanned;

  /// Delete group label
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteGroupLabel;

  /// Delete group warning
  ///
  /// In en, this message translates to:
  /// **'This action is IRREVERSIBLE. The group will be permanently deleted.'**
  String get deleteGroupWarning;

  /// Confirm delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeleteTitle;

  /// Confirm delete dialog content
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This action is irreversible.'**
  String get confirmDeleteContent;

  /// Change role dialog title
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get changeRoleTitle;

  /// Admin role
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminRole;

  /// Member role
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberRole;

  /// Freeze user dialog title
  ///
  /// In en, this message translates to:
  /// **'Freeze user'**
  String get freezeUserTitle;

  /// User banned notification
  ///
  /// In en, this message translates to:
  /// **'User banned'**
  String get userBanned;

  /// User kicked notification
  ///
  /// In en, this message translates to:
  /// **'User kicked'**
  String get userKicked;

  /// Group deleted notification
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get groupDeleted;

  /// Load error
  ///
  /// In en, this message translates to:
  /// **'Load error: {error}'**
  String loadError(String error);

  /// Public label
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicLabel;

  /// Private label
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateLabel;

  /// No description label
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// Members label
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersLabel;

  /// General label
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalLabel;

  /// New chat screen title
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChatTitle;

  /// Direct chat tab
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get directChatTab;

  /// Group chat tab
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupChatTab;

  /// Start direct chat title
  ///
  /// In en, this message translates to:
  /// **'Start a direct chat'**
  String get startDirectChatTitle;

  /// Contact identifier description
  ///
  /// In en, this message translates to:
  /// **'Enter the user\'s username or Aegis ID'**
  String get contactIdDescription;

  /// Contact identifier label
  ///
  /// In en, this message translates to:
  /// **'Username or Aegis ID'**
  String get contactIdLabel;

  /// Start chat button
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get startChatButton;

  /// Hint card title
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hintCardTitle;

  /// Contact identifier explanation
  ///
  /// In en, this message translates to:
  /// **'You can use a username or numeric Aegis user ID'**
  String get contactIdExplanation;

  /// Enter user ID validation
  ///
  /// In en, this message translates to:
  /// **'Enter user ID'**
  String get enterUserIdError;

  /// Create new room title
  ///
  /// In en, this message translates to:
  /// **'Create new room'**
  String get createNewRoomTitle;

  /// Description optional label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptionalLabel;

  /// Private group label
  ///
  /// In en, this message translates to:
  /// **'Private group'**
  String get privateGroupLabel;

  /// Private group subtitle
  ///
  /// In en, this message translates to:
  /// **'Only invited users can join'**
  String get privateGroupSubtitle;

  /// Create room button
  ///
  /// In en, this message translates to:
  /// **'Create room'**
  String get createRoomButton;

  /// Customization screen title
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get customizationTitle;

  /// Customization hero title
  ///
  /// In en, this message translates to:
  /// **'Shape the app around your rhythm'**
  String get customizationHeroTitle;

  /// Customization hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Build a distinct look with live preview, curated presets, motion, and density controls.'**
  String get customizationHeroSubtitle;

  /// Notifications screen hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Tune alerts, sound behavior, and custom previews so incoming activity feels calm and readable.'**
  String get notificationsHeroSubtitle;

  /// Live preview badge
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get livePreviewBadge;

  /// Style presets section title
  ///
  /// In en, this message translates to:
  /// **'Style presets'**
  String get stylePresetsTitle;

  /// Style presets section subtitle
  ///
  /// In en, this message translates to:
  /// **'Start with a strong visual direction, then tune the details.'**
  String get stylePresetsSubtitle;

  /// Mood section title
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodSectionTitle;

  /// Mood section subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose the accent that drives surfaces, highlights, and the background atmosphere.'**
  String get moodSectionSubtitle;

  /// Type section title
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeSectionTitle;

  /// Type section subtitle
  ///
  /// In en, this message translates to:
  /// **'Pair a font family with the weight and size that feels right across the whole UI.'**
  String get typeSectionSubtitle;

  /// Motion section title
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get motionSectionTitle;

  /// Motion section subtitle
  ///
  /// In en, this message translates to:
  /// **'Control how much the interface breathes, drifts, and reacts in the background.'**
  String get motionSectionSubtitle;

  /// Density section title
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get densitySectionTitle;

  /// Density section subtitle
  ///
  /// In en, this message translates to:
  /// **'Tighten spacing, bubble geometry, and navigation timing for a sharper layout.'**
  String get densitySectionSubtitle;

  /// Theme mode selector label on customization screen
  ///
  /// In en, this message translates to:
  /// **'Light balance'**
  String get themeModeLabel;

  /// Dynamic bubbles label
  ///
  /// In en, this message translates to:
  /// **'Dynamic bubbles'**
  String get dynamicBubblesLabel;

  /// Dynamic bubbles subtitle
  ///
  /// In en, this message translates to:
  /// **'Give chat bubbles directional corners for a more conversational rhythm.'**
  String get dynamicBubblesSubtitle;

  /// Bubble rounding label
  ///
  /// In en, this message translates to:
  /// **'Bubble rounding'**
  String get bubbleRoundingLabel;

  /// Bubble rounding compact label
  ///
  /// In en, this message translates to:
  /// **'Sharper'**
  String get bubbleRoundingCompact;

  /// Bubble rounding soft label
  ///
  /// In en, this message translates to:
  /// **'Softer'**
  String get bubbleRoundingSoft;

  /// Navigation auto hide label
  ///
  /// In en, this message translates to:
  /// **'Navigation auto-hide'**
  String get navBarTimeoutLabel;

  /// Navigation auto hide duration
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String navBarTimeoutValue(int seconds);

  /// Short navigation timeout label
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get navBarTimeoutShort;

  /// Long navigation timeout label
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get navBarTimeoutLong;

  /// Quiet Glass preset title
  ///
  /// In en, this message translates to:
  /// **'Quiet Glass'**
  String get presetQuietGlass;

  /// Quiet Glass preset subtitle
  ///
  /// In en, this message translates to:
  /// **'Balanced contrast with cool depth and steady motion.'**
  String get presetQuietGlassSubtitle;

  /// Night Signal preset title
  ///
  /// In en, this message translates to:
  /// **'Night Signal'**
  String get presetNightSignal;

  /// Night Signal preset subtitle
  ///
  /// In en, this message translates to:
  /// **'Tighter density, stronger highlights, and a darker pulse.'**
  String get presetNightSignalSubtitle;

  /// Editorial preset title
  ///
  /// In en, this message translates to:
  /// **'Editorial'**
  String get presetEditorial;

  /// Editorial preset subtitle
  ///
  /// In en, this message translates to:
  /// **'Calmer motion, restrained color, and a more reading-focused tone.'**
  String get presetEditorialSubtitle;

  /// Solar Flare preset title
  ///
  /// In en, this message translates to:
  /// **'Solar Flare'**
  String get presetSolarFlare;

  /// Solar Flare preset subtitle
  ///
  /// In en, this message translates to:
  /// **'Warm highlights and brighter surfaces with energetic movement.'**
  String get presetSolarFlareSubtitle;

  /// Retro Pulse preset title
  ///
  /// In en, this message translates to:
  /// **'Retro Pulse'**
  String get presetRetroPulse;

  /// Retro Pulse preset subtitle
  ///
  /// In en, this message translates to:
  /// **'Compact, playful, and intentionally stylized.'**
  String get presetRetroPulseSubtitle;

  /// Preview rooms tab label
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get previewRoomsLabel;

  /// Preview conversation tab label
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get previewConversationLabel;

  /// Preview settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get previewSettingsLabel;

  /// Room list preview title
  ///
  /// In en, this message translates to:
  /// **'Morning brief'**
  String get previewRoomsTitle;

  /// Room list preview subtitle
  ///
  /// In en, this message translates to:
  /// **'A compact room list with real-sounding snippets and cleaner status markers.'**
  String get previewRoomsSubtitle;

  /// Conversation preview title
  ///
  /// In en, this message translates to:
  /// **'Quick exchange'**
  String get previewConversationTitle;

  /// Conversation preview subtitle
  ///
  /// In en, this message translates to:
  /// **'Check how tone, spacing, and bubble shape read in a short live dialog.'**
  String get previewConversationSubtitle;

  /// Settings preview title
  ///
  /// In en, this message translates to:
  /// **'Controls at hand'**
  String get previewSettingsTitle;

  /// Settings preview subtitle
  ///
  /// In en, this message translates to:
  /// **'Preview how the settings stack feels before applying anything globally.'**
  String get previewSettingsSubtitle;

  /// Live preview label
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get previewLiveLabel;

  /// Preview room design sync title
  ///
  /// In en, this message translates to:
  /// **'Design Sync'**
  String get previewRoomDesignSync;

  /// Preview room design sync subtitle
  ///
  /// In en, this message translates to:
  /// **'Good morning. I left the fresh mockups in the pinned note.'**
  String get previewRoomDesignSyncSubtitle;

  /// Preview room release check title
  ///
  /// In en, this message translates to:
  /// **'Release Check'**
  String get previewRoomReleaseCheck;

  /// Preview room release check subtitle
  ///
  /// In en, this message translates to:
  /// **'Do you know what time the rollout starts? I am lining up the checklist.'**
  String get previewRoomReleaseCheckSubtitle;

  /// Preview room alpha ops title
  ///
  /// In en, this message translates to:
  /// **'Alpha Ops'**
  String get previewRoomAlphaOps;

  /// Preview room alpha ops subtitle
  ///
  /// In en, this message translates to:
  /// **'Tokyo is already awake. The overnight logs look clean.'**
  String get previewRoomAlphaOpsSubtitle;

  /// Preview incoming message
  ///
  /// In en, this message translates to:
  /// **'Good morning. Did the background finally stop feeling like a demo build?'**
  String get previewIncomingMessage;

  /// Preview outgoing message
  ///
  /// In en, this message translates to:
  /// **'Almost. Now it reads like a real chat: calmer spacing, cleaner type, better rhythm.'**
  String get previewOutgoingMessage;

  /// Preview typing status
  ///
  /// In en, this message translates to:
  /// **'Typing, corners, and pacing react here immediately.'**
  String get previewTypingStatus;

  /// Settings preview appearance subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick a template, adjust motion, and keep the whole shell consistent.'**
  String get previewSettingsAppearanceSubtitle;

  /// Preview settings notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Preview how secondary settings cards will stack.'**
  String get previewSettingsNotificationsSubtitle;

  /// Preview settings privacy subtitle
  ///
  /// In en, this message translates to:
  /// **'Check hierarchy, contrast, and icon weight before applying.'**
  String get previewSettingsPrivacySubtitle;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Aegis Violet'**
  String get themeColorAegisViolet;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Indigo Signal'**
  String get themeColorIndigoSignal;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Amethyst'**
  String get themeColorAmethyst;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Rose Pulse'**
  String get themeColorRosePulse;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Solar Amber'**
  String get themeColorSolarAmber;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Pale Violet'**
  String get themeColorPaleViolet;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Signal Coral'**
  String get themeColorSignalCoral;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Mint Relay'**
  String get themeColorMintRelay;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Cyan Air'**
  String get themeColorCyanAir;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Lime Current'**
  String get themeColorLimeCurrent;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Aurora Mint'**
  String get themeColorAuroraMint;

  /// Theme color name
  ///
  /// In en, this message translates to:
  /// **'Slate Mono'**
  String get themeColorSlateMono;

  /// Background motion master toggle label
  ///
  /// In en, this message translates to:
  /// **'Animated background'**
  String get backgroundMotionToggleLabel;

  /// Background motion enabled subtitle
  ///
  /// In en, this message translates to:
  /// **'The atmosphere layer stays alive behind the UI.'**
  String get backgroundMotionOnSubtitle;

  /// Background motion disabled subtitle
  ///
  /// In en, this message translates to:
  /// **'Use a still backdrop for a quieter, flatter surface.'**
  String get backgroundMotionOffSubtitle;

  /// Circle motion mode label
  ///
  /// In en, this message translates to:
  /// **'Orbit'**
  String get motionModeCircles;

  /// Circle motion mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Floating light blobs with soft parallax drift.'**
  String get motionModeCirclesSubtitle;

  /// Wave motion mode label
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get motionModeWaves;

  /// Wave motion mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Layered bottom waves that move more like ambient light.'**
  String get motionModeWavesSubtitle;

  /// Colors tab
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colorsTab;

  /// Fonts tab
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get fontsTab;

  /// Effects tab
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get effectsTab;

  /// Select color theme label
  ///
  /// In en, this message translates to:
  /// **'Select color theme'**
  String get selectColorTheme;

  /// Theme applies everywhere hint
  ///
  /// In en, this message translates to:
  /// **'The selected theme is applied throughout the app'**
  String get themeAppliesEverywhere;

  /// Font settings title
  ///
  /// In en, this message translates to:
  /// **'Font settings'**
  String get fontSettingsTitle;

  /// Select font family label
  ///
  /// In en, this message translates to:
  /// **'Select font family'**
  String get selectFontFamily;

  /// App font label
  ///
  /// In en, this message translates to:
  /// **'App font'**
  String get appFontLabel;

  /// Font weight label
  ///
  /// In en, this message translates to:
  /// **'Font weight'**
  String get fontWeightLabel;

  /// Font preview label
  ///
  /// In en, this message translates to:
  /// **'Preview: Sample text'**
  String get fontPreview;

  /// Compact mode label
  ///
  /// In en, this message translates to:
  /// **'Reduce padding and sizes'**
  String get compactMode;

  /// Enable circles label
  ///
  /// In en, this message translates to:
  /// **'Enable circles'**
  String get enableCircles;

  /// Circles description
  ///
  /// In en, this message translates to:
  /// **'Animated circles in the background'**
  String get circlesDesc;

  /// Floating circles label
  ///
  /// In en, this message translates to:
  /// **'Floating circles'**
  String get floatingCirclesLabel;

  /// React on tilt label
  ///
  /// In en, this message translates to:
  /// **'React to phone tilt'**
  String get reactOnTilt;

  /// Parallax effect label
  ///
  /// In en, this message translates to:
  /// **'Parallax effect'**
  String get parallaxEffect;

  /// Circles speed label
  ///
  /// In en, this message translates to:
  /// **'Movement speed'**
  String get circlesSpeedLabel;

  /// Static motion option
  ///
  /// In en, this message translates to:
  /// **'Static'**
  String get staticMotion;

  /// Brightness label
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightnessLabel;

  /// Dim opacity option
  ///
  /// In en, this message translates to:
  /// **'Dim'**
  String get dimOpacity;

  /// Bright opacity option
  ///
  /// In en, this message translates to:
  /// **'Bright'**
  String get brightOpacity;

  /// Performance label
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performanceLabel;

  /// Current speed prefix
  ///
  /// In en, this message translates to:
  /// **'Current: '**
  String get currentSpeedPrefix;

  /// Speed prefix
  ///
  /// In en, this message translates to:
  /// **'Speed:'**
  String get speedPrefix;

  /// Advanced search title
  ///
  /// In en, this message translates to:
  /// **'Advanced search'**
  String get advancedSearchTitle;

  /// Search query hint
  ///
  /// In en, this message translates to:
  /// **'Enter query...'**
  String get searchQueryHint;

  /// Search type label
  ///
  /// In en, this message translates to:
  /// **'Search type'**
  String get searchTypeLabel;

  /// Search type: all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchTypeAll;

  /// Search type: messages
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get searchTypeMessages;

  /// Search type: media
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get searchTypeMedia;

  /// Search type: users
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get searchTypeUsers;

  /// Period label
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodLabel;

  /// From date label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// To date label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// Search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// Results count
  ///
  /// In en, this message translates to:
  /// **'Results ({count})'**
  String resultsCount(int count);

  /// No results found label
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Forgot password title
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get forgotPasswordTitle;

  /// Forgot password description
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link'**
  String get forgotPasswordDescription;

  /// Send reset button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendResetButton;

  /// Forgot password unavailable
  ///
  /// In en, this message translates to:
  /// **'Password recovery is not available'**
  String get forgotPasswordUnavailable;

  /// Change email screen title
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmailTitle;

  /// Change email description
  ///
  /// In en, this message translates to:
  /// **'Enter a new email address'**
  String get changeEmailDescription;

  /// Current value prefix
  ///
  /// In en, this message translates to:
  /// **'Current: '**
  String get currentPrefix;

  /// New email label
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get newEmailLabel;

  /// Change email button
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmailButton;

  /// Change email error
  ///
  /// In en, this message translates to:
  /// **'Could not change email: {error}'**
  String changeEmailError(String error);

  /// Change phone screen title
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get changePhoneTitle;

  /// Change phone description
  ///
  /// In en, this message translates to:
  /// **'Enter a new phone number and your current password.'**
  String get changePhoneDescription;

  /// New phone label
  ///
  /// In en, this message translates to:
  /// **'New number (+1...)'**
  String get newPhoneLabel;

  /// Current password optional label
  ///
  /// In en, this message translates to:
  /// **'Current password (if required)'**
  String get currentPasswordOptional;

  /// Change phone button
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changePhoneButton;

  /// Phone cannot be changed message
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be changed'**
  String get phoneCannotBeChanged;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotBeChanged;

  /// Change phone error
  ///
  /// In en, this message translates to:
  /// **'Could not change number: {error}'**
  String changePhoneError(String error);

  /// OTP screen title
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get confirmCodeTitle;

  /// Code sent to phone
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}'**
  String codeSentTo(String phone);

  /// Enter code hint
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCodeHint;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// Resend code countdown
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} s'**
  String resendCountdown(int seconds);

  /// Resend code button
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCodeButton;

  /// Biometric setup title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get biometricSetupTitle;

  /// Auth methods label
  ///
  /// In en, this message translates to:
  /// **'Authentication methods'**
  String get authMethodsLabel;

  /// Biometric auth label
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get biometricAuthLabel;

  /// Biometric auth subtitle
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or Face ID'**
  String get biometricAuthSubtitle;

  /// Biometrics enabled label
  ///
  /// In en, this message translates to:
  /// **'Biometrics enabled'**
  String get biometricEnabledLabel;

  /// About security label
  ///
  /// In en, this message translates to:
  /// **'About security'**
  String get aboutSecurityLabel;

  /// About security content
  ///
  /// In en, this message translates to:
  /// **'Choose a convenient authentication method to protect your account.'**
  String get aboutSecurityContent;

  /// Set PIN code label
  ///
  /// In en, this message translates to:
  /// **'Set PIN code'**
  String get setPinCode;

  /// Update available title
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// Update hero title
  ///
  /// In en, this message translates to:
  /// **'Release ready to install'**
  String get updateHeroTitle;

  /// Update hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Review the release, verify its integrity, and move through installation with a clear step-by-step flow.'**
  String get updateHeroSubtitle;

  /// Required update status
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get updateStatusRequired;

  /// Recommended update status
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get updateStatusRecommended;

  /// Update pipeline title
  ///
  /// In en, this message translates to:
  /// **'Update pipeline'**
  String get updatePipelineTitle;

  /// Update pipeline subtitle
  ///
  /// In en, this message translates to:
  /// **'Each stage exposes what is happening now and what comes next.'**
  String get updatePipelineSubtitle;

  /// Download stage title
  ///
  /// In en, this message translates to:
  /// **'Download package'**
  String get updateStageDownloadTitle;

  /// Download stage subtitle
  ///
  /// In en, this message translates to:
  /// **'Fetch the installer package to local storage.'**
  String get updateStageDownloadSubtitle;

  /// Verify stage title
  ///
  /// In en, this message translates to:
  /// **'Verify integrity'**
  String get updateStageVerifyTitle;

  /// Verify stage subtitle
  ///
  /// In en, this message translates to:
  /// **'Check the downloaded file against the published SHA-256 digest.'**
  String get updateStageVerifySubtitle;

  /// Install stage title
  ///
  /// In en, this message translates to:
  /// **'Install release'**
  String get updateStageInstallTitle;

  /// Install stage subtitle
  ///
  /// In en, this message translates to:
  /// **'Request permission if needed and hand the package to the system installer.'**
  String get updateStageInstallSubtitle;

  /// Release summary title
  ///
  /// In en, this message translates to:
  /// **'Release summary'**
  String get releaseSummaryTitle;

  /// Release summary subtitle
  ///
  /// In en, this message translates to:
  /// **'Important changes are grouped to make scanning faster than reading a raw changelog.'**
  String get releaseSummarySubtitle;

  /// Release notes new section
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get releaseSectionNew;

  /// Release notes improved section
  ///
  /// In en, this message translates to:
  /// **'Improved'**
  String get releaseSectionImproved;

  /// Release notes fixed section
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get releaseSectionFixed;

  /// Release notes security section
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get releaseSectionSecurity;

  /// Update trust section title
  ///
  /// In en, this message translates to:
  /// **'Trust and compatibility'**
  String get updateTrustTitle;

  /// Update trust section subtitle
  ///
  /// In en, this message translates to:
  /// **'See where the package comes from, how it is verified, and what build you are about to install.'**
  String get updateTrustSubtitle;

  /// Update trust source label
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get updateTrustSource;

  /// Update trust integrity label
  ///
  /// In en, this message translates to:
  /// **'Integrity'**
  String get updateTrustIntegrity;

  /// Update trust platform label
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get updateTrustPlatform;

  /// Update trust ABI label
  ///
  /// In en, this message translates to:
  /// **'ABI'**
  String get updateTrustAbi;

  /// Update trust verified value
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get updateTrustVerified;

  /// Update trust pending value
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get updateTrustPending;

  /// Update trust failed value
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get updateTrustFailed;

  /// Update trust unavailable value
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get updateTrustUnavailable;

  /// Update trust unknown value
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get updateTrustUnknown;

  /// Debug update preview title
  ///
  /// In en, this message translates to:
  /// **'Preview release card'**
  String get updatePreviewModeTitle;

  /// Debug update preview subtitle
  ///
  /// In en, this message translates to:
  /// **'This entry was opened from the debug catalog, so it shows a styled placeholder instead of real release notes.'**
  String get updatePreviewModeSubtitle;

  /// Debug update preview empty notes text
  ///
  /// In en, this message translates to:
  /// **'Preview notes were not provided for this mock release.'**
  String get updatePreviewModeEmptyNotes;

  /// Current version label
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get updateCurrentVersionLabel;

  /// Incoming version label
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get updateIncomingVersionLabel;

  /// What's new label
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNewLabel;

  /// No update description
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noUpdateDescription;

  /// Download progress
  ///
  /// In en, this message translates to:
  /// **'Downloading... {percent}%'**
  String downloadingProgress(int percent);

  /// Checking integrity
  ///
  /// In en, this message translates to:
  /// **'Checking integrity...'**
  String get checkingIntegrity;

  /// Requesting install
  ///
  /// In en, this message translates to:
  /// **'Requesting installation...'**
  String get requestingInstall;

  /// Update mandatory label
  ///
  /// In en, this message translates to:
  /// **'Update is mandatory'**
  String get updateMandatory;

  /// Later button
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterButton;

  /// Downloading label
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloadingLabel;

  /// Installing label
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get installingLabel;

  /// Update button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// Download failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to download update'**
  String get downloadFailed;

  /// Integrity check failed
  ///
  /// In en, this message translates to:
  /// **'Downloaded file failed integrity check (sha256)'**
  String get integrityCheckFailed;

  /// Install permission dialog title
  ///
  /// In en, this message translates to:
  /// **'Install permission'**
  String get installPermissionTitle;

  /// Install permission dialog content
  ///
  /// In en, this message translates to:
  /// **'To install the update, allow installation from unknown sources.'**
  String get installPermissionContent;

  /// Install permission required
  ///
  /// In en, this message translates to:
  /// **'Install permission is required'**
  String get installPermissionRequired;

  /// Install failed message
  ///
  /// In en, this message translates to:
  /// **'Installation failed'**
  String get installFailed;

  /// SSO feature required message
  ///
  /// In en, this message translates to:
  /// **'This feature requires webview_flutter configuration'**
  String get ssoFeatureRequired;

  /// SSO login via idp
  ///
  /// In en, this message translates to:
  /// **'SSO login via {idpId}'**
  String ssoLoginVia(String idpId);

  /// Forward message dialog title
  ///
  /// In en, this message translates to:
  /// **'Forward message'**
  String get forwardMessageTitle;

  /// Search chat hint
  ///
  /// In en, this message translates to:
  /// **'Search chat...'**
  String get searchChatHint;

  /// Forward button with count
  ///
  /// In en, this message translates to:
  /// **'Forward ({count})'**
  String forwardButton(int count);

  /// Room avatar updated notification
  ///
  /// In en, this message translates to:
  /// **'Room avatar updated'**
  String get roomAvatarUpdated;

  /// Room avatar upload error
  ///
  /// In en, this message translates to:
  /// **'Error uploading avatar: {error}'**
  String roomAvatarUploadError(String error);

  /// Room settings saved notification
  ///
  /// In en, this message translates to:
  /// **'Room settings saved'**
  String get roomSettingsSaved;

  /// Room settings save error
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String roomSettingsSaveError(String error);

  /// Upload avatar button
  ///
  /// In en, this message translates to:
  /// **'Upload avatar'**
  String get uploadAvatarButton;

  /// Load members error
  ///
  /// In en, this message translates to:
  /// **'Error loading members: {error}'**
  String loadMembersError(String error);

  /// Leave room dialog title
  ///
  /// In en, this message translates to:
  /// **'Leave room?'**
  String get leaveRoomTitle;

  /// Leave room dialog content
  ///
  /// In en, this message translates to:
  /// **'You won\'t be able to return to this room unless re-invited.'**
  String get leaveRoomContent;

  /// Leave action
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveAction;

  /// Left room notification
  ///
  /// In en, this message translates to:
  /// **'You left the room'**
  String get leftRoom;

  /// Leave room error
  ///
  /// In en, this message translates to:
  /// **'Error leaving room: {error}'**
  String leaveRoomError(String error);

  /// Report not implemented notice
  ///
  /// In en, this message translates to:
  /// **'Report feature not yet implemented'**
  String get reportNotImplemented;

  /// Badge label for features that are not ready yet
  ///
  /// In en, this message translates to:
  /// **'In development'**
  String get featureInDevelopmentLabel;

  /// Explanation for a settings feature that is still in development
  ///
  /// In en, this message translates to:
  /// **'{feature} is in development and will appear here in a future update.'**
  String featureInDevelopmentMessage(String feature);

  /// Invite action
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get inviteAction;

  /// Threads label
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get threadsLabel;

  /// Pinned messages label
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinnedLabel;

  /// Files label
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filesLabel;

  /// Empty state for shared files section
  ///
  /// In en, this message translates to:
  /// **'No shared files yet'**
  String get noSharedFiles;

  /// Media label
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get mediaLabel;

  /// Empty state for shared media section
  ///
  /// In en, this message translates to:
  /// **'No shared media yet'**
  String get noSharedMedia;

  /// Extensions label
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get extensionsLabel;

  /// Copy link action
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLinkAction;

  /// Polls label
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get pollsLabel;

  /// Export chat action
  ///
  /// In en, this message translates to:
  /// **'Export chat'**
  String get exportChatAction;

  /// Report action
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportAction;

  /// Leave room action
  ///
  /// In en, this message translates to:
  /// **'Leave room'**
  String get leaveRoomAction;

  /// Room title in app bar
  ///
  /// In en, this message translates to:
  /// **'Room — {name}'**
  String roomTitle(String name);

  /// Room settings label
  ///
  /// In en, this message translates to:
  /// **'Room settings'**
  String get roomSettingsLabel;

  /// Authentication error
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {error}'**
  String authError(String error);

  /// Login required dialog title
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// Login required dialog content
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to search contacts. Go to login?'**
  String get loginRequiredContent;

  /// Login action button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginAction;

  /// Search error
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String searchError(String error);

  /// Search contacts screen title
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get searchContactsTitle;

  /// Nickname or phone hint
  ///
  /// In en, this message translates to:
  /// **'Nickname or phone number'**
  String get nicknameOrPhoneHint;

  /// Select contact error
  ///
  /// In en, this message translates to:
  /// **'Could not select contact: {error}'**
  String selectContactError(String error);

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Feedback category: features
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get feedbackCategoryFeatures;

  /// Feedback category: performance
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get feedbackCategoryPerformance;

  /// Feedback category: security/privacy
  ///
  /// In en, this message translates to:
  /// **'Security/Privacy'**
  String get feedbackCategorySecurity;

  /// Feedback category: sync/network
  ///
  /// In en, this message translates to:
  /// **'Sync/Network'**
  String get feedbackCategoryNetworkSync;

  /// Short description label
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get shortDescriptionLabel;

  /// Short description hint
  ///
  /// In en, this message translates to:
  /// **'E.g. \"Chat backup to cloud\"'**
  String get shortDescriptionHint;

  /// Feedback form validation
  ///
  /// In en, this message translates to:
  /// **'Select at least one idea or write a description'**
  String get feedbackValidation;

  /// Details optional label
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get detailsOptionalLabel;

  /// Details hint
  ///
  /// In en, this message translates to:
  /// **'What should work, how it works now and how you\'d like it?'**
  String get detailsHint;

  /// Big features section title
  ///
  /// In en, this message translates to:
  /// **'Major features (select what interests you most)'**
  String get bigFeaturesTitle;

  /// Feedback suggestion: E2E encryption
  ///
  /// In en, this message translates to:
  /// **'End-to-end E2E encryption (Olm/Megolm) + device verification'**
  String get feedbackE2E;

  /// Feedback suggestion: backup
  ///
  /// In en, this message translates to:
  /// **'Chat backup (local/cloud) + transfer to new device'**
  String get feedbackBackup;

  /// Feedback suggestion: threads
  ///
  /// In en, this message translates to:
  /// **'Threads, reactions, mentions, improved message search'**
  String get feedbackThreads;

  /// Feedback suggestion: calls
  ///
  /// In en, this message translates to:
  /// **'Voice/video calls and quick voice rooms'**
  String get feedbackCalls;

  /// Feedback suggestion: folders
  ///
  /// In en, this message translates to:
  /// **'Chat folders/categories and smart notification filters'**
  String get feedbackFolders;

  /// Feedback suggestion: bots
  ///
  /// In en, this message translates to:
  /// **'Bots and integrations (webhooks, GitHub/Jira, reminders)'**
  String get feedbackBots;

  /// Feedback suggestion: slow net mode
  ///
  /// In en, this message translates to:
  /// **'\"Slow internet\" mode + aggressive media caching'**
  String get feedbackSlowNet;

  /// Start chat bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get startChatTitle;

  /// Create room subtitle
  ///
  /// In en, this message translates to:
  /// **'Private or public group'**
  String get createRoomSubtitle;

  /// Invite user option title
  ///
  /// In en, this message translates to:
  /// **'Invite user'**
  String get inviteUserTitle;

  /// Invite user option subtitle
  ///
  /// In en, this message translates to:
  /// **'Find and message a user'**
  String get inviteUserSubtitle;

  /// Join by code option title
  ///
  /// In en, this message translates to:
  /// **'Join by code'**
  String get joinByCodeTitle;

  /// Join by code option subtitle
  ///
  /// In en, this message translates to:
  /// **'Join a room using an invite code'**
  String get joinByCodeSubtitle;

  /// Subtitle for chats home screen
  ///
  /// In en, this message translates to:
  /// **'Private messages, groups and invite links in one place'**
  String get chatsSubtitle;

  /// Quick actions section title on chats screen
  ///
  /// In en, this message translates to:
  /// **'Start something new'**
  String get chatsQuickStartTitle;

  /// Recent chats section title
  ///
  /// In en, this message translates to:
  /// **'Recent chats'**
  String get chatsRecentTitle;

  /// Hint for joining a room via invite link or alias
  ///
  /// In en, this message translates to:
  /// **'Paste an invite link, alias or code'**
  String get joinLinkHint;

  /// Font label
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get fontLabel;

  /// PIN related string
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pinCodeLabel;

  /// PIN related string
  ///
  /// In en, this message translates to:
  /// **'4-6 digits for protection'**
  String get pinCodeSubtitle;

  /// PIN related string
  ///
  /// In en, this message translates to:
  /// **'PIN (4-6 digits)'**
  String get pinHint;

  /// PIN related string
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4-6 digits'**
  String get pinLengthError;

  /// PIN related string
  ///
  /// In en, this message translates to:
  /// **'PIN set'**
  String get pinSetSuccess;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Generic delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Generic close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Generic send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// Generic copy button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// Generic share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// Generic settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// Feedback category: UX/Design
  ///
  /// In en, this message translates to:
  /// **'UX/Design'**
  String get feedbackCategoryUxDesign;

  /// Subject line for sharing feedback
  ///
  /// In en, this message translates to:
  /// **'TwoSpace — suggestion'**
  String get feedbackShareSubject;

  /// Header line of feedback message
  ///
  /// In en, this message translates to:
  /// **'TwoSpace — suggestion/improvement'**
  String get feedbackMessageHeader;

  /// Version line of feedback message
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String feedbackVersion(String version);

  /// Category line of feedback message
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String feedbackCategoryLine(String category);

  /// Short title line of feedback message
  ///
  /// In en, this message translates to:
  /// **'Brief: {title}'**
  String feedbackShortTitle(String title);

  /// Wish list header in feedback message
  ///
  /// In en, this message translates to:
  /// **'What would be especially great:'**
  String get feedbackWishList;

  /// Details header in feedback message
  ///
  /// In en, this message translates to:
  /// **'Details:'**
  String get feedbackDetailsLine;

  /// Subtitle when floating circles are enabled
  ///
  /// In en, this message translates to:
  /// **'Circles displayed'**
  String get circlesVisible;

  /// Subtitle when floating circles are disabled
  ///
  /// In en, this message translates to:
  /// **'Circles hidden'**
  String get circlesHidden;

  /// Slow speed label
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  /// Fast speed label
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  /// Advanced settings section label
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get advancedSettingsLabel;

  /// Compact mode toggle title
  ///
  /// In en, this message translates to:
  /// **'Compact mode'**
  String get compactModeLabel;

  /// Current device info placeholder
  ///
  /// In en, this message translates to:
  /// **'Android • Active'**
  String get activeDeviceInfo;

  /// Stub placeholder text
  ///
  /// In en, this message translates to:
  /// **'Stub — {key}'**
  String stubPlaceholder(String key);

  /// Error loading messages
  ///
  /// In en, this message translates to:
  /// **'Error loading messages: {error}'**
  String loadMessagesError(String error);

  /// Pins updated snackbar
  ///
  /// In en, this message translates to:
  /// **'Pins updated'**
  String get pinnedUpdated;

  /// Edit message error
  ///
  /// In en, this message translates to:
  /// **'Edit error: {error}'**
  String editError(String error);

  /// More reactions button
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreButton;

  /// Share error message
  ///
  /// In en, this message translates to:
  /// **'Could not share: {error}'**
  String shareError(String error);

  /// Send failed error
  ///
  /// In en, this message translates to:
  /// **'Send failed: {error}'**
  String sendError(String error);

  /// Voice recording unsupported message
  ///
  /// In en, this message translates to:
  /// **'Voice recording is not supported on this platform'**
  String get voiceRecordingUnsupported;

  /// Microphone permission required message
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required'**
  String get microphonePermissionRequired;

  /// Generic error with detail
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(String error);

  /// ownersLabel
  ///
  /// In en, this message translates to:
  /// **'👑 Owners'**
  String get ownersLabel;

  /// administratorsLabel
  ///
  /// In en, this message translates to:
  /// **'⚡ Administrators'**
  String get administratorsLabel;

  /// oneHour
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get oneHour;

  /// oneDay
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get oneDay;

  /// sevenDays
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get sevenDays;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeSelection;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationNew;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get settingsDoNotDisturb;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Sound Settings'**
  String get settingsSoundOptions;

  /// Custom notification sound title
  ///
  /// In en, this message translates to:
  /// **'Notification sound'**
  String get notificationToneTitle;

  /// Custom notification sound subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose a local audio file for message and alert previews.'**
  String get notificationToneSubtitle;

  /// Custom ringtone title
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get ringtoneTitle;

  /// Custom ringtone subtitle
  ///
  /// In en, this message translates to:
  /// **'Use a separate local audio file for incoming call previews.'**
  String get ringtoneSubtitle;

  /// Choose sound file button label
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseSoundLabel;

  /// Play preview button label
  ///
  /// In en, this message translates to:
  /// **'Play preview'**
  String get playPreviewLabel;

  /// Stop preview button label
  ///
  /// In en, this message translates to:
  /// **'Stop preview'**
  String get stopPreviewLabel;

  /// No custom sound selected label
  ///
  /// In en, this message translates to:
  /// **'No custom file selected yet.'**
  String get customSoundNotSelected;

  /// Clear custom sound button label
  ///
  /// In en, this message translates to:
  /// **'Reset custom file'**
  String get clearCustomSoundLabel;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Storage Management'**
  String get settingsStorageManagement;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get settingsStorageUsage;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'App Size'**
  String get settingsStorageAppSize;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Clear Selected'**
  String get settingsStorageClearBtn;

  /// Storage screen title
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get storageMemoryTitle;

  /// Storage chart center label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get storageTotalLabel;

  /// Selected storage amount label
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get storageSelectedLabel;

  /// Photos section in storage
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get storagePhotosLabel;

  /// Videos section in storage
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get storageVideosLabel;

  /// Cache section in storage
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get storageCacheLabel;

  /// App data section in storage
  ///
  /// In en, this message translates to:
  /// **'App data'**
  String get storageAppDataLabel;

  /// Selected cleanup total title
  ///
  /// In en, this message translates to:
  /// **'Selected to clear'**
  String get storageCleanupTitle;

  /// Storage cleanup subtitle
  ///
  /// In en, this message translates to:
  /// **'Review what can be safely removed.'**
  String get storageCleanupSubtitle;

  /// Storage auto clean section title
  ///
  /// In en, this message translates to:
  /// **'Auto-clean'**
  String get storageAutoCleanTitle;

  /// Storage auto clean subtitle
  ///
  /// In en, this message translates to:
  /// **'Run cleanup automatically on a schedule or when storage grows beyond the selected limit.'**
  String get storageAutoCleanSubtitle;

  /// Storage auto clean period label
  ///
  /// In en, this message translates to:
  /// **'Cleanup period'**
  String get storageAutoCleanPeriodLabel;

  /// Storage auto clean daily period
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get storageAutoCleanPeriodDaily;

  /// Storage auto clean weekly period
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get storageAutoCleanPeriodWeekly;

  /// Storage auto clean monthly period
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get storageAutoCleanPeriodMonthly;

  /// Storage auto clean threshold label
  ///
  /// In en, this message translates to:
  /// **'Run instantly above'**
  String get storageAutoCleanThresholdLabel;

  /// Storage auto clean types label
  ///
  /// In en, this message translates to:
  /// **'Clear data types'**
  String get storageAutoCleanTypesLabel;

  /// Storage auto clean status card title
  ///
  /// In en, this message translates to:
  /// **'Automation status'**
  String get storageAutoCleanStatusTitle;

  /// Storage auto clean enabled status
  ///
  /// In en, this message translates to:
  /// **'Auto-clean is active and will run when the schedule arrives or the storage threshold is exceeded.'**
  String get storageAutoCleanStatusEnabled;

  /// Storage auto clean disabled status
  ///
  /// In en, this message translates to:
  /// **'Auto-clean is off. Only manual cleanup will run until you enable it again.'**
  String get storageAutoCleanStatusDisabled;

  /// Storage auto clean last run label
  ///
  /// In en, this message translates to:
  /// **'Last run'**
  String get storageAutoCleanLastRunLabel;

  /// Storage auto clean never run label
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get storageAutoCleanLastRunNever;

  /// Storage auto clean select all
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get storageAutoCleanSelectAll;

  /// Storage auto clean select none
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get storageAutoCleanSelectNone;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Keep Chat Data'**
  String get settingsStorageKeepChat;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Keep Channel Data'**
  String get settingsStorageKeepChannel;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Keep Group Data'**
  String get settingsStorageKeepGroup;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Propose Improvement'**
  String get settingsAboutPropose;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get settingsAboutCheckUpdate;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'App Lock (Biometrics/PIN)'**
  String get biometricsEnable;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Setup App Lock'**
  String get biometricsSetup;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Uses TwoSpace'**
  String get contactsTwoSpaceYes;

  /// Auto added setting
  ///
  /// In en, this message translates to:
  /// **'Not in TwoSpace'**
  String get contactsTwoSpaceNo;

  /// Unified people tab title
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleTitle;

  /// People tab subtitle
  ///
  /// In en, this message translates to:
  /// **'Contacts, favorites, search and invites in one place'**
  String get peopleSubtitle;

  /// Quick action to start a new chat
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get peopleQuickNewChat;

  /// Quick action to invite friends
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get peopleQuickInvite;

  /// Quick action to refresh people data
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get peopleQuickSync;

  /// Hint for the people search field
  ///
  /// In en, this message translates to:
  /// **'Search by name, nickname or phone'**
  String get peopleSearchHint;

  /// All people segment
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get peopleSegmentAll;

  /// TwoSpace users segment
  ///
  /// In en, this message translates to:
  /// **'TwoSpace'**
  String get peopleSegmentTwoSpace;

  /// Phonebook segment
  ///
  /// In en, this message translates to:
  /// **'Phonebook'**
  String get peopleSegmentPhonebook;

  /// Recent people segment
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get peopleSegmentRecent;

  /// Loading label for people screen
  ///
  /// In en, this message translates to:
  /// **'Loading people…'**
  String get peopleLoading;

  /// Empty title for people screen
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get peopleNoPeopleTitle;

  /// Empty message for people screen
  ///
  /// In en, this message translates to:
  /// **'Your favorites, recent conversations and contacts will appear here.'**
  String get peopleNoPeopleMessage;

  /// Title for people permission card
  ///
  /// In en, this message translates to:
  /// **'Phonebook access is limited'**
  String get peoplePermissionCardTitle;

  /// Message for contacts permission request
  ///
  /// In en, this message translates to:
  /// **'Allow contacts access to show your phonebook and invite people faster.'**
  String get peoplePermissionCardMessage;

  /// Message for permanently denied contacts permission
  ///
  /// In en, this message translates to:
  /// **'Enable contacts access in system settings to restore your phonebook section.'**
  String get peoplePermissionCardMessageSettings;

  /// Section title for favorite and frequent people
  ///
  /// In en, this message translates to:
  /// **'Favorites & frequent'**
  String get peopleFavoritesFrequentTitle;

  /// Section title for recent people
  ///
  /// In en, this message translates to:
  /// **'Recent people'**
  String get peopleRecentTitle;

  /// Section title for TwoSpace users
  ///
  /// In en, this message translates to:
  /// **'TwoSpace people'**
  String get peopleTwoSpaceTitle;

  /// Section title for invite candidates
  ///
  /// In en, this message translates to:
  /// **'Invite to TwoSpace'**
  String get peopleInviteTitle;

  /// Subtitle for invite-only contacts
  ///
  /// In en, this message translates to:
  /// **'Invite this contact to TwoSpace'**
  String get peopleInviteSubtitle;

  /// Loading label while searching people
  ///
  /// In en, this message translates to:
  /// **'Searching people…'**
  String get peopleSearching;

  /// Search results section for remote users
  ///
  /// In en, this message translates to:
  /// **'TwoSpace results'**
  String get peopleSearchRemoteTitle;

  /// Search results section for local people
  ///
  /// In en, this message translates to:
  /// **'Recent and saved'**
  String get peopleSearchLocalTitle;

  /// Search results section for invite candidates
  ///
  /// In en, this message translates to:
  /// **'Invite from phonebook'**
  String get peopleSearchInviteTitle;

  /// Empty title for people search
  ///
  /// In en, this message translates to:
  /// **'No matching people'**
  String get peopleSearchEmptyTitle;

  /// Empty message for people search
  ///
  /// In en, this message translates to:
  /// **'Try another name, nickname or phone number.'**
  String get peopleSearchEmptyMessage;

  /// Badge for TwoSpace users
  ///
  /// In en, this message translates to:
  /// **'TwoSpace'**
  String get peopleTwoSpaceBadge;

  /// Fallback subtitle for a person
  ///
  /// In en, this message translates to:
  /// **'No extra details yet'**
  String get peopleNoDetails;

  /// Generic invite share text
  ///
  /// In en, this message translates to:
  /// **'Join me on TwoSpace — a secure messenger for chats and calls.'**
  String get peopleInviteShareText;

  /// Specific invite share text
  ///
  /// In en, this message translates to:
  /// **'Join me on TwoSpace, {personName} — let’s chat and call securely.'**
  String peopleInviteSpecificShareText(String personName);

  /// Action to open a person's profile
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get peopleViewProfileAction;

  /// Action to remove favorite person
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get peopleRemoveFavoriteAction;

  /// Action to add favorite person
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get peopleAddFavoriteAction;

  /// Calls screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Recent calls, quick redial and people-first history'**
  String get callsSubtitle;

  /// Action to start a call
  ///
  /// In en, this message translates to:
  /// **'Start call'**
  String get callsStartCallAction;

  /// Quick start card title on calls screen
  ///
  /// In en, this message translates to:
  /// **'Call someone now'**
  String get callsQuickStartTitle;

  /// Quick start card subtitle on calls screen
  ///
  /// In en, this message translates to:
  /// **'Open People, search for someone and start a secure voice or video call.'**
  String get callsQuickStartSubtitle;

  /// Hint for calls search field
  ///
  /// In en, this message translates to:
  /// **'Search call history'**
  String get callsSearchHint;

  /// Filter label for video calls
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get callsVideoFilter;

  /// Section title for top call contacts
  ///
  /// In en, this message translates to:
  /// **'Top contacts'**
  String get callsTopContactsTitle;

  /// Loading label for calls screen
  ///
  /// In en, this message translates to:
  /// **'Loading calls…'**
  String get callsLoadingLabel;

  /// Empty title for calls screen
  ///
  /// In en, this message translates to:
  /// **'No calls yet'**
  String get callsEmptyTitle;

  /// Empty message for calls screen
  ///
  /// In en, this message translates to:
  /// **'Your call history will appear here after your first voice or video call.'**
  String get callsEmptyMessage;

  /// Empty message for filtered call history
  ///
  /// In en, this message translates to:
  /// **'No calls match the current search or filter.'**
  String get callsEmptySearchMessage;

  /// Section title for today's calls
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get callsTodaySection;

  /// Section title for current week calls
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get callsThisWeekSection;

  /// Section title for older calls
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get callsEarlierSection;

  /// Summary count for grouped calls
  ///
  /// In en, this message translates to:
  /// **'{count} calls'**
  String callsThreadCount(int count);

  /// Summary for missed calls in a thread
  ///
  /// In en, this message translates to:
  /// **'{count} missed'**
  String callsMissedSummary(int count);

  /// Call action label to mute microphone
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get callsMuteAction;

  /// Call action label to toggle speaker
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get callsSpeakerAction;

  /// Call action label to toggle camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get callsCameraAction;

  /// Call action label to switch camera
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get callsSwitchCameraAction;

  /// Call action label to end a call
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get callsEndAction;

  /// Status while connecting a call
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get callsConnectingLabel;

  /// Status while ringing a call
  ///
  /// In en, this message translates to:
  /// **'Ringing…'**
  String get callsRingingLabel;

  /// Detailed call connection status
  ///
  /// In en, this message translates to:
  /// **'Creating a secure call session.'**
  String get callsConnectingDetail;

  /// Detailed ringing status
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other person to answer.'**
  String get callsRingingDetail;

  /// Detailed secure video call description
  ///
  /// In en, this message translates to:
  /// **'Video is protected and routed through the current secure session.'**
  String get callsVideoSecureDetail;

  /// Detailed secure voice call description
  ///
  /// In en, this message translates to:
  /// **'Voice is protected and routed through the current secure session.'**
  String get callsVoiceSecureDetail;

  /// No description provided for @timestampPrecisionLabel.
  ///
  /// In en, this message translates to:
  /// **'Message time precision'**
  String get timestampPrecisionLabel;

  /// No description provided for @timestampPrecisionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how detailed timestamps look in chats and chat list.'**
  String get timestampPrecisionSubtitle;

  /// No description provided for @timestampPrecisionMinutes.
  ///
  /// In en, this message translates to:
  /// **'Hours and minutes'**
  String get timestampPrecisionMinutes;

  /// No description provided for @timestampPrecisionSeconds.
  ///
  /// In en, this message translates to:
  /// **'Hours, minutes and seconds'**
  String get timestampPrecisionSeconds;

  /// No description provided for @timestampPrecisionMilliseconds.
  ///
  /// In en, this message translates to:
  /// **'Hours, minutes, seconds and milliseconds'**
  String get timestampPrecisionMilliseconds;

  /// No description provided for @startupTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing TwoSpace'**
  String get startupTitle;

  /// No description provided for @startupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checking the secure session and opening your chats.'**
  String get startupSubtitle;

  /// No description provided for @startupFooter.
  ///
  /// In en, this message translates to:
  /// **'This screen is only shown during app startup.'**
  String get startupFooter;

  /// No description provided for @startupStepEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Loading configuration'**
  String get startupStepEnvironment;

  /// No description provided for @startupStepDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Starting diagnostics'**
  String get startupStepDiagnostics;

  /// No description provided for @startupStepValidation.
  ///
  /// In en, this message translates to:
  /// **'Validating environment'**
  String get startupStepValidation;

  /// No description provided for @startupStepSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading settings'**
  String get startupStepSettings;

  /// No description provided for @startupStepSession.
  ///
  /// In en, this message translates to:
  /// **'Restoring secure session'**
  String get startupStepSession;

  /// No description provided for @startupStepLaunch.
  ///
  /// In en, this message translates to:
  /// **'Starting app'**
  String get startupStepLaunch;

  /// No description provided for @callsDemoBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo, not a working call'**
  String get callsDemoBannerTitle;

  /// No description provided for @callsDemoBannerVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice calls are shown as a visual prototype only. Audio transport is not connected yet.'**
  String get callsDemoBannerVoiceMessage;

  /// No description provided for @callsDemoBannerVideoMessage.
  ///
  /// In en, this message translates to:
  /// **'Video calls are shown as a visual prototype only. The remote stream is unavailable, but your local camera preview works.'**
  String get callsDemoBannerVideoMessage;

  /// No description provided for @callsCameraPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to show your local preview during a video call.'**
  String get callsCameraPermissionMessage;

  /// No description provided for @callsCameraPermissionSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera access is blocked. Open system settings to enable the local video preview.'**
  String get callsCameraPermissionSettingsMessage;

  /// No description provided for @callsCameraPermissionAction.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get callsCameraPermissionAction;

  /// No description provided for @callsCameraUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get callsCameraUnavailableTitle;

  /// No description provided for @callsCameraUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The local camera preview could not be started on this device.'**
  String get callsCameraUnavailableMessage;

  /// No description provided for @callsCameraUnsupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'This platform does not support the local video preview.'**
  String get callsCameraUnsupportedMessage;

  /// No description provided for @callsCameraOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera preview is turned off for this demo call.'**
  String get callsCameraOffMessage;

  /// No description provided for @callsFrontCameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Front camera'**
  String get callsFrontCameraLabel;

  /// No description provided for @callsRearCameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Rear camera'**
  String get callsRearCameraLabel;

  /// Title for a notice shown when animated background effects were automatically disabled to reduce jank
  ///
  /// In en, this message translates to:
  /// **'Background effects were simplified'**
  String get backgroundOptimizationDisabledTitle;

  /// Body text for a notice shown when animated background effects were automatically disabled
  ///
  /// In en, this message translates to:
  /// **'TwoSpace detected sustained slow frames and turned off heavy background effects to keep scrolling and chat interactions smooth.'**
  String get backgroundOptimizationDisabledMessage;

  /// Action label that opens appearance settings after background effects were automatically disabled
  ///
  /// In en, this message translates to:
  /// **'Open appearance settings'**
  String get backgroundOptimizationOpenSettings;

  /// No description provided for @roomJoinRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Who can join'**
  String get roomJoinRuleLabel;

  /// No description provided for @roomJoinRulePublic.
  ///
  /// In en, this message translates to:
  /// **'Open to everyone'**
  String get roomJoinRulePublic;

  /// No description provided for @roomJoinRulePublicDescription.
  ///
  /// In en, this message translates to:
  /// **'Anyone can discover and join this room.'**
  String get roomJoinRulePublicDescription;

  /// No description provided for @roomJoinRuleInviteOnly.
  ///
  /// In en, this message translates to:
  /// **'Invite only'**
  String get roomJoinRuleInviteOnly;

  /// No description provided for @roomJoinRuleInviteOnlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Only invited users can join this room.'**
  String get roomJoinRuleInviteOnlyDescription;

  /// No description provided for @roomJoinRuleApproval.
  ///
  /// In en, this message translates to:
  /// **'Approval required'**
  String get roomJoinRuleApproval;

  /// No description provided for @roomJoinRuleApprovalDescription.
  ///
  /// In en, this message translates to:
  /// **'Users can request access and must be approved before joining.'**
  String get roomJoinRuleApprovalDescription;

  /// No description provided for @roomHistoryVisibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Who can see history'**
  String get roomHistoryVisibilityLabel;

  /// No description provided for @roomHistoryVisibilityWorldReadable.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get roomHistoryVisibilityWorldReadable;

  /// No description provided for @roomHistoryVisibilityWorldReadableDescription.
  ///
  /// In en, this message translates to:
  /// **'Anyone can view earlier messages.'**
  String get roomHistoryVisibilityWorldReadableDescription;

  /// No description provided for @roomHistoryVisibilityJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined members'**
  String get roomHistoryVisibilityJoined;

  /// No description provided for @roomHistoryVisibilityJoinedDescription.
  ///
  /// In en, this message translates to:
  /// **'Only joined members can view earlier messages.'**
  String get roomHistoryVisibilityJoinedDescription;

  /// No description provided for @roomHistoryVisibilityInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited users only'**
  String get roomHistoryVisibilityInvited;

  /// No description provided for @roomHistoryVisibilityInvitedDescription.
  ///
  /// In en, this message translates to:
  /// **'Only invited users can view earlier messages.'**
  String get roomHistoryVisibilityInvitedDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pl',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
