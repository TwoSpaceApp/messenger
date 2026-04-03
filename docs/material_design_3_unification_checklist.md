# Material Design 3 Unification Checklist

Обновлено: 2026-04-03

## Цель документа

Этот файл нужен как единая рабочая карта для перевода всего приложения к одному визуальному языку на базе Material Design 3.

Документ закрывает четыре задачи:
- фиксирует общую иерархию интерфейса приложения;
- фиксирует единый набор компонентов и паттернов;
- перечисляет все экраны проекта, включая вспомогательные и внутренние;
- позволяет отмечать статус переработки каждого экрана в единый дизайн.

## Как пользоваться

Для каждого экрана ниже нужно держать отмеченным только один фактический статус:

- `[x] Backlog` — экран еще не перерабатывался
- `[x] In progress` — идет активная переработка
- `[x] UI ready` — экран визуально собран, но требует сверки
- `[x] QA passed` — экран проверен и принят

По умолчанию все экраны в этом документе заведены как `Backlog`.

## Глобальная цель по стилю

Целевой стиль приложения:
- единый Material Design 3 без смешения нескольких визуальных систем в пределах одного пользовательского потока;
- общие правила для AppBar, Card, ListTile, Button, Dialog, BottomSheet, Search, Form, Empty/Error/Loading states;
- единая система отступов, радиусов, elevation, типографики и состояния компонентов;
- одинаковая логика адаптива для mobile, tablet и desktop;
- современный, спокойный, технологичный визуальный язык без случайных локальных исключений.

## Целевая иерархия приложения

### Уровень 0. App Shell

- Корневой контейнер приложения
- Глобальная тема Material Design 3
- Единый `ColorScheme`
- Единая типографика
- Единые motion-правила
- Глобальные transient states: Snackbar, Dialog, BottomSheet, Banner

### Уровень 1. Entry / Auth

- Splash
- Welcome
- Login
- Register
- Recovery / OTP / 2FA / biometric setup

Требование:
- экраны должны выглядеть как одна серия, а не как набор разных лендингов;
- единая hero-зона, форма, supporting text, CTA-блок, secondary actions.

### Уровень 2. Primary Navigation

- MainScreen
- Home / Chats
- Calls
- People / Contacts
- Settings

Требование:
- единый navigation shell;
- одинаковое поведение top app bar, FAB, scroll, search entry points;
- единое поведение safe areas, bottom navigation, large/medium top app bar.

### Уровень 3. Section Screens

- списки чатов;
- списки контактов;
- список настроек;
- списки результатов поиска;
- списки медиа, участников, объектов хранения.

Требование:
- унифицированный список с одним стилем плитки, состояний, фильтров и секций.

### Уровень 4. Detail Screens

- ChatScreen
- ProfileScreen
- GroupSettingsScreen
- ChatSettingsScreen
- CallScreen
- UpdateScreen

Требование:
- detail-экраны должны собираться из стандартных detail-блоков, а не из локально придуманных панелей.

### Уровень 5. Modal / Support Surfaces

- поиск;
- подтверждения;
- action sheets;
- picker-экраны;
- feedback и privacy dialogs.

Требование:
- dialogs, menus, sheets, pickers должны жить в одном визуальном стандарте MD3.

### Уровень 6. Internal / Dev

- DevMenuScreen

Требование:
- внутренние экраны могут быть проще визуально, но должны использовать те же базовые токены и компоненты.

## Базовые MD3 foundations

### Цвет и surface system

Нужно стандартизировать:
- `surface`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`;
- `primary`, `secondary`, `tertiary` только как системные акценты;
- `error` только для destructive и critical состояний;
- одинаковое поведение цветовых ролей в light и dark;
- отказ от локальных случайных градиентов там, где они не поддерживают иерархию.

### Типографика

Нужно зафиксировать:
- `headlineSmall` для основных заголовков экранов;
- `titleLarge` для ключевых секций;
- `titleMedium` для card/page blocks;
- `bodyLarge` и `bodyMedium` для основной информации;
- `labelLarge` для CTA и chip-like controls;
- одинаковые line-height и weight для secondary text.

### Радиусы и elevation

Нужно выбрать системные значения:
- `8` — compact corners;
- `12` — стандартные inputs и small cards;
- `16` — medium containers;
- `20-24` — hero cards / sheets / modal surfaces.

Elevation:
- low elevation для card/list sections;
- явный elevated surface только там, где нужен акцент;
- не смешивать glass-эффекты и плотные MD3-surface без причины.

### Spacing system

Единая шкала:
- `4`, `8`, `12`, `16`, `20`, `24`, `32`

Нужно убрать экраны, где расстояния живут случайными значениями без общего ритма.

### Motion

Нужно выровнять:
- screen transition behavior;
- FAB / sheet / dialog animation;
- loading-to-content transition;
- animated switches между list/detail/filter states.

Цель:
- аккуратное MD3-ощущение, а не набор разных анимационных подходов.

## Единый инвентарь компонентов

Ниже перечислены компоненты, которые должны стать каноническими для всего приложения.

### 1. App shell и navigation

- `NavigationBar` для mobile primary navigation
- `NavigationRail` для tablet/desktop при необходимости
- `FloatingActionButton` и `LargeFloatingActionButton` для ключевых действий
- `TopAppBar` в вариантах `small`, `medium`, `large`
- `TabBar` только как часть стандартного section navigation
- `SearchBar` и при необходимости `SearchAnchor`

### 2. Surface components

- `Card`
- `FilledCard`
- `OutlinedCard`
- section container для grouped settings/list blocks
- стандартный page hero container

### 3. List and discovery

- `ListTile`
- `ExpansionTile`
- `SegmentedButton`
- `FilterChip`
- `AssistChip`
- `SuggestionChip`
- `Badge`
- `Divider`
- section header row

### 4. Forms and input

- `TextField`
- `TextFormField`
- `DropdownMenu` или `DropdownButtonFormField`
- `SwitchListTile`
- `CheckboxListTile`
- `RadioListTile`
- date / picker entry fields
- supporting and validation text

### 5. Actions

- `FilledButton`
- `FilledButton.icon`
- `OutlinedButton`
- `TextButton`
- destructive button pattern
- inline action row pattern

### 6. Feedback and status

- `CircularProgressIndicator`
- `LinearProgressIndicator`
- loading skeleton pattern
- empty state pattern
- error state pattern
- `SnackBar`
- inline banners

### 7. Dialogs and sheets

- `AlertDialog`
- standard confirmation dialog
- `showModalBottomSheet` в одном стиле
- picker sheets
- action sheets

### 8. Messaging-specific components

- chat list tile
- message bubble
- composer bar
- reply preview
- attachment action strip
- unread badge
- room summary card
- member tile

### 9. Settings-specific components

- settings section card
- settings hero header
- settings searchable item tile
- settings value tile with trailing control

### 10. Profile / person-specific components

- profile hero block
- avatar stack / avatar picker
- info row
- action row for message / call / invite
- presence chip

## Компоненты, которые должны быть переиспользуемыми

Нужно довести до общего набора reusable-компонентов:
- `AppPageHeader`
- `AppSectionHeader`
- `AppSectionCard`
- `AppListItem`
- `AppSearchHeader`
- `AppEmptyState`
- `AppErrorState`
- `AppLoadingState`
- `AppConfirmDialog`
- `AppActionSheet`
- `AppPreferenceTile`
- `AppFormSection`
- `ChatRoomTile`
- `ProfileHeroCard`
- `SettingsGroupCard`

## Канонические типы экранов

Чтобы не проектировать каждый экран с нуля, каждый экран должен быть приведен к одному из типов:

### Type A. Entry Screen

Для:
- splash
- welcome
- login
- register
- otp
- biometric

Шаблон:
- brand/header zone;
- supporting copy;
- main form or action cluster;
- primary CTA;
- secondary CTA / legal / recovery links.

### Type B. List Screen

Для:
- home
- people
- contacts
- settings search
- advanced search
- calls

Шаблон:
- medium or large top app bar;
- optional search/filter row;
- grouped list or card list;
- FAB или context action.

### Type C. Detail Screen

Для:
- chat
- profile
- chat settings
- group settings
- call
- update

Шаблон:
- top app bar;
- hero/summary block;
- body sections;
- secondary actions;
- destructive actions в нижней зоне.

### Type D. Form Screen

Для:
- create chat
- create group
- account settings
- feedback
- privacy setup flows

Шаблон:
- structured form sections;
- grouped inputs;
- clear validation and helper text;
- sticky or explicit bottom CTA.

### Type E. Settings Screen

Для:
- settings
- customization
- notifications
- privacy
- storage

Шаблон:
- searchable grouped preferences;
- one style of preference tile;
- consistent toggles, segmented controls, sliders and pickers.

## Порядок внедрения

Рекомендуемый порядок работы:

1. Foundations и reusable components
2. Main shell и primary navigation
3. Home / Chat / Chat settings / Group settings
4. People / Profile / Contacts / Search contacts
5. Settings cluster
6. Auth cluster
7. Secondary and internal screens

## Экранный реестр

Ниже перечислены все экраны, которые нужно привести к единому стилю MD3.

---

## Auth Flow

### SplashScreen

Файл: `lib/features/auth/presentation/screens/splash_screen.dart`

Роль:
- точка загрузки приложения и инициализации сервисов

Целевой тип:
- Type A. Entry Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести экран к одному launch-style с MD3 surface и brand hierarchy
- [ ] Стандартизировать progress indicator и supporting text
- [ ] Убрать визуальные решения, не совпадающие с Welcome/Login
- [ ] Проверить light/dark и safe areas

### WelcomeScreen

Файл: `lib/features/auth/presentation/screens/welcome_screen.dart`

Роль:
- приветственный экран перед входом

Целевой тип:
- Type A. Entry Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Единая hero-композиция с Login/Register
- [ ] Стандартизировать primary/secondary CTA
- [ ] Выстроить MD3 typography и vertical rhythm
- [ ] Синхронизировать иллюстрации, iconography и supporting copy

### LoginScreen

Файл: `lib/features/auth/presentation/screens/login_screen.dart`

Роль:
- основной вход пользователя

Целевой тип:
- Type A. Entry Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести поля и кнопки к одному MD3 form-standard
- [ ] Стандартизировать error, loading и disabled states
- [ ] Выровнять recovery-links и secondary navigation
- [ ] Проверить desktop/tablet layout и max-width формы

### RegisterScreen

Файл: `lib/features/auth/presentation/screens/register_screen.dart`

Роль:
- регистрация нового пользователя

Целевой тип:
- Type A. Entry Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Синхронизировать с Login по структуре формы и CTA
- [ ] Унифицировать helper/validation text
- [ ] Перевести сложные шаги на секционный MD3 form layout
- [ ] Проверить поведение длинных форм на mobile

### ForgotPasswordScreen

Файл: `lib/features/auth/presentation/screens/forgot_password_screen.dart`

Роль:
- восстановление доступа

Целевой тип:
- Type A. Entry Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Собрать как компактный MD3 recovery flow
- [ ] Стандартизировать message states и info banners
- [ ] Выравнять с Login/Register по spacing и top app bar
- [ ] Сделать единый confirmation/result state

### OtpScreen

Файл: `lib/features/auth/presentation/screens/otp_screen.dart`

Роль:
- ввод одноразового кода

Целевой тип:
- Type A. Entry Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Унифицировать OTP input pattern под MD3
- [ ] Стандартизировать timer, resend, error state
- [ ] Синхронизировать visual hierarchy с recovery flow
- [ ] Проверить accessibility и autofill behavior

### ChangeEmailScreen

Файл: `lib/features/auth/presentation/screens/change_email_screen.dart`

Роль:
- изменение email

Целевой тип:
- Type D. Form Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Перевести на стандартный account form layout
- [ ] Унифицировать top app bar и action area
- [ ] Выстроить helper/error/success states
- [ ] Синхронизировать с ChangePhone и AccountSettings

### ChangePhoneScreen

Файл: `lib/features/auth/presentation/screens/change_phone_screen.dart`

Роль:
- изменение телефона

Целевой тип:
- Type D. Form Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Использовать тот же шаблон, что и ChangeEmail
- [ ] Стандартизировать field grouping и CTA
- [ ] Проверить маски ввода и validation states
- [ ] Синхронизировать с OTP-related UX

### TfaSetupScreen

Файл: `lib/features/auth/presentation/screens/tfa_setup_screen.dart`

Роль:
- настройка двухфакторной аутентификации

Целевой тип:
- Type D. Form Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Собрать пошаговый secure setup flow в стиле MD3
- [ ] Унифицировать QR/code/manual entry blocks
- [ ] Стандартизировать warning/destructive/info states
- [ ] Выровнять с PrivacyScreen и BiometricSetupScreen

### BiometricSetupScreen

Файл: `lib/features/auth/presentation/screens/biometric_setup_screen.dart`

Роль:
- включение биометрии

Целевой тип:
- Type A. Entry Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Сделать компактный permission/setup flow в одном стиле с auth
- [ ] Стандартизировать иллюстрацию, icon container и CTA
- [ ] Проверить success/skip/failure states
- [ ] Синхронизировать с PrivacyScreen

### SsoWebviewScreen

Файл: `lib/features/auth/presentation/screens/sso_webview_screen.dart`

Роль:
- встроенный веб-поток SSO

Целевой тип:
- Type C. Detail Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Унифицировать верхнюю панель и loading state webview
- [ ] Стандартизировать error/retry/cancel UX
- [ ] Добавить MD3 container around status overlays
- [ ] Проверить вложенный browser-flow в app shell

---

## Main Navigation And Core Communication

### MainScreen

Файл: `lib/features/chat/presentation/screens/main_screen.dart`

Роль:
- главный shell приложения

Целевой тип:
- shell / primary navigation

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Зафиксировать один канонический MD3 navigation shell
- [ ] Стандартизировать `NavigationBar` или совместимый custom-shell под MD3 tokens
- [ ] Выровнять unread badges, active states и background surfaces
- [ ] Проверить tablet/desktop adaptation

### HomeScreen

Файл: `lib/features/chat/presentation/screens/home_screen.dart`

Роль:
- список диалогов и комнат

Целевой тип:
- Type B. List Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Утвердить канонический chat list tile
- [ ] Привести header, search entry, FAB и empty states к MD3
- [ ] Стандартизировать skeleton/loading/error states
- [ ] Выровнять списки комнат, presence и unread indicators

### ChatScreen

Файл: `lib/features/chat/presentation/screens/chat_screen.dart`

Роль:
- основной экран переписки

Целевой тип:
- Type C. Detail Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Зафиксировать единый message bubble system в духе MD3
- [ ] Унифицировать top app bar, composer, attachment row и reply preview
- [ ] Привести media/message states к одной визуальной системе
- [ ] Проверить search, selection mode, pinned/reaction UI и thread-like states

### ChatSettingsScreen

Файл: `lib/features/chat/presentation/screens/chat_settings_screen.dart`

Роль:
- настройки direct/channel room

Целевой тип:
- Type C. Detail Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести к каноническому detail settings layout
- [ ] Унифицировать sidebar/mobile detail navigation
- [ ] Стандартизировать info rows, action tiles, destructive blocks
- [ ] Проверить consistency с GroupSettingsScreen

### GroupSettingsScreen

Файл: `lib/features/chat/presentation/screens/group_settings_screen.dart`

Роль:
- настройки групп и управление участниками

Целевой тип:
- Type C. Detail Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести к тому же MD3-шаблону, что и ChatSettings
- [ ] Упростить visual density сложных moderation/settings блоков
- [ ] Унифицировать chips, dropdowns, member tiles и destructive actions
- [ ] Проверить desktop split-view и mobile stacked behavior

### CreateChatScreen

Файл: `lib/features/chat/presentation/screens/create_chat_screen.dart`

Роль:
- создание direct/group/join flows

Целевой тип:
- Type D. Form Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Зафиксировать единый multi-mode creation flow
- [ ] Привести tabs/forms/error banners к MD3
- [ ] Унифицировать segmented/tab behavior и CTA area
- [ ] Проверить, чтобы экран визуально совпадал с CreateGroupScreen

### CreateGroupScreen

Файл: `lib/features/chat/presentation/screens/create_group_screen.dart`

Роль:
- создание группы и room metadata

Целевой тип:
- Type D. Form Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Перевести на единый form-builder style с CreateChat
- [ ] Стандартизировать avatar picker, visibility cards и switches
- [ ] Выровнять action placement, validation и helper text
- [ ] Проверить длинные формы и keyboard behavior

### CallsScreen

Файл: `lib/features/chat/presentation/screens/calls_screen.dart`

Роль:
- список звонков / история коммуникаций

Целевой тип:
- Type B. List Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести список звонков к тому же list pattern, что Home/People
- [ ] Стандартизировать empty/loading/filter states
- [ ] Унифицировать call status chips и action affordances
- [ ] Проверить соответствие CallScreen по стилю

### CallScreen

Файл: `lib/features/chat/presentation/screens/call_screen.dart`

Роль:
- текущий аудио/видеозвонок

Целевой тип:
- Type C. Detail Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Собрать единый in-call control system
- [ ] Стандартизировать action buttons, overlays и participant surfaces
- [ ] Выровнять typography, timer, device state и permission messages
- [ ] Проверить dark theme и landscape behavior

### AdvancedSearchScreen

Файл: `lib/features/chat/presentation/screens/advanced_search_screen.dart`

Роль:
- расширенный поиск

Целевой тип:
- Type B. List Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Утвердить единый search pattern для всего приложения
- [ ] Привести фильтры к MD3 chips/segmented controls
- [ ] Унифицировать result list, empty и no-match states
- [ ] Синхронизировать с SettingsSearchScreen и SearchContactsScreen

---

## People And Profile

### PeopleScreen

Файл: `lib/features/people/presentation/screens/people_screen.dart`

Роль:
- каталог людей, контактов, поиска и invite actions

Целевой тип:
- Type B. List Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Зафиксировать единый people list pattern
- [ ] Унифицировать hero, search, filters, section headers и person tile
- [ ] Выровнять permission banner, invite and quick actions
- [ ] Проверить overlap с ContactsScreen и SearchContactsScreen

### ContactsScreen

Файл: `lib/features/profile/presentation/screens/contacts_screen.dart`

Роль:
- обертка над списком контактов в контексте primary navigation

Целевой тип:
- Type B. List Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Зафиксировать сокращенный chrome-режим для PeopleScreen
- [ ] Проверить соответствие top app bar и shell contexts
- [ ] Стандартизировать contextual differences без отдельного дизайна
- [ ] Исключить визуальный дрейф от основного PeopleScreen

### SearchContactsScreen

Файл: `lib/features/profile/presentation/screens/search_contacts_screen.dart`

Роль:
- быстрый поиск контактов в модальном/flow-контексте

Целевой тип:
- Type B. List Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Использовать тот же search pattern, что AdvancedSearch/SettingsSearch
- [ ] Зафиксировать compact chrome variant
- [ ] Синхронизировать поведение autofocus, clear, filter и result states
- [ ] Убедиться, что это не отдельный визуальный продукт, а вариант PeopleScreen

### ProfileScreen

Файл: `lib/features/profile/presentation/screens/profile_screen.dart`

Роль:
- профиль пользователя и собственный профиль

Целевой тип:
- Type C. Detail Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Зафиксировать один канонический profile hero block
- [ ] Унифицировать action row, info list, edit mode и avatar edit
- [ ] Привести к MD3 detail hierarchy без случайных локальных паттернов
- [ ] Проверить режимы self-profile и foreign-profile

### AccountSettingsScreen

Файл: `lib/features/profile/presentation/screens/account_settings_screen.dart`

Роль:
- настройки учетной записи, пароль, связанные действия

Целевой тип:
- Type E. Settings Screen / Type D. Form Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести к одному account/settings pattern
- [ ] Унифицировать grouped cards, password fields и destructive actions
- [ ] Синхронизировать с PrivacyScreen и SettingsScreen
- [ ] Проверить dialog pattern и validation states

---

## Settings Cluster

### SettingsScreen

Файл: `lib/features/settings/presentation/screens/settings_screen.dart`

Роль:
- главный экран настроек

Целевой тип:
- Type E. Settings Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Утвердить канонический settings home pattern
- [ ] Стандартизировать section cards, preference tiles и grouped actions
- [ ] Выровнять language/theme/search/danger zone в одном стиле
- [ ] Проверить соответствие всему settings cluster

### SettingsSearchScreen

Файл: `lib/features/settings/presentation/screens/settings_search_screen.dart`

Роль:
- поиск по настройкам

Целевой тип:
- Type B. List Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести search header и filter chips к единому стандарту
- [ ] Унифицировать result tile pattern
- [ ] Синхронизировать c AdvancedSearch и SearchContacts
- [ ] Проверить empty/no-results state

### CustomizationScreen

Файл: `lib/features/settings/presentation/screens/customization_screen.dart`

Роль:
- настройки темы и персонализации

Целевой тип:
- Type E. Settings Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести personalization flow к системному MD3 configurator style
- [ ] Стандартизировать preset cards, sliders, switches и preview surfaces
- [ ] Проверить, что personalization не ломает основной MD3 standard
- [ ] Зафиксировать границы кастомизации внутри единого design system

### NotificationsScreen

Файл: `lib/features/settings/presentation/screens/notifications_screen.dart`

Роль:
- уведомления и звук

Целевой тип:
- Type E. Settings Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Унифицировать settings card pattern с главным SettingsScreen
- [ ] Привести sound cards, toggles и preview actions к MD3
- [ ] Проверить grouped preference hierarchy
- [ ] Синхронизировать с Privacy/Storage по visual density

### PrivacyScreen

Файл: `lib/features/settings/presentation/screens/privacy_screen.dart`

Роль:
- privacy и security preferences

Целевой тип:
- Type E. Settings Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Зафиксировать secure settings layout
- [ ] Унифицировать toggles, navigation tiles и dialogs
- [ ] Синхронизировать с TfaSetup и BiometricSetup
- [ ] Проверить destructive and irreversible actions styling

### StorageScreen

Файл: `lib/features/settings/presentation/screens/storage_screen.dart`

Роль:
- управление памятью и очисткой

Целевой тип:
- Type E. Settings Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести complex settings/dashboard screen к одному MD3 language
- [ ] Унифицировать overview card, cleanup tiles, sheets и progress indicators
- [ ] Проверить графические элементы на соответствие MD3
- [ ] Согласовать с Notifications и Customization по section architecture

### FeedbackScreen

Файл: `lib/features/settings/presentation/screens/feedback_screen.dart`

Роль:
- отправка обратной связи

Целевой тип:
- Type D. Form Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Привести форму к стандарту MD3 form section
- [ ] Унифицировать field layout, helper text и action row
- [ ] Синхронизировать со screen family Account/Privacy/Create
- [ ] Проверить success/copy/send states

### UpdateScreen

Файл: `lib/features/settings/presentation/screens/update_screen.dart`

Роль:
- обновление приложения

Целевой тип:
- Type C. Detail Screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Зафиксировать один update/install detail pattern
- [ ] Унифицировать progress, permissions, warning dialogs и CTA
- [ ] Привести status surfaces к MD3 container logic
- [ ] Проверить large-screen behavior и long text states

### DevMenuScreen

Файл: `lib/features/settings/presentation/screens/dev_menu_screen.dart`

Роль:
- внутренний экран разработчика

Целевой тип:
- internal settings/tooling screen

Статус:
- [x] Backlog
- [ ] In progress
- [ ] UI ready
- [ ] QA passed

Checklist:
- [ ] Перевести на те же базовые токены, что и settings cluster
- [ ] Упростить и стандартизировать internal tools layout
- [ ] Сохранить функциональность без визуального дрейфа
- [ ] Не тратить усилия на уникальный декоративный стиль

---

## Cross-Screen Consistency Matrix

Ниже перечислены общие зоны, которые должны быть унифицированы сразу на уровне всего приложения.

### Top app bar

- [ ] Один набор top app bar variants для auth, list, detail, settings
- [ ] Единые leading/trailing icon sizes
- [ ] Единые title max-width, overflow и subtitle rules
- [ ] Одинаковая работа с scroll-under effect

### Buttons

- [ ] Все primary CTA перевести в единый `FilledButton` pattern
- [ ] Все secondary CTA перевести в `OutlinedButton` или `TextButton` по четким правилам
- [ ] Все destructive CTA выделять одинаково
- [ ] Убрать смешение локальных button styles без причины

### Cards and grouped sections

- [ ] Один стандарт section card
- [ ] Один стандарт hero card
- [ ] Один стандарт grouped preferences card
- [ ] Одинаковые внутренние paddings и dividers

### Lists

- [ ] Один стандарт item height/spacing для list surfaces
- [ ] Один стандарт avatar + title + subtitle + trailing layout
- [ ] Единая секционная структура списков
- [ ] Единые empty/loading/error overlays

### Forms

- [ ] Один стандарт input fields
- [ ] Один стандарт validation and helper text
- [ ] Один стандарт submit area
- [ ] Одинаковая работа keyboard-safe layouts

### Dialogs and bottom sheets

- [ ] Один стандарт confirm dialog
- [ ] Один стандарт picker/action bottom sheet
- [ ] Единые destructive dialogs
- [ ] Одинаковые corner, padding и action spacing

### Status states

- [ ] Один стандарт loading screen
- [ ] Один стандарт empty state
- [ ] Один стандарт error state
- [ ] Один стандарт retry state

## Definition Of Done для экрана

Экран считается завершенным только если:

- [ ] Он приведен к одному из канонических типов экранов
- [ ] Он использует только согласованный набор MD3-компонентов
- [ ] Он не имеет уникальных локальных layout-исключений без причины
- [ ] Он совпадает по стилю с соседними экранами своего пользовательского потока
- [ ] Он проверен в light и dark mode
- [ ] Он проверен минимум на mobile и tablet width
- [ ] Он имеет корректные loading, empty, error и disabled states
- [ ] Его dialogs, sheets, chips, buttons и fields не выбиваются из системы

## Приоритет переработки

### P0

- MainScreen
- HomeScreen
- ChatScreen
- PeopleScreen
- ProfileScreen
- SettingsScreen

### P1

- ChatSettingsScreen
- GroupSettingsScreen
- CreateChatScreen
- CreateGroupScreen
- NotificationsScreen
- PrivacyScreen
- AccountSettingsScreen
- LoginScreen
- RegisterScreen

### P2

- AdvancedSearchScreen
- CallsScreen
- CallScreen
- FeedbackScreen
- StorageScreen
- UpdateScreen
- WelcomeScreen
- ForgotPasswordScreen
- OtpScreen
- TfaSetupScreen
- BiometricSetupScreen
- ChangeEmailScreen
- ChangePhoneScreen
- SearchContactsScreen
- ContactsScreen
- CustomizationScreen
- SettingsSearchScreen
- SsoWebviewScreen
- SplashScreen
- DevMenuScreen

## Итог

Если этот документ поддерживать в актуальном состоянии, он может служить одновременно:
- дизайн-бэклогом;
- чек-листом для рефакторинга экранов;
- базой для постановки задач;
- картой перехода проекта к единому Material Design 3.