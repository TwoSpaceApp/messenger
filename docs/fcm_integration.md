# Интеграция Firebase Cloud Messaging (FCM) для TwoSpace

## Что уже реализовано

### Клиентская часть (Flutter)

1. **Зависимости** (`pubspec.yaml`):
   - `firebase_core: ^3.12.0` - базовая интеграция Firebase
   - `firebase_messaging: ^15.2.0` - push-уведомления
   - `flutter_local_notifications: ^18.0.0` - локальные уведомления

2. **Конфигурация Firebase**:
   - Файл `lib/firebase_options.dart` сгенерирован через `flutterfire configure`
   - Настроены платформы: Android, iOS, macOS, Windows, Web
   - Проект Firebase: `twospace-push`

3. **Сервис уведомлений** (`lib/core/services/notification_service.dart`):
   - Инициализация FCM и локальных уведомлений
   - Обработка foreground/background сообщений
   - Получение и обновление FCM токена
   - Подписка/отписка от топиков
   - Отображение локальных уведомлений при foreground сообщениях
   - Навигация при тапе на уведомление

4. **Инициализация** (`lib/core/services/initialization_service.dart`):
   - Firebase инициализируется на этапе запуска приложения
   - Используется `DefaultFirebaseOptions.currentPlatform`

## Что требуется от вас (серверная часть)

### 1. Firebase Admin SDK

Установите Firebase Admin SDK на ваш сервер:

```bash
# Node.js
npm install firebase-admin

# Python
pip install firebase-admin

# Go
go get firebase.google.com/go
```

### 2. Сервисный аккаунт

1. Перейдите в [Firebase Console](https://console.firebase.google.com/)
2. Project Settings → Service Accounts
3. Сгенерируйте новый приватный ключ
4. Сохраните JSON-файл на сервере

### 3. Инициализация Admin SDK

**Node.js пример:**
```javascript
const admin = require('firebase-admin');

const serviceAccount = require('./path/to/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
```

### 4. Отправка уведомлений

#### Отправка конкретному устройству (по FCM токену):

```javascript
const message = {
  token: 'DEVICE_FCM_TOKEN', // Получите от клиента
  notification: {
    title: 'Новое сообщение',
    body: 'Привет! Как дела?',
  },
  data: {
    type: 'message',
    chat_id: 'chat_123',
    message_id: 'msg_456',
  },
  android: {
    priority: 'high',
    notification: {
      channelId: 'messages',
      sound: 'default',
    },
  },
  apns: {
    payload: {
      aps: {
        sound: 'default',
        badge: 1,
      },
    },
  },
};

admin.messaging().send(message)
  .then((response) => {
    console.log('Successfully sent message:', response);
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });
```

#### Отправка по топику:

```javascript
const message = {
  topic: 'all_users', // или 'user_USER_ID'
  notification: {
    title: 'Объявление',
    body: 'Важное обновление!',
  },
  data: {
    type: 'announcement',
  },
};

admin.messaging().send(message);
```

#### Мультикаст (несколько устройств):

```javascript
const tokens = ['token1', 'token2', 'token3'];

const message = {
  notification: {
    title: 'Новое сообщение',
    body: 'Привет!',
  },
  data: {
    type: 'message',
    chat_id: 'chat_123',
  },
};

admin.messaging().sendMulticast({
  tokens: tokens,
  ...message,
});
```

### 5. Обработка FCM токенов

#### Получение токена от клиента

Клиентское приложение получает FCM токен через:
```dart
final token = await FirebaseMessaging.instance.getToken();
```

**Важно:** Отправьте этот токен на ваш сервер и сохраните в базе данных, связав с пользователем.

#### Обновление токена

FCM токен может измениться. Клиент слушает обновления:
```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  // Отправьте newToken на сервер
});
```

#### Удаление токена при выходе

При logout вызывайте:
```dart
await FirebaseMessaging.instance.deleteToken();
```

### 6. Рекомендуемая структура данных на сервере

```sql
CREATE TABLE user_fcm_tokens (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    fcm_token VARCHAR(255) NOT NULL UNIQUE,
    device_type VARCHAR(50), -- 'android', 'ios', 'web'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

CREATE INDEX idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX idx_user_fcm_tokens_token ON user_fcm_tokens(fcm_token);
```

### 7. API эндпоинты для клиента

#### Регистрация FCM токена

```http
POST /api/v1/users/fcm-token
Authorization: Bearer <token>
Content-Type: application/json

{
  "fcm_token": "string",
  "device_type": "android|ios|web"
}
```

#### Удаление FCM токена (при logout)

```http
DELETE /api/v1/users/fcm-token
Authorization: Bearer <token>
Content-Type: application/json

{
  "fcm_token": "string"
}
```

### 8. Логика отправки уведомлений

#### При новом сообщении:

1. Сохраните сообщение в БД
2. Найдите все FCM токены получателя
3. Отправьте FCM уведомление
4. Обработайте ошибки (invalid token → удалите из БД)

```javascript
async function sendMessageNotification(recipientId, message) {
  // Получаем токены получателя
  const tokens = await db.query(
    'SELECT fcm_token FROM user_fcm_tokens WHERE user_id = ? AND is_active = true',
    [recipientId]
  );

  if (tokens.length === 0) return;

  const fcmMessage = {
    notification: {
      title: message.sender_name,
      body: message.text.substring(0, 100), // Обрезаем длинные сообщения
    },
    data: {
      type: 'message',
      chat_id: message.chat_id,
      message_id: message.id,
      sender_id: message.sender_id,
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'messages',
        sound: 'default',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
  };

  // Отправляем multicast
  const response = await admin.messaging().sendMulticast({
    tokens: tokens.map(t => t.fcm_token),
    ...fcmMessage,
  });

  // Обрабатываем ошибки
  response.responses.forEach((resp, idx) => {
    if (!resp.success) {
      if (resp.error.code === 'messaging/invalid-registration-token' ||
          resp.error.code === 'messaging/registration-token-not-registered') {
        // Удаляем невалидный токен
        db.query('DELETE FROM user_fcm_tokens WHERE fcm_token = ?', [tokens[idx].fcm_token]);
      }
    }
  });
}
```

### 9. Типы уведомлений (data payload)

Клиентское приложение ожидает следующие типы уведомлений в `data.type`:

| Тип | Описание | Обязательные поля |
|-----|----------|-------------------|
| `message` | Новое сообщение | `chat_id`, `message_id` |
| `chat` | Новый чат | `chat_id` |
| `group` | Новая группа | `chat_id` |
| `reaction` | Реакция на сообщение | `message_id` |

### 10. Тестирование

#### Отправка тестового уведомления через curl:

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/twospace-push/messages:send \
  -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "message": {
      "token": "DEVICE_FCM_TOKEN",
      "notification": {
        "title": "Test",
        "body": "Hello from FCM!"
      },
      "data": {
        "type": "message",
        "chat_id": "test_chat"
      }
    }
  }'
```

#### Получение access token:

```bash
# Используя gcloud
gcloud auth application-default print-access-token
```

## Проверка интеграции

1. Запустите приложение
2. Проверьте логи - должен появиться FCM токен
3. Отправьте тестовое уведомление через Firebase Console или API
4. Проверьте:
   - Foreground: появляется локальное уведомление
   - Background: системное уведомление
   - Тап на уведомление: открывается нужный чат

## Troubleshooting

### Уведомления не приходят

1. Проверьте `google-services.json` (Android) и `GoogleService-Info.plist` (iOS)
2. Убедитесь, что FCM токен получен и отправлен на сервер
3. Проверьте права уведомлений в настройках устройства
4. Для iOS: проверьте APNS конфигурацию в Firebase Console

### Ошибки при отправке

- `InvalidRegistration` - токен устарел, удалите из БД
- `NotRegistered` - приложение удалено или токен отозван
- `MismatchSenderId` - неверный Firebase проект

## Полезные ссылки

- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [FlutterFire Messaging](https://firebase.flutter.dev/docs/messaging/overview/)
