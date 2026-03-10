// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => '로딩 중...';

  @override
  String get initializing => '초기화 중...';

  @override
  String get errorGeneric => '오류가 발생했습니다';

  @override
  String get errorInitialization => '초기화 오류';

  @override
  String get errorInitializationFull => '초기화 오류. 앱을 재시작하세요.';

  @override
  String get errorNetwork => '네트워크 오류. 연결을 확인하세요.';

  @override
  String get errorAuth => '인증 오류.';

  @override
  String get errorInvalidArguments => '잘못된 인수입니다.';

  @override
  String get errorInvalidArgumentsProfile => '프로필에 대한 잘못된 인수입니다.';

  @override
  String get errorInvalidArgumentsChat => '채팅에 대한 잘못된 인수입니다.';

  @override
  String get retry => '재시도';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get send => '보내기';

  @override
  String get close => '닫기';

  @override
  String errorWithDetail(String error) {
    return '오류: $error';
  }

  @override
  String get ok => '확인';

  @override
  String get confirm => '확인';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get next => '다음';

  @override
  String get back => '뒤로';

  @override
  String get done => '완료';

  @override
  String get noData => '데이터 없음';

  @override
  String get nothingFound => '찾을 수 없음';

  @override
  String get copyAction => '복사';

  @override
  String get shareAction => '공유';

  @override
  String get textCopied => '텍스트가 복사되었습니다';

  @override
  String get onlineLabel => '온라인';

  @override
  String get offlineLabel => '오프라인';

  @override
  String get userDefault => '사용자';

  @override
  String get lessThanMinuteAgo => '1분 미만 전';

  @override
  String minutesAgo(int count) {
    return '$count분 전';
  }

  @override
  String hoursAgo(int count) {
    return '$count시간 전';
  }

  @override
  String daysAgo(int count) {
    return '$count일 전';
  }

  @override
  String get videoLabel => '동영상';

  @override
  String videoLoadError(String error) {
    return '동영상 오류: $error';
  }

  @override
  String get saveFailed => '저장에 실패했습니다';

  @override
  String get shareSheetFailed => '공유를 열 수 없습니다';

  @override
  String get speedLabel => '속도:';

  @override
  String get previewTitle => '미리보기';

  @override
  String fileDownloaded(String path) {
    return '파일 다운로드됨: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return '파일이 임시 저장됨: $path';
  }

  @override
  String get savedToGallery => '갤러리에 저장됨';

  @override
  String authorizationError(String message) {
    return '인증 오류: $message';
  }

  @override
  String get loginTitle => '로그인';

  @override
  String get welcomeBack => '환영합니다';

  @override
  String get emailOrUsernameLabel => '사용자 이름';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get loginButton => '로그인';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get noAccount => '계정이 없으신가요?';

  @override
  String get orDivider => '또는';

  @override
  String get validationEnterEmailOrUsername => '사용자 이름을 입력하세요';

  @override
  String get validationEnterPassword => '비밀번호를 입력하세요';

  @override
  String get registerTitle => '회원가입';

  @override
  String get fillAllFields => '모든 필드를 입력하세요';

  @override
  String get passwordStrengthWeak => '약함';

  @override
  String get passwordStrengthMedium => '보통';

  @override
  String get passwordStrengthGood => '좋음';

  @override
  String get passwordStrengthStrong => '강함';

  @override
  String get fullNameLabel => '전체 이름';

  @override
  String get nicknameAtLabel => '닉네임 (@사용자명)';

  @override
  String get uploadPhotoPrompt => '프로필 사진 업로드';

  @override
  String get photoLooksGreat => '멋져 보여요!';

  @override
  String get helpFriendsFind => '친구들이 당신을 찾을 수 있도록 도와주세요';

  @override
  String get setupInterfaceTitle => '인터페이스 맞춤설정';

  @override
  String get colorThemeLabel => '색상 테마';

  @override
  String get validationEnterEmail => '이메일을 입력하세요';

  @override
  String get validationInvalidEmail => '이메일 주소가 유효하지 않습니다';

  @override
  String get validationPasswordTooShort => '비밀번호가 너무 짧습니다';

  @override
  String get backToLogin => '로그인';

  @override
  String get finishButton => '완료';

  @override
  String filePickError(String error) {
    return '파일 선택 오류: $error';
  }

  @override
  String get chatsTitle => '채팅';

  @override
  String get noChats => '채팅 없음';

  @override
  String get noMessages => '（메시지 없음）';

  @override
  String get newChat => '새 채팅';

  @override
  String get messageInputHint => '메시지 입력...';

  @override
  String get replyAction => '답장';

  @override
  String get editShort => '편집';

  @override
  String get pinAction => '고정';

  @override
  String get moreReactions => '더 보기';

  @override
  String get replyDialogTitle => '답장';

  @override
  String get replyHint => '답장 텍스트';

  @override
  String get editMessageTitle => '메시지 편집';

  @override
  String get editMessageHint => '새 텍스트';

  @override
  String get deleteMessageTitle => '메시지를 삭제하시겠습니까?';

  @override
  String get pinsUpdated => '고정이 업데이트되었습니다';

  @override
  String get messageEdited => '메시지가 편집되었습니다';

  @override
  String get fileSent => '파일이 전송되었습니다';

  @override
  String get voiceNotSupported => '이 플랫폼에서는 음성 녹음이 지원되지 않습니다';

  @override
  String get microphonePermRequired => '마이크 권한이 필요합니다';

  @override
  String get recordingError => '녹음 오류';

  @override
  String sendFailedError(String error) {
    return '전송 실패: $error';
  }

  @override
  String attachmentSendError(String error) {
    return '첨부 파일 오류: $error';
  }

  @override
  String shareFailedError(String error) {
    return '공유 실패: $error';
  }

  @override
  String replyError(String error) {
    return '답장 오류: $error';
  }

  @override
  String pinError(String error) {
    return '고정 오류: $error';
  }

  @override
  String deleteError(String error) {
    return '삭제 오류: $error';
  }

  @override
  String editMessageError(String error) {
    return '편집 오류: $error';
  }

  @override
  String get userTyping => '사용자가 입력 중...';

  @override
  String get statusOnline => '온라인';

  @override
  String get statusLastSeenRecently => '최근에 온라인';

  @override
  String get settingsTitle => '설정';

  @override
  String get appearanceSection => '외관';

  @override
  String get themeLabel => '테마';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get customizationLabel => '맞춤설정';

  @override
  String get customizationSubtitle => '색상, 폰트 및 UI 효과';

  @override
  String get notificationsSection => '알림';

  @override
  String get notificationsLabel => '알림';

  @override
  String get soundLabel => '소리';

  @override
  String get accountSection => '계정';

  @override
  String get profileLabel => '프로필';

  @override
  String get profileSubtitle => '프로필 정보 편집';

  @override
  String get accountSettingsLabel => '계정 설정';

  @override
  String get accountSettingsSubtitle => '비밀번호, 보안, 2FA';

  @override
  String get privacyLabel => '개인정보';

  @override
  String get privacySubtitle => '개인정보 관리';

  @override
  String get generalSection => '일반';

  @override
  String get languageLabel => '언어';

  @override
  String get textSizeLabel => '텍스트 크기';

  @override
  String get sendByEnterLabel => 'Enter로 전송';

  @override
  String get sendByEnterSubtitle => 'Shift+Enter로 줄 바꿈';

  @override
  String get dataStorageSection => '데이터 및 저장소';

  @override
  String get autoDownloadLabel => '미디어 자동 다운로드';

  @override
  String get autoDownloadSubtitle => '사진과 동영상 자동 다운로드';

  @override
  String get storageManagementLabel => '저장소 관리';

  @override
  String get storageManagementSubtitle => '캐시 및 데이터 삭제';

  @override
  String get clearCacheTitle => '캐시 삭제';

  @override
  String get clearCacheContent => '캐시된 데이터를 삭제하시겠습니까?';

  @override
  String get cacheCleared => '캐시가 삭제되었습니다';

  @override
  String get developmentSection => '개발';

  @override
  String get devMenuSubtitle => '플로팅 디버그 버튼';

  @override
  String get aboutSection => '정보';

  @override
  String get suggestImprovementLabel => '개선 제안';

  @override
  String get suggestImprovementSubtitle => '아이디어 및 새 기능 요청';

  @override
  String get dangerZoneSection => '위험 구역';

  @override
  String get logoutLabel => '로그아웃';

  @override
  String get logoutSubtitle => '이 기기에서 로그아웃';

  @override
  String get logoutDialogTitle => '로그아웃';

  @override
  String get logoutDialogContent => '정말 로그아웃하시겠습니까?';

  @override
  String get logoutAction => '로그아웃';

  @override
  String get languageRussian => '러시아어';

  @override
  String get languageUkrainian => '우크라이나어';

  @override
  String get clientDescription => 'Flutter/Dart로 만든 TwoSpace 클라이언트';

  @override
  String errorLogout(String error) {
    return '오류: $error';
  }

  @override
  String get accountSettingsTitle => '계정 설정';

  @override
  String get securitySection => '보안';

  @override
  String get twoFactorLabel => '2단계 인증';

  @override
  String get twoFactorSubtitle => '계정 추가 보호';

  @override
  String get biometricLabel => '생체 인증';

  @override
  String get biometricSubtitle => '지문으로 로그인';

  @override
  String get activeSessionsLabel => '활성 세션';

  @override
  String get activeSessionsSubtitle => '기기 관리';

  @override
  String get currentDevice => '현재 기기';

  @override
  String get changePasswordSection => '비밀번호 변경';

  @override
  String get currentPasswordLabel => '현재 비밀번호';

  @override
  String get newPasswordLabel => '새 비밀번호';

  @override
  String get confirmPasswordLabel => '비밀번호 확인';

  @override
  String get minPasswordHelper => '최소 8자';

  @override
  String get changePasswordButton => '비밀번호 변경';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get passwordTooShort => '비밀번호는 최소 8자여야 합니다';

  @override
  String get passwordChangeSuccess => '비밀번호가 변경되었습니다';

  @override
  String get contactDataSection => '연락처 데이터';

  @override
  String get emailLabel => '이메일';

  @override
  String get phoneLabel => '전화';

  @override
  String get deleteAccountLabel => '계정 삭제';

  @override
  String get deleteAccountSubtitle => '되돌릴 수 없는 작업';

  @override
  String get deleteAccountTitle => '계정 삭제';

  @override
  String get deleteAccountContent => '계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteFeatureLater => '계정 삭제 기능은 나중에 제공될 예정입니다';

  @override
  String get profileTitle => '프로필';

  @override
  String get saveTooltip => '저장';

  @override
  String get editTooltip => '편집';

  @override
  String get writeMessageButton => '메시지';

  @override
  String get callButton => '통화';

  @override
  String get aboutField => '자기 소개';

  @override
  String get nicknameField => '닉네임';

  @override
  String get locationField => '위치';

  @override
  String get birthdayField => '생일';

  @override
  String get nameField => '이름';

  @override
  String get avatarUploadLater => '아바타 업로드는 나중에 추가될 예정입니다';

  @override
  String get profileSaved => '프로필이 저장되었습니다';

  @override
  String createChatError(String error) {
    return '채팅을 만들 수 없습니다: $error';
  }

  @override
  String get privacyTitle => '개인정보';

  @override
  String get hideFromSearch => '검색에서 숨기기';

  @override
  String get hideFromSearchSubtitle => '검색 결과에 표시하지 않음';

  @override
  String get hideLastSeen => '마지막 접속 시간 숨기기';

  @override
  String get hideLastSeenSubtitle => '다른 사람들에게 온라인 시간이 표시되지 않습니다';

  @override
  String get sessionExpiry => '세션 만료';

  @override
  String sessionExpirySubtitle(int days) {
    return '이 기기의 자동 로그인: $days일';
  }

  @override
  String get sessionExpiryDaysTitle => '세션 만료 (일)';

  @override
  String get sessionExpiryDaysContent => '일 수를 선택하세요 (최소: 7, 최대: 365).';

  @override
  String get daysLabel => '일';

  @override
  String get enterDaysError => '7에서 365 사이의 숫자를 입력하세요';

  @override
  String sessionExpirySet(int days) {
    return '세션 만료: $days일';
  }

  @override
  String get changeEmailLabel => '이메일 변경';

  @override
  String get changeEmailSubtitle => '이메일 주소 업데이트';

  @override
  String get twoFactorPrivacySubtitle => '고급 보호 활성화 또는 비활성화';

  @override
  String get changePhoneLabel => '전화번호 변경';

  @override
  String get changePhoneSubtitle => '전화번호 업데이트';

  @override
  String updatePrivacyError(String error) {
    return '개인정보를 업데이트할 수 없습니다: $error';
  }

  @override
  String updateSettingError(String error) {
    return '설정을 업데이트할 수 없습니다: $error';
  }

  @override
  String get contactsTitle => '연락처';

  @override
  String get searchContactsHint => '연락처 검색...';

  @override
  String get contactsAccessTitle => '연락처 접근';

  @override
  String get contactsPermDeniedPermanent => '권한이 영구적으로 거부되었습니다. 설정을 여세요.';

  @override
  String get contactsPermRequired => '연락처 권한이 필요합니다.';

  @override
  String get openSettingsButton => '설정 열기';

  @override
  String get requestPermissionButton => '권한 요청';

  @override
  String get noContacts => '연락처를 찾을 수 없습니다';

  @override
  String get callAction => '통화';

  @override
  String get writeMessageAction => '메시지';

  @override
  String callNotification(String number) {
    return '통화: $number';
  }

  @override
  String messageNotification(String name) {
    return '메시지 수신자: $name';
  }

  @override
  String get callsTitle => '통화';

  @override
  String get searchByNameHint => '이름으로 검색...';

  @override
  String get allFilter => '전체';

  @override
  String get incomingFilter => '수신';

  @override
  String get outgoingFilter => '발신';

  @override
  String get missedFilter => '부재중';

  @override
  String get noCallsFound => '통화 없음';

  @override
  String get yesterdayLabel => '어제';

  @override
  String get incomingCall => '수신';

  @override
  String get outgoingCall => '발신';

  @override
  String get missedCall => '부재중';

  @override
  String get videoCallLabel => '화상 통화';

  @override
  String get voiceCallLabel => '음성 통화';

  @override
  String get sendMessageCallAction => '메시지';

  @override
  String get createRoomTitle => '방 만들기';

  @override
  String get createButton => '만들기';

  @override
  String get roomNameLabel => '방 이름';

  @override
  String get roomNameHint => '예: 프로젝트 이름';

  @override
  String get roomTopicLabel => '주제 (선택사항)';

  @override
  String get roomTopicHint => '이 방은 무엇에 관한 것입니까?';

  @override
  String get roomVisibilityLabel => '방 공개 설정';

  @override
  String get privateRoomOption => '비공개 방';

  @override
  String get privateRoomSubtitle => '초대된 사용자만 참가 가능';

  @override
  String get publicRoomOption => '공개 방';

  @override
  String get publicRoomSubtitle => '누구나 참가 가능';

  @override
  String get showHistoryLabel => '메시지 기록 표시';

  @override
  String get showHistorySubtitle => '새 멤버가 이전 메시지를 볼 수 있습니다';

  @override
  String get enterRoomNameError => '방 이름을 입력하세요';

  @override
  String get roomCreatedSuccess => '방이 성공적으로 만들어졌습니다!';

  @override
  String imagePickError(String error) {
    return '이미지 선택 오류: $error';
  }

  @override
  String get groupInfoTab => '정보';

  @override
  String get groupMembersTab => '멤버';

  @override
  String get groupRolesTab => '역할';

  @override
  String get groupBansTab => '차단';

  @override
  String get groupDeleteTab => '삭제';

  @override
  String membersCount(int count) {
    return '멤버: $count';
  }

  @override
  String get messageHistoryToggle => '메시지 기록';

  @override
  String get showHistoryToggleLabel => '기록 표시';

  @override
  String get settingSaved => '설정이 저장되었습니다';

  @override
  String get backgroundColorLabel => '배경 색상';

  @override
  String get noMembers => '멤버 없음';

  @override
  String get roleAction => '역할';

  @override
  String get freezeAction => '동결';

  @override
  String get banAction => '차단';

  @override
  String get kickAction => '추방';

  @override
  String get noBannedUsers => '차단된 사용자 없음';

  @override
  String get bannedLabel => '차단됨';

  @override
  String get userUnbanned => '사용자 차단이 해제되었습니다';

  @override
  String get deleteGroupLabel => '그룹 삭제';

  @override
  String get deleteGroupWarning => '이 작업은 되돌릴 수 없습니다. 그룹이 영구적으로 삭제됩니다.';

  @override
  String get confirmDeleteTitle => '삭제 확인';

  @override
  String get confirmDeleteContent => '정말 하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get changeRoleTitle => '역할 변경';

  @override
  String get adminRole => '관리자';

  @override
  String get memberRole => '멤버';

  @override
  String get freezeUserTitle => '사용자 동결';

  @override
  String get userBanned => '사용자가 차단되었습니다';

  @override
  String get userKicked => '사용자가 추방되었습니다';

  @override
  String get groupDeleted => '그룹이 삭제되었습니다';

  @override
  String loadError(String error) {
    return '로드 오류: $error';
  }

  @override
  String get publicLabel => '공개';

  @override
  String get privateLabel => '비공개';

  @override
  String get noDescription => '설명 없음';

  @override
  String get membersLabel => '멤버';

  @override
  String get generalLabel => '일반';

  @override
  String get newChatTitle => '새 채팅';

  @override
  String get directChatTab => '직접';

  @override
  String get groupChatTab => '그룹';

  @override
  String get startDirectChatTitle => '직접 채팅 시작';

  @override
  String get contactIdDescription => '사용자 이름 또는 Aegis ID를 입력하세요';

  @override
  String get contactIdLabel => '사용자 이름 또는 Aegis ID';

  @override
  String get startChatButton => '채팅 시작';

  @override
  String get hintCardTitle => '힌트';

  @override
  String get contactIdExplanation => '사용자 이름 또는 숫자형 Aegis 사용자 ID를 사용할 수 있습니다';

  @override
  String get enterUserIdError => '사용자 ID를 입력하세요';

  @override
  String get createNewRoomTitle => '새 방 만들기';

  @override
  String get descriptionOptionalLabel => '설명 (선택사항)';

  @override
  String get privateGroupLabel => '비공개 그룹';

  @override
  String get privateGroupSubtitle => '초대된 사용자만 참가 가능';

  @override
  String get createRoomButton => '방 만들기';

  @override
  String get customizationTitle => '맞춤설정';

  @override
  String get colorsTab => '색상';

  @override
  String get fontsTab => '폰트';

  @override
  String get effectsTab => '효과';

  @override
  String get selectColorTheme => '색상 테마 선택';

  @override
  String get themeAppliesEverywhere => '선택한 테마가 앱 전체에 적용됩니다';

  @override
  String get fontSettingsTitle => '폰트 설정';

  @override
  String get selectFontFamily => '폰트 패밀리 선택';

  @override
  String get appFontLabel => '앱 폰트';

  @override
  String get fontWeightLabel => '폰트 굵기';

  @override
  String get fontPreview => '미리보기: 샘플 텍스트';

  @override
  String get compactMode => '간격 및 크기 줄이기';

  @override
  String get enableCircles => '원 활성화';

  @override
  String get circlesDesc => '배경의 애니메이션 원';

  @override
  String get floatingCirclesLabel => '플로팅 원';

  @override
  String get reactOnTilt => '기울기에 반응';

  @override
  String get parallaxEffect => '시차 효과';

  @override
  String get circlesSpeedLabel => '움직임 속도';

  @override
  String get staticMotion => '정적';

  @override
  String get brightnessLabel => '밝기';

  @override
  String get dimOpacity => '어둡게';

  @override
  String get brightOpacity => '밝게';

  @override
  String get performanceLabel => '성능';

  @override
  String get currentSpeedPrefix => '현재: ';

  @override
  String get speedPrefix => '속도:';

  @override
  String get advancedSearchTitle => '고급 검색';

  @override
  String get searchQueryHint => '쿼리 입력...';

  @override
  String get searchTypeLabel => '검색 유형';

  @override
  String get searchTypeAll => '전체';

  @override
  String get searchTypeMessages => '메시지';

  @override
  String get searchTypeMedia => '미디어';

  @override
  String get searchTypeUsers => '사용자';

  @override
  String get periodLabel => '기간';

  @override
  String get fromDate => '시작';

  @override
  String get toDate => '종료';

  @override
  String get searchButton => '검색';

  @override
  String resultsCount(int count) {
    return '결과 ($count)';
  }

  @override
  String get noResultsFound => '결과를 찾을 수 없습니다';

  @override
  String get forgotPasswordTitle => '비밀번호 재설정';

  @override
  String get forgotPasswordDescription => '재설정 링크를 받으려면 이메일을 입력하세요';

  @override
  String get sendResetButton => '보내기';

  @override
  String get forgotPasswordUnavailable => '비밀번호 복구를 사용할 수 없습니다';

  @override
  String get changeEmailTitle => '이메일 변경';

  @override
  String get changeEmailDescription => '새 이메일 주소를 입력하세요';

  @override
  String get currentPrefix => '현재: ';

  @override
  String get newEmailLabel => '새 이메일';

  @override
  String get changeEmailButton => '이메일 변경';

  @override
  String changeEmailError(String error) {
    return '이메일을 변경할 수 없습니다: $error';
  }

  @override
  String get changePhoneTitle => '전화번호 변경';

  @override
  String get changePhoneDescription => '새 전화번호와 현재 비밀번호를 입력하세요.';

  @override
  String get newPhoneLabel => '새 번호 (+82...)';

  @override
  String get currentPasswordOptional => '현재 비밀번호 (필요한 경우)';

  @override
  String get changePhoneButton => '번호 변경';

  @override
  String get phoneCannotBeChanged => '전화번호를 변경할 수 없습니다';

  @override
  String get emailCannotBeChanged => '이메일을 변경할 수 없습니다';

  @override
  String changePhoneError(String error) {
    return '번호를 변경할 수 없습니다: $error';
  }

  @override
  String get confirmCodeTitle => '코드 확인';

  @override
  String codeSentTo(String phone) {
    return '$phone으로 코드를 보냈습니다';
  }

  @override
  String get enterCodeHint => '코드 입력';

  @override
  String get confirmButton => '확인';

  @override
  String resendCountdown(int seconds) {
    return '$seconds초 후 재전송';
  }

  @override
  String get resendCodeButton => '코드 재전송';

  @override
  String get biometricSetupTitle => '보안';

  @override
  String get authMethodsLabel => '인증 방법';

  @override
  String get biometricAuthLabel => '생체 인증';

  @override
  String get biometricAuthSubtitle => '지문 또는 Face ID';

  @override
  String get biometricEnabledLabel => '생체 인증 활성화됨';

  @override
  String get aboutSecurityLabel => '보안 정보';

  @override
  String get aboutSecurityContent => '편리한 인증 방법을 선택하세요.';

  @override
  String get setPinCode => 'PIN 코드 설정';

  @override
  String get updateAvailableTitle => '업데이트 가능';

  @override
  String get whatsNewLabel => '새소식';

  @override
  String get noUpdateDescription => '설명 없음';

  @override
  String downloadingProgress(int percent) {
    return '다운로드 중... $percent%';
  }

  @override
  String get checkingIntegrity => '무결성 확인 중...';

  @override
  String get requestingInstall => '설치 요청 중...';

  @override
  String get updateMandatory => '필수 업데이트';

  @override
  String get laterButton => '나중에';

  @override
  String get downloadingLabel => '다운로드 중...';

  @override
  String get installingLabel => '설치 중...';

  @override
  String get updateButton => '업데이트';

  @override
  String get downloadFailed => '업데이트를 다운로드할 수 없습니다';

  @override
  String get integrityCheckFailed => '다운로드한 파일이 무결성 확인(sha256)을 통과하지 못했습니다';

  @override
  String get installPermissionTitle => '설치 권한';

  @override
  String get installPermissionContent => '알 수 없는 소스에서 설치를 허용하세요.';

  @override
  String get installPermissionRequired => '설치 권한이 필요합니다';

  @override
  String get installFailed => '설치에 실패했습니다';

  @override
  String get ssoFeatureRequired => '이 기능에는 webview_flutter 구성이 필요합니다';

  @override
  String ssoLoginVia(String idpId) {
    return '$idpId를 통한 SSO 로그인';
  }

  @override
  String get forwardMessageTitle => '메시지 전달';

  @override
  String get searchChatHint => '채팅 검색...';

  @override
  String forwardButton(int count) {
    return '전달 ($count)';
  }

  @override
  String get roomAvatarUpdated => '방 아바타가 업데이트되었습니다';

  @override
  String roomAvatarUploadError(String error) {
    return '아바타 업로드 오류: $error';
  }

  @override
  String get roomSettingsSaved => '방 설정이 저장되었습니다';

  @override
  String roomSettingsSaveError(String error) {
    return '저장 오류: $error';
  }

  @override
  String get uploadAvatarButton => '아바타 업로드';

  @override
  String loadMembersError(String error) {
    return '멤버 로드 오류: $error';
  }

  @override
  String get leaveRoomTitle => '방을 나가시겠습니까?';

  @override
  String get leaveRoomContent => '다시 초대받지 않으면 돌아올 수 없습니다.';

  @override
  String get leaveAction => '나가기';

  @override
  String get leftRoom => '방을 나갔습니다';

  @override
  String leaveRoomError(String error) {
    return '나가기 오류: $error';
  }

  @override
  String get reportNotImplemented => '신고 기능이 아직 구현되지 않았습니다';

  @override
  String get inviteAction => '초대';

  @override
  String get threadsLabel => '스레드';

  @override
  String get pinnedLabel => '고정됨';

  @override
  String get filesLabel => '파일';

  @override
  String get mediaLabel => '미디어';

  @override
  String get extensionsLabel => '확장';

  @override
  String get copyLinkAction => '링크 복사';

  @override
  String get pollsLabel => '투표';

  @override
  String get exportChatAction => '채팅 내보내기';

  @override
  String get reportAction => '신고';

  @override
  String get leaveRoomAction => '방 나가기';

  @override
  String roomTitle(String name) {
    return '방 — $name';
  }

  @override
  String get roomSettingsLabel => '방 설정';

  @override
  String authError(String error) {
    return '인증 오류: $error';
  }

  @override
  String get loginRequired => '로그인 필요';

  @override
  String get loginRequiredContent => '연락처를 검색하려면 로그인해야 합니다. 로그인하시겠습니까?';

  @override
  String get loginAction => '로그인';

  @override
  String searchError(String error) {
    return '검색 오류: $error';
  }

  @override
  String get searchContactsTitle => '연락처 검색';

  @override
  String get nicknameOrPhoneHint => '닉네임 또는 전화번호';

  @override
  String selectContactError(String error) {
    return '연락처를 선택할 수 없습니다: $error';
  }

  @override
  String get categoryLabel => '카테고리';

  @override
  String get feedbackCategoryFeatures => '기능';

  @override
  String get feedbackCategoryPerformance => '성능';

  @override
  String get feedbackCategorySecurity => '보안/개인정보';

  @override
  String get feedbackCategoryNetworkSync => '동기화/네트워크';

  @override
  String get shortDescriptionLabel => '간단한 설명';

  @override
  String get shortDescriptionHint => '예: \"클라우드에서 채팅 백업\"';

  @override
  String get feedbackValidation => '최소 하나의 아이디어를 선택하거나 설명을 입력하세요';

  @override
  String get detailsOptionalLabel => '세부 정보 (선택사항)';

  @override
  String get detailsHint => '무엇이 작동해야 하는지, 현재 어떻게 작동하는지, 어떻게 원하는지?';

  @override
  String get bigFeaturesTitle => '주요 기능 (가장 관심 있는 항목 선택)';

  @override
  String get feedbackE2E => '종단 간 E2E 암호화 (Olm/Megolm) + 기기 확인';

  @override
  String get feedbackBackup => '채팅 백업 (로컬/클라우드) + 새 기기로 이전';

  @override
  String get feedbackThreads => '스레드, 리액션, 멘션, 개선된 메시지 검색';

  @override
  String get feedbackCalls => '음성/화상 통화 및 빠른 음성 방';

  @override
  String get feedbackFolders => '채팅 폴더/카테고리 및 스마트 알림 필터';

  @override
  String get feedbackBots => '봇 및 통합 (웹훅, GitHub/Jira, 알림)';

  @override
  String get feedbackSlowNet => '\"느린 인터넷\" 모드 + 공격적인 미디어 캐싱';

  @override
  String get startChatTitle => '채팅 시작';

  @override
  String get createRoomSubtitle => '비공개 또는 공개 그룹';

  @override
  String get inviteUserTitle => '사용자 초대';

  @override
  String get inviteUserSubtitle => '사용자 찾기 및 메시지 보내기';

  @override
  String get joinByCodeTitle => '코드로 참가';

  @override
  String get joinByCodeSubtitle => '초대 코드로 방에 참가';

  @override
  String get fontLabel => '폰트';

  @override
  String get pinCodeLabel => 'PIN 코드';

  @override
  String get pinCodeSubtitle => '보호를 위한 4-6자리';

  @override
  String get pinHint => 'PIN(4-6자리)';

  @override
  String get pinLengthError => 'PIN은 4-6자리여야 합니다';

  @override
  String get pinSetSuccess => 'PIN이 설정되었습니다';

  @override
  String get cancelButton => '취소';

  @override
  String get deleteButton => '삭제';

  @override
  String get closeButton => '닫기';

  @override
  String get saveButton => '저장';

  @override
  String get sendButton => '전송';

  @override
  String get copyButton => '복사';

  @override
  String get shareButton => '공유';

  @override
  String get settingsLabel => '설정';

  @override
  String get feedbackCategoryUxDesign => 'UX/디자인';

  @override
  String get feedbackShareSubject => 'TwoSpace — 제안';

  @override
  String get feedbackMessageHeader => 'TwoSpace — 제안/개선';

  @override
  String feedbackVersion(String version) {
    return '버전: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return '카테고리: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return '요약: $title';
  }

  @override
  String get feedbackWishList => '특히 훌륭할 것:';

  @override
  String get feedbackDetailsLine => '세부 사항:';

  @override
  String get circlesVisible => '서클 표시';

  @override
  String get circlesHidden => '서클 숨김';

  @override
  String get speedSlow => '느림';

  @override
  String get speedFast => '빠름';

  @override
  String get advancedSettingsLabel => '고급 설정';

  @override
  String get compactModeLabel => '컴팩트 모드';

  @override
  String get activeDeviceInfo => 'Android • 활성';

  @override
  String stubPlaceholder(String key) {
    return '스텁 — $key';
  }

  @override
  String loadMessagesError(String error) {
    return '메시지 로딩 오류: $error';
  }

  @override
  String get pinnedUpdated => '고정 항목 업데이트됨';

  @override
  String editError(String error) {
    return '편집 오류: $error';
  }

  @override
  String get moreButton => '더보기';

  @override
  String shareError(String error) {
    return '공유할 수 없습니다: $error';
  }

  @override
  String sendError(String error) {
    return '전송 오류: $error';
  }

  @override
  String get voiceRecordingUnsupported => '이 플랫폼에서는 음성 녹음이 지원되지 않습니다';

  @override
  String get microphonePermissionRequired => '마이크 권한이 필요합니다';

  @override
  String genericError(String error) {
    return '오류: $error';
  }

  @override
  String get ownersLabel => '👑 소유자';

  @override
  String get administratorsLabel => '⚡ 관리자';

  @override
  String get oneHour => '1시간';

  @override
  String get oneDay => '1일';

  @override
  String get sevenDays => '7일';

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
  String get peopleTitle => '사람들';

  @override
  String get peopleSubtitle => '연락처, 즐겨찾기, 검색, 초대를 한곳에서';

  @override
  String get peopleQuickNewChat => '새 채팅';

  @override
  String get peopleQuickInvite => '초대';

  @override
  String get peopleQuickSync => '동기화';

  @override
  String get peopleSearchHint => '이름, 닉네임 또는 전화번호로 검색';

  @override
  String get peopleSegmentAll => '전체';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => '주소록';

  @override
  String get peopleSegmentRecent => '최근';

  @override
  String get peopleLoading => '사람을 불러오는 중…';

  @override
  String get peopleNoPeopleTitle => '아직 사람이 없습니다';

  @override
  String get peopleNoPeopleMessage => '즐겨찾기, 최근 대화, 연락처가 여기에 표시됩니다.';

  @override
  String get peoplePermissionCardTitle => '연락처 접근이 제한됨';

  @override
  String get peoplePermissionCardMessage =>
      '주소록을 표시하고 더 빠르게 초대하려면 연락처 접근을 허용하세요.';

  @override
  String get peoplePermissionCardMessageSettings =>
      '주소록 섹션을 복원하려면 시스템 설정에서 연락처 접근을 활성화하세요.';

  @override
  String get peopleFavoritesFrequentTitle => '즐겨찾기 및 자주 연락하는 사람';

  @override
  String get peopleRecentTitle => '최근 사람';

  @override
  String get peopleTwoSpaceTitle => 'TwoSpace 사용자';

  @override
  String get peopleInviteTitle => 'TwoSpace로 초대';

  @override
  String get peopleInviteSubtitle => '이 연락처를 TwoSpace로 초대';

  @override
  String get peopleSearching => '사람 검색 중…';

  @override
  String get peopleSearchRemoteTitle => 'TwoSpace 결과';

  @override
  String get peopleSearchLocalTitle => '최근 및 저장됨';

  @override
  String get peopleSearchInviteTitle => '주소록에서 초대';

  @override
  String get peopleSearchEmptyTitle => '일치하는 사람이 없습니다';

  @override
  String get peopleSearchEmptyMessage => '다른 이름, 닉네임 또는 전화번호를 시도해 보세요.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => '추가 정보가 아직 없습니다';

  @override
  String get peopleInviteShareText => 'TwoSpace에 함께해요. 채팅과 통화를 위한 안전한 메신저입니다.';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return '$personName님, TwoSpace에 함께해요. 안전하게 채팅하고 통화할 수 있어요.';
  }

  @override
  String get peopleViewProfileAction => '프로필 보기';

  @override
  String get peopleRemoveFavoriteAction => '즐겨찾기에서 제거';

  @override
  String get peopleAddFavoriteAction => '즐겨찾기에 추가';

  @override
  String get callsSubtitle => '최근 통화, 빠른 재통화, 사람 중심의 기록';

  @override
  String get callsStartCallAction => '통화 시작';

  @override
  String get callsQuickStartTitle => '지금 통화';

  @override
  String get callsQuickStartSubtitle =>
      '사람 탭을 열고 상대를 찾아 안전한 음성 또는 영상 통화를 시작하세요.';

  @override
  String get callsSearchHint => '통화 기록 검색';

  @override
  String get callsVideoFilter => '영상';

  @override
  String get callsTopContactsTitle => '자주 연락하는 사람';

  @override
  String get callsLoadingLabel => '통화 불러오는 중…';

  @override
  String get callsEmptyTitle => '아직 통화가 없습니다';

  @override
  String get callsEmptyMessage => '첫 음성 또는 영상 통화 후 통화 기록이 여기에 표시됩니다.';

  @override
  String get callsEmptySearchMessage => '현재 검색어나 필터와 일치하는 통화가 없습니다.';

  @override
  String get callsTodaySection => '오늘';

  @override
  String get callsThisWeekSection => '이번 주';

  @override
  String get callsEarlierSection => '이전';

  @override
  String callsThreadCount(int count) {
    return '통화 $count회';
  }

  @override
  String callsMissedSummary(int count) {
    return '부재중 $count회';
  }

  @override
  String get callsMuteAction => '음소거';

  @override
  String get callsSpeakerAction => '스피커';

  @override
  String get callsCameraAction => '카메라';

  @override
  String get callsSwitchCameraAction => '전환';

  @override
  String get callsEndAction => '통화 종료';

  @override
  String get callsConnectingLabel => '연결 중…';

  @override
  String get callsRingingLabel => '벨 울리는 중…';

  @override
  String get callsConnectingDetail => '보안 통화 세션을 생성하는 중입니다.';

  @override
  String get callsRingingDetail => '상대방이 응답하기를 기다리는 중입니다.';

  @override
  String get callsVideoSecureDetail => '영상은 보호되며 현재 보안 세션을 통해 전송됩니다.';

  @override
  String get callsVoiceSecureDetail => '음성은 보호되며 현재 보안 세션을 통해 전송됩니다.';

  @override
  String get timestampPrecisionLabel => '메시지 시간 정밀도';

  @override
  String get timestampPrecisionSubtitle =>
      '채팅 내부와 채팅 목록에서 시간을 얼마나 자세히 표시할지 선택하세요.';

  @override
  String get timestampPrecisionMinutes => '시와 분';

  @override
  String get timestampPrecisionSeconds => '시, 분, 초';

  @override
  String get timestampPrecisionMilliseconds => '시, 분, 초, 밀리초';

  @override
  String get startupTitle => 'TwoSpace 준비 중';

  @override
  String get startupSubtitle => '보안 세션을 확인하고 채팅을 열고 있습니다.';

  @override
  String get startupFooter => '이 화면은 앱 시작 중에만 표시됩니다.';

  @override
  String get startupStepEnvironment => '구성을 불러오는 중';

  @override
  String get startupStepDiagnostics => '진단을 시작하는 중';

  @override
  String get startupStepValidation => '환경을 확인하는 중';

  @override
  String get startupStepSettings => '설정을 불러오는 중';

  @override
  String get startupStepSession => '보안 세션을 복원하는 중';

  @override
  String get startupStepLaunch => '앱을 시작하는 중';

  @override
  String get callsDemoBannerTitle => '예시, 동작하지 않는 기능';

  @override
  String get callsDemoBannerVoiceMessage =>
      '음성 통화는 현재 시각적 프로토타입으로만 표시됩니다. 오디오 전송은 아직 연결되지 않았습니다.';

  @override
  String get callsDemoBannerVideoMessage =>
      '영상 통화는 현재 시각적 프로토타입으로만 표시됩니다. 원격 영상은 아직 사용할 수 없지만, 내 로컬 카메라 미리보기는 동작합니다.';

  @override
  String get callsCameraPermissionMessage =>
      '영상 통화 중 내 로컬 미리보기를 표시하려면 카메라 접근을 허용하세요.';

  @override
  String get callsCameraPermissionSettingsMessage =>
      '카메라 접근이 차단되었습니다. 시스템 설정을 열어 로컬 영상 미리보기를 활성화하세요.';

  @override
  String get callsCameraPermissionAction => '카메라 허용';

  @override
  String get callsCameraUnavailableTitle => '카메라를 사용할 수 없음';

  @override
  String get callsCameraUnavailableMessage => '이 기기에서 로컬 카메라 미리보기를 시작할 수 없습니다.';

  @override
  String get callsCameraUnsupportedMessage => '이 플랫폼은 로컬 영상 미리보기를 지원하지 않습니다.';

  @override
  String get callsCameraOffMessage => '이 데모 통화에서는 카메라 미리보기가 꺼져 있습니다.';

  @override
  String get callsFrontCameraLabel => '전면 카메라';

  @override
  String get callsRearCameraLabel => '후면 카메라';
}
