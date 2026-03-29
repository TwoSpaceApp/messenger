// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => '読み込み中...';

  @override
  String get initializing => '初期化中...';

  @override
  String get errorGeneric => 'エラーが発生しました';

  @override
  String get errorInitialization => '初期化エラー';

  @override
  String get errorInitializationFull => '初期化エラー。アプリを再起動してください。';

  @override
  String get errorNetwork => 'ネットワークエラー。接続を確認してください。';

  @override
  String get errorAuth => '認証エラー。';

  @override
  String get errorInvalidArguments => '引数が無効です。';

  @override
  String get errorInvalidArgumentsProfile => 'プロフィールの引数が無効です。';

  @override
  String get errorInvalidArgumentsChat => 'チャットの引数が無効です。';

  @override
  String get retry => '再試行';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get send => '送信';

  @override
  String get close => '閉じる';

  @override
  String errorWithDetail(String error) {
    return 'エラー: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get confirm => '確認';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get done => '完了';

  @override
  String get noData => 'データなし';

  @override
  String get nothingFound => '見つかりません';

  @override
  String get copyAction => 'コピー';

  @override
  String get shareAction => '共有';

  @override
  String get textCopied => 'テキストをコピーしました';

  @override
  String get onlineLabel => 'オンライン';

  @override
  String get offlineLabel => 'オフライン';

  @override
  String get userDefault => 'ユーザー';

  @override
  String get lessThanMinuteAgo => '1分未満前';

  @override
  String minutesAgo(int count) {
    return '$count分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String daysAgo(int count) {
    return '$count日前';
  }

  @override
  String get videoLabel => '動画';

  @override
  String videoLoadError(String error) {
    return '動画エラー: $error';
  }

  @override
  String get saveFailed => '保存に失敗しました';

  @override
  String get shareSheetFailed => '共有を開けませんでした';

  @override
  String get speedLabel => '速度:';

  @override
  String get previewTitle => 'プレビュー';

  @override
  String fileDownloaded(String path) {
    return 'ファイルをダウンロードしました: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return 'ファイルを一時保存しました: $path';
  }

  @override
  String get savedToGallery => 'ギャラリーに保存しました';

  @override
  String authorizationError(String message) {
    return '認証エラー: $message';
  }

  @override
  String get loginTitle => 'ログイン';

  @override
  String get welcomeBack => 'ようこそ';

  @override
  String get emailOrUsernameLabel => 'ユーザー名';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get loginButton => 'ログイン';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get noAccount => 'アカウントをお持ちでないですか？';

  @override
  String get orDivider => 'または';

  @override
  String get validationEnterEmailOrUsername => 'ユーザー名を入力してください';

  @override
  String get validationEnterPassword => 'パスワードを入力してください';

  @override
  String get registerTitle => '登録';

  @override
  String get fillAllFields => 'すべてのフィールドを入力してください';

  @override
  String get passwordStrengthWeak => '弱い';

  @override
  String get passwordStrengthMedium => '普通';

  @override
  String get passwordStrengthGood => '良い';

  @override
  String get passwordStrengthStrong => '強い';

  @override
  String get fullNameLabel => 'フルネーム';

  @override
  String get nicknameAtLabel => 'ニックネーム (@ユーザー名)';

  @override
  String get uploadPhotoPrompt => 'プロフィール写真をアップロード';

  @override
  String get photoLooksGreat => '素晴らしい！';

  @override
  String get helpFriendsFind => '友達があなたを見つけやすくしましょう';

  @override
  String get setupInterfaceTitle => 'インターフェースをカスタマイズ';

  @override
  String get colorThemeLabel => 'カラーテーマ';

  @override
  String get validationEnterEmail => 'メールを入力してください';

  @override
  String get validationInvalidEmail => 'メールアドレスが無効です';

  @override
  String get validationPasswordTooShort => 'パスワードが短すぎます';

  @override
  String get backToLogin => 'ログイン';

  @override
  String get finishButton => '完了';

  @override
  String filePickError(String error) {
    return 'ファイル選択エラー: $error';
  }

  @override
  String get chatsTitle => 'チャット';

  @override
  String get noChats => 'チャットなし';

  @override
  String get noMessages => '（メッセージなし）';

  @override
  String get newChat => '新しいチャット';

  @override
  String get messageInputHint => 'メッセージを入力...';

  @override
  String get addCaptionHint => 'キャプションまたはメッセージを追加';

  @override
  String get unlockApp => 'ロック解除';

  @override
  String get unlockButton => 'ロック解除';

  @override
  String get dropFilesTitle => 'ファイルをドロップして添付';

  @override
  String get dropFilesSubtitle => 'メッセージ入力欄の上に表示されます。';

  @override
  String get videoUnavailable => '動画を利用できません';

  @override
  String get guestRole => 'ゲスト';

  @override
  String get replyAction => '返信';

  @override
  String get editShort => '編集';

  @override
  String get pinAction => 'ピン留め';

  @override
  String get moreReactions => 'もっと';

  @override
  String get replyDialogTitle => '返信';

  @override
  String get replyHint => '返信テキスト';

  @override
  String get editMessageTitle => 'メッセージを編集';

  @override
  String get editMessageHint => '新しいテキスト';

  @override
  String get deleteMessageTitle => 'メッセージを削除しますか？';

  @override
  String get pinsUpdated => 'ピンを更新しました';

  @override
  String get messageEdited => 'メッセージを編集しました';

  @override
  String get fileSent => 'ファイルを送信しました';

  @override
  String get voiceNotSupported => 'このプラットフォームでは音声録音がサポートされていません';

  @override
  String get microphonePermRequired => 'マイクの許可が必要です';

  @override
  String get recordingError => '録音エラー';

  @override
  String sendFailedError(String error) {
    return '送信に失敗しました: $error';
  }

  @override
  String attachmentSendError(String error) {
    return '添付ファイルエラー: $error';
  }

  @override
  String shareFailedError(String error) {
    return '共有に失敗しました: $error';
  }

  @override
  String replyError(String error) {
    return '返信エラー: $error';
  }

  @override
  String pinError(String error) {
    return 'ピンエラー: $error';
  }

  @override
  String deleteError(String error) {
    return '削除エラー: $error';
  }

  @override
  String editMessageError(String error) {
    return '編集エラー: $error';
  }

  @override
  String get userTyping => 'ユーザーが入力中...';

  @override
  String get statusOnline => 'オンライン';

  @override
  String get statusLastSeenRecently => '最近オンライン';

  @override
  String get settingsTitle => '設定';

  @override
  String get appearanceSection => '外観';

  @override
  String get themeLabel => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get customizationLabel => 'カスタマイズ';

  @override
  String get customizationSubtitle => '色、フォント、UIエフェクト';

  @override
  String get notificationsSection => '通知';

  @override
  String get notificationsLabel => '通知';

  @override
  String get soundLabel => 'サウンド';

  @override
  String get accountSection => 'アカウント';

  @override
  String get profileLabel => 'プロフィール';

  @override
  String get profileSubtitle => 'プロフィール情報を編集';

  @override
  String get accountSettingsLabel => 'アカウント設定';

  @override
  String get accountSettingsSubtitle => 'パスワード、セキュリティ、2FA';

  @override
  String get privacyLabel => 'プライバシー';

  @override
  String get privacySubtitle => 'プライバシーを管理';

  @override
  String get generalSection => '一般';

  @override
  String get languageLabel => '言語';

  @override
  String get textSizeLabel => 'テキストサイズ';

  @override
  String get sendByEnterLabel => 'Enterで送信';

  @override
  String get sendByEnterSubtitle => 'Shift+Enterで改行';

  @override
  String get dataStorageSection => 'データとストレージ';

  @override
  String get autoDownloadLabel => 'メディアの自動ダウンロード';

  @override
  String get autoDownloadSubtitle => '写真と動画を自動でダウンロード';

  @override
  String get storageManagementLabel => 'ストレージ管理';

  @override
  String get storageManagementSubtitle => 'キャッシュとデータを削除';

  @override
  String get clearCacheTitle => 'キャッシュを削除';

  @override
  String get clearCacheContent => 'キャッシュデータを削除しますか？';

  @override
  String get cacheCleared => 'キャッシュを削除しました';

  @override
  String get developmentSection => '開発';

  @override
  String get devMenuSubtitle => 'フローティングデバッグボタン';

  @override
  String get aboutSection => 'について';

  @override
  String get suggestImprovementLabel => '改善を提案';

  @override
  String get suggestImprovementSubtitle => 'アイデアや新機能のリクエスト';

  @override
  String get dangerZoneSection => '危険ゾーン';

  @override
  String get logoutLabel => 'ログアウト';

  @override
  String get logoutSubtitle => 'このデバイスからログアウト';

  @override
  String get logoutDialogTitle => 'ログアウト';

  @override
  String get logoutDialogContent => '本当にログアウトしますか？';

  @override
  String get logoutAction => 'ログアウト';

  @override
  String get languageRussian => 'ロシア語';

  @override
  String get languageUkrainian => 'ウクライナ語';

  @override
  String get clientDescription => 'Flutter/Dartで作成したTwoSpaceクライアント';

  @override
  String errorLogout(String error) {
    return 'エラー: $error';
  }

  @override
  String get accountSettingsTitle => 'アカウント設定';

  @override
  String get securitySection => 'セキュリティ';

  @override
  String get twoFactorLabel => '二要素認証';

  @override
  String get twoFactorSubtitle => 'アカウントの追加保護';

  @override
  String get biometricLabel => '生体認証';

  @override
  String get biometricSubtitle => '指紋でログイン';

  @override
  String get activeSessionsLabel => 'アクティブセッション';

  @override
  String get activeSessionsSubtitle => 'デバイスを管理';

  @override
  String get currentDevice => '現在のデバイス';

  @override
  String get changePasswordSection => 'パスワード変更';

  @override
  String get currentPasswordLabel => '現在のパスワード';

  @override
  String get newPasswordLabel => '新しいパスワード';

  @override
  String get confirmPasswordLabel => 'パスワードを確認';

  @override
  String get minPasswordHelper => '最低8文字';

  @override
  String get changePasswordButton => 'パスワードを変更';

  @override
  String get passwordMismatch => 'パスワードが一致しません';

  @override
  String get passwordTooShort => 'パスワードは最低8文字必要です';

  @override
  String get passwordChangeSuccess => 'パスワードを変更しました';

  @override
  String get contactDataSection => '連絡先データ';

  @override
  String get emailLabel => 'メール';

  @override
  String get phoneLabel => '電話';

  @override
  String get deleteAccountLabel => 'アカウントを削除';

  @override
  String get deleteAccountSubtitle => '取り消し不可能な操作';

  @override
  String get deleteAccountTitle => 'アカウントを削除';

  @override
  String get deleteAccountContent => 'アカウントを削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get deleteFeatureLater => 'アカウント削除は後で利用可能になります';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get saveTooltip => '保存';

  @override
  String get editTooltip => '編集';

  @override
  String get writeMessageButton => 'メッセージ';

  @override
  String get callButton => '電話';

  @override
  String get aboutField => '自己紹介';

  @override
  String get nicknameField => 'ニックネーム';

  @override
  String get locationField => '場所';

  @override
  String get birthdayField => '誕生日';

  @override
  String get nameField => '名前';

  @override
  String get avatarUploadLater => 'アバターのアップロードは後で追加されます';

  @override
  String get profileSaved => 'プロフィールを保存しました';

  @override
  String createChatError(String error) {
    return 'チャットを作成できませんでした: $error';
  }

  @override
  String get privacyTitle => 'プライバシー';

  @override
  String get hideFromSearch => '検索から非表示';

  @override
  String get hideFromSearchSubtitle => '検索結果に表示しない';

  @override
  String get hideLastSeen => '最終オンライン時刻を非表示';

  @override
  String get hideLastSeenSubtitle => '他のユーザーにオンライン時刻が表示されません';

  @override
  String get sessionExpiry => 'セッションの有効期限';

  @override
  String sessionExpirySubtitle(int days) {
    return 'このデバイスの自動ログイン: $days日';
  }

  @override
  String get sessionExpiryDaysTitle => 'セッションの有効期限（日数）';

  @override
  String get sessionExpiryDaysContent => '日数を選択してください（最小: 7、最大: 365）。';

  @override
  String get daysLabel => '日';

  @override
  String get enterDaysError => '7〜365の数字を入力してください';

  @override
  String sessionExpirySet(int days) {
    return 'セッションの有効期限: $days日';
  }

  @override
  String get changeEmailLabel => 'メールを変更';

  @override
  String get changeEmailSubtitle => 'メールアドレスを更新';

  @override
  String get twoFactorPrivacySubtitle => '追加保護を有効または無効にする';

  @override
  String get changePhoneLabel => '電話番号を変更';

  @override
  String get changePhoneSubtitle => '電話番号を更新';

  @override
  String updatePrivacyError(String error) {
    return 'プライバシーを更新できませんでした: $error';
  }

  @override
  String updateSettingError(String error) {
    return '設定を更新できませんでした: $error';
  }

  @override
  String get contactsTitle => '連絡先';

  @override
  String get searchContactsHint => '連絡先を検索...';

  @override
  String get contactsAccessTitle => '連絡先へのアクセス';

  @override
  String get contactsPermDeniedPermanent => '許可が永続的に拒否されました。設定を開いてください。';

  @override
  String get contactsPermRequired => '連絡先の許可が必要です。';

  @override
  String get openSettingsButton => '設定を開く';

  @override
  String get requestPermissionButton => '許可をリクエスト';

  @override
  String get noContacts => '連絡先が見つかりません';

  @override
  String get callAction => '電話';

  @override
  String get writeMessageAction => 'メッセージ';

  @override
  String callNotification(String number) {
    return '電話: $number';
  }

  @override
  String messageNotification(String name) {
    return 'メッセージ宛先: $name';
  }

  @override
  String get callsTitle => '通話';

  @override
  String get searchByNameHint => '名前で検索...';

  @override
  String get allFilter => 'すべて';

  @override
  String get incomingFilter => '着信';

  @override
  String get outgoingFilter => '発信';

  @override
  String get missedFilter => '不在着信';

  @override
  String get noCallsFound => '通話なし';

  @override
  String get yesterdayLabel => '昨日';

  @override
  String get incomingCall => '着信';

  @override
  String get outgoingCall => '発信';

  @override
  String get missedCall => '不在着信';

  @override
  String get videoCallLabel => 'ビデオ通話';

  @override
  String get voiceCallLabel => '音声通話';

  @override
  String get sendMessageCallAction => 'メッセージ';

  @override
  String get createRoomTitle => 'ルームを作成';

  @override
  String get createButton => '作成';

  @override
  String get roomNameLabel => 'ルーム名';

  @override
  String get roomNameHint => '例: プロジェクト名';

  @override
  String get roomTopicLabel => 'トピック（任意）';

  @override
  String get roomTopicHint => 'このルームは何についてですか？';

  @override
  String get roomVisibilityLabel => 'ルームの公開設定';

  @override
  String get privateRoomOption => 'プライベートルーム';

  @override
  String get privateRoomSubtitle => '招待されたユーザーのみ参加可能';

  @override
  String get publicRoomOption => 'パブリックルーム';

  @override
  String get publicRoomSubtitle => '誰でも参加可能';

  @override
  String get showHistoryLabel => 'メッセージ履歴を表示';

  @override
  String get showHistorySubtitle => '新しいメンバーは以前のメッセージを見られます';

  @override
  String get enterRoomNameError => 'ルーム名を入力してください';

  @override
  String get roomCreatedSuccess => 'ルームが作成されました！';

  @override
  String imagePickError(String error) {
    return '画像選択エラー: $error';
  }

  @override
  String get groupInfoTab => '情報';

  @override
  String get groupMembersTab => 'メンバー';

  @override
  String get groupRolesTab => 'ロール';

  @override
  String get groupBansTab => 'BAN';

  @override
  String get groupDeleteTab => '削除';

  @override
  String membersCount(int count) {
    return 'メンバー: $count';
  }

  @override
  String get messageHistoryToggle => 'メッセージ履歴';

  @override
  String get showHistoryToggleLabel => '履歴を表示';

  @override
  String get settingSaved => '設定を保存しました';

  @override
  String get backgroundColorLabel => '背景色';

  @override
  String get noMembers => 'メンバーなし';

  @override
  String get roleAction => 'ロール';

  @override
  String get freezeAction => 'フリーズ';

  @override
  String get banAction => 'BAN';

  @override
  String get kickAction => 'キック';

  @override
  String get noBannedUsers => 'BANされたユーザーなし';

  @override
  String get bannedLabel => 'BAN済み';

  @override
  String get userUnbanned => 'ユーザーのBANを解除しました';

  @override
  String get deleteGroupLabel => 'グループを削除';

  @override
  String get deleteGroupWarning => 'この操作は取り消せません。グループは完全に削除されます。';

  @override
  String get confirmDeleteTitle => '削除を確認';

  @override
  String get confirmDeleteContent => '本当によろしいですか？この操作は取り消せません。';

  @override
  String get changeRoleTitle => 'ロールを変更';

  @override
  String get adminRole => '管理者';

  @override
  String get memberRole => 'メンバー';

  @override
  String get freezeUserTitle => 'ユーザーをフリーズ';

  @override
  String get userBanned => 'ユーザーをBANしました';

  @override
  String get userKicked => 'ユーザーをキックしました';

  @override
  String get groupDeleted => 'グループを削除しました';

  @override
  String loadError(String error) {
    return '読み込みエラー: $error';
  }

  @override
  String get publicLabel => 'パブリック';

  @override
  String get privateLabel => 'プライベート';

  @override
  String get noDescription => '説明なし';

  @override
  String get membersLabel => 'メンバー';

  @override
  String get generalLabel => '一般';

  @override
  String get newChatTitle => '新しいチャット';

  @override
  String get directChatTab => 'ダイレクト';

  @override
  String get groupChatTab => 'グループ';

  @override
  String get startDirectChatTitle => 'ダイレクトチャットを開始';

  @override
  String get contactIdDescription => 'ユーザー名または Aegis ID を入力してください';

  @override
  String get contactIdLabel => 'ユーザー名または Aegis ID';

  @override
  String get startChatButton => 'チャットを開始';

  @override
  String get hintCardTitle => 'ヒント';

  @override
  String get contactIdExplanation => 'ユーザー名または数値の Aegis ユーザー ID を使用できます';

  @override
  String get enterUserIdError => 'ユーザーIDを入力してください';

  @override
  String get createNewRoomTitle => '新しいルームを作成';

  @override
  String get descriptionOptionalLabel => '説明（任意）';

  @override
  String get privateGroupLabel => 'プライベートグループ';

  @override
  String get privateGroupSubtitle => '招待されたユーザーのみ参加可能';

  @override
  String get createRoomButton => 'ルームを作成';

  @override
  String get customizationTitle => 'カスタマイズ';

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
  String get colorsTab => 'カラー';

  @override
  String get fontsTab => 'フォント';

  @override
  String get effectsTab => 'エフェクト';

  @override
  String get selectColorTheme => 'カラーテーマを選択';

  @override
  String get themeAppliesEverywhere => '選択したテーマがアプリ全体に適用されます';

  @override
  String get fontSettingsTitle => 'フォント設定';

  @override
  String get selectFontFamily => 'フォントファミリーを選択';

  @override
  String get appFontLabel => 'アプリのフォント';

  @override
  String get fontWeightLabel => 'フォントウェイト';

  @override
  String get fontPreview => 'プレビュー: サンプルテキスト';

  @override
  String get compactMode => '間隔とサイズを縮小';

  @override
  String get enableCircles => 'サークルを有効化';

  @override
  String get circlesDesc => '背景のアニメーションサークル';

  @override
  String get floatingCirclesLabel => 'フローティングサークル';

  @override
  String get reactOnTilt => '傾きに反応';

  @override
  String get parallaxEffect => 'パララックスエフェクト';

  @override
  String get circlesSpeedLabel => '動きの速度';

  @override
  String get staticMotion => '静的';

  @override
  String get brightnessLabel => '明るさ';

  @override
  String get dimOpacity => '暗め';

  @override
  String get brightOpacity => '明るめ';

  @override
  String get performanceLabel => 'パフォーマンス';

  @override
  String get currentSpeedPrefix => '現在: ';

  @override
  String get speedPrefix => '速度:';

  @override
  String get advancedSearchTitle => '詳細検索';

  @override
  String get searchQueryHint => 'クエリを入力...';

  @override
  String get searchTypeLabel => '検索タイプ';

  @override
  String get searchTypeAll => 'すべて';

  @override
  String get searchTypeMessages => 'メッセージ';

  @override
  String get searchTypeMedia => 'メディア';

  @override
  String get searchTypeUsers => 'ユーザー';

  @override
  String get periodLabel => '期間';

  @override
  String get fromDate => '開始';

  @override
  String get toDate => '終了';

  @override
  String get searchButton => '検索';

  @override
  String resultsCount(int count) {
    return '結果 ($count)';
  }

  @override
  String get noResultsFound => '結果が見つかりません';

  @override
  String get forgotPasswordTitle => 'パスワードのリセット';

  @override
  String get forgotPasswordDescription => 'リセットリンクを受け取るためにメールを入力してください';

  @override
  String get sendResetButton => '送信';

  @override
  String get forgotPasswordUnavailable => 'パスワードの回復は利用できません';

  @override
  String get changeEmailTitle => 'メールを変更';

  @override
  String get changeEmailDescription => '新しいメールアドレスを入力してください';

  @override
  String get currentPrefix => '現在: ';

  @override
  String get newEmailLabel => '新しいメール';

  @override
  String get changeEmailButton => 'メールを変更';

  @override
  String changeEmailError(String error) {
    return 'メールを変更できませんでした: $error';
  }

  @override
  String get changePhoneTitle => '電話番号を変更';

  @override
  String get changePhoneDescription => '新しい電話番号と現在のパスワードを入力してください。';

  @override
  String get newPhoneLabel => '新しい番号 (+81...)';

  @override
  String get currentPasswordOptional => '現在のパスワード（必要な場合）';

  @override
  String get changePhoneButton => '番号を変更';

  @override
  String get phoneCannotBeChanged => '電話番号は変更できません';

  @override
  String get emailCannotBeChanged => 'メールアドレスは変更できません';

  @override
  String changePhoneError(String error) {
    return '番号を変更できませんでした: $error';
  }

  @override
  String get confirmCodeTitle => 'コードを確認';

  @override
  String codeSentTo(String phone) {
    return '$phoneにコードを送信しました';
  }

  @override
  String get enterCodeHint => 'コードを入力';

  @override
  String get confirmButton => '確認';

  @override
  String resendCountdown(int seconds) {
    return '$seconds秒後に再送';
  }

  @override
  String get resendCodeButton => 'コードを再送';

  @override
  String get biometricSetupTitle => 'セキュリティ';

  @override
  String get authMethodsLabel => '認証方法';

  @override
  String get biometricAuthLabel => '生体認証';

  @override
  String get biometricAuthSubtitle => '指紋またはFace ID';

  @override
  String get biometricEnabledLabel => '生体認証が有効';

  @override
  String get aboutSecurityLabel => 'セキュリティについて';

  @override
  String get aboutSecurityContent => '便利な認証方法を選択してください。';

  @override
  String get setPinCode => 'PINコードを設定';

  @override
  String get updateAvailableTitle => 'アップデートが利用可能';

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
  String get whatsNewLabel => '新機能';

  @override
  String get noUpdateDescription => '説明なし';

  @override
  String downloadingProgress(int percent) {
    return 'ダウンロード中... $percent%';
  }

  @override
  String get checkingIntegrity => '整合性を確認中...';

  @override
  String get requestingInstall => 'インストールをリクエスト中...';

  @override
  String get updateMandatory => '必須アップデート';

  @override
  String get laterButton => '後で';

  @override
  String get downloadingLabel => 'ダウンロード中...';

  @override
  String get installingLabel => 'インストール中...';

  @override
  String get updateButton => 'アップデート';

  @override
  String get downloadFailed => 'アップデートのダウンロードに失敗しました';

  @override
  String get integrityCheckFailed => 'ダウンロードしたファイルは整合性チェック（sha256）に失敗しました';

  @override
  String get installPermissionTitle => 'インストール許可';

  @override
  String get installPermissionContent => '不明なソースからのインストールを許可してください。';

  @override
  String get installPermissionRequired => 'インストール許可が必要です';

  @override
  String get installFailed => 'インストールに失敗しました';

  @override
  String get ssoFeatureRequired => 'この機能にはwebview_flutterの設定が必要です';

  @override
  String ssoLoginVia(String idpId) {
    return '$idpId 経由のSSОログイン';
  }

  @override
  String get forwardMessageTitle => 'メッセージを転送';

  @override
  String get searchChatHint => 'チャットを検索...';

  @override
  String forwardButton(int count) {
    return '転送 ($count)';
  }

  @override
  String get roomAvatarUpdated => 'ルームアバターを更新しました';

  @override
  String roomAvatarUploadError(String error) {
    return 'アバターのアップロードエラー: $error';
  }

  @override
  String get roomSettingsSaved => 'ルームの設定を保存しました';

  @override
  String roomSettingsSaveError(String error) {
    return '保存エラー: $error';
  }

  @override
  String get uploadAvatarButton => 'アバターをアップロード';

  @override
  String loadMembersError(String error) {
    return 'メンバーの読み込みエラー: $error';
  }

  @override
  String get leaveRoomTitle => 'ルームを退出しますか？';

  @override
  String get leaveRoomContent => '再度招待されるまで戻ることができません。';

  @override
  String get leaveAction => '退出';

  @override
  String get leftRoom => 'ルームを退出しました';

  @override
  String leaveRoomError(String error) {
    return '退出エラー: $error';
  }

  @override
  String get reportNotImplemented => '報告機能はまだ実装されていません';

  @override
  String get featureInDevelopmentLabel => '開発中';

  @override
  String featureInDevelopmentMessage(String feature) {
    return 'この機能は現在開発中で、今後のバージョンで利用できるようになります。';
  }

  @override
  String get inviteAction => '招待';

  @override
  String get threadsLabel => 'スレッド';

  @override
  String get pinnedLabel => 'ピン留め';

  @override
  String get filesLabel => 'ファイル';

  @override
  String get noSharedFiles => '共有ファイルはまだありません';

  @override
  String get mediaLabel => 'メディア';

  @override
  String get noSharedMedia => '共有メディアはまだありません';

  @override
  String get extensionsLabel => '拡張機能';

  @override
  String get copyLinkAction => 'リンクをコピー';

  @override
  String get pollsLabel => '投票';

  @override
  String get exportChatAction => 'チャットをエクスポート';

  @override
  String get reportAction => '報告';

  @override
  String get leaveRoomAction => 'ルームを退出';

  @override
  String roomTitle(String name) {
    return 'ルーム — $name';
  }

  @override
  String get roomSettingsLabel => 'ルーム設定';

  @override
  String authError(String error) {
    return '認証エラー: $error';
  }

  @override
  String get loginRequired => 'ログインが必要';

  @override
  String get loginRequiredContent => '連絡先を検索するにはログインが必要です。ログインしますか？';

  @override
  String get loginAction => 'ログイン';

  @override
  String searchError(String error) {
    return '検索エラー: $error';
  }

  @override
  String get searchContactsTitle => '連絡先を検索';

  @override
  String get nicknameOrPhoneHint => 'ニックネームまたは電話番号';

  @override
  String selectContactError(String error) {
    return '連絡先を選択できませんでした: $error';
  }

  @override
  String get categoryLabel => 'カテゴリ';

  @override
  String get feedbackCategoryFeatures => '機能';

  @override
  String get feedbackCategoryPerformance => 'パフォーマンス';

  @override
  String get feedbackCategorySecurity => 'セキュリティ/プライバシー';

  @override
  String get feedbackCategoryNetworkSync => '同期/ネットワーク';

  @override
  String get shortDescriptionLabel => '簡単な説明';

  @override
  String get shortDescriptionHint => '例:「クラウドでのチャットバックアップ」';

  @override
  String get feedbackValidation => '少なくとも1つのアイデアを選択するか、説明を入力してください';

  @override
  String get detailsOptionalLabel => '詳細（任意）';

  @override
  String get detailsHint => '何が機能すべきか、現在どのように動作しているか、どのようにしたいか？';

  @override
  String get bigFeaturesTitle => '主な機能（最も興味があるものを選択）';

  @override
  String get feedbackE2E => 'エンドツーエンド暗号化（Olm/Megolm）+ デバイス検証';

  @override
  String get feedbackBackup => 'チャットバックアップ（ローカル/クラウド）+ 新しいデバイスへの転送';

  @override
  String get feedbackThreads => 'スレッド、リアクション、メンション、改善されたメッセージ検索';

  @override
  String get feedbackCalls => '音声/ビデオ通話と素早い音声ルーム';

  @override
  String get feedbackFolders => 'チャットフォルダ/カテゴリとスマート通知フィルター';

  @override
  String get feedbackBots => 'ボットとインテグレーション（Webhook、GitHub/Jira、リマインダー）';

  @override
  String get feedbackSlowNet => '「低速インターネット」モード + 積極的なメディアキャッシング';

  @override
  String get startChatTitle => 'チャットを開始';

  @override
  String get createRoomSubtitle => 'プライベートまたはパブリックグループ';

  @override
  String get inviteUserTitle => 'ユーザーを招待';

  @override
  String get inviteUserSubtitle => 'ユーザーを検索してメッセージを送る';

  @override
  String get joinByCodeTitle => 'コードで参加';

  @override
  String get joinByCodeSubtitle => '招待コードを使ってルームに参加';

  @override
  String get chatsSubtitle => '個人チャット、グループ、招待リンクをひとつの場所に';

  @override
  String get chatsQuickStartTitle => '新しく始める';

  @override
  String get chatsRecentTitle => '最近のチャット';

  @override
  String get joinLinkHint => '招待リンク、エイリアス、またはコードを貼り付け';

  @override
  String get fontLabel => 'フォント';

  @override
  String get pinCodeLabel => 'PINコード';

  @override
  String get pinCodeSubtitle => '保護のための4-6桁';

  @override
  String get pinHint => 'PIN（4〜6桁）';

  @override
  String get pinLengthError => 'PINは4〜6桁である必要があります';

  @override
  String get pinSetSuccess => 'PINが設定されました';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get deleteButton => '削除';

  @override
  String get closeButton => '閉じる';

  @override
  String get saveButton => '保存';

  @override
  String get sendButton => '送信';

  @override
  String get copyButton => 'コピー';

  @override
  String get shareButton => '共有';

  @override
  String get settingsLabel => '設定';

  @override
  String get feedbackCategoryUxDesign => 'UX/デザイン';

  @override
  String get feedbackShareSubject => 'TwoSpace — 提案';

  @override
  String get feedbackMessageHeader => 'TwoSpace — 提案/改善';

  @override
  String feedbackVersion(String version) {
    return 'バージョン: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return 'カテゴリ: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return '概要: $title';
  }

  @override
  String get feedbackWishList => '特に嬉しいこと:';

  @override
  String get feedbackDetailsLine => '詳細:';

  @override
  String get circlesVisible => 'サークル表示中';

  @override
  String get circlesHidden => 'サークル非表示';

  @override
  String get speedSlow => '遅い';

  @override
  String get speedFast => '速い';

  @override
  String get advancedSettingsLabel => '詳細設定';

  @override
  String get compactModeLabel => 'コンパクトモード';

  @override
  String get activeDeviceInfo => 'Android • アクティブ';

  @override
  String stubPlaceholder(String key) {
    return 'スタブ — $key';
  }

  @override
  String loadMessagesError(String error) {
    return 'メッセージの読み込みエラー: $error';
  }

  @override
  String get pinnedUpdated => 'ピン留め更新済み';

  @override
  String editError(String error) {
    return '編集エラー: $error';
  }

  @override
  String get moreButton => 'もっと';

  @override
  String shareError(String error) {
    return '共有できませんでした: $error';
  }

  @override
  String sendError(String error) {
    return '送信エラー: $error';
  }

  @override
  String get voiceRecordingUnsupported => 'このプラットフォームでは音声録音はサポートされていません';

  @override
  String get microphonePermissionRequired => 'マイクの許可が必要です';

  @override
  String genericError(String error) {
    return 'エラー: $error';
  }

  @override
  String get ownersLabel => '👑 オーナー';

  @override
  String get administratorsLabel => '⚡ 管理者';

  @override
  String get oneHour => '1時間';

  @override
  String get oneDay => '1日';

  @override
  String get sevenDays => '7日';

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
  String get storageMemoryTitle => 'メモリ';

  @override
  String get storageTotalLabel => '合計';

  @override
  String get storageSelectedLabel => 'Selected';

  @override
  String get storagePhotosLabel => '写真';

  @override
  String get storageVideosLabel => '動画';

  @override
  String get storageCacheLabel => 'キャッシュ';

  @override
  String get storageAppDataLabel => 'アプリデータ';

  @override
  String get storageCleanupTitle => '削除予定';

  @override
  String get storageCleanupSubtitle => '安全に削除できる項目を確認します。';

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
  String get peopleTitle => '人々';

  @override
  String get peopleSubtitle => '連絡先、お気に入り、検索、招待をひとつの場所に';

  @override
  String get peopleQuickNewChat => '新しいチャット';

  @override
  String get peopleQuickInvite => '招待';

  @override
  String get peopleQuickSync => '同期';

  @override
  String get peopleSearchHint => '名前、ニックネーム、電話番号で検索';

  @override
  String get peopleSegmentAll => 'すべて';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => '連絡先帳';

  @override
  String get peopleSegmentRecent => '最近';

  @override
  String get peopleLoading => '人を読み込み中…';

  @override
  String get peopleNoPeopleTitle => 'まだ誰もいません';

  @override
  String get peopleNoPeopleMessage => 'お気に入り、最近の会話、連絡先がここに表示されます。';

  @override
  String get peoplePermissionCardTitle => '連絡先へのアクセスが制限されています';

  @override
  String get peoplePermissionCardMessage =>
      '連絡先帳を表示し、より速く招待するために連絡先へのアクセスを許可してください。';

  @override
  String get peoplePermissionCardMessageSettings =>
      '連絡先帳セクションを復元するには、システム設定で連絡先アクセスを有効にしてください。';

  @override
  String get peopleFavoritesFrequentTitle => 'お気に入りとよく使う人';

  @override
  String get peopleRecentTitle => '最近の人';

  @override
  String get peopleTwoSpaceTitle => 'TwoSpaceの人々';

  @override
  String get peopleInviteTitle => 'TwoSpaceに招待';

  @override
  String get peopleInviteSubtitle => 'この連絡先をTwoSpaceに招待';

  @override
  String get peopleSearching => '人を検索中…';

  @override
  String get peopleSearchRemoteTitle => 'TwoSpaceの結果';

  @override
  String get peopleSearchLocalTitle => '最近と保存済み';

  @override
  String get peopleSearchInviteTitle => '連絡先帳から招待';

  @override
  String get peopleSearchEmptyTitle => '該当する人がいません';

  @override
  String get peopleSearchEmptyMessage => '別の名前、ニックネーム、または電話番号を試してください。';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => '追加情報はまだありません';

  @override
  String get peopleInviteShareText =>
      'TwoSpaceに参加しませんか。チャットと通話のための安全なメッセンジャーです。';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return '$personNameさん、TwoSpaceに参加しませんか。安全にチャットや通話ができます。';
  }

  @override
  String get peopleViewProfileAction => 'プロフィールを表示';

  @override
  String get peopleRemoveFavoriteAction => 'お気に入りから削除';

  @override
  String get peopleAddFavoriteAction => 'お気に入りに追加';

  @override
  String get callsSubtitle => '最近の通話、すばやい折り返し、相手中心の履歴';

  @override
  String get callsStartCallAction => '通話を開始';

  @override
  String get callsQuickStartTitle => '今すぐ通話';

  @override
  String get callsQuickStartSubtitle => '人々を開き、相手を探して、安全な音声通話またはビデオ通話を開始します。';

  @override
  String get callsSearchHint => '通話履歴を検索';

  @override
  String get callsVideoFilter => 'ビデオ';

  @override
  String get callsTopContactsTitle => 'よく通話する相手';

  @override
  String get callsLoadingLabel => '通話を読み込み中…';

  @override
  String get callsEmptyTitle => 'まだ通話はありません';

  @override
  String get callsEmptyMessage => '最初の音声通話またはビデオ通話の後に通話履歴がここに表示されます。';

  @override
  String get callsEmptySearchMessage => '現在の検索またはフィルターに一致する通話はありません。';

  @override
  String get callsTodaySection => '今日';

  @override
  String get callsThisWeekSection => '今週';

  @override
  String get callsEarlierSection => '以前';

  @override
  String callsThreadCount(int count) {
    return '$count件の通話';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count件の不在';
  }

  @override
  String get callsMuteAction => 'ミュート';

  @override
  String get callsSpeakerAction => 'スピーカー';

  @override
  String get callsCameraAction => 'カメラ';

  @override
  String get callsSwitchCameraAction => '切替';

  @override
  String get callsEndAction => '通話終了';

  @override
  String get callsConnectingLabel => '接続中…';

  @override
  String get callsRingingLabel => '呼び出し中…';

  @override
  String get callsConnectingDetail => '安全な通話セッションを作成しています。';

  @override
  String get callsRingingDetail => '相手が応答するのを待っています。';

  @override
  String get callsVideoSecureDetail => '映像は保護され、現在の安全なセッションを通して送られます。';

  @override
  String get callsVoiceSecureDetail => '音声は保護され、現在の安全なセッションを通して送られます。';

  @override
  String get timestampPrecisionLabel => 'メッセージ時刻の精度';

  @override
  String get timestampPrecisionSubtitle => 'チャット内とチャット一覧で時刻をどこまで細かく表示するか選択します。';

  @override
  String get timestampPrecisionMinutes => '時と分';

  @override
  String get timestampPrecisionSeconds => '時・分・秒';

  @override
  String get timestampPrecisionMilliseconds => '時・分・秒・ミリ秒';

  @override
  String get startupTitle => 'TwoSpace を準備しています';

  @override
  String get startupSubtitle => '安全なセッションを確認し、チャットを開いています。';

  @override
  String get startupFooter => 'この画面はアプリ起動時にのみ表示されます。';

  @override
  String get startupStepEnvironment => '設定を読み込んでいます';

  @override
  String get startupStepDiagnostics => '診断を開始しています';

  @override
  String get startupStepValidation => '環境を検証しています';

  @override
  String get startupStepSettings => '設定を読み込んでいます';

  @override
  String get startupStepSession => '安全なセッションを復元しています';

  @override
  String get startupStepLaunch => 'アプリを起動しています';

  @override
  String get callsDemoBannerTitle => '例示用、未実装の機能です';

  @override
  String get callsDemoBannerVoiceMessage =>
      '音声通話は現在、見た目のプロトタイプとしてのみ表示されています。音声通信はまだ接続されていません。';

  @override
  String get callsDemoBannerVideoMessage =>
      'ビデオ通話は現在、見た目のプロトタイプとしてのみ表示されています。相手側の映像は利用できませんが、自分のローカルカメラプレビューは動作します。';

  @override
  String get callsCameraPermissionMessage =>
      'ビデオ通話中にローカルプレビューを表示するため、カメラへのアクセスを許可してください。';

  @override
  String get callsCameraPermissionSettingsMessage =>
      'カメラへのアクセスがブロックされています。システム設定を開いてローカルプレビューを有効にしてください。';

  @override
  String get callsCameraPermissionAction => 'カメラを許可';

  @override
  String get callsCameraUnavailableTitle => 'カメラを利用できません';

  @override
  String get callsCameraUnavailableMessage => 'この端末ではローカルカメラプレビューを開始できませんでした。';

  @override
  String get callsCameraUnsupportedMessage =>
      'このプラットフォームではローカルビデオプレビューをサポートしていません。';

  @override
  String get callsCameraOffMessage => 'このデモ通話ではカメラプレビューがオフになっています。';

  @override
  String get callsFrontCameraLabel => '前面カメラ';

  @override
  String get callsRearCameraLabel => '背面カメラ';

  @override
  String get backgroundOptimizationDisabledTitle => '背景エフェクトを軽量化しました';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace は継続的なフレーム遅延を検出したため、スクロールやチャット操作を滑らかに保つために重い背景エフェクトを無効にしました。';

  @override
  String get backgroundOptimizationOpenSettings => '表示設定を開く';
}
