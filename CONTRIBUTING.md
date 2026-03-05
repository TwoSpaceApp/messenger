# Руководство для разработчиков (CONTRIBUTING)

Добро пожаловать в руководство по разработке TwoSpace! 🌌

Спасибо за интерес к нашему проекту. Этот документ описывает, как начать разработку и внести вклад.

## 🚀 Быстрый старт

### Требования

- **Flutter**: 3.38.8 (желательно совпадать с CI)
- **Dart**: 3.10.x (идёт вместе с Flutter)
- **Java**: 17 (для Android; в CI используется Java 17)
- **Xcode**: 13+ (для iOS)

> Примечание: приложение загружает `.env.example` (встроен в билд). Файл `.env` опционален и может переопределять значения (удобно для разработки/desktop).

### Установка

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/TwoSpaceApp/messenger.git
   cd messenger
   ```

2. **Установите зависимости:**
   ```bash
   flutter pub get
   ```

3. **(Опционально) Подготовьте `.env` файл:**
   ```bash
   cp .env.example .env
   # Отредактируйте .env с правильными значениями
   ```

4. **Запустите приложение:**
   ```bash
   flutter run
   ```

### Платформы (запуск и сборка)

#### Android

- Запуск: `flutter run -d android`
- Release как в CI: `flutter build apk --release --split-per-abi`
- AAB: `flutter build appbundle --release`

#### Windows

Нужно Visual Studio 2022 с компонентом **Desktop development with C++**.

- Включить таргет: `flutter config --enable-windows-desktop`
- Запуск: `flutter run -d windows`
- Release как в CI: `flutter build windows --release`

#### Linux (Ubuntu/Debian)

Пакеты для сборки (пример как в CI):

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
   clang cmake ninja-build pkg-config \
   libgtk-3-dev libsecret-1-dev libasound2-dev \
   libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
   libcurl4-openssl-dev libc-ares-dev libssl-dev \
   liblzma-dev
```

- Включить таргет: `flutter config --enable-linux-desktop`
- Запуск: `flutter run -d linux`
- Release как в CI: `flutter build linux --release`

## 🔧 Процесс разработки

### Структура проекта

```
lib/
├── main.dart                 # Точка входа, MaterialApp + locale + theme
├── config/                   # Конфигурация (environment.dart, UI tokens)
├── constants/                # Константы приложения
├── l10n/                     # ARB-файлы локализации (10 языков)
├── models/                   # Модели данных
├── providers/                # Riverpod-провайдеры
├── screens/                  # Экраны (UI)
├── services/
│   ├── aegis/                # Нижний уровень: Aegis TCP-протокол
│   │   ├── aegis_client.dart         # Основной клиент протокола
│   │   ├── transport.dart            # TCP-транспорт с буферизацией фреймов
│   │   ├── message.dart              # Модель протокольного фрейма
│   │   ├── message_encoder.dart      # Кодирование/декодирование бинарного фрейма
│   │   ├── message_payloads.dart     # Типы payload (запросы, ответы, сущности)
│   │   ├── message_type.dart         # Enum типов сообщений
│   │   ├── protocol_constants.dart   # Magic, размеры полей
│   │   └── exceptions.dart           # Исключения протокола
│   ├── aegis_auth_service.dart   # Flutter-обёртка над AegisClient (singleton)
│   ├── auth_service.dart         # Высокоуровневая аутентификация (Aegis + Matrix)
│   ├── settings_service.dart     # Тема, язык, настройки пользователя
│   └── ...                       # Прочие сервисы
├── sound/                    # Аудио (уведомления, звонки)
├── utils/                    # Вспомогательные функции
└── widgets/
    └── ...                       # Прочие переиспользуемые компоненты
```

### Кодовый стиль

Мы используем **Dart/Flutter conventions**:

```bash
# Форматирование кода
dart format lib test

# Анализ кода
flutter analyze
```

### Именование переменных

- **Private переменные**: с подчёркиванием `_privateVar`
- **Constants**: `camelCase` для конст, `SCREAMING_SNAKE_CASE` для констант-полей
- **Methods**: `camelCase`
- **Classes**: `PascalCase`

### Логирование

Используйте наш встроенный логгер:

```dart
import 'package:two_space_app/services/dev_logger.dart';

final logger = DevLogger('MyService');
logger.debug('Debug сообщение');
logger.info('Информация');
logger.warning('Предупреждение');
logger.error('Ошибка');
logger.exception('Исключение', exception, stackTrace);
```

### Тестирование

Напишите тесты для всех сервисов:

```bash
# Запустить все тесты
flutter test

# Запустить конкретный тест
flutter test test/unit/my_service_test.dart

# С покрытием
flutter test --coverage
```

Пример теста:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyService', () {
    test('делает что-то правильно', () {
      // Arrange
      final service = MyService();
      
      // Act
      final result = service.doSomething();
      
      // Assert
      expect(result, isTrue);
    });
  });
}
```

## � Работа с протоколом Aegis

Весь клиентский код протокола находится в `lib/services/aegis/`.

### Добавление новой операции

1. При необходимости добавьте значение в `MessageType` (`message_type.dart`) — согласуйте номер с командой сервера.
2. Добавьте классы request/response в `message_payloads.dart` (по аналогии с `RegistrationRequest` / `RegistrationResponse`).
3. Реализуйте метод в `AegisClient` (`aegis_client.dart`):
   ```dart
   Future<MyResponse> myOperation(MyRequest req) async {
     _ensureConnectedAndAuthenticated();
     final msg = Message.withType(MessageType.myOp, req.toBytes());
     msg.flags = ProtocolConstants.flagRequiresAck;
     await _transport.sendMessage(msg);
     final resp = await messages
         .firstWhere((m) => m.type == MessageType.myOpResponse)
         .timeout(const Duration(seconds: 10));
     return MyResponse.fromBytes(resp.payload);
   }
   ```
4. При необходимости добавьте proxy-метод в `AegisAuthService`.
5. Напишите unit-тест.

### Тест соединения вручную

```bash
# Запустить Aegis-сервер локально (из Aegis-main/)
# Затем установить переменные и запустить приложение:
AEGIS_HOST=localhost AEGIS_PORT=8888 flutter run
```

---

## 🌍 Локализация (i18n)

Все строки UI хранятся в `lib/l10n/app_<код>.arb`. Генерация кода запускается автоматически при сборке.

### Добавить новую строку

1. Добавьте ключ во **все** 10 ARB-файлов (`app_ru.arb`, `app_en.arb`, …).
2. Для строк с параметрами используйте плейсхолдеры:
   ```json
   "welcomeUser": "Привет, {name}!",
   "@welcomeUser": {
     "placeholders": { "name": { "type": "String" } }
   }
   ```
3. Перегенерируйте:
   ```bash
   flutter gen-l10n
   ```
4. Используйте в коде как **позиционный** параметр:
   ```dart
   Text(l10n.welcomeUser(username))
   ```
   > ⚠️ Не используйте именованные параметры (`l10n.welcomeUser(name: x)`) — gen-l10n генерирует позиционную сигнатуру.

### Добавить новый язык

1. Создайте `lib/l10n/app_<код>.arb` (скопируйте `app_en.arb` и переведите).
2. Добавьте `Locale('<код>')` в `supportedLocales` в `main.dart`.
3. Добавьте запись в список `_languages` в `lib/widgets/language_switcher.dart`.
4. Запустите `flutter gen-l10n`.

### Смена языка в рантайме

Используйте `SettingsService.setLanguage(code)`. Реактивная связка через `ValueListenableBuilder<String>` в `main.dart` применяет новую `locale` немедленно.

---

## �📝 Правила коммитов

Используйте **Conventional Commits**:

```
type(scope): subject

body (опционально)
```

### Типы коммитов:

- `feat`: новая функция
- `fix`: исправление бага
- `refactor`: рефакторинг без изменения функциональности
- `test`: добавление/обновление тестов
- `docs`: документация
- `chore`: обновления зависимостей, конфигурации
- `ci`: CI/CD pipeline
- `perf`: оптимизация производительности

### Примеры:

```
feat(auth): добавить 2FA аутентификацию
fix(chat): исправить крах при отправке больших файлов
docs(readme): обновить инструкции по установке
test(services): добавить unit-тесты для AegisService
```

## 🔄 Git Workflow

1. **Создайте ветку от `main`:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feat/my-feature
   ```

2. **Сделайте изменения и закоммитьте:**
   ```bash
   git add .
   git commit -m "feat(chat): добавить реакции на сообщения"
   ```

3. **Запушьте ветку:**
   ```bash
   git push origin feat/my-feature
   ```

4. **Создайте Pull Request на GitHub**

5. **Ждите review и CI checks**

## 🧪 Pre-commit Checks

Перед push убедитесь:

```bash
# 1. Форматирование
dart format lib test

# 2. Анализ
flutter analyze

# 3. Тесты
flutter test --coverage

# 4. Сборка (если возможно)
flutter build apk --release --split-per-abi
flutter build windows --release (для Windows)
flutter build linux --release (для Linux)
```

## 🤖 CI артефакты (что ожидать)

Сборки публикуются в GitHub Actions → конкретный workflow run → **Summary** и **Artifacts**.

- Android:
   - `app-debug.apk` (PR)
   - `app-*-release.apk` (split per ABI) + `app-release.aab` (push/manual)
- Windows:
   - артефакт `twospace-windows-debug` (PR) или `twospace-windows-release` (push/manual)
- Linux:
   - артефакт `twospace-linux-debug` (PR) или `twospace-linux-release` (push/manual)

Примечание: GitHub Actions отдаёт артефакты как `.zip` (это нормально). Внутри — файлы приложения (без вложенного второго архива).

## 🐛 Репортинг багов

Если нашли баг, воспользуйтесь шаблоном в Issues, чтобы сообщить о проблеме

## ✨ Запрос функций

Хотите новую функцию?

1. **Создайте Issue** с заголовком:
   ```
   [FEATURE] Добавить голосовые сообщения
   ```
2. **Опишите:**
   - Что нужно сделать
   - Почему это важно
   - Возможные варианты реализации

## 📚 Документация

Документируйте ваш код:

```dart
/// Сервис для работы с Matrix/Synapse сервером
/// 
/// Отвечает за:
/// - Аутентификацию пользователя
/// - Отправку/получение сообщений
/// - Управление комнатами
/// 
/// Пример использования:
/// ```dart
/// final service = MatrixService();
/// await service.login(userId, password);
/// await service.sendMessage(roomId, 'Привет');
/// ```
class MatrixService {
  /// Отправить сообщение в комнату
  /// 
  /// Параметры:
  /// - [roomId]: ID комнаты в Matrix
  /// - [message]: Текст сообщения
  /// 
  /// Выбросит [MatrixException] если сообщение не отправилось
  Future<void> sendMessage(String roomId, String message) async {
    // implementation
  }
}
```

## 🔐 Безопасность

- **Никогда** не коммитьте `.env` или ключи
- Используйте `flutter_secure_storage` для чувствительных данных (токены, учётные данные)
- Проверяйте входные данные перед использованием
- Используйте HTTPS для всех REST API запросов

## 📞 Связь

- 🔗 [Telegram-канал](https://t.me/twospace_messenger)
- 🌐 [Официальный сайт](https://twospace.ru)
- 📧 support@twospace.ru

## 📜 Лицензия

Проект распространяется под **Elastic License 2.0**.  
При внесении изменений вы соглашаетесь с условиями лицензии.

---

**Спасибо за вклад!** 🎉  
Любые вопросы — создавайте Issue или пишите в Telegram!
