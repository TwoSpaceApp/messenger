// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'TwoSpace';

  @override
  String get loading => 'Загрузка...';

  @override
  String get initializing => 'Инициализация...';

  @override
  String get errorGeneric => 'Произошла ошибка';

  @override
  String get errorInitialization => 'Ошибка инициализации';

  @override
  String get errorInitializationFull =>
      'Ошибка инициализации. Пожалуйста, перезапустите приложение.';

  @override
  String get errorNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get errorAuth => 'Ошибка аутентификации.';

  @override
  String get errorInvalidArguments => 'Неверные аргументы.';

  @override
  String get errorInvalidArgumentsProfile => 'Неверные аргументы для профиля.';

  @override
  String get errorInvalidArgumentsChat => 'Неверные аргументы для чата.';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get send => 'Отправить';

  @override
  String get close => 'Закрыть';

  @override
  String errorWithDetail(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get ok => 'ОК';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get done => 'Готово';

  @override
  String get noData => 'Нет данных';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get copyAction => 'Копировать';

  @override
  String get shareAction => 'Поделиться';

  @override
  String get textCopied => 'Текст скопирован';

  @override
  String get onlineLabel => 'Онлайн';

  @override
  String get offlineLabel => 'Оффлайн';

  @override
  String get userDefault => 'Пользователь';

  @override
  String get lessThanMinuteAgo => 'меньше минуты назад';

  @override
  String minutesAgo(int count) {
    return '$count мин. назад';
  }

  @override
  String hoursAgo(int count) {
    return '$count ч. назад';
  }

  @override
  String daysAgo(int count) {
    return '$count д. назад';
  }

  @override
  String get videoLabel => 'Видео';

  @override
  String videoLoadError(String error) {
    return 'Ошибка загрузки видео: $error';
  }

  @override
  String get saveFailed => 'Не удалось сохранить';

  @override
  String get shareSheetFailed => 'Не удалось открыть лист обмена';

  @override
  String get speedLabel => 'Скорость:';

  @override
  String get previewTitle => 'Просмотр';

  @override
  String fileDownloaded(String path) {
    return 'Файл загружен: $path';
  }

  @override
  String fileSavedTemp(String path) {
    return 'Файл сохранён временно: $path';
  }

  @override
  String get savedToGallery => 'Сохранено в галерею';

  @override
  String authorizationError(String message) {
    return 'Ошибка авторизации: $message';
  }

  @override
  String get loginTitle => 'Вход';

  @override
  String get welcomeBack => 'Добро пожаловать';

  @override
  String get emailOrUsernameLabel => 'Email или Username';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get orDivider => 'Или';

  @override
  String get validationEnterEmailOrUsername =>
      'Введите email или имя пользователя';

  @override
  String get validationEnterPassword => 'Введите пароль';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get fillAllFields => 'Заполните все поля';

  @override
  String get passwordStrengthWeak => 'Слабый';

  @override
  String get passwordStrengthMedium => 'Средний';

  @override
  String get passwordStrengthGood => 'Хороший';

  @override
  String get passwordStrengthStrong => 'Сильный';

  @override
  String get fullNameLabel => 'Полное имя';

  @override
  String get nicknameAtLabel => 'Никнейм (@username)';

  @override
  String get uploadPhotoPrompt => 'Загрузите фото профиля';

  @override
  String get photoLooksGreat => 'Отлично выглядите!';

  @override
  String get helpFriendsFind => 'Помогите друзьям найти вас';

  @override
  String get setupInterfaceTitle => 'Настройте интерфейс';

  @override
  String get colorThemeLabel => 'Цветовая тема';

  @override
  String get validationEnterEmail => 'Введите email';

  @override
  String get validationInvalidEmail => 'Некорректный email';

  @override
  String get validationPasswordTooShort => 'Пароль слишком короткий';

  @override
  String get backToLogin => 'Вход';

  @override
  String get finishButton => 'Завершить';

  @override
  String filePickError(String error) {
    return 'Ошибка выбора файла: $error';
  }

  @override
  String get chatsTitle => 'Чаты';

  @override
  String get noChats => 'Нет чатов';

  @override
  String get noMessages => '(нет сообщений)';

  @override
  String get newChat => 'Новый чат';

  @override
  String get messageInputHint => 'Напишите сообщение...';

  @override
  String get replyAction => 'Ответить';

  @override
  String get editShort => 'Редакт.';

  @override
  String get pinAction => 'Закрепить';

  @override
  String get moreReactions => 'Ещё';

  @override
  String get replyDialogTitle => 'Ответить';

  @override
  String get replyHint => 'Текст ответа';

  @override
  String get editMessageTitle => 'Редактировать сообщение';

  @override
  String get editMessageHint => 'Новый текст';

  @override
  String get deleteMessageTitle => 'Удалить сообщение?';

  @override
  String get pinsUpdated => 'Закрепления обновлены';

  @override
  String get messageEdited => 'Сообщение отредактировано';

  @override
  String get fileSent => 'Файл отправлен';

  @override
  String get voiceNotSupported =>
      'Запись голоса не поддерживается на этой платформе';

  @override
  String get microphonePermRequired => 'Нужно разрешение микрофона';

  @override
  String get recordingError => 'Ошибка записи';

  @override
  String sendFailedError(String error) {
    return 'Отправка не удалась: $error';
  }

  @override
  String attachmentSendError(String error) {
    return 'Ошибка отправки вложения: $error';
  }

  @override
  String shareFailedError(String error) {
    return 'Не удалось поделиться: $error';
  }

  @override
  String replyError(String error) {
    return 'Ошибка ответа: $error';
  }

  @override
  String pinError(String error) {
    return 'Ошибка закрепа: $error';
  }

  @override
  String deleteError(String error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String editMessageError(String error) {
    return 'Ошибка редактирования: $error';
  }

  @override
  String get userTyping => 'Пользователь печатает...';

  @override
  String get statusOnline => 'В сети';

  @override
  String get statusLastSeenRecently => 'Был(а) недавно';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get appearanceSection => 'Внешний вид';

  @override
  String get themeLabel => 'Тема';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get customizationLabel => 'Кастомизация';

  @override
  String get customizationSubtitle => 'Цвета, шрифт и UI-эффекты';

  @override
  String get notificationsSection => 'Уведомления';

  @override
  String get notificationsLabel => 'Уведомления';

  @override
  String get soundLabel => 'Звук';

  @override
  String get accountSection => 'Аккаунт';

  @override
  String get profileLabel => 'Профиль';

  @override
  String get profileSubtitle => 'Изменить данные профиля';

  @override
  String get accountSettingsLabel => 'Настройки аккаунта';

  @override
  String get accountSettingsSubtitle => 'Пароль, безопасность, 2FA';

  @override
  String get privacyLabel => 'Приватность';

  @override
  String get privacySubtitle => 'Управление приватностью';

  @override
  String get generalSection => 'Общие';

  @override
  String get languageLabel => 'Язык';

  @override
  String get textSizeLabel => 'Размер текста';

  @override
  String get sendByEnterLabel => 'Отправка по Enter';

  @override
  String get sendByEnterSubtitle => 'Shift+Enter для новой строки';

  @override
  String get dataStorageSection => 'Данные и хранилище';

  @override
  String get autoDownloadLabel => 'Автозагрузка медиа';

  @override
  String get autoDownloadSubtitle => 'Загружать фото и видео автоматически';

  @override
  String get storageManagementLabel => 'Управление хранилищем';

  @override
  String get storageManagementSubtitle => 'Очистить кеш и данные';

  @override
  String get clearCacheTitle => 'Очистить кеш';

  @override
  String get clearCacheContent => 'Удалить кешированные данные?';

  @override
  String get cacheCleared => 'Кеш очищен';

  @override
  String get developmentSection => 'Разработка';

  @override
  String get devMenuSubtitle => 'Плавающая кнопка отладки';

  @override
  String get aboutSection => 'О приложении';

  @override
  String get suggestImprovementLabel => 'Предложить улучшение';

  @override
  String get suggestImprovementSubtitle => 'Форма идей и больших нововведений';

  @override
  String get dangerZoneSection => 'Опасная зона';

  @override
  String get logoutLabel => 'Выход из аккаунта';

  @override
  String get logoutSubtitle => 'Выход с этого устройства';

  @override
  String get logoutDialogTitle => 'Выход из аккаунта';

  @override
  String get logoutDialogContent => 'Вы уверены, что хотите выйти?';

  @override
  String get logoutAction => 'Выход';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get matrixTooltip =>
      'Matrix — это открытый протокол для федеративного обмена сообщениями';

  @override
  String get clientDescription => 'Клиент TwoSpace написан на Flutter/Dart';

  @override
  String errorLogout(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get accountSettingsTitle => 'Настройки аккаунта';

  @override
  String get securitySection => 'Безопасность';

  @override
  String get twoFactorLabel => 'Двухфакторная аутентификация';

  @override
  String get twoFactorSubtitle => 'Дополнительная защита аккаунта';

  @override
  String get biometricLabel => 'Биометрия';

  @override
  String get biometricSubtitle => 'Вход по отпечатку пальца';

  @override
  String get activeSessionsLabel => 'Активные сеансы';

  @override
  String get activeSessionsSubtitle => 'Управление устройствами';

  @override
  String get currentDevice => 'Текущее устройство';

  @override
  String get changePasswordSection => 'Смена пароля';

  @override
  String get currentPasswordLabel => 'Текущий пароль';

  @override
  String get newPasswordLabel => 'Новый пароль';

  @override
  String get confirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get minPasswordHelper => 'Минимум 8 символов';

  @override
  String get changePasswordButton => 'Изменить пароль';

  @override
  String get passwordMismatch => 'Пароли не совпадают';

  @override
  String get passwordTooShort => 'Пароль должен быть не менее 8 символов';

  @override
  String get passwordChangeSuccess => 'Пароль успешно изменён';

  @override
  String get contactDataSection => 'Контактные данные';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get deleteAccountLabel => 'Удалить аккаунт';

  @override
  String get deleteAccountSubtitle => 'Необратимое действие';

  @override
  String get deleteAccountTitle => 'Удаление аккаунта';

  @override
  String get deleteAccountContent =>
      'Вы уверены, что хотите удалить аккаунт? Это действие необратимо.';

  @override
  String get deleteFeatureLater => 'Функция удаления будет добавлена позже';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get saveTooltip => 'Сохранить';

  @override
  String get editTooltip => 'Редактировать';

  @override
  String get writeMessageButton => 'Написать';

  @override
  String get callButton => 'Позвонить';

  @override
  String get aboutField => 'О себе';

  @override
  String get nicknameField => 'Никнейм';

  @override
  String get locationField => 'Место';

  @override
  String get birthdayField => 'День рождения';

  @override
  String get nameField => 'Имя';

  @override
  String get avatarUploadLater => 'Загрузка аватара будет добавлена позже';

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String createChatError(String error) {
    return 'Не удалось создать чат: $error';
  }

  @override
  String get privacyTitle => 'Приватность';

  @override
  String get hideFromSearch => 'Скрыть из поиска';

  @override
  String get hideFromSearchSubtitle =>
      'Не показывать меня в результатах поиска';

  @override
  String get hideLastSeen => 'Скрывать статус «был(а) в сети»';

  @override
  String get hideLastSeenSubtitle => 'Другие не увидят, когда вы были в сети';

  @override
  String get sessionExpiry => 'Срок действия входа';

  @override
  String sessionExpirySubtitle(int days) {
    return 'Автоматический повторный вход на этом устройстве: $days дней';
  }

  @override
  String get sessionExpiryDaysTitle => 'Срок действия входа (дни)';

  @override
  String get sessionExpiryDaysContent =>
      'Выберите количество дней (мин: 7, макс: 365).';

  @override
  String get daysLabel => 'Дней';

  @override
  String get enterDaysError => 'Введите число от 7 до 365';

  @override
  String sessionExpirySet(int days) {
    return 'Срок входа установлен: $days дней';
  }

  @override
  String get changeEmailLabel => 'Изменить email';

  @override
  String get changeEmailSubtitle => 'Обновить адрес электронной почты';

  @override
  String get twoFactorPrivacySubtitle => 'Включить/отключить усиленную защиту';

  @override
  String get changePhoneLabel => 'Изменить телефон';

  @override
  String get changePhoneSubtitle => 'Обновить номер телефона';

  @override
  String updatePrivacyError(String error) {
    return 'Не удалось обновить приватность: $error';
  }

  @override
  String updateSettingError(String error) {
    return 'Не удалось обновить настройку: $error';
  }

  @override
  String get contactsTitle => 'Контакты';

  @override
  String get searchContactsHint => 'Поиск контактов...';

  @override
  String get contactsAccessTitle => 'Доступ к контактам';

  @override
  String get contactsPermDeniedPermanent =>
      'Разрешение отклонено навсегда. Откройте настройки для доступа к контактам.';

  @override
  String get contactsPermRequired =>
      'Для отображения контактов необходимо разрешение.';

  @override
  String get openSettingsButton => 'Открыть настройки';

  @override
  String get requestPermissionButton => 'Запросить разрешение';

  @override
  String get noContacts => 'Контакты не найдены';

  @override
  String get callAction => 'Позвонить';

  @override
  String get writeMessageAction => 'Написать сообщение';

  @override
  String callNotification(String number) {
    return 'Звонок: $number';
  }

  @override
  String messageNotification(String name) {
    return 'Сообщение для: $name';
  }

  @override
  String get callsTitle => 'Звонки';

  @override
  String get searchByNameHint => 'Поиск по имени...';

  @override
  String get allFilter => 'Все';

  @override
  String get incomingFilter => 'Входящие';

  @override
  String get outgoingFilter => 'Исходящие';

  @override
  String get missedFilter => 'Пропущенные';

  @override
  String get noCallsFound => 'Нет звонков';

  @override
  String get yesterdayLabel => 'Вчера';

  @override
  String get incomingCall => 'Входящий';

  @override
  String get outgoingCall => 'Исходящий';

  @override
  String get missedCall => 'Пропущенный';

  @override
  String get videoCallLabel => 'Видеозвонок';

  @override
  String get voiceCallLabel => 'Голосовой звонок';

  @override
  String get sendMessageCallAction => 'Написать сообщение';

  @override
  String get createRoomTitle => 'Создать комнату';

  @override
  String get createButton => 'Создать';

  @override
  String get roomNameLabel => 'Название комнаты';

  @override
  String get roomNameHint => 'Например, название вашего проекта';

  @override
  String get roomTopicLabel => 'Тема (необязательно)';

  @override
  String get roomTopicHint => 'О чём эта комната?';

  @override
  String get roomVisibilityLabel => 'Видимость комнаты';

  @override
  String get privateRoomOption => 'Частная комната';

  @override
  String get privateRoomSubtitle =>
      'Только приглашённые пользователи могут присоединиться';

  @override
  String get publicRoomOption => 'Общедоступная комната';

  @override
  String get publicRoomSubtitle => 'Любой пользователь может присоединиться';

  @override
  String get showHistoryLabel => 'Показывать историю сообщений';

  @override
  String get showHistorySubtitle =>
      'Новые пользователи смогут видеть предыдущие сообщения';

  @override
  String get enterRoomNameError => 'Пожалуйста, введите название комнаты';

  @override
  String get roomCreatedSuccess => 'Комната успешно создана!';

  @override
  String imagePickError(String error) {
    return 'Ошибка выбора изображения: $error';
  }

  @override
  String get groupInfoTab => 'Информация';

  @override
  String get groupMembersTab => 'Участники';

  @override
  String get groupRolesTab => 'Роли';

  @override
  String get groupBansTab => 'Запреты';

  @override
  String get groupDeleteTab => 'Удалить';

  @override
  String membersCount(int count) {
    return 'Участников: $count';
  }

  @override
  String get messageHistoryToggle => 'История сообщений';

  @override
  String get showHistoryToggleLabel => 'Показывать историю';

  @override
  String get settingSaved => 'Настройка сохранена';

  @override
  String get backgroundColorLabel => 'Цвет фона';

  @override
  String get noMembers => 'Нет участников';

  @override
  String get roleAction => 'Роль';

  @override
  String get freezeAction => 'Заморозить';

  @override
  String get banAction => 'Забанить';

  @override
  String get kickAction => 'Исключить';

  @override
  String get noBannedUsers => 'Нет забаненных пользователей';

  @override
  String get bannedLabel => 'Забанен';

  @override
  String get userUnbanned => 'Пользователь разбанен';

  @override
  String get deleteGroupLabel => 'Удалить группу';

  @override
  String get deleteGroupWarning =>
      'Это действие НЕОБРАТИМО. Группа будет удалена навсегда.';

  @override
  String get confirmDeleteTitle => 'Подтвердить удаление';

  @override
  String get confirmDeleteContent => 'Вы уверены? Это действие необратимо.';

  @override
  String get changeRoleTitle => 'Изменить роль';

  @override
  String get adminRole => 'Администратор';

  @override
  String get memberRole => 'Участник';

  @override
  String get freezeUserTitle => 'Заморозить пользователя';

  @override
  String get userBanned => 'Пользователь забанен';

  @override
  String get userKicked => 'Пользователь исключён';

  @override
  String get groupDeleted => 'Группа удалена';

  @override
  String loadError(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String get publicLabel => 'Публичная';

  @override
  String get privateLabel => 'Приватная';

  @override
  String get noDescription => 'Нет описания';

  @override
  String get membersLabel => 'Участники';

  @override
  String get generalLabel => 'Общие';

  @override
  String get newChatTitle => 'Новый чат';

  @override
  String get directChatTab => 'Личный чат';

  @override
  String get groupChatTab => 'Группа';

  @override
  String get startDirectChatTitle => 'Начать личный чат';

  @override
  String get matrixIdDescription =>
      'Введите Matrix ID пользователя (например @user:server.com)';

  @override
  String get matrixIdLabel => 'Matrix ID пользователя';

  @override
  String get startChatButton => 'Начать чат';

  @override
  String get hintCardTitle => 'Подсказка';

  @override
  String get matrixIdExplanation => 'Matrix ID состоит из @username:server.com';

  @override
  String get enterUserIdError => 'Введите ID пользователя';

  @override
  String get createNewRoomTitle => 'Создать новую комнату';

  @override
  String get descriptionOptionalLabel => 'Описание (опционально)';

  @override
  String get privateGroupLabel => 'Приватная группа';

  @override
  String get privateGroupSubtitle =>
      'Только приглашённые пользователи могут присоединиться';

  @override
  String get createRoomButton => 'Создать комнату';

  @override
  String get customizationTitle => 'Кастомизация';

  @override
  String get colorsTab => 'Цвета';

  @override
  String get fontsTab => 'Шрифты';

  @override
  String get effectsTab => 'Эффекты';

  @override
  String get selectColorTheme => 'Выберите цветовую тему';

  @override
  String get themeAppliesEverywhere =>
      'Выбранная тема применяется во всём приложении';

  @override
  String get fontSettingsTitle => 'Настройки шрифта';

  @override
  String get selectFontFamily => 'Выберите семейство шрифта';

  @override
  String get appFontLabel => 'Шрифт приложения';

  @override
  String get fontWeightLabel => 'Толщина шрифта';

  @override
  String get fontPreview => 'Предпросмотр: Пример текста';

  @override
  String get compactMode => 'Уменьшить отступы и размеры';

  @override
  String get enableCircles => 'Включить круги';

  @override
  String get circlesDesc => 'Анимированные круги на фоне';

  @override
  String get floatingCirclesLabel => 'Плавающие круги';

  @override
  String get reactOnTilt => 'Реагируют на наклон телефона';

  @override
  String get parallaxEffect => 'Параллакс-эффект';

  @override
  String get circlesSpeedLabel => 'Скорость движения';

  @override
  String get staticMotion => 'Статичное движение';

  @override
  String get brightnessLabel => 'Яркость';

  @override
  String get dimOpacity => 'Тусклые';

  @override
  String get brightOpacity => 'Яркие';

  @override
  String get performanceLabel => 'Производительность';

  @override
  String get currentSpeedPrefix => 'Текущий: ';

  @override
  String get speedPrefix => 'Скорость:';

  @override
  String get advancedSearchTitle => 'Расширенный поиск';

  @override
  String get searchQueryHint => 'Введите запрос...';

  @override
  String get searchTypeLabel => 'Тип поиска';

  @override
  String get searchTypeAll => 'Все';

  @override
  String get searchTypeMessages => 'Сообщения';

  @override
  String get searchTypeMedia => 'Медиа';

  @override
  String get searchTypeUsers => 'Пользователи';

  @override
  String get periodLabel => 'Период';

  @override
  String get fromDate => 'От';

  @override
  String get toDate => 'До';

  @override
  String get searchButton => 'Искать';

  @override
  String resultsCount(int count) {
    return 'Результаты ($count)';
  }

  @override
  String get noResultsFound => 'Результатов не найдено';

  @override
  String get forgotPasswordTitle => 'Восстановление пароля';

  @override
  String get forgotPasswordDescription =>
      'Введите email, на который будет отправлена ссылка для сброса';

  @override
  String get sendResetButton => 'Отправить';

  @override
  String get forgotPasswordUnavailable =>
      'Функция восстановления пароля недоступна';

  @override
  String get changeEmailTitle => 'Изменить email';

  @override
  String get changeEmailDescription => 'Введите новый адрес электронной почты';

  @override
  String get currentPrefix => 'Текущий: ';

  @override
  String get newEmailLabel => 'Новый email';

  @override
  String get changeEmailButton => 'Изменить email';

  @override
  String changeEmailError(String error) {
    return 'Не удалось изменить email: $error';
  }

  @override
  String get changePhoneTitle => 'Изменить номер телефона';

  @override
  String get changePhoneDescription =>
      'Введите новый номер телефона и текущий пароль.';

  @override
  String get newPhoneLabel => 'Новый номер (+7...)';

  @override
  String get currentPasswordOptional => 'Текущий пароль (если требуется)';

  @override
  String get changePhoneButton => 'Изменить номер';

  @override
  String get phoneCannotBeChanged => 'Номер телефона не может быть изменён';

  @override
  String get emailCannotBeChanged => 'Email не может быть изменён';

  @override
  String changePhoneError(String error) {
    return 'Не удалось изменить номер: $error';
  }

  @override
  String get confirmCodeTitle => 'Подтвердите код';

  @override
  String codeSentTo(String phone) {
    return 'Мы отправили код на $phone';
  }

  @override
  String get enterCodeHint => 'Введите код';

  @override
  String get confirmButton => 'Подтвердить';

  @override
  String resendCountdown(int seconds) {
    return 'Повторная отправка через $seconds с';
  }

  @override
  String get resendCodeButton => 'Отправить код повторно';

  @override
  String get biometricSetupTitle => 'Безопасность';

  @override
  String get authMethodsLabel => 'Методы аутентификации';

  @override
  String get biometricAuthLabel => 'Биометрическая аутентификация';

  @override
  String get biometricAuthSubtitle => 'Отпечаток пальца или Face ID';

  @override
  String get biometricEnabledLabel => 'Биометрия включена';

  @override
  String get aboutSecurityLabel => 'О безопасности';

  @override
  String get aboutSecurityContent =>
      'Выберите удобный метод аутентификации для защиты аккаунта.';

  @override
  String get setPinCode => 'Установить PIN-код';

  @override
  String get updateAvailableTitle => 'Доступно обновление';

  @override
  String get whatsNewLabel => 'Что нового';

  @override
  String get noUpdateDescription => 'Описание отсутствует';

  @override
  String downloadingProgress(int percent) {
    return 'Скачивание... $percent%';
  }

  @override
  String get checkingIntegrity => 'Проверка целостности...';

  @override
  String get requestingInstall => 'Запрос на установку...';

  @override
  String get updateMandatory => 'Обновление обязательно';

  @override
  String get laterButton => 'Позже';

  @override
  String get downloadingLabel => 'Скачивается...';

  @override
  String get installingLabel => 'Устанавливается...';

  @override
  String get updateButton => 'Обновить';

  @override
  String get downloadFailed => 'Не удалось скачать обновление';

  @override
  String get integrityCheckFailed =>
      'Скачанный файл не прошёл проверку целостности (sha256)';

  @override
  String get installPermissionTitle => 'Разрешение на установку';

  @override
  String get installPermissionContent =>
      'Чтобы установить обновление, разрешите установку из неизвестных источников.';

  @override
  String get installPermissionRequired => 'Нужны разрешения для установки';

  @override
  String get installFailed => 'Установка не удалась';

  @override
  String get ssoFeatureRequired =>
      'Функция требует конфигурации webview_flutter';

  @override
  String ssoLoginVia(String idpId) {
    return 'SSO вход через $idpId';
  }

  @override
  String get forwardMessageTitle => 'Переслать сообщение';

  @override
  String get searchChatHint => 'Поиск чата...';

  @override
  String forwardButton(int count) {
    return 'Переслать ($count)';
  }

  @override
  String get roomAvatarUpdated => 'Аватар комнаты обновлён';

  @override
  String roomAvatarUploadError(String error) {
    return 'Ошибка при загрузке аватара: $error';
  }

  @override
  String get roomSettingsSaved => 'Настройки комнаты сохранены';

  @override
  String roomSettingsSaveError(String error) {
    return 'Ошибка при сохранении: $error';
  }

  @override
  String get uploadAvatarButton => 'Загрузить аватар';

  @override
  String loadMembersError(String error) {
    return 'Ошибка загрузки участников: $error';
  }

  @override
  String get leaveRoomTitle => 'Покинуть комнату?';

  @override
  String get leaveRoomContent =>
      'Вы не сможете вернуться в эту комнату, если вас не пригласят заново.';

  @override
  String get leaveAction => 'Покинуть';

  @override
  String get leftRoom => 'Вы покинули комнату';

  @override
  String leaveRoomError(String error) {
    return 'Ошибка при выходе: $error';
  }

  @override
  String get reportNotImplemented => 'Функция жалобы ещё не реализована';

  @override
  String get inviteAction => 'Пригласить';

  @override
  String get threadsLabel => 'Ветки';

  @override
  String get pinnedLabel => 'Закреплённые';

  @override
  String get filesLabel => 'Файлы';

  @override
  String get mediaLabel => 'Медиа';

  @override
  String get extensionsLabel => 'Расширения';

  @override
  String get copyLinkAction => 'Копировать ссылку';

  @override
  String get pollsLabel => 'Опросы';

  @override
  String get exportChatAction => 'Экспорт чата';

  @override
  String get reportAction => 'Пожаловаться';

  @override
  String get leaveRoomAction => 'Покинуть комнату';

  @override
  String roomTitle(String name) {
    return 'Комната — $name';
  }

  @override
  String get roomSettingsLabel => 'Настройки комнаты';

  @override
  String authError(String error) {
    return 'Ошибка аутентификации: $error';
  }

  @override
  String get loginRequired => 'Требуется вход';

  @override
  String get loginRequiredContent =>
      'Для поиска контактов необходим вход в аккаунт. Хотите перейти на экран входа?';

  @override
  String get loginAction => 'Войти';

  @override
  String searchError(String error) {
    return 'Ошибка поиска: $error';
  }

  @override
  String get searchContactsTitle => 'Поиск контактов';

  @override
  String get nicknameOrPhoneHint => 'Никнейм или номер телефона';

  @override
  String selectContactError(String error) {
    return 'Не удалось выбрать контакт: $error';
  }

  @override
  String get categoryLabel => 'Категория';

  @override
  String get feedbackCategoryFeatures => 'Функции';

  @override
  String get feedbackCategoryPerformance => 'Производительность';

  @override
  String get feedbackCategorySecurity => 'Безопасность/Приватность';

  @override
  String get feedbackCategoryNetworkSync => 'Синхронизация/Сеть';

  @override
  String get shortDescriptionLabel => 'Короткое описание';

  @override
  String get shortDescriptionHint => 'Например: \"Бэкап чатов в облако\"';

  @override
  String get feedbackValidation =>
      'Выберите хотя бы одну идею или напишите описание';

  @override
  String get detailsOptionalLabel => 'Детали (опционально)';

  @override
  String get detailsHint =>
      'Что именно должно работать, как сейчас и как хотелось бы?';

  @override
  String get bigFeaturesTitle =>
      'Большие нововведения (выберите, что интереснее всего)';

  @override
  String get feedbackE2E =>
      'Сквозное E2E-шифрование (Olm/Megolm) + верификация устройств';

  @override
  String get feedbackBackup =>
      'Резервное копирование чатов (локально/облако) + перенос на новое устройство';

  @override
  String get feedbackThreads =>
      'Треды, реакции и упоминания, улучшенный поиск по сообщениям';

  @override
  String get feedbackCalls => 'Голосовые/видео-звонки и быстрые voice rooms';

  @override
  String get feedbackFolders =>
      'Папки/категории чатов и умные фильтры уведомлений';

  @override
  String get feedbackBots =>
      'Боты и интеграции (вебхуки, GitHub/Jira, напоминания)';

  @override
  String get feedbackSlowNet =>
      'Режим «медленного интернета» + агрессивное кэширование медиа';

  @override
  String get startChatTitle => 'Начать чат';

  @override
  String get createRoomSubtitle => 'Приватная или публичная группа';

  @override
  String get inviteUserTitle => 'Пригласить пользователя';

  @override
  String get inviteUserSubtitle => 'Найти и написать пользователю';

  @override
  String get joinByCodeTitle => 'Присоединиться по коду';

  @override
  String get joinByCodeSubtitle =>
      'Присоединиться к комнате по пригласительному коду';

  @override
  String get fontLabel => 'Шрифт';

  @override
  String get pinCodeLabel => 'PIN-код';

  @override
  String get pinCodeSubtitle => '4-6 цифр для защиты';

  @override
  String get pinHint => 'PIN (4-6 цифр)';

  @override
  String get pinLengthError => 'PIN должен быть 4-6 цифр';

  @override
  String get pinSetSuccess => 'PIN установлен';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get closeButton => 'Закрыть';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get sendButton => 'Отправить';

  @override
  String get copyButton => 'Копировать';

  @override
  String get shareButton => 'Поделиться';

  @override
  String get settingsLabel => 'Настройки';

  @override
  String get feedbackCategoryUxDesign => 'UX/Дизайн';

  @override
  String get feedbackShareSubject => 'TwoSpace — предложение';

  @override
  String get feedbackMessageHeader => 'TwoSpace — предложение/улучшение';

  @override
  String feedbackVersion(String version) {
    return 'Версия: $version';
  }

  @override
  String feedbackCategoryLine(String category) {
    return 'Категория: $category';
  }

  @override
  String feedbackShortTitle(String title) {
    return 'Кратко: $title';
  }

  @override
  String get feedbackWishList => 'Что было бы особенно здорово:';

  @override
  String get feedbackDetailsLine => 'Подробности:';

  @override
  String get circlesVisible => 'Круги отображаются';

  @override
  String get circlesHidden => 'Круги скрыты';

  @override
  String get speedSlow => 'Медленно';

  @override
  String get speedFast => 'Быстро';

  @override
  String get advancedSettingsLabel => 'Расширенные настройки';

  @override
  String get compactModeLabel => 'Компактный режим';

  @override
  String get activeDeviceInfo => 'Android • Активно';

  @override
  String stubPlaceholder(String key) {
    return 'Заглушка — $key';
  }

  @override
  String loadMessagesError(String error) {
    return 'Ошибка загрузки сообщений: $error';
  }

  @override
  String get pinnedUpdated => 'Закреплённые обновлены';

  @override
  String editError(String error) {
    return 'Ошибка редактирования: $error';
  }

  @override
  String get moreButton => 'Ещё';

  @override
  String shareError(String error) {
    return 'Не удалось поделиться: $error';
  }

  @override
  String sendError(String error) {
    return 'Ошибка отправки: $error';
  }

  @override
  String get voiceRecordingUnsupported =>
      'Запись голоса не поддерживается на этой платформе';

  @override
  String get microphonePermissionRequired =>
      'Требуется разрешение на использование микрофона';

  @override
  String genericError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get ownersLabel => '👑 Владельцы';

  @override
  String get administratorsLabel => '⚡ Администраторы';

  @override
  String get oneHour => '1 час';

  @override
  String get oneDay => '1 день';

  @override
  String get sevenDays => '7 дней';

  @override
  String get settingsThemeSelection => 'Тема';

  @override
  String get settingsNotificationNew => 'Уведомления';

  @override
  String get settingsDoNotDisturb => 'Не беспокоить';

  @override
  String get settingsSoundOptions => 'Настройки звука';

  @override
  String get settingsStorageManagement => 'Управление хранилищем';

  @override
  String get settingsStorageUsage => 'Использование хранилища';

  @override
  String get settingsStorageAppSize => 'Размер приложения';

  @override
  String get settingsStorageClearBtn => 'Очистить выбранное';

  @override
  String get settingsStorageKeepChat => 'Хранить данные чатов';

  @override
  String get settingsStorageKeepChannel => 'Хранить данные каналов';

  @override
  String get settingsStorageKeepGroup => 'Хранить данные групп';

  @override
  String get settingsAboutPropose => 'Предложить улучшение';

  @override
  String get settingsAboutCheckUpdate => 'Проверить обновление';

  @override
  String get biometricsEnable => 'Блокировка приложения';

  @override
  String get biometricsSetup => 'Настроить блокировку';

  @override
  String get contactsTwoSpaceYes => 'Есть в TwoSpace';

  @override
  String get contactsTwoSpaceNo => 'Нету в TwoSpace';
}
