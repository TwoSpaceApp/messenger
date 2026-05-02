# Руководство для разработчиков (CONTRIBUTING)

Добро пожаловать в руководство по разработке TwoSpace! 🌌

Спасибо за интерес к нашему проекту. Этот документ описывает, как начать разработку и внести вклад.

## 🚀 Быстрый старт

### Требования

- **Flutter**: 3.38.8 (желательно совпадать с CI)
- **Dart**: 3.10.x (идёт вместе с Flutter)
- **Java**: 17 (для Android; в CI используется Java 17)
- **Xcode**: 13+ (для iOS)

> Примечание: проект использует `envied`. Рабочие значения берутся из локального `.env`, а [.env.example](.env.example) служит только шаблоном без секретов.

> Для Aegis не нужно добавлять старые signed-handshake переменные. Обычно клиенту достаточно адреса и порта, а `api_id` и `api_hash` передаются самим клиентом в handshake. `AEGIS_TRANSPORT_MASKING_KEY` указывайте только если сервер явно включает `Server:EnableTransportMasking`.

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

3. **Подготовьте `.env` файл:**
   ```bash
   cp .env.example .env
   # Отредактируйте .env с нужными значениями
   dart build -d
   ```

   Правила работы с env:

   - редактируйте только `.env`
   - не кладите секреты в `.env.example`
   - не коммитьте `.env`
   - после любого изменения `.env` обязательно перегенерируйте [lib/core/config/env.g.dart](lib/core/config/env.g.dart)

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

### Архитектура и Структура проекта

Проект использует архитектуру **Feature-First** (Feature-Driven), что означает группировку кода по функциональным модулям. Для управления состоянием используется **Riverpod**, а для навигации — **GoRouter**.

```text
lib/
├── core/                     # Ядро: общие элементы для всего приложения
│   ├── config/               # Настройки окружения (Envied), темы, UI-токены
│   ├── constants/            # Цветовые палитры, строки, константы
│   ├── l10n/                 # Переводы и файлы локализации (.arb)
│   ├── models/               # Базовые доменные модели (User, Chat)
│   ├── navigation/           # Настройки GoRouter (app_router.dart)
│   ├── network/              # Логика клиента протокола Aegis и Dio
│   ├── providers/            # Глобальные Riverpod-провайдеры (тема, язык)
│   ├── services/             # Системные сервисы (Sentry, Storage)
│   ├── sound/                # Аудио-движок (запись и воспроизведение)
│   ├── utils/                # Утилиты и хелперы (JWT, шифрование)
│   └── widgets/              # Переиспользуемые UI-компоненты
│
├── features/                 # Функциональные модули мессенджера
│   ├── auth/                 # Авторизация, регистрация, MFA, биометрия
│   ├── chat/                 # Список чатов, экран переписки, звонки
│   ├── profile/              # Настройки профиля, контакты
│   └── settings/             # Настройки приложения и кастомизация
│
│       # Внутри каждой фичи используется разделение на слои:
│       # ├── data/           # Сервисы, репозитории, API-вызовы
│       # ├── domain/         # Специфичные модели
│       # ├── presentation/   # Экраны (screens) и виджеты (widgets)
│       # └── providers/      # Специфичные стейты (Riverpod)
│
└── main.dart                 # Точка входа в приложение
```

### Принципы написания кода
1. **Навигация**: Используйте `context.push('/path')` или `context.go('/path')` вместо устаревшего `Navigator.pushNamed`. Все маршруты описаны в `lib/core/navigation/app_router.dart` (GoRouter).
2. **Импорты**: В проекте используются **абсолютные** пакетные импорты (`import 'package:two_space_app/.../...'`). Старайтесь избегать относительных импортов (`../`).
3. **Управление состоянием**: Повсеместно используется Riverpod с кодогенерацией (`@riverpod`, `riverpod_annotation`). Старайтесь не создавать глобальные переменные состояния вне провайдеров. Используйте `ConsumerWidget` и `ConsumerStatefulWidget`.
4. **Модели данных и Стейты**: Для описания моделей и стейтов провайдеров используйте пакет `freezed` (и `@freezed`). Это дает иммутабельность, генерацию `copyWith` и безопасные union-типы.
5. **Кодогенерация**: При изменении классов с аннотациями (`@riverpod`, `@freezed`, `@JsonSerializable`) обязательно запускайте генератор:
   ```bash
   dart build -d
   ```

6. **Изменения env**: После правки `.env` тоже запускайте `dart build -d`, потому что `Envied` генерирует compile-time файл [lib/core/config/env.g.dart](lib/core/config/env.g.dart).

### 🧪 Тестирование

#### Запуск тестов

```bash
# Запуск всех тестов
flutter test

# Запуск конкретных тестов
flutter test test/unit/aegis_chat_local_store_test.dart

# Запуск с подробным выводом
flutter test --reporter=expanded
```

#### Как писать тесты

1. **Unit-тесты**: Размещайте в `test/unit/` или `test/features/<feature>/`. Тестируйте сервисы, утилиты и бизнес-логику без UI.
2. **Integration-тесты**: Размещайте в `test/integration/`. Тестируйте потоки через реальные провайдеры и сервисы.
3. **Widget-тесты**: Размещайте рядом с фичей в `test/features/<feature>/widget_tests/`. Тестируйте конкретные виджеты с моками.
4. Используйте `Mock` классы для `AegisAuthService`, `AegisChatService` и других внешних зависимостей.
5. Не зависите от реальных сетевых вызовов в тестах — мокайте всё через ` dio` и `AegisProtocolClient`.

#### Пример мока сервиса:

```dart
class MockAegisAuthService extends Mock implements AegisAuthService {}

final provider = Provider<AegisAuthService>((ref) {
  return ref.watch(authServiceProvider);
});

testWidgets('...', (tester) async {
  final mockAuth = MockAegisAuthService();
  when(mockAuth.getUser()).thenReturn(User(id: '123'));
  
  // ... тест
});
```

### 🔨 Build Runner и Кодогенерация

Если вы меняете классы с аннотациями (`@freezed`, `@JsonSerializable`, `@riverpod`), необходимо запустить генератор:

```bash
# Стандартный способ (предпочтительный)
dart run build_runner build --delete-conflicting-outputs

# Альтернативный (watch mode — для разработки)
dart run build_runner watch

# Через алиас в проекте (если настроен)
dart build -d
```

**Важно:**
- `--delete-conflicting-outputs` удаляет сгенерированные файлы перед созданием новых. Используйте это всегда при изменении моделей.
- Если `build_runner` падает с ошибкой памяти, увеличьте лимит: `export PUB_CACHE_MEMORY=2048` (или больше).
- Никогда не редактируйте `*.g.dart`, `*.freezed.dart` и `env.g.dart` вручную — изменения будут перезаписаны.
- Если генератор зависает, попробуйте `rm -rf build/ && dart run build_runner build --delete-conflicting-outputs`.

### 📋 Процесс Pull Request

1. Создайте ветку от `main`: `git checkout -b feat/your-feature-name`
2. Внесите изменения, следуйте правилам из `AGENTS.md`
3. Убедитесь, что `flutter analyze` не выдает ошибок в изменённых файлах:
   ```bash
   flutter analyze lib/core/services/your_new_file.dart
   ```
4. Добавьте/обновите тесты для ваших изменений
5. Коммитьте с понятным сообщением на английском: `feat: add login retry mechanism`
6. Отправьте PR с описанием изменений и связанных issue
