# План интеграции протокола Aegis

Этот файл — рабочий чеклист по поэтапной замене Matrix/заглушек на реальный Aegis-протокол.
Работаем последовательно, один пункт за раз.

---

## ✅ Уже сделано

- [x] Скопированы файлы `AegisDartClient` → `lib/services/aegis/`
- [x] Создан `AegisAuthService` (`lib/services/aegis_auth_service.dart`)
- [x] `AuthService.loginUser` → делегирует в `AegisAuthService.login`
- [x] `AuthService.registerUser` → делегирует в `AegisAuthService.register`
- [x] `AuthService.signOut` → делегирует в `AegisAuthService.logout`
- [x] `AuthService.restoreSessionFromToken` → пробует Aegis, затем Matrix
- [x] `Environment` расширен: `aegisHost`, `aegisPort`, `aegisConnectTimeout`
- [x] `MaterialApp.locale` подключён к `SettingsService.languageNotifier`
- [x] Виджет `LanguageSwitcherButton` (`lib/widgets/language_switcher.dart`)
- [x] Переключатель языка на экране **логина**
- [x] Переключатель языка на экране **регистрации**
- [x] Переключатель языка на экране **настроек** (заменён старый Dropdown)

---

## 🔲 Этап 1 — Auth & сессии (приоритет: высокий)

### 1.1 Доработать flow входа
- [ ] После успешного Aegis-логина сохранять полноценный `userId` (сейчас username)
- [ ] Разобраться, возвращает ли сервер токен сессии отдельно от пары user:pass
- [ ] Если сервер возвращает JWT/session token — хранить его вместо raw-пароля

### 1.2 Восстановление сессии при запуске
- [ ] `AuthNotifier.build()` → вызывать `AegisAuthService.restoreSession()`
- [ ] При успехе — `AuthState.authenticated(userId, token)`
- [ ] При неудаче — `AuthState.unauthenticated()`

### 1.3 Экран логина
- [ ] Поле «username или email» уже есть — убедиться что передаётся правильно
- [ ] Показывать понятные ошибки Aegis (`ConnectionException`, `TimeoutException`)
- [ ] Добавить индикатор «Подключение к серверу…» пока идёт TCP-handshake

### 1.4 Экран регистрации
- [ ] Шаг 1 (имя/email/пароль) — уже подключён к `AegisAuthService.register`
- [ ] Убрать/скрыть неиспользуемые шаги (телефон, аватар) если сервер их не требует
- [ ] После регистрации автоматически входить в аккаунт (уже реализовано)

### 1.5 X3DH keypair (будущее)
- [ ] Генерировать реальную X25519 keypair при регистрации (сейчас placeholder)
- [ ] Хранить приватный ключ в `FlutterSecureStorage`
- [ ] Передавать публичный ключ в `AegisAuthService.register`

---

## 🔲 Этап 2 — Поиск пользователей

**Готово в клиенте:** `AegisClient.searchUsers(query)` → `UserSearchResponse`

- [ ] Создать/обновить `AegisUserService` для поиска пользователей
- [ ] Подключить к `SearchContactsScreen` — заменить Matrix-заглушку
- [ ] Подключить к `AdvancedSearchScreen` — поиск по username
- [ ] Отображать результаты: аватар (заглушка), username, онлайн-статус

---

## 🔲 Этап 3 — Приватные чаты (1-на-1)

**Готово в клиенте:** `AegisClient.sendPrivateMessage(toUserId, content)`

- [ ] Создать `AegisMessageService` как Dart-слой поверх `AegisClient`
- [ ] Реализовать получение входящих сообщений через `AegisClient.messages` Stream
- [ ] Подключить `ChatScreen` к Aegis вместо Matrix:
  - Отправка текстовых сообщений
  - Получение в реальном времени
  - История (если сервер поддерживает)
- [ ] Подключить `HomeScreen` — список чатов (пока заглушка)

---

## 🔲 Этап 4 — Каналы

**Готово в клиенте:**
- `AegisClient.createChannel(name, description, type)`
- `AegisClient.joinChannel(channelId)`
- `AegisClient.sendChannelMessage(channelId, content)`
- Типы каналов: `ChannelType.public` / `private` / `group`

- [ ] Создать экран «Каналы» (список публичных каналов)
- [ ] Подключить `CreateGroupScreen` → перенаправить на создание Aegis-канала
- [ ] `GroupSettingsScreen` → управление участниками через Aegis API
- [ ] Отправка сообщений в канал из `ChatScreen`

---

## 🔲 Этап 5 — Присутствие (UserPresence)

**Доступно в протоколе:** `MessageType.userPresence` (тип 9)

- [ ] Обрабатывать входящие `UserPresence` сообщения в Stream
- [ ] Обновлять `UserStatusIndicator` в реальном времени
- [ ] Отправлять своё presence при открытии/закрытии приложения

---

## 🔲 Этап 6 — Групповые сообщения

**Доступно в протоколе:** `MessageType.groupMessage/groupCreate/groupLeave`

> ⚠️ Серверные обработчики GroupMessage и т.д. помечены в `todo.md` как незавершённые.
> Пункты ниже — на будущее, когда сервер поддержит.

- [ ] `AegisClient.sendGroupMessage(groupId, content)` (добавить метод)
- [ ] Создание групп через протокол
- [ ] Выход из группы

---

## 🔲 Этап 7 — Typing indicators

**Описан в `todo.md` протокола:** `MessageType.UserTyping` (планируется)

- [ ] Отправлять typing event при наборе текста
- [ ] Отображать «печатает…» в `ChatScreen`

---

## 🔲 Этап 8 — История сообщений

- [ ] Уточнить, поддерживает ли сервер пагинированную историю
- [ ] Реализовать подгрузку истории при открытии чата
- [ ] Кешировать сообщения локально (SQLite / Hive)

---

## 🔲 Этап 9 — Push-уведомления

- [ ] Отправлять `FCM/APNs` токен на Aegis-сервер при логине
- [ ] Обрабатывать входящие уведомления когда приложение в фоне
- [ ] Настроить `notification_provider.dart` для Aegis-уведомлений

---

## 🔲 Этап 10 — Шифрование (E2E)

**Описано в README:** X3DH + AES-GCM

- [ ] Реализовать X25519 keypair при регистрации (см. п. 1.5)
- [ ] Реализовать X3DH handshake для каждого нового чата
- [ ] Шифровать payload перед отправкой через `AegisCryptoProvider`
- [ ] Расшифровывать входящие сообщения

---

## Технические заметки

### Адрес сервера
Настраивается через `.env`:
```
AEGIS_HOST=localhost
AEGIS_PORT=8888
```

### Запуск Aegis-сервера локально
```bash
cd Aegis-main
dotnet run --project src/Aegis.Server
```

### Структура клиентских файлов
```
lib/services/aegis/
  aegis_client.dart       ← Главный клиент (AegisClient)
  transport.dart          ← TCP-соединение (AegisTransport)
  message.dart            ← Структура Message
  message_encoder.dart    ← Сериализация/десериализация
  message_payloads.dart   ← Все Request/Response типы
  message_type.dart       ← Enum MessageType
  protocol_constants.dart ← Magic, version, sizes
  exceptions.dart         ← ConnectionException, etc.
  logger.dart             ← AegisLogger

lib/services/
  aegis_auth_service.dart ← Обёртка для Flutter (Singleton)
```

### Что НЕ делать
- Не редактировать папку `Aegis-main/` — это только справка
- Не трогать Matrix-код пока — нужен как fallback если Aegis недоступен
