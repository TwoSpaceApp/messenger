![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows%20%7C%20Android%20%7C%20iOS-lightgrey?style=for-the-badge)

<div align="center">

# 🌌 Мессенджер TwoSpace

**Чётко. Быстро. Удобно.**

</div>

TwoSpace - это кроссплатформенный мессенджер, разрабатываемый на языке **Dart** на **Flutter** в рамках студенческого проекта.
Мы планируем объединить лучшие функции **Telegram**, **Discord** и **Widgetable**, создавая интуитивный, гибкий и красивый инструмент для общения с современными решениями.

> 💡 **Статус**: закрытое тестирование.
>
> ⚠️ ПРЕДУПРЕЖДЕНИЕ: TwoSpace находится в стадии активной разработки (альфа-версия). На данном этапе мы не рекомендуем использовать его для передачи конфиденциальной информации, финансовых данных и т.д.
>
> 🛠️ **Участие**: Принимаем предложения! Хотите попробовать — пишите в [наш Telegram-канал](https://t.me/twospace_messenger).

---

## 🧰 Используемые технологии

| Технология        | Версия      | Назначение |
|-------------------|-------------|------------|
| **Dart SDK**      | `3.10.x`    | Язык программирования от Google, основа логики приложения |
| **Flutter**       | `3.38.8`    | Фреймворк для кроссплатформенной разработки |
| **Riverpod**      | `3.0+`      | Современный стейт-менеджмент (с кодогенерацией) |
| **GoRouter**      | `17.x`      | Декларативная маршрутизация и Deep Links |
| **Freezed**       | `3.2.x`     | Генерация иммутабельных моделей и Union-типов |
| **Протокол Aegis**| `-`         | Собственный бинарный TCP-протокол |

---

## 🔐 Протокол Aegis

TwoSpace использует **Aegis** — собственный бинарный протокол поверх TCP.

## 🌍 Поддержка языков

Приложение полностью локализовано с помощью **Flutter Gen-l10n** (ARB-файлы).

Поддерживаемые языки: 🇷🇺 Русский · 🇬🇧 English · 🇩🇪 Deutsch · 🇪🇸 Español · 🇫🇷 Français · 🇮🇹 Italiano · 🇯🇵 日本語 · 🇰🇷 한국어 · 🇵🇱 Polski · 🇨🇳 中文

Все строки находятся в `lib/core/l10n/app_*.arb`.

Сменить язык можно на экране **Настройки** или прямо на экранах **Вход / Регистрация** через кнопку с флагом в правом верхнем углу. Выбор сохраняется в `flutter_secure_storage` и применяется немедленно без перезапуска.

---

## 🔧 Переменные окружения (.env)

В проекте используется `envied`.

- Шаблон хранится в [.env.example](.env.example)
- Секреты и приватные значения должны лежать только в локальном `.env`
- `.env` не коммитится
- После любого изменения `.env` нужно пересобрать файл [lib/core/config/env.g.dart](lib/core/config/env.g.dart)

Базовый поток:

1. `cp .env.example .env`
2. Отредактировать `.env`
3. Выполнить `dart run build_runner build -d`

Не храните в `.env.example` реальные секреты вроде `SENTRY_DSN`, токенов или приватных endpoint credentials.

---

## 🚀 Быстрый запуск в виде проекта

Коротко:

1) `cp .env.example .env`
2) `dart run build_runner build -d`
3) `flutter pub get`
4) `flutter run`

Полный гайд для разработки (зависимости для Linux/Windows, команды сборки, pre-commit checks) — в [CONTRIBUTING.md](CONTRIBUTING.md).


---

## 🤖 Как запустить?

На этапе альфа-теста официальных релизов нету, только артефакты CI. Артефакты доступны в GitHub Actions в разделе **Artifacts** у конкретного workflow run.

### Android (workflow: Build Android)

- Debug (PR): `app-debug.apk`
- Release: split APKs: `app-*-release.apk` (несколько файлов по ABI) + `app-release.aab`

Установка:
- Скачайте APK из GitHub Actions → Artifacts
- Перенесите на телефон и установите (может потребоваться разрешить установку из неизвестных источников)

### Windows (workflow: Build Desktop)

- Скачайте артефакт из GitHub Actions → Artifacts
- Распакуйте и запустите `two_space_app.exe`

### Linux (workflow: Build Desktop)

- Скачайте артефакт из GitHub Actions → Artifacts и распакуйте
- Запуск:
	- `chmod +x two_space_app && ./two_space_app`

Если приложение не стартует из-за отсутствующих системных библиотек (GTK/secret/alsa), поставьте зависимости (Ubuntu/Debian):

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  libgtk-3-0 libsecret-1-0 libasound2
```



---

## 📣 Связь и новости

Оставайтесь в курсе обновлений и участвуйте в обсуждении:  
🔗 [**Telegram-канал TwoSpace**](https://t.me/twospace_messenger)

Официальный сайт с подробностями:
🔗 [**Сайт TwoSpace**](https://twospace.ru) (на данный момент в разработке)

---

## Лицензия

Этот проект распространяется под лицензией **Apache License 2.0**.

© 2024-2026 Synapse Corp. Все права защищены.

**Важно для пользователей мессенджера:**
- TwoSpace разрабатывается в образовательных целях
- Все функции безопасности предоставлены "как есть" без гарантий
- Использование в коммерческих целях разрешено при соблюдении условий лицензии Apache 2.0
- Название "TwoSpace" является торговой маркой Synapse Corp.

Полный текст лицензии см. в файле [LICENSE](LICENSE).

> Все права защищены. Любое использование кода вне условий лицензии запрещено.

---

<div align="center">

❤️ Сделано с заботой о пользователях.

</div>
