# Развертывание TwoSpace Web на сервер

Полная инструкция по развертыванию веб-версии TwoSpace на сервер с доменом `web.twospace.ru`.

## 📋 Содержание

- [Быстрый старт](#быстрый-старт)
- [Предварительные требования](#предварительные-требования)
- [Пошаговое развертывание](#пошаговое-развертывание)
- [Команды для управления](#команды-для-управления)
- [Устранение неполадок](#устранение-неполадок)

## 🚀 Быстрый старт

```bash
# 1. На локальной машине: подготовить и собрать веб-версию
./scripts/build-web.sh --release

# 2. Развернуть на сервер
./scripts/deploy.sh 95.215.56.43 root

# 3. На сервере: выполнить настройку (если еще не сделана)
sudo bash /opt/twospace/setup-server.sh
```

## 📦 Предварительные требования

### На локальной машине
- Flutter SDK 3.38.8+
- Dart SDK 3.8.0+
- SSH доступ к серверу
- Утилита `tar` и `gzip`

### На сервере
- Linux (Ubuntu/Debian рекомендуется)
- Порты 80 и 443 открыты
- Минимум 512MB свободной памяти
- Доступ в интернет для SSL сертификатов

### Предварительная настройка домена
- Убедитесь, что `web.twospace.ru` уже указан на IP `95.215.56.43` в вашем DNS провайдере
- Проверьте: `nslookup web.twospace.ru`

## 📝 Пошаговое развертывание

### Этап 1: Сборка веб-версии

**На вашей локальной машине:**

```bash
cd /path/to/messenger

# Собрать веб-версию в режиме release
./scripts/build-web.sh --release
```

Результат:
- Собранные файлы: `build/web/`
- Размер примерно: 30-50MB (зависит от конфигурации)

**Если скрипт не имеет прав:**
```bash
chmod +x scripts/build-web.sh
```

### Этап 2: Развертывание на сервер

**На вашей локальной машине:**

```bash
# Развернуть на сервер
# Синтаксис: ./scripts/deploy.sh <IP_сервера> <пользователь>
./scripts/deploy.sh 95.215.56.43 root
```

**Что делает скрипт:**
1. Проверяет наличие собранной веб-версии
2. Пересобирает её (clean build)
3. Архивирует файлы (`tar.gz`)
4. Загружает архив на сервер через SCP
5. Распаковывает на сервере в `/var/www/twospace-web`
6. Устанавливает правильные права доступа

### Этап 3: Настройка сервера

**На сервере:**

```bash
# Подключиться к серверу
ssh root@95.215.56.43

# Выполнить настройку (всё автоматизировано)
sudo bash /opt/twospace/setup-server.sh
```

**Что делает скрипт настройки:**
1. Обновляет пакеты системы
2. Устанавливает Nginx (если не установлен)
3. Устанавливает Certbot для SSL
4. Конфигурирует Nginx для доменов и HTTPS
5. Генерирует SSL сертификаты через Let's Encrypt
6. Настраивает автоматическое продление сертификатов
7. Перезагружает Nginx с новой конфигурацией

### Этап 4: Проверка

**На сервере:**

```bash
# Проверить статус Nginx
sudo systemctl status nginx

# Проверить конфигурацию Nginx
sudo nginx -t

# Просмотреть логи
sudo journalctl -u nginx -f

# Проверить SSL сертификат
sudo certbot certificates

# Проверить продление (dry-run)
sudo certbot renew --dry-run
```

**Локально:**

```bash
# Проверить доступ по HTTP → HTTPS
curl -I http://web.twospace.ru/

# Проверить HTTPS
curl -I https://web.twospace.ru/

# Проверить SSL сертификат
openssl s_client -connect web.twospace.ru:443 -servername web.twospace.ru

# Online SSL check
# Перейти на: https://www.ssllabs.com/ssltest/analyze.html?d=web.twospace.ru
```

## 🎯 Команды для управления

### Nginx

```bash
# Запустить
sudo systemctl start nginx

# Остановить
sudo systemctl stop nginx

# Перезагрузить (без перезапуска)
sudo systemctl reload nginx

# Полный перезапуск
sudo systemctl restart nginx

# Статус
sudo systemctl status nginx

# Включить автозагрузку при перезагрузке
sudo systemctl enable nginx

# Отключить автозагрузку
sudo systemctl disable nginx
```

### Логи

```bash
# Логи Nginx (access)
sudo tail -f /var/log/nginx/twospace-access.log

# Логи Nginx (errors)
sudo tail -f /var/log/nginx/twospace-error.log

# Логи systemd
sudo journalctl -u nginx -f

# Все логи в реальном времени
sudo journalctl -f
```

### SSL сертификаты

```bash
# Посмотреть все сертификаты
sudo certbot certificates

# Продлить вручную
sudo certbot renew --force-renewal

# Проверить, будет ли продление работать (dry-run)
sudo certbot renew --dry-run

# Статус автопродления
sudo systemctl status certbot.timer

# Детали автопродления
sudo systemctl list-timers certbot.timer
```

### Развертывание обновлений

```bash
# На локальной машине
./scripts/build-web.sh --release
./scripts/deploy.sh 95.215.56.43 root

# Новая версия автоматически:
# 1. Создает резервную копию старой версии
# 2. Распаковывает новую в /var/www/twospace-web
# 3. Nginx автоматически использует новые файлы
```

## 🐛 Устранение неполадок

### Проблема: Nginx возвращает 404

**Решение:**
```bash
# Проверить, что файлы на месте
ls -la /var/www/twospace-web/

# Проверить права доступа
sudo chown -R www-data:www-data /var/www/twospace-web
sudo chmod -R 755 /var/www/twospace-web

# Проверить конфигурацию
sudo nginx -t

# Перезагрузить
sudo systemctl reload nginx
```

### Проблема: SSL сертификат не сгенерировался

**Проверить:**
```bash
# Доступен ли домен
nslookup web.twospace.ru

# Доступен ли порт 80
sudo nc -l 0.0.0.0 80  # В одном терминале
telnet web.twospace.ru 80  # В другом

# Логи certbot
sudo certbot renew --dry-run -v
```

**Решение:**
```bash
# Попробовать вручную
sudo certbot certonly --nginx -d web.twospace.ru -v

# Если не работает, используйте standalone
sudo certbot certonly --standalone -d web.twospace.ru
```

### Проблема: Высокая нагрузка на сервер

**Проверить:**
```bash
# Использование CPU и памяти
top

# Статистика Nginx
sudo systemctl status nginx

# Активные соединения
sudo netstat -an | grep ESTABLISHED | wc -l

# Размер логов
du -sh /var/log/nginx/
```

**Решение:**
```bash
# Включить gzip (уже в nginx.conf)
# Ротация логов (настроить logrotate)
sudo vim /etc/logrotate.d/nginx
```

### Проблема: DNS не разрешает домен

```bash
# Проверить DNS на локальной машине
nslookup web.twospace.ru
dig web.twospace.ru

# Проверить на сервере
sudo systemctl restart systemd-resolved
nslookup web.twospace.ru 8.8.8.8
```

### Проблема: Приложение не загружается (пустая страница)

**Проверить браузер:**
- Консоль DevTools (F12 → Console)
- Network tab для CORS ошибок
- Application tab для Service Worker

**Проверить сервер:**
```bash
# CORS headers установлены?
curl -I -H "Origin: http://localhost" https://web.twospace.ru/

# Файл index.html существует?
ls -la /var/www/twospace-web/index.html

# JavaScript файлы загружаются?
curl -I https://web.twospace.ru/main.dart.js | head -5
```

## 🔒 Безопасность

Текущая конфигурация включает:
- HTTPS с TLS 1.2+
- Автоматическое продление сертификатов
- Security headers (HSTS, X-Frame-Options, CSP-like)
- Gzip сжатие
- Кэширование статических ассетов

**Дополнительно рекомендуется:**
```bash
# Настроить файрвол
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable

# Настроить fail2ban для защиты от brute-force
sudo apt-get install fail2ban
sudo systemctl enable fail2ban
```

## 📞 Контакты и поддержка

При возникновении проблем:
1. Проверьте логи: `sudo journalctl -u nginx -f`
2. Проверьте конфигурацию: `sudo nginx -t`
3. Посмотрите на DNS: `nslookup web.twospace.ru`
4. Попробуйте обновить: `./scripts/deploy.sh 95.215.56.43 root`

---

**Версия:** 1.0  
**Последнее обновление:** 2026-04-20
