# План интеграции Aegis

Актуальный рабочий план полной миграции клиента с Matrix на Aegis.

## Принципы

- Matrix больше не рассматривается как целевой backend.
- Папка `Aegis-main/` используется только как справка по закрытому протоколу и в итоговую сборку не входит.
- Если серверная часть ещё не даёт полноценный API для сценария, во Flutter допускается временный локальный кэш/заглушка поверх реального Aegis-транспорта.
- Любая новая пользовательская строка должна проходить через l10n.

---

## Что уже готово в протоколе Aegis

По коду из `Aegis-main/` в сервере и протоколе уже есть:

- Handshake + TCP transport
- Auth / Register
- User search
- Private chat message
- Channel create / join / message
- Profile get / update
- Channel edit
- Message edit / delete
- Group create / edit / send message
- Role / permission handlers для channel/group

## Ограничения текущего протокола/сервера

- Сервер создаёт `SessionToken` в БД, но текущий `AuthHandler` возвращает клиенту пустой `SessionToken`
- Отдельного публичного API списка приватных чатов/каналов для клиента пока нет
- Пагинированная история сообщений для Flutter-клиента в SDK пока не оформлена отдельным методом
- Typing indicators в production-flow не готовы
- Presence тип есть в enum, но клиентский realtime-flow для него не собран
- Media transfer для Aegis-протокола как полноценный серверный сценарий ещё не доведён до Flutter-интеграции

Из-за этого клиент сейчас использует смешанный подход:

- реальный Aegis transport для auth / search / direct send / channel create / channel send / profile update;
- локальный persisted store во Flutter для списка диалогов, локальной истории и UI-состояния.

---

## Выполнено в приложении

### Auth / session

- [x] `AegisClient` переведён на реальный JSON auth-request вместо raw Matrix-style token flow
- [x] Поддержан auth по username/password
- [x] Поддержан token auth для будущего корректного server-returned session token
- [x] `AegisAuthService.login()` сохраняет реальный `userId` и `username`
- [x] `AegisAuthService.restoreSession()` восстановлен для текущего server-state:
  - если серверный токен появится — будет использован он;
  - пока сервер его не возвращает, клиент переавторизуется по сохранённой credential-pair
- [x] `AuthNotifier.build()` теперь реально вызывает восстановление сессии
- [x] Регистрация больше не делает лишний повторный логин по email

### Chat / profile migration

- [x] Добавлен `AegisChatService` как основной Flutter-слой над `AegisClient`
- [x] Добавлен локальный persisted store для:
  - списка диалогов;
  - локальной истории сообщений;
  - профилей пользователей;
  - метаданных каналов/групп
- [x] Добавлен `AegisGroupService`-адаптер для экранов групп
- [x] `HomeScreen` переведён на Aegis-backed список чатов
- [x] `CreateChatScreen` переведён на Aegis direct chat / channel create
- [x] `ChatScreen` переведён на Aegis chat service
- [x] `ChatSettingsScreen` переведён на Aegis room settings
- [x] `CreateGroupScreen` переведён на Aegis group/channel flow
- [x] `GroupSettingsScreen` переведён на Aegis group adapter
- [x] `ProfileScreen` переведён на Aegis profile loading
- [x] `AuthListener` получает welcome-profile через Aegis
- [x] `chat_backend_factory.dart` больше создаёт Aegis backend
- [x] `chat_provider.dart` больше не использует Matrix backend

### l10n / UX

- [x] Строки создания чата больше не говорят пользователю про Matrix ID
- [x] Обновлены переводы `matrixIdDescription`, `matrixIdLabel`, `matrixIdExplanation` на всех поддерживаемых языках под Aegis/generic contact id

---

## Что ещё осталось сделать

### 1. Убрать оставшийся legacy Matrix-код из codebase

- [ ] Выпилить неиспользуемые `ChatMatrixService`, `GroupMatrixService`, `MatrixService` и matrix-* adapters
- [ ] Почистить `AuthService` от Matrix-only веток и комментариев
- [ ] Удалить matrix-specific provider registration и screen dependencies вне мигрированных сценариев

### 2. Завершить realtime delivery

- [ ] Проверить, как сервер пушит входящие private/channel/group сообщения в живое соединение
- [ ] Дособрать client-side обработку push-сообщений без локальных допущений
- [ ] Привязать unread counters и список чатов к реальным inbound событиям

### 3. Нормальный список диалогов и история с сервера

- [ ] Когда сервер даст явные list/history методы — убрать временный local-first индекс чатов
- [ ] Перевести `HomeScreen` и `ChatScreen` на server-backed history sync
- [ ] Добавить reconcile локального кэша и серверной истории

### 4. Media

- [ ] Подключить настоящий Aegis file transfer после готовности серверных handlers
- [ ] Убрать локальный file-path fallback для вложений

### 5. Presence / typing / push

- [ ] Подключить `UserPresence`
- [ ] Подключить typing indicators, когда серверный поток будет готов
- [ ] Настроить push-уведомления уже поверх Aegis user/channel events

### 6. Криптография

- [ ] Генерация реальной X25519 keypair на клиенте
- [ ] Передача реального public key при регистрации
- [ ] Переход на настоящий session token вместо credential-pair fallback
- [ ] Дальнейшая E2E интеграция поверх X3DH / ratchet после готовности server/client SDK

---

## Текущий статус миграции

### Уже работает на Aegis

- логин
- регистрация
- восстановление сессии
- поиск пользователей
- открытие direct chat
- создание channel/group chat
- отправка private message
- отправка channel message
- загрузка и редактирование профиля
- базовые настройки комнаты/группы на клиентском уровне

### Временно реализовано client-side кэшем

- список диалогов
- локальная история чата
- часть group-management UI
- часть room settings UI
- media fallback через локальные файлы

### Требует следующего прохода

- полная зачистка legacy Matrix файлов
- server-backed history / list APIs
- полноценный inbound realtime
- presence / typing / media protocol

---

## Решения, принятые в этом проходе

- Не держать Matrix как fallback-путь
- Где сервер уже готов — ходить в реальный Aegis
- Где серверного API пока не хватает — закрывать сценарий локальным persisted store, чтобы продукт оставался рабочим
- Не изменять `Aegis-main/`, а только использовать его как спецификацию
