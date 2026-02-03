# Quick Invoice

## Версия
- **Flutter**: 3.35.7
- **Dart**: 3.9.2

## 1. Ссылки и ключи
Ссылки и ключи для Apphud находятся по следующему пути:
/lib/main.dart → `CommonConfig`

## 2. Функции приложения

### Основные функции:
- **Создание инвойсов**: Быстрое создание профессиональных счетов
- **Управление клиентами**: База данных клиентов с контактной информацией
- **PDF генерация**: Создание PDF с поддержкой Unicode (кириллица, латиница)
- **Шаблоны**: Classic, Modern, Minimal шаблоны для инвойсов
- **Статистика**: Отслеживание доходов и статусов инвойсов
- **Экспорт и шаринг**: Отправка инвойсов через Share Sheet

### Премиум функции:
- **Шаблоны PDF**: Доступ ко всем шаблонам
- **Неограниченные инвойсы**: Без лимитов на создание
- **Статистика**: Полная статистика по доходам

## 3. AppHud Onboarding JSON
```json
{
  "title": "Unlimited\nAccess!",
  "limitedButton": "Or proceed with limited version",
  "tryFreeButton": "Continue",
  "continueButton": "Continue",
  "products": [
    {
      "id": "com.QuickInvoicea23p.appWeek",
      "title": "Optimal",
      "periodly": "week"
    }
  ]
}
```

## 4. AppHud Main JSON
```json
{
  "title": "Unlimited access!",
  "tryFreeButton": "Try free & subscribe",
  "continueButton": "Continue & subscribe",
  "purchaseButton": "Purchase & continue",
  "products": [
    {
      "id": "com.QuickInvoicea23p.appLifetime",
      "title": "Life time deal",
      "periodly": "one-time"
    },
    {
      "id": "com.QuickInvoicea23p.appMonth",>
      "title": "Popular",
      "periodly": "month"
    },
    {
      "id": "com.QuickInvoicea23p.appYear",
      "title": "Best Deal",
      "periodly": "year"
    },
    {
      "id": "com.QuickInvoicea23p.appWeekTrial",
      "title": "Optimal",
      "periodly": "week-trial"
    }
  ]
}
```

## 🍏 iOS Capabilities

### 0. **Background Modes**

- `UIBackgroundModes` → `fetch`, `remote-notification`.
- **Библиотеки**:
  - [apphud](https://pub.dev/packages/apphud)

### 1. **Push Notifications**

- **Библиотеки**:
  - [apphud](https://pub.dev/packages/apphud)

### 2. **In-App Purchases**

- **Библиотеки**:
  - [apphud](https://pub.dev/packages/apphud)
