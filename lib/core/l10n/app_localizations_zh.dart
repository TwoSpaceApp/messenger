// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => '加载中...';

  @override
  String get initializing => '初始化中...';

  @override
  String get errorGeneric => '发生错误';

  @override
  String get errorInitialization => '初始化错误';

  @override
  String get errorInitializationFull => '初始化错误。请重启应用。';

  @override
  String get errorNetwork => '网络错误。请检查连接。';

  @override
  String get errorAuth => '认证错误。';

  @override
  String get errorInvalidArguments => '参数无效。';

  @override
  String get errorInvalidArgumentsProfile => '个人资料参数无效。';

  @override
  String get errorInvalidArgumentsChat => '聊天参数无效。';

  @override
  String get retry => '重试';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get send => '发送';

  @override
  String get close => '关闭';

  @override
  String errorWithDetail(String error) {
    return '错误: $error';
  }

  @override
  String get ok => '确定';

  @override
  String get confirm => '确认';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get next => '下一步';

  @override
  String get back => '返回';

  @override
  String get done => '完成';

  @override
  String get noData => '无数据';

  @override
  String get nothingFound => '未找到';

  @override
  String get copyAction => '复制';

  @override
  String get shareAction => '分享';

  @override
  String get textCopied => '文本已复制';

  @override
  String get onlineLabel => '在线';

  @override
  String get offlineLabel => '离线';

  @override
  String get userDefault => '用户';

  @override
  String get lessThanMinuteAgo => '不到一分钟前';

  @override
  String minutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String get videoLabel => '视频';

  @override
  String videoLoadError(String error) {
    return '视频错误: $error';
  }

  @override
  String get saveFailed => '保存失败';

  @override
  String get shareSheetFailed => '无法打开分享';

  @override
  String get speedLabel => '速度:';

  @override
  String get previewTitle => '预览';

  @override
  String fileDownloaded(String path) {
    return '文件已下载: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return '文件已临时保存: $path';
  }

  @override
  String get savedToGallery => '已保存到相册';

  @override
  String authorizationError(String message) {
    return '授权错误: $message';
  }

  @override
  String get loginTitle => '登录';

  @override
  String get welcomeBack => '欢迎';

  @override
  String get emailOrUsernameLabel => '用户名';

  @override
  String get passwordLabel => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get noAccount => '没有账户？';

  @override
  String get orDivider => '或';

  @override
  String get validationEnterEmailOrUsername => '请输入用户名';

  @override
  String get validationEnterPassword => '请输入密码';

  @override
  String get registerTitle => '注册';

  @override
  String get fillAllFields => '请填写所有字段';

  @override
  String get passwordStrengthWeak => '弱';

  @override
  String get passwordStrengthMedium => '中等';

  @override
  String get passwordStrengthGood => '良好';

  @override
  String get passwordStrengthStrong => '强';

  @override
  String get fullNameLabel => '全名';

  @override
  String get nicknameAtLabel => '昵称 (@用户名)';

  @override
  String get uploadPhotoPrompt => '上传头像';

  @override
  String get photoLooksGreat => '看起来很棒！';

  @override
  String get helpFriendsFind => '帮助朋友找到您';

  @override
  String get setupInterfaceTitle => '自定义界面';

  @override
  String get colorThemeLabel => '颜色主题';

  @override
  String get validationEnterEmail => '请输入电子邮件';

  @override
  String get validationInvalidEmail => '电子邮件地址无效';

  @override
  String get validationPasswordTooShort => '密码太短';

  @override
  String get backToLogin => '登录';

  @override
  String get finishButton => '完成';

  @override
  String filePickError(String error) {
    return '文件选择错误: $error';
  }

  @override
  String get chatsTitle => '聊天';

  @override
  String get noChats => '无聊天';

  @override
  String get noMessages => '（无消息）';

  @override
  String get newChat => '新聊天';

  @override
  String get messageInputHint => '输入消息...';

  @override
  String get addCaptionHint => '添加说明或消息';

  @override
  String get unlockApp => '解锁';

  @override
  String get unlockButton => '解锁';

  @override
  String get dropFilesTitle => '拖放文件以附加';

  @override
  String get dropFilesSubtitle => '它们将显示在消息输入框上方。';

  @override
  String get videoUnavailable => '视频不可用';

  @override
  String get guestRole => '访客';

  @override
  String get replyAction => '回复';

  @override
  String get editShort => '编辑';

  @override
  String get pinAction => '置顶';

  @override
  String get moreReactions => '更多';

  @override
  String get replyDialogTitle => '回复';

  @override
  String get replyHint => '回复内容';

  @override
  String get editMessageTitle => '编辑消息';

  @override
  String get editMessageHint => '新内容';

  @override
  String get deleteMessageTitle => '删除消息？';

  @override
  String get pinsUpdated => '置顶已更新';

  @override
  String get messageEdited => '消息已编辑';

  @override
  String get fileSent => '文件已发送';

  @override
  String get voiceNotSupported => '此平台不支持语音录制';

  @override
  String get microphonePermRequired => '需要麦克风权限';

  @override
  String get recordingError => '录制错误';

  @override
  String sendFailedError(String error) {
    return '发送失败: $error';
  }

  @override
  String attachmentSendError(String error) {
    return '附件错误: $error';
  }

  @override
  String shareFailedError(String error) {
    return '分享失败: $error';
  }

  @override
  String replyError(String error) {
    return '回复错误: $error';
  }

  @override
  String pinError(String error) {
    return '置顶错误: $error';
  }

  @override
  String deleteError(String error) {
    return '删除错误: $error';
  }

  @override
  String editMessageError(String error) {
    return '编辑错误: $error';
  }

  @override
  String get userTyping => '用户正在输入...';

  @override
  String get statusOnline => '在线';

  @override
  String get statusLastSeenRecently => '最近在线';

  @override
  String get settingsTitle => '设置';

  @override
  String get appearanceSection => '外观';

  @override
  String get themeLabel => '主题';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get customizationLabel => '自定义';

  @override
  String get customizationSubtitle => '颜色、字体和UI效果';

  @override
  String get notificationsSection => '通知';

  @override
  String get notificationsLabel => '通知';

  @override
  String get soundLabel => '声音';

  @override
  String get accountSection => '账户';

  @override
  String get profileLabel => '个人资料';

  @override
  String get profileSubtitle => '编辑个人资料信息';

  @override
  String get accountSettingsLabel => '账户设置';

  @override
  String get accountSettingsSubtitle => '密码、安全、双重认证';

  @override
  String get privacyLabel => '隐私';

  @override
  String get privacySubtitle => '管理隐私';

  @override
  String get generalSection => '通用';

  @override
  String get languageLabel => '语言';

  @override
  String get textSizeLabel => '文字大小';

  @override
  String get sendByEnterLabel => '按Enter发送';

  @override
  String get sendByEnterSubtitle => 'Shift+Enter换行';

  @override
  String get dataStorageSection => '数据与存储';

  @override
  String get autoDownloadLabel => '自动下载媒体';

  @override
  String get autoDownloadSubtitle => '自动下载照片和视频';

  @override
  String get storageManagementLabel => '存储管理';

  @override
  String get storageManagementSubtitle => '清除缓存和数据';

  @override
  String get clearCacheTitle => '清除缓存';

  @override
  String get clearCacheContent => '删除缓存数据？';

  @override
  String get cacheCleared => '缓存已清除';

  @override
  String get developmentSection => '开发';

  @override
  String get devMenuSubtitle => '悬浮调试按钮';

  @override
  String get aboutSection => '关于';

  @override
  String get suggestImprovementLabel => '建议改进';

  @override
  String get suggestImprovementSubtitle => '想法和新功能请求';

  @override
  String get dangerZoneSection => '危险区域';

  @override
  String get logoutLabel => '退出登录';

  @override
  String get logoutSubtitle => '从此设备退出登录';

  @override
  String get logoutDialogTitle => '退出登录';

  @override
  String get logoutDialogContent => '确定要退出登录吗？';

  @override
  String get logoutAction => '退出登录';

  @override
  String get languageRussian => '俄语';

  @override
  String get languageUkrainian => '乌克兰语';

  @override
  String get clientDescription => '使用Flutter/Dart构建的TwoSpace客户端';

  @override
  String errorLogout(String error) {
    return '错误: $error';
  }

  @override
  String get accountSettingsTitle => '账户设置';

  @override
  String get securitySection => '安全';

  @override
  String get twoFactorLabel => '两步验证';

  @override
  String get twoFactorSubtitle => '账户额外保护';

  @override
  String get biometricLabel => '生物识别';

  @override
  String get biometricSubtitle => '使用指纹登录';

  @override
  String get activeSessionsLabel => '活跃会话';

  @override
  String get activeSessionsSubtitle => '管理设备';

  @override
  String get currentDevice => '当前设备';

  @override
  String get changePasswordSection => '修改密码';

  @override
  String get currentPasswordLabel => '当前密码';

  @override
  String get newPasswordLabel => '新密码';

  @override
  String get confirmPasswordLabel => '确认密码';

  @override
  String get minPasswordHelper => '至少8个字符';

  @override
  String get changePasswordButton => '修改密码';

  @override
  String get passwordMismatch => '密码不匹配';

  @override
  String get passwordTooShort => '密码至少需要8个字符';

  @override
  String get passwordChangeSuccess => '密码修改成功';

  @override
  String get contactDataSection => '联系数据';

  @override
  String get emailLabel => '电子邮件';

  @override
  String get phoneLabel => '电话';

  @override
  String get deleteAccountLabel => '删除账户';

  @override
  String get deleteAccountSubtitle => '不可逆操作';

  @override
  String get deleteAccountTitle => '删除账户';

  @override
  String get deleteAccountContent => '确定要删除账户吗？此操作不可撤销。';

  @override
  String get deleteFeatureLater => '账户删除功能稍后提供';

  @override
  String get profileTitle => '个人资料';

  @override
  String get saveTooltip => '保存';

  @override
  String get editTooltip => '编辑';

  @override
  String get writeMessageButton => '消息';

  @override
  String get callButton => '通话';

  @override
  String get aboutField => '关于我';

  @override
  String get nicknameField => '昵称';

  @override
  String get locationField => '位置';

  @override
  String get birthdayField => '生日';

  @override
  String get nameField => '姓名';

  @override
  String get avatarUploadLater => '头像上传功能稍后添加';

  @override
  String get profileSaved => '个人资料已保存';

  @override
  String createChatError(String error) {
    return '无法创建聊天: $error';
  }

  @override
  String get privacyTitle => '隐私';

  @override
  String get hideFromSearch => '在搜索中隐藏';

  @override
  String get hideFromSearchSubtitle => '不在搜索结果中显示';

  @override
  String get hideLastSeen => '隐藏最后在线时间';

  @override
  String get hideLastSeenSubtitle => '其他人看不到您的在线时间';

  @override
  String get sessionExpiry => '会话过期';

  @override
  String sessionExpirySubtitle(int days) {
    return '此设备自动登录: $days天';
  }

  @override
  String get sessionExpiryDaysTitle => '会话过期（天）';

  @override
  String get sessionExpiryDaysContent => '选择天数（最少: 7，最多: 365）。';

  @override
  String get daysLabel => '天';

  @override
  String get enterDaysError => '请输入7到365之间的数字';

  @override
  String sessionExpirySet(int days) {
    return '会话过期: $days天';
  }

  @override
  String get changeEmailLabel => '修改电子邮件';

  @override
  String get changeEmailSubtitle => '更新电子邮件地址';

  @override
  String get twoFactorPrivacySubtitle => '启用或禁用增强保护';

  @override
  String get changePhoneLabel => '修改电话';

  @override
  String get changePhoneSubtitle => '更新电话号码';

  @override
  String updatePrivacyError(String error) {
    return '无法更新隐私设置: $error';
  }

  @override
  String updateSettingError(String error) {
    return '无法更新设置: $error';
  }

  @override
  String get contactsTitle => '联系人';

  @override
  String get searchContactsHint => '搜索联系人...';

  @override
  String get contactsAccessTitle => '访问联系人';

  @override
  String get contactsPermDeniedPermanent => '权限被永久拒绝。请打开设置。';

  @override
  String get contactsPermRequired => '需要联系人权限。';

  @override
  String get openSettingsButton => '打开设置';

  @override
  String get requestPermissionButton => '请求权限';

  @override
  String get noContacts => '未找到联系人';

  @override
  String get callAction => '通话';

  @override
  String get writeMessageAction => '消息';

  @override
  String callNotification(String number) {
    return '通话: $number';
  }

  @override
  String messageNotification(String name) {
    return '发消息给: $name';
  }

  @override
  String get callsTitle => '通话';

  @override
  String get searchByNameHint => '按姓名搜索...';

  @override
  String get allFilter => '全部';

  @override
  String get incomingFilter => '来电';

  @override
  String get outgoingFilter => '去电';

  @override
  String get missedFilter => '未接';

  @override
  String get noCallsFound => '无通话';

  @override
  String get yesterdayLabel => '昨天';

  @override
  String get incomingCall => '来电';

  @override
  String get outgoingCall => '去电';

  @override
  String get missedCall => '未接';

  @override
  String get videoCallLabel => '视频通话';

  @override
  String get voiceCallLabel => '语音通话';

  @override
  String get sendMessageCallAction => '消息';

  @override
  String get createRoomTitle => '创建房间';

  @override
  String get createButton => '创建';

  @override
  String get roomNameLabel => '房间名称';

  @override
  String get roomNameHint => '例如: 您的项目名称';

  @override
  String get roomTopicLabel => '主题（可选）';

  @override
  String get roomTopicHint => '这个房间是关于什么的？';

  @override
  String get roomVisibilityLabel => '房间可见性';

  @override
  String get privateRoomOption => '私人房间';

  @override
  String get privateRoomSubtitle => '只有受邀用户可以加入';

  @override
  String get publicRoomOption => '公开房间';

  @override
  String get publicRoomSubtitle => '任何人都可以加入';

  @override
  String get showHistoryLabel => '显示消息历史';

  @override
  String get showHistorySubtitle => '新成员可以查看之前的消息';

  @override
  String get enterRoomNameError => '请输入房间名称';

  @override
  String get roomCreatedSuccess => '房间创建成功！';

  @override
  String imagePickError(String error) {
    return '图片选择错误: $error';
  }

  @override
  String get groupInfoTab => '信息';

  @override
  String get groupMembersTab => '成员';

  @override
  String get groupRolesTab => '角色';

  @override
  String get groupBansTab => '封禁';

  @override
  String get groupDeleteTab => '删除';

  @override
  String membersCount(int count) {
    return '成员: $count';
  }

  @override
  String get messageHistoryToggle => '消息历史';

  @override
  String get showHistoryToggleLabel => '显示历史';

  @override
  String get settingSaved => '设置已保存';

  @override
  String get backgroundColorLabel => '背景颜色';

  @override
  String get noMembers => '无成员';

  @override
  String get roleAction => '角色';

  @override
  String get freezeAction => '冻结';

  @override
  String get banAction => '封禁';

  @override
  String get kickAction => '踢出';

  @override
  String get noBannedUsers => '无封禁用户';

  @override
  String get bannedLabel => '已封禁';

  @override
  String get userUnbanned => '用户已解封';

  @override
  String get deleteGroupLabel => '删除群组';

  @override
  String get deleteGroupWarning => '此操作不可逆。群组将被永久删除。';

  @override
  String get confirmDeleteTitle => '确认删除';

  @override
  String get confirmDeleteContent => '确定吗？此操作不可撤销。';

  @override
  String get changeRoleTitle => '修改角色';

  @override
  String get adminRole => '管理员';

  @override
  String get memberRole => '成员';

  @override
  String get freezeUserTitle => '冻结用户';

  @override
  String get userBanned => '用户已封禁';

  @override
  String get userKicked => '用户已踢出';

  @override
  String get groupDeleted => '群组已删除';

  @override
  String loadError(String error) {
    return '加载错误: $error';
  }

  @override
  String get publicLabel => '公开';

  @override
  String get privateLabel => '私人';

  @override
  String get noDescription => '无描述';

  @override
  String get membersLabel => '成员';

  @override
  String get generalLabel => '通用';

  @override
  String get newChatTitle => '新聊天';

  @override
  String get directChatTab => '直接';

  @override
  String get groupChatTab => '群组';

  @override
  String get startDirectChatTitle => '开始直接聊天';

  @override
  String get contactIdDescription => '输入用户名或 Aegis ID';

  @override
  String get contactIdLabel => '用户名或 Aegis ID';

  @override
  String get startChatButton => '开始聊天';

  @override
  String get hintCardTitle => '提示';

  @override
  String get contactIdExplanation => '可以使用用户名或数字形式的 Aegis 用户 ID';

  @override
  String get enterUserIdError => '请输入用户ID';

  @override
  String get createNewRoomTitle => '创建新房间';

  @override
  String get descriptionOptionalLabel => '描述（可选）';

  @override
  String get privateGroupLabel => '私人群组';

  @override
  String get privateGroupSubtitle => '只有受邀用户可以加入';

  @override
  String get createRoomButton => '创建房间';

  @override
  String get customizationTitle => '自定义';

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
  String get colorsTab => '颜色';

  @override
  String get fontsTab => '字体';

  @override
  String get effectsTab => '效果';

  @override
  String get selectColorTheme => '选择颜色主题';

  @override
  String get themeAppliesEverywhere => '所选主题将应用于整个应用';

  @override
  String get fontSettingsTitle => '字体设置';

  @override
  String get selectFontFamily => '选择字体系列';

  @override
  String get appFontLabel => '应用字体';

  @override
  String get fontWeightLabel => '字体粗细';

  @override
  String get fontPreview => '预览: 示例文字';

  @override
  String get compactMode => '减少间距和大小';

  @override
  String get enableCircles => '启用圆圈';

  @override
  String get circlesDesc => '背景中的动画圆圈';

  @override
  String get floatingCirclesLabel => '悬浮圆圈';

  @override
  String get reactOnTilt => '对倾斜做出反应';

  @override
  String get parallaxEffect => '视差效果';

  @override
  String get circlesSpeedLabel => '运动速度';

  @override
  String get staticMotion => '静态';

  @override
  String get brightnessLabel => '亮度';

  @override
  String get dimOpacity => '暗淡';

  @override
  String get brightOpacity => '明亮';

  @override
  String get performanceLabel => '性能';

  @override
  String get currentSpeedPrefix => '当前: ';

  @override
  String get speedPrefix => '速度:';

  @override
  String get advancedSearchTitle => '高级搜索';

  @override
  String get searchQueryHint => '输入搜索词...';

  @override
  String get searchTypeLabel => '搜索类型';

  @override
  String get searchTypeAll => '全部';

  @override
  String get searchTypeMessages => '消息';

  @override
  String get searchTypeMedia => '媒体';

  @override
  String get searchTypeUsers => '用户';

  @override
  String get periodLabel => '时间段';

  @override
  String get fromDate => '从';

  @override
  String get toDate => '到';

  @override
  String get searchButton => '搜索';

  @override
  String resultsCount(int count) {
    return '结果 ($count)';
  }

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get forgotPasswordTitle => '重置密码';

  @override
  String get forgotPasswordDescription => '输入电子邮件以接收重置链接';

  @override
  String get sendResetButton => '发送';

  @override
  String get forgotPasswordUnavailable => '密码恢复不可用';

  @override
  String get changeEmailTitle => '修改电子邮件';

  @override
  String get changeEmailDescription => '输入新电子邮件地址';

  @override
  String get currentPrefix => '当前: ';

  @override
  String get newEmailLabel => '新电子邮件';

  @override
  String get changeEmailButton => '修改电子邮件';

  @override
  String changeEmailError(String error) {
    return '无法修改电子邮件: $error';
  }

  @override
  String get changePhoneTitle => '修改电话号码';

  @override
  String get changePhoneDescription => '输入新电话号码和当前密码。';

  @override
  String get newPhoneLabel => '新号码 (+86...)';

  @override
  String get currentPasswordOptional => '当前密码（如需要）';

  @override
  String get changePhoneButton => '修改号码';

  @override
  String get phoneCannotBeChanged => '无法修改电话号码';

  @override
  String get emailCannotBeChanged => '电子邮件无法更改';

  @override
  String changePhoneError(String error) {
    return '无法修改号码: $error';
  }

  @override
  String get confirmCodeTitle => '确认验证码';

  @override
  String codeSentTo(String phone) {
    return '我们向$phone发送了验证码';
  }

  @override
  String get enterCodeHint => '输入验证码';

  @override
  String get confirmButton => '确认';

  @override
  String resendCountdown(int seconds) {
    return '$seconds秒后重新发送';
  }

  @override
  String get resendCodeButton => '重新发送验证码';

  @override
  String get biometricSetupTitle => '安全';

  @override
  String get authMethodsLabel => '认证方式';

  @override
  String get biometricAuthLabel => '生物识别认证';

  @override
  String get biometricAuthSubtitle => '指纹或面部识别';

  @override
  String get biometricEnabledLabel => '生物识别已启用';

  @override
  String get aboutSecurityLabel => '关于安全';

  @override
  String get aboutSecurityContent => '选择便捷的认证方式。';

  @override
  String get setPinCode => '设置PIN码';

  @override
  String get updateAvailableTitle => '有可用更新';

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
  String get whatsNewLabel => '新功能';

  @override
  String get noUpdateDescription => '无描述';

  @override
  String downloadingProgress(int percent) {
    return '下载中... $percent%';
  }

  @override
  String get checkingIntegrity => '检查完整性...';

  @override
  String get requestingInstall => '请求安装...';

  @override
  String get updateMandatory => '强制更新';

  @override
  String get laterButton => '稍后';

  @override
  String get downloadingLabel => '下载中...';

  @override
  String get installingLabel => '安装中...';

  @override
  String get updateButton => '更新';

  @override
  String get downloadFailed => '无法下载更新';

  @override
  String get integrityCheckFailed => '下载的文件未通过完整性检查（sha256）';

  @override
  String get installPermissionTitle => '安装权限';

  @override
  String get installPermissionContent => '请允许从未知来源安装。';

  @override
  String get installPermissionRequired => '需要安装权限';

  @override
  String get installFailed => '安装失败';

  @override
  String get ssoFeatureRequired => '此功能需要webview_flutter配置';

  @override
  String ssoLoginVia(String idpId) {
    return '通过 $idpId 进行SSO登录';
  }

  @override
  String get forwardMessageTitle => '转发消息';

  @override
  String get searchChatHint => '搜索聊天...';

  @override
  String forwardButton(int count) {
    return '转发 ($count)';
  }

  @override
  String get roomAvatarUpdated => '房间头像已更新';

  @override
  String roomAvatarUploadError(String error) {
    return '上传头像错误: $error';
  }

  @override
  String get roomSettingsSaved => '房间设置已保存';

  @override
  String roomSettingsSaveError(String error) {
    return '保存错误: $error';
  }

  @override
  String get uploadAvatarButton => '上传头像';

  @override
  String loadMembersError(String error) {
    return '加载成员错误: $error';
  }

  @override
  String get leaveRoomTitle => '离开房间？';

  @override
  String get leaveRoomContent => '不重新邀请将无法返回。';

  @override
  String get leaveAction => '离开';

  @override
  String get leftRoom => '您已离开房间';

  @override
  String leaveRoomError(String error) {
    return '离开错误: $error';
  }

  @override
  String get reportNotImplemented => '举报功能尚未实现';

  @override
  String get featureInDevelopmentLabel => '开发中';

  @override
  String featureInDevelopmentMessage(String feature) {
    return '此功能仍在开发中，将在后续版本中提供。';
  }

  @override
  String get inviteAction => '邀请';

  @override
  String get threadsLabel => '线程';

  @override
  String get pinnedLabel => '置顶';

  @override
  String get filesLabel => '文件';

  @override
  String get noSharedFiles => '暂无共享文件';

  @override
  String get mediaLabel => '媒体';

  @override
  String get noSharedMedia => '暂无共享媒体';

  @override
  String get extensionsLabel => '扩展';

  @override
  String get copyLinkAction => '复制链接';

  @override
  String get pollsLabel => '投票';

  @override
  String get exportChatAction => '导出聊天';

  @override
  String get reportAction => '举报';

  @override
  String get leaveRoomAction => '离开房间';

  @override
  String roomTitle(String name) {
    return '房间 — $name';
  }

  @override
  String get roomSettingsLabel => '房间设置';

  @override
  String authError(String error) {
    return '认证错误: $error';
  }

  @override
  String get loginRequired => '需要登录';

  @override
  String get loginRequiredContent => '您需要登录才能搜索联系人。前往登录？';

  @override
  String get loginAction => '登录';

  @override
  String searchError(String error) {
    return '搜索错误: $error';
  }

  @override
  String get searchContactsTitle => '搜索联系人';

  @override
  String get nicknameOrPhoneHint => '昵称或电话号码';

  @override
  String selectContactError(String error) {
    return '无法选择联系人: $error';
  }

  @override
  String get categoryLabel => '类别';

  @override
  String get feedbackCategoryFeatures => '功能';

  @override
  String get feedbackCategoryPerformance => '性能';

  @override
  String get feedbackCategorySecurity => '安全/隐私';

  @override
  String get feedbackCategoryNetworkSync => '同步/网络';

  @override
  String get shortDescriptionLabel => '简短描述';

  @override
  String get shortDescriptionHint => '例如: \"云端聊天备份\"';

  @override
  String get feedbackValidation => '请至少选择一个想法或填写描述';

  @override
  String get detailsOptionalLabel => '详细信息（可选）';

  @override
  String get detailsHint => '应该如何工作，现在如何工作，您希望如何？';

  @override
  String get bigFeaturesTitle => '主要功能（选择您最感兴趣的）';

  @override
  String get feedbackE2E => '端到端E2E加密（Olm/Megolm）+ 设备验证';

  @override
  String get feedbackBackup => '聊天备份（本地/云）+ 转移到新设备';

  @override
  String get feedbackThreads => '线程、反应、提及、改进的消息搜索';

  @override
  String get feedbackCalls => '语音/视频通话和快速语音房间';

  @override
  String get feedbackFolders => '聊天文件夹/类别和智能通知过滤器';

  @override
  String get feedbackBots => '机器人和集成（Webhook、GitHub/Jira、提醒）';

  @override
  String get feedbackSlowNet => '\"慢速网络\"模式 + 积极的媒体缓存';

  @override
  String get startChatTitle => '开始聊天';

  @override
  String get createRoomSubtitle => '私人或公开群组';

  @override
  String get inviteUserTitle => '邀请用户';

  @override
  String get inviteUserSubtitle => '查找用户并发送消息';

  @override
  String get joinByCodeTitle => '通过代码加入';

  @override
  String get joinByCodeSubtitle => '使用邀请码加入房间';

  @override
  String get chatsSubtitle => '私聊、群组和邀请链接集中在一处';

  @override
  String get chatsQuickStartTitle => '开始新的对话';

  @override
  String get chatsRecentTitle => '最近聊天';

  @override
  String get joinLinkHint => '粘贴邀请链接、别名或代码';

  @override
  String get fontLabel => '字体';

  @override
  String get pinCodeLabel => 'PIN码';

  @override
  String get pinCodeSubtitle => '4-6位数字保护';

  @override
  String get pinHint => 'PIN（4-6位）';

  @override
  String get pinLengthError => 'PIN必须是4-6位数字';

  @override
  String get pinSetSuccess => 'PIN已设置';

  @override
  String get cancelButton => '取消';

  @override
  String get deleteButton => '删除';

  @override
  String get closeButton => '关闭';

  @override
  String get saveButton => '保存';

  @override
  String get sendButton => '发送';

  @override
  String get copyButton => '复制';

  @override
  String get shareButton => '分享';

  @override
  String get settingsLabel => '设置';

  @override
  String get feedbackCategoryUxDesign => 'UX/设计';

  @override
  String get feedbackShareSubject => 'TwoSpace — 建议';

  @override
  String get feedbackMessageHeader => 'TwoSpace — 建议/改进';

  @override
  String feedbackVersion(String version) {
    return '版本: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return '类别: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return '简述: $title';
  }

  @override
  String get feedbackWishList => '特别希望的是:';

  @override
  String get feedbackDetailsLine => '详细信息:';

  @override
  String get circlesVisible => '圆圈已显示';

  @override
  String get circlesHidden => '圆圈已隐藏';

  @override
  String get speedSlow => '慢';

  @override
  String get speedFast => '快';

  @override
  String get advancedSettingsLabel => '高级设置';

  @override
  String get compactModeLabel => '紧凑模式';

  @override
  String get activeDeviceInfo => 'Android • 活跃';

  @override
  String stubPlaceholder(String key) {
    return '存根 — $key';
  }

  @override
  String loadMessagesError(String error) {
    return '加载消息时出错: $error';
  }

  @override
  String get pinnedUpdated => '已更新置顶';

  @override
  String editError(String error) {
    return '编辑错误: $error';
  }

  @override
  String get moreButton => '更多';

  @override
  String shareError(String error) {
    return '无法分享: $error';
  }

  @override
  String sendError(String error) {
    return '发送失败: $error';
  }

  @override
  String get voiceRecordingUnsupported => '此平台不支持语音录制';

  @override
  String get microphonePermissionRequired => '需要麦克风权限';

  @override
  String genericError(String error) {
    return '错误: $error';
  }

  @override
  String get ownersLabel => '👑 所有者';

  @override
  String get administratorsLabel => '⚡ 管理员';

  @override
  String get oneHour => '1小时';

  @override
  String get oneDay => '1天';

  @override
  String get sevenDays => '7天';

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
  String get storageMemoryTitle => '内存';

  @override
  String get storageTotalLabel => '总计';

  @override
  String get storagePhotosLabel => '照片';

  @override
  String get storageVideosLabel => '视频';

  @override
  String get storageCacheLabel => '缓存';

  @override
  String get storageAppDataLabel => '应用数据';

  @override
  String get storageCleanupTitle => '将被清理';

  @override
  String get storageCleanupSubtitle => '检查可安全删除的内容。';

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
  String get peopleTitle => '联系人';

  @override
  String get peopleSubtitle => '联系人、收藏、搜索和邀请都在一个地方';

  @override
  String get peopleQuickNewChat => '新聊天';

  @override
  String get peopleQuickInvite => '邀请';

  @override
  String get peopleQuickSync => '同步';

  @override
  String get peopleSearchHint => '按姓名、昵称或电话号码搜索';

  @override
  String get peopleSegmentAll => '全部';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => '通讯录';

  @override
  String get peopleSegmentRecent => '最近';

  @override
  String get peopleLoading => '正在加载联系人…';

  @override
  String get peopleNoPeopleTitle => '还没有联系人';

  @override
  String get peopleNoPeopleMessage => '你的收藏、最近会话和联系人会显示在这里。';

  @override
  String get peoplePermissionCardTitle => '联系人访问受限';

  @override
  String get peoplePermissionCardMessage => '允许访问联系人，以显示通讯录并更快邀请他人。';

  @override
  String get peoplePermissionCardMessageSettings => '请在系统设置中开启联系人权限，以恢复通讯录分区。';

  @override
  String get peopleFavoritesFrequentTitle => '收藏与常用';

  @override
  String get peopleRecentTitle => '最近联系人';

  @override
  String get peopleTwoSpaceTitle => 'TwoSpace 用户';

  @override
  String get peopleInviteTitle => '邀请加入 TwoSpace';

  @override
  String get peopleInviteSubtitle => '邀请此联系人加入 TwoSpace';

  @override
  String get peopleSearching => '正在搜索联系人…';

  @override
  String get peopleSearchRemoteTitle => 'TwoSpace 结果';

  @override
  String get peopleSearchLocalTitle => '最近与已保存';

  @override
  String get peopleSearchInviteTitle => '从通讯录邀请';

  @override
  String get peopleSearchEmptyTitle => '没有匹配的联系人';

  @override
  String get peopleSearchEmptyMessage => '请尝试其他姓名、昵称或电话号码。';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => '暂无更多信息';

  @override
  String get peopleInviteShareText => '加入 TwoSpace 吧，这是一个安全的聊天和通话应用。';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return '$personName，来加入 TwoSpace 吧，我们可以安全聊天和通话。';
  }

  @override
  String get peopleViewProfileAction => '查看资料';

  @override
  String get peopleRemoveFavoriteAction => '从收藏中移除';

  @override
  String get peopleAddFavoriteAction => '加入收藏';

  @override
  String get callsSubtitle => '最近通话、快速回拨以及以联系人为中心的记录';

  @override
  String get callsStartCallAction => '开始通话';

  @override
  String get callsQuickStartTitle => '立即通话';

  @override
  String get callsQuickStartSubtitle => '打开联系人，找到某人并开始安全的语音或视频通话。';

  @override
  String get callsSearchHint => '搜索通话记录';

  @override
  String get callsVideoFilter => '视频';

  @override
  String get callsTopContactsTitle => '常用联系人';

  @override
  String get callsLoadingLabel => '正在加载通话…';

  @override
  String get callsEmptyTitle => '还没有通话';

  @override
  String get callsEmptyMessage => '首次语音或视频通话后，通话记录会显示在这里。';

  @override
  String get callsEmptySearchMessage => '没有符合当前搜索或筛选条件的通话。';

  @override
  String get callsTodaySection => '今天';

  @override
  String get callsThisWeekSection => '本周';

  @override
  String get callsEarlierSection => '更早';

  @override
  String callsThreadCount(int count) {
    return '$count 次通话';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count 次未接';
  }

  @override
  String get callsMuteAction => '静音';

  @override
  String get callsSpeakerAction => '扬声器';

  @override
  String get callsCameraAction => '摄像头';

  @override
  String get callsSwitchCameraAction => '切换';

  @override
  String get callsEndAction => '结束通话';

  @override
  String get callsConnectingLabel => '连接中…';

  @override
  String get callsRingingLabel => '响铃中…';

  @override
  String get callsConnectingDetail => '正在创建安全通话会话。';

  @override
  String get callsRingingDetail => '正在等待对方接听。';

  @override
  String get callsVideoSecureDetail => '视频受到保护，并通过当前安全会话传输。';

  @override
  String get callsVoiceSecureDetail => '语音受到保护，并通过当前安全会话传输。';

  @override
  String get timestampPrecisionLabel => '消息时间精度';

  @override
  String get timestampPrecisionSubtitle => '选择在聊天内和聊天列表中显示多精细的时间戳。';

  @override
  String get timestampPrecisionMinutes => '小时和分钟';

  @override
  String get timestampPrecisionSeconds => '小时、分钟和秒';

  @override
  String get timestampPrecisionMilliseconds => '小时、分钟、秒和毫秒';

  @override
  String get startupTitle => '正在准备 TwoSpace';

  @override
  String get startupSubtitle => '正在检查安全会话并打开你的聊天。';

  @override
  String get startupFooter => '此界面只会在应用启动时显示。';

  @override
  String get startupStepEnvironment => '正在加载配置';

  @override
  String get startupStepDiagnostics => '正在启动诊断';

  @override
  String get startupStepValidation => '正在验证环境';

  @override
  String get startupStepSettings => '正在加载设置';

  @override
  String get startupStepSession => '正在恢复安全会话';

  @override
  String get startupStepLaunch => '正在启动应用';

  @override
  String get callsDemoBannerTitle => '示例，功能暂不可用';

  @override
  String get callsDemoBannerVoiceMessage => '语音通话目前仅作为界面原型展示，音频传输尚未接入。';

  @override
  String get callsDemoBannerVideoMessage =>
      '视频通话目前仅作为界面原型展示，远端视频流暂不可用，但你的本地摄像头预览可以正常工作。';

  @override
  String get callsCameraPermissionMessage => '请允许访问摄像头，以便在视频通话中显示你的本地预览。';

  @override
  String get callsCameraPermissionSettingsMessage =>
      '摄像头权限已被阻止。请打开系统设置以启用本地视频预览。';

  @override
  String get callsCameraPermissionAction => '允许摄像头';

  @override
  String get callsCameraUnavailableTitle => '摄像头不可用';

  @override
  String get callsCameraUnavailableMessage => '无法在此设备上启动本地摄像头预览。';

  @override
  String get callsCameraUnsupportedMessage => '当前平台不支持本地视频预览。';

  @override
  String get callsCameraOffMessage => '此演示通话中的摄像头预览已关闭。';

  @override
  String get callsFrontCameraLabel => '前置摄像头';

  @override
  String get callsRearCameraLabel => '后置摄像头';

  @override
  String get backgroundOptimizationDisabledTitle => '背景效果已精简';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace 检测到持续掉帧，因此关闭了较重的背景效果，以保持滚动和聊天操作流畅。';

  @override
  String get backgroundOptimizationOpenSettings => '打开外观设置';
}
