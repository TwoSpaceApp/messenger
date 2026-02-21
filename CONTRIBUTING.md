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

### Структура проекта (TODO: актуализировать)

```
lib/
├── main.dart                 # Точка входа
├── config/                   # Конфигурация (environment, UI tokens)
├── constants/                # Константы приложения
├── models/                   # Модели данных
├── screens/                  # Экраны (UI)
├── services/                 # Бизнес-логика (Aegis, auth, chat)
├── sound/                    # Всё связяное с аудио (Пока в бете)
├── utils/                    # Вспомогательные функции
└── widgets/                  # Переиспользуемые компоненты
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

## 📝 Правила коммитов

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
- Используйте `flutter_secure_storage` для чувствительных данных
- Проверяйте входные данные перед использованием
- Используйте HTTPS для всех API запросов

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
