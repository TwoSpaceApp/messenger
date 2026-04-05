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
  String get emailOrUsernameLabel => 'Username';

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
  String get validationEnterEmailOrUsername => 'Введите username';

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
  String get addCaptionHint => 'Добавьте подпись или сообщение';

  @override
  String get unlockApp => 'Разблокировать';

  @override
  String get unlockButton => 'Разблокировать';

  @override
  String get dropFilesTitle => 'Перетащите файлы для прикрепления';

  @override
  String get dropFilesSubtitle => 'Они появятся над полем ввода.';

  @override
  String get videoUnavailable => 'Видео недоступно';

  @override
  String get guestRole => 'Гость';

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
  String get widgetsTitle => 'Виджеты';

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
  String get contactIdDescription =>
      'Введите username или Aegis ID пользователя';

  @override
  String get contactIdLabel => 'Username или Aegis ID';

  @override
  String get startChatButton => 'Начать чат';

  @override
  String get hintCardTitle => 'Подсказка';

  @override
  String get contactIdExplanation =>
      'Можно использовать username или числовой Aegis ID пользователя';

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
  String get customizationHeroTitle => 'Соберите интерфейс под свой ритм';

  @override
  String get customizationHeroSubtitle =>
      'Настраивайте стиль через живое превью, готовые пресеты, движение и плотность интерфейса.';

  @override
  String get notificationsHeroSubtitle =>
      'Настройте оповещения, звук и пользовательские превью так, чтобы всё ощущалось спокойно и аккуратно.';

  @override
  String get livePreviewBadge => 'Живое превью';

  @override
  String get stylePresetsTitle => 'Пресеты стиля';

  @override
  String get stylePresetsSubtitle =>
      'Начните с готового визуального направления, затем доведите детали вручную.';

  @override
  String get moodSectionTitle => 'Характер';

  @override
  String get moodSectionSubtitle =>
      'Выберите акцент, который задаёт фон, подсветки и общий тон интерфейса.';

  @override
  String get typeSectionTitle => 'Типографика';

  @override
  String get typeSectionSubtitle =>
      'Подберите семейство шрифта, насыщенность и размер для всего приложения.';

  @override
  String get motionSectionTitle => 'Движение';

  @override
  String get motionSectionSubtitle =>
      'Управляйте тем, насколько живо ведут себя фон и световые слои.';

  @override
  String get densitySectionTitle => 'Плотность';

  @override
  String get densitySectionSubtitle =>
      'Настройте отступы, форму пузырей и скорость исчезновения навигации.';

  @override
  String get themeModeLabel => 'Баланс света';

  @override
  String get dynamicBubblesLabel => 'Динамические пузыри';

  @override
  String get dynamicBubblesSubtitle =>
      'Добавляет направленные углы пузырям сообщений для более живого ритма диалога.';

  @override
  String get bubbleRoundingLabel => 'Скругление пузырей';

  @override
  String get bubbleRoundingCompact => 'Резче';

  @override
  String get bubbleRoundingSoft => 'Мягче';

  @override
  String get navBarTimeoutLabel => 'Автоскрытие навигации';

  @override
  String navBarTimeoutValue(int seconds) {
    return '$seconds с';
  }

  @override
  String get navBarTimeoutShort => 'Быстро';

  @override
  String get navBarTimeoutLong => 'Спокойно';

  @override
  String get presetQuietGlass => 'Quiet Glass';

  @override
  String get presetQuietGlassSubtitle =>
      'Холодная глубина, ровный контраст и спокойное движение.';

  @override
  String get presetNightSignal => 'Night Signal';

  @override
  String get presetNightSignalSubtitle =>
      'Более плотная компоновка, яркие акценты и тёмный пульс.';

  @override
  String get presetEditorial => 'Editorial';

  @override
  String get presetEditorialSubtitle =>
      'Сдержанное движение, спокойный цвет и акцент на чтении.';

  @override
  String get presetSolarFlare => 'Solar Flare';

  @override
  String get presetSolarFlareSubtitle =>
      'Тёплые акценты, светлее поверхности и более энергичный фон.';

  @override
  String get presetRetroPulse => 'Retro Pulse';

  @override
  String get presetRetroPulseSubtitle =>
      'Компактно, игриво и намеренно стилизовано.';

  @override
  String get previewRoomsLabel => 'Комнаты';

  @override
  String get previewConversationLabel => 'Диалог';

  @override
  String get previewSettingsLabel => 'Настройки';

  @override
  String get previewRoomsTitle => 'Утренний обзор';

  @override
  String get previewRoomsSubtitle =>
      'Компактный список комнат с живыми фразами и более понятными статусами.';

  @override
  String get previewConversationTitle => 'Короткий диалог';

  @override
  String get previewConversationSubtitle =>
      'Проверьте, как в небольшом разговоре читаются ритм, отступы и форма пузырей.';

  @override
  String get previewSettingsTitle => 'Настройки под рукой';

  @override
  String get previewSettingsSubtitle =>
      'Сразу видно, как будут собираться карточки параметров до применения ко всему приложению.';

  @override
  String get previewLiveLabel => 'Live';

  @override
  String get previewRoomDesignSync => 'Design Sync';

  @override
  String get previewRoomDesignSyncSubtitle =>
      'Доброе утро. Свежие макеты уже лежат в закрепе.';

  @override
  String get previewRoomReleaseCheck => 'Release Check';

  @override
  String get previewRoomReleaseCheckSubtitle =>
      'Знаешь, который час стартуем релиз? Я собираю чек-лист.';

  @override
  String get previewRoomAlphaOps => 'Alpha Ops';

  @override
  String get previewRoomAlphaOpsSubtitle =>
      'В Токио уже утро. Ночные логи выглядят спокойно.';

  @override
  String get previewIncomingMessage =>
      'Доброе утро. Фон уже перестал ощущаться как тестовый экран?';

  @override
  String get previewOutgoingMessage =>
      'Почти. Теперь это больше похоже на живой чат: спокойнее ритм, чище типографика.';

  @override
  String get previewTypingStatus =>
      'Набор, углы и ритм сообщений меняются здесь сразу.';

  @override
  String get previewSettingsAppearanceSubtitle =>
      'Выберите шаблон, подкрутите движение и проверьте цельность оболочки.';

  @override
  String get previewSettingsNotificationsSubtitle =>
      'Так будет выглядеть стек вторичных карточек настроек.';

  @override
  String get previewSettingsPrivacySubtitle =>
      'Проверьте иерархию, контраст и вес иконок до применения.';

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
  String get backgroundMotionToggleLabel => 'Анимированный фон';

  @override
  String get backgroundMotionOnSubtitle =>
      'Световые слои продолжают мягко двигаться за интерфейсом.';

  @override
  String get backgroundMotionOffSubtitle =>
      'Фон становится статичным и спокойным без лишнего движения.';

  @override
  String get motionModeCircles => 'Орбиты';

  @override
  String get motionModeCirclesSubtitle =>
      'Плавающие световые сферы с мягким параллаксом.';

  @override
  String get motionModeWaves => 'Волны';

  @override
  String get motionModeWavesSubtitle =>
      'Слоистые нижние волны, похожие на мягкое атмосферное свечение.';

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
  String get updateHeroTitle => 'Релиз готов к установке';

  @override
  String get updateHeroSubtitle =>
      'Посмотрите состав релиза, проверьте целостность и пройдите установку по понятным шагам.';

  @override
  String get updateStatusRequired => 'Обязательно';

  @override
  String get updateStatusRecommended => 'Рекомендуется';

  @override
  String get updatePipelineTitle => 'Пайплайн обновления';

  @override
  String get updatePipelineSubtitle =>
      'Каждый этап показывает, что происходит сейчас и что будет следующим шагом.';

  @override
  String get updateStageDownloadTitle => 'Скачать пакет';

  @override
  String get updateStageDownloadSubtitle =>
      'Сохранить установочный пакет в локальное хранилище.';

  @override
  String get updateStageVerifyTitle => 'Проверить целостность';

  @override
  String get updateStageVerifySubtitle =>
      'Сверить скачанный файл с опубликованным SHA-256 хэшем.';

  @override
  String get updateStageInstallTitle => 'Установить релиз';

  @override
  String get updateStageInstallSubtitle =>
      'При необходимости запросить разрешение и передать пакет системному установщику.';

  @override
  String get releaseSummaryTitle => 'Сводка релиза';

  @override
  String get releaseSummarySubtitle =>
      'Изменения сгруппированы так, чтобы их было проще просканировать, чем читать сырой changelog.';

  @override
  String get releaseSectionNew => 'Новое';

  @override
  String get releaseSectionImproved => 'Улучшено';

  @override
  String get releaseSectionFixed => 'Исправлено';

  @override
  String get releaseSectionSecurity => 'Безопасность';

  @override
  String get updateTrustTitle => 'Доверие и совместимость';

  @override
  String get updateTrustSubtitle =>
      'Откуда пришёл пакет, как он проверяется и какую именно сборку вы собираетесь установить.';

  @override
  String get updateTrustSource => 'Источник';

  @override
  String get updateTrustIntegrity => 'Целостность';

  @override
  String get updateTrustPlatform => 'Платформа';

  @override
  String get updateTrustAbi => 'ABI';

  @override
  String get updateTrustVerified => 'Проверено';

  @override
  String get updateTrustPending => 'Ожидается';

  @override
  String get updateTrustFailed => 'Ошибка';

  @override
  String get updateTrustUnavailable => 'Недоступно';

  @override
  String get updateTrustUnknown => 'Неизвестно';

  @override
  String get updatePreviewModeTitle => 'Карточка превью релиза';

  @override
  String get updatePreviewModeSubtitle =>
      'Этот экран открыт из debug-каталога, поэтому здесь показан оформленный плейсхолдер вместо реальных заметок релиза.';

  @override
  String get updatePreviewModeEmptyNotes =>
      'Для этого тестового релиза заметки пока не заданы.';

  @override
  String get updateCurrentVersionLabel => 'Текущая';

  @override
  String get updateIncomingVersionLabel => 'Новая';

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
  String get featureInDevelopmentLabel => 'В разработке';

  @override
  String featureInDevelopmentMessage(String feature) {
    return 'Раздел «$feature» ещё в разработке и появится в одном из следующих обновлений.';
  }

  @override
  String get inviteAction => 'Пригласить';

  @override
  String get threadsLabel => 'Ветки';

  @override
  String get pinnedLabel => 'Закреплённые';

  @override
  String get filesLabel => 'Файлы';

  @override
  String get noSharedFiles => 'Общих файлов пока нет';

  @override
  String get mediaLabel => 'Медиа';

  @override
  String get noSharedMedia => 'Общих медиа пока нет';

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
  String get startDirectChatSubtitle =>
      'Открыть приватный диалог с одним человеком';

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
  String get chatsSubtitle =>
      'Личные чаты, группы и пригласительные ссылки в одном месте';

  @override
  String get chatsQuickStartTitle => 'Начните новый диалог';

  @override
  String get chatsRecentTitle => 'Недавние чаты';

  @override
  String get joinLinkHint => 'Вставьте пригласительную ссылку, алиас или код';

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
  String get notificationToneTitle => 'Звук уведомлений';

  @override
  String get notificationToneSubtitle =>
      'Выберите локальный аудиофайл для превью сообщений и оповещений.';

  @override
  String get ringtoneTitle => 'Рингтон';

  @override
  String get ringtoneSubtitle =>
      'Используйте отдельный локальный файл для превью входящих звонков.';

  @override
  String get chooseSoundLabel => 'Выбрать файл';

  @override
  String get playPreviewLabel => 'Прослушать';

  @override
  String get stopPreviewLabel => 'Остановить';

  @override
  String get customSoundNotSelected => 'Пользовательский файл пока не выбран.';

  @override
  String get clearCustomSoundLabel => 'Сбросить файл';

  @override
  String get settingsStorageManagement => 'Управление хранилищем';

  @override
  String get settingsStorageUsage => 'Использование хранилища';

  @override
  String get settingsStorageAppSize => 'Размер приложения';

  @override
  String get settingsStorageClearBtn => 'Очистить выбранное';

  @override
  String get storageMemoryTitle => 'Память';

  @override
  String get storageTotalLabel => 'Всего';

  @override
  String get storageSelectedLabel => 'Выбрано';

  @override
  String get storagePhotosLabel => 'Фото';

  @override
  String get storageVideosLabel => 'Видео';

  @override
  String get storageCacheLabel => 'Кэш';

  @override
  String get storageAppDataLabel => 'Данные приложения';

  @override
  String get storageCleanupTitle => 'Будет очищено';

  @override
  String get storageCleanupSubtitle => 'Посмотри, что можно безопасно удалить.';

  @override
  String get storageAutoCleanTitle => 'Автоочистка';

  @override
  String get storageAutoCleanSubtitle =>
      'Запускайте очистку по расписанию или сразу, когда объём данных превысит выбранный порог.';

  @override
  String get storageAutoCleanPeriodLabel => 'Период очистки';

  @override
  String get storageAutoCleanPeriodDaily => 'Каждый день';

  @override
  String get storageAutoCleanPeriodWeekly => 'Раз в неделю';

  @override
  String get storageAutoCleanPeriodMonthly => 'Раз в месяц';

  @override
  String get storageAutoCleanThresholdLabel => 'Сразу при объёме больше';

  @override
  String get storageAutoCleanTypesLabel => 'Что очищать';

  @override
  String get storageAutoCleanStatusTitle => 'Статус автоочистки';

  @override
  String get storageAutoCleanStatusEnabled =>
      'Автоочистка активна и запустится по расписанию или при превышении порога хранилища.';

  @override
  String get storageAutoCleanStatusDisabled =>
      'Автоочистка выключена. Сейчас будет работать только ручная очистка.';

  @override
  String get storageAutoCleanLastRunLabel => 'Последний запуск';

  @override
  String get storageAutoCleanLastRunNever => 'Никогда';

  @override
  String get storageAutoCleanSelectAll => 'Выбрать всё';

  @override
  String get storageAutoCleanSelectNone => 'Сбросить выбор';

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

  @override
  String get peopleTitle => 'Люди';

  @override
  String get peopleSubtitle =>
      'Контакты, избранные, поиск и приглашения в одном месте';

  @override
  String get peopleQuickNewChat => 'Новый чат';

  @override
  String get peopleQuickInvite => 'Пригласить';

  @override
  String get peopleQuickSync => 'Синхронизировать';

  @override
  String get peopleSearchHint => 'Поиск по имени, нику или номеру';

  @override
  String get peopleSegmentAll => 'Все';

  @override
  String get peopleSegmentTwoSpace => 'TwoSpace';

  @override
  String get peopleSegmentPhonebook => 'Телефонная книга';

  @override
  String get peopleSegmentRecent => 'Недавние';

  @override
  String get peopleLoading => 'Загружаем людей…';

  @override
  String get peopleNoPeopleTitle => 'Пока никого нет';

  @override
  String get peopleNoPeopleMessage =>
      'Здесь появятся избранные, недавние диалоги и контакты.';

  @override
  String get peoplePermissionCardTitle => 'Доступ к контактам ограничен';

  @override
  String get peoplePermissionCardMessage =>
      'Разрешите доступ к контактам, чтобы видеть телефонную книгу и быстрее приглашать людей.';

  @override
  String get peoplePermissionCardMessageSettings =>
      'Включите доступ к контактам в системных настройках, чтобы вернуть раздел телефонной книги.';

  @override
  String get peopleFavoritesFrequentTitle => 'Избранные и частые';

  @override
  String get peopleRecentTitle => 'Недавние люди';

  @override
  String get peopleTwoSpaceTitle => 'Люди в TwoSpace';

  @override
  String get peopleInviteTitle => 'Пригласить в TwoSpace';

  @override
  String get peopleInviteSubtitle => 'Пригласить этот контакт в TwoSpace';

  @override
  String get peopleSearching => 'Ищем людей…';

  @override
  String get peopleSearchRemoteTitle => 'Результаты TwoSpace';

  @override
  String get peopleSearchLocalTitle => 'Недавние и сохранённые';

  @override
  String get peopleSearchInviteTitle => 'Пригласить из телефонной книги';

  @override
  String get peopleSearchEmptyTitle => 'Люди не найдены';

  @override
  String get peopleSearchEmptyMessage =>
      'Попробуйте другой запрос, ник или номер телефона.';

  @override
  String get peopleTwoSpaceBadge => 'TwoSpace';

  @override
  String get peopleNoDetails => 'Пока без дополнительных данных';

  @override
  String get peopleInviteShareText =>
      'Присоединяйся ко мне в TwoSpace — это защищённый мессенджер для чатов и звонков.';

  @override
  String peopleInviteSpecificShareText(String personName) {
    return 'Присоединяйся ко мне в TwoSpace, $personName — будем безопасно общаться и созваниваться.';
  }

  @override
  String get peopleViewProfileAction => 'Открыть профиль';

  @override
  String get peopleRemoveFavoriteAction => 'Убрать из избранного';

  @override
  String get peopleAddFavoriteAction => 'Добавить в избранное';

  @override
  String get callsSubtitle =>
      'Недавние звонки, быстрый перезвон и история вокруг людей';

  @override
  String get widgetsSubtitle =>
      'Скоро здесь появятся тёплые новые способы оставаться ближе друг к другу.';

  @override
  String get widgetsComingTitle => 'Новые форматы общения уже в пути';

  @override
  String get widgetsComingBody =>
      'В одном из следующих обновлений здесь появятся спокойные совместные виджеты и лёгкие способы держать связь с близкими.';

  @override
  String get callsStartCallAction => 'Начать звонок';

  @override
  String get callsQuickStartTitle => 'Позвонить сейчас';

  @override
  String get callsQuickStartSubtitle =>
      'Откройте раздел людей, найдите человека и начните защищённый голосовой или видеозвонок.';

  @override
  String get callsSearchHint => 'Поиск по истории звонков';

  @override
  String get callsVideoFilter => 'Видео';

  @override
  String get callsTopContactsTitle => 'Частые контакты';

  @override
  String get callsLoadingLabel => 'Загружаем звонки…';

  @override
  String get callsEmptyTitle => 'Звонков пока нет';

  @override
  String get callsEmptyMessage =>
      'История звонков появится здесь после первого голосового или видеозвонка.';

  @override
  String get callsEmptySearchMessage =>
      'По текущему поиску или фильтру звонков ничего не найдено.';

  @override
  String get callsTodaySection => 'Сегодня';

  @override
  String get callsThisWeekSection => 'На этой неделе';

  @override
  String get callsEarlierSection => 'Раньше';

  @override
  String callsThreadCount(int count) {
    return '$count звонков';
  }

  @override
  String callsMissedSummary(int count) {
    return '$count пропущенных';
  }

  @override
  String get callsMuteAction => 'Микрофон';

  @override
  String get callsSpeakerAction => 'Динамик';

  @override
  String get callsCameraAction => 'Камера';

  @override
  String get callsSwitchCameraAction => 'Сменить';

  @override
  String get callsEndAction => 'Завершить звонок';

  @override
  String get callsConnectingLabel => 'Подключение…';

  @override
  String get callsRingingLabel => 'Гудки…';

  @override
  String get callsConnectingDetail => 'Создаём защищённую сессию звонка.';

  @override
  String get callsRingingDetail => 'Ждём, пока собеседник ответит.';

  @override
  String get callsVideoSecureDetail =>
      'Видео защищено и проходит через текущую безопасную сессию.';

  @override
  String get callsVoiceSecureDetail =>
      'Голос защищён и проходит через текущую безопасную сессию.';

  @override
  String get timestampPrecisionLabel => 'Точность времени сообщений';

  @override
  String get timestampPrecisionSubtitle =>
      'Выберите, насколько подробно показывать время в чатах и списке чатов.';

  @override
  String get timestampPrecisionMinutes => 'Часы и минуты';

  @override
  String get timestampPrecisionSeconds => 'Часы, минуты и секунды';

  @override
  String get timestampPrecisionMilliseconds =>
      'Часы, минуты, секунды и миллисекунды';

  @override
  String get startupTitle => 'Подготавливаем TwoSpace';

  @override
  String get startupSubtitle =>
      'Проверяем защищённую сессию и открываем ваши чаты.';

  @override
  String get startupFooter =>
      'Этот экран показывается только во время запуска приложения.';

  @override
  String get startupStepEnvironment => 'Загружаем конфигурацию';

  @override
  String get startupStepDiagnostics => 'Запускаем диагностику';

  @override
  String get startupStepValidation => 'Проверяем окружение';

  @override
  String get startupStepSettings => 'Загружаем настройки';

  @override
  String get startupStepSession => 'Восстанавливаем защищённую сессию';

  @override
  String get startupStepLaunch => 'Запускаем приложение';

  @override
  String get callsDemoBannerTitle => 'Пример, нерабочий функционал';

  @override
  String get callsDemoBannerVoiceMessage =>
      'Голосовые звонки пока показаны только как визуальный прототип. Передача аудио ещё не подключена.';

  @override
  String get callsDemoBannerVideoMessage =>
      'Видеозвонки пока показаны только как визуальный прототип. Удалённый видеопоток недоступен, но локальный предпросмотр камеры работает.';

  @override
  String get callsCameraPermissionMessage =>
      'Разрешите доступ к камере, чтобы показывать ваш локальный предпросмотр во время видеозвонка.';

  @override
  String get callsCameraPermissionSettingsMessage =>
      'Доступ к камере заблокирован. Откройте системные настройки и включите локальный видеопросмотр.';

  @override
  String get callsCameraPermissionAction => 'Разрешить камеру';

  @override
  String get callsCameraUnavailableTitle => 'Камера недоступна';

  @override
  String get callsCameraUnavailableMessage =>
      'Не удалось запустить локальный предпросмотр камеры на этом устройстве.';

  @override
  String get callsCameraUnsupportedMessage =>
      'На этой платформе локальный видеопросмотр не поддерживается.';

  @override
  String get callsCameraOffMessage =>
      'Предпросмотр камеры отключён для этого демонстрационного звонка.';

  @override
  String get callsFrontCameraLabel => 'Фронтальная камера';

  @override
  String get callsRearCameraLabel => 'Основная камера';

  @override
  String get backgroundOptimizationDisabledTitle => 'Фоновые эффекты упрощены';

  @override
  String get backgroundOptimizationDisabledMessage =>
      'TwoSpace заметил стабильные просадки кадров и отключил тяжёлые фоновые эффекты, чтобы прокрутка и работа с чатами оставались плавными.';

  @override
  String get backgroundOptimizationOpenSettings =>
      'Открыть настройки оформления';

  @override
  String get roomJoinRuleLabel => 'Кто может вступить';

  @override
  String get roomJoinRulePublic => 'Открыто для всех';

  @override
  String get roomJoinRulePublicDescription =>
      'Любой пользователь может найти и вступить в эту комнату.';

  @override
  String get roomJoinRuleInviteOnly => 'Только по приглашению';

  @override
  String get roomJoinRuleInviteOnlyDescription =>
      'Вступить в эту комнату могут только приглашённые пользователи.';

  @override
  String get roomJoinRuleApproval => 'Требуется одобрение';

  @override
  String get roomJoinRuleApprovalDescription =>
      'Пользователи могут запросить доступ, но вступление требует одобрения.';

  @override
  String get roomHistoryVisibilityLabel => 'Кто видит историю';

  @override
  String get roomHistoryVisibilityWorldReadable => 'Все';

  @override
  String get roomHistoryVisibilityWorldReadableDescription =>
      'Любой пользователь может просматривать предыдущие сообщения.';

  @override
  String get roomHistoryVisibilityJoined => 'Вступившие участники';

  @override
  String get roomHistoryVisibilityJoinedDescription =>
      'Предыдущие сообщения видят только вступившие участники.';

  @override
  String get roomHistoryVisibilityInvited => 'Только приглашённые';

  @override
  String get roomHistoryVisibilityInvitedDescription =>
      'Предыдущие сообщения видят только приглашённые пользователи.';

  @override
  String get loginUsernameOnlyError =>
      'Для входа используйте username TwoSpace.';

  @override
  String get twoFactorInvalidCodeMessage =>
      'Код 2FA или recovery phrase неверны. Попробуйте ещё раз.';

  @override
  String get twoFactorCodeRequiredMessage =>
      'Введите код из приложения-аутентификатора или используйте recovery phrase.';

  @override
  String get twoFactorEnabledMessage =>
      'Двухфакторная аутентификация включена.';

  @override
  String twoFactorEnableFailed(String error) {
    return 'Не удалось включить 2FA: $error';
  }

  @override
  String get twoFactorSetupTitle => 'Настройка двухфакторной аутентификации';

  @override
  String get twoFactorSetupDescription =>
      'Сканируйте QR-код в приложении-аутентификаторе, сохраните recovery phrase и затем подтвердите включение свежим TOTP-кодом.';

  @override
  String get twoFactorSecretTitle => 'Или введите этот секретный ключ вручную';

  @override
  String get twoFactorRecoveryPhraseTitle =>
      'Recovery phrase. Сохраните её в безопасном месте перед включением 2FA.';

  @override
  String get twoFactorVerificationCodeLabel => 'Код подтверждения';

  @override
  String get twoFactorVerificationCodeHint =>
      'Введите текущий код из приложения-аутентификатора';

  @override
  String get twoFactorVerifyEnableAction => 'Подтвердить и включить 2FA';

  @override
  String get twoFactorDisableSectionTitle =>
      'Отключить двухфакторную аутентификацию';

  @override
  String get twoFactorDisableSectionDescription =>
      'Выключите 2FA с помощью актуального кода из аутентификатора или одноразовой recovery phrase.';

  @override
  String get twoFactorDisableCodeHint =>
      'Введите актуальный код из аутентификатора';

  @override
  String get twoFactorRecoveryPhraseFieldLabel => 'Recovery phrase';

  @override
  String get twoFactorRecoveryPhraseFieldHint =>
      'Вставьте recovery phrase, если доступа к приложению-аутентификатору больше нет';

  @override
  String get twoFactorDisableAction => 'Отключить 2FA';

  @override
  String get twoFactorDisableCredentialsRequired =>
      'Чтобы отключить 2FA, введите код из аутентификатора или recovery phrase.';

  @override
  String get twoFactorDisabledMessage =>
      'Двухфакторная аутентификация отключена.';

  @override
  String twoFactorDisableFailed(String error) {
    return 'Не удалось отключить 2FA: $error';
  }

  @override
  String get twoFactorLoginRecoveryHint =>
      'Или вставьте recovery phrase вместо кода';

  @override
  String get chatListTimeoutTitle => 'Сервер отвечает слишком долго';

  @override
  String chatListTimeoutMessage(String error) {
    return 'Сохранённые чаты остаются доступными. Попробуйте обновить список ещё раз.\n$error';
  }

  @override
  String get chatListOfflineTitle => 'Нет соединения с сервером';

  @override
  String chatListOfflineMessage(String error) {
    return 'Локальный кэш по-прежнему доступен. Список обновится автоматически, когда соединение вернётся.\n$error';
  }

  @override
  String get groupAvatarTitle => 'Аватар группы';

  @override
  String get groupAvatarSubtitle =>
      'Аватар можно добавить сразу при создании группы.';

  @override
  String get chooseFileButton => 'Выбрать файл';

  @override
  String get groupHistoryTitle => 'Сохранять историю для новых участников';

  @override
  String get fileAccessDeniedMessage => 'Нет доступа к выбранному файлу.';

  @override
  String get avatarFileAccessDeniedMessage =>
      'Нет доступа к файлу аватара. Попробуйте выбрать другой файл.';

  @override
  String get profileEmptySelfHint =>
      'Профиль пока выглядит пустым. Добавьте имя, описание или локацию, чтобы он выглядел полноценно.';

  @override
  String get profileEmptyOtherHint =>
      'Пользователь ещё не заполнил профиль или сервер не вернул подробные поля.';

  @override
  String get twoFactorDisableConfirmContent =>
      'Отключить двухфакторную аутентификацию для этого аккаунта? Чтобы вернуть дополнительную защиту, её придётся настроить заново.';

  @override
  String get betaTestLabel => 'Бета-тест';

  @override
  String get homeBetaWelcomeTitle => 'Приветствуем в бета-тесте TwoSpace!';

  @override
  String get homeBetaWelcomeBody =>
      'Функционал может часто меняться. Отправляйте предложения.';

  @override
  String get devMenuInfoLoading => 'Собираем сведения об устройстве…';

  @override
  String get devMenuAppNameLabel => 'Название приложения';

  @override
  String get devMenuVersionLabel => 'Версия';

  @override
  String get devMenuPackageNameLabel => 'Имя пакета';

  @override
  String get devMenuDeviceLabel => 'Устройство';
}
