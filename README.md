# 📊 Analytics

A lightweight, platform-aware analytics and error tracking system for Flutter apps.  
It captures events, logs, and errors (both Flutter and platform-level), with optional delegate handling for custom reporting, cloud sync, or local logging.

---

## ⚙️ Features

- Singleton manager for centralized analytics and logging.
- Tracks **custom events**, **logs**, and **errors** across the entire app.
- Captures **Flutter framework errors** via `FlutterError.onError`.
- Handles **platform-level exceptions** using `PlatformDispatcher.onError`.
- Supports structured data models:
  - `AnalyticsEvent` — for event tracking.
  - `AnalyticsError` — for error reporting with stack traces.
- Optional **delegate system** for integrating custom analytics services (e.g., Firebase, Sentry).
- Configurable behavior:
  - `enabled` — toggle analytics globally.
  - `showLogs`, `showSuccessLogs`, `showLogTime` — for development insights.
- Unified `call()` helper for safe execution of async functions with automatic success/failure tracking.
- Provides built-in **logging and performance measurement hooks**.
- Works seamlessly in both **Flutter UI** and **background isolates**.
- Minimal dependencies and **zero setup overhead** — works out of the box.

---

## 🚀 Example Usage

```dart
import 'package:in_app_analytics/analytics.dart';

void main() {
  // Initialize Analytics once in your app
  Analytics.init(
    enabled: true,
    showLogs: true,
    delegate: MyAnalyticsDelegate(),
  );

  // Log a custom event
  Analytics.event(
    "purchase",
    msg: "User purchased premium plan",
    props: {"plan": "pro", "price": 9.99},
  );

  // Capture an error manually
  try {
    throw Exception("Something went wrong");
  } catch (e, s) {
    Analytics.error("manual_error", msg: e.toString(), stack: s);
  }

  // Use safe call for async tasks
  Analytics.call("fetch_data", () async {
    await Future.delayed(const Duration(seconds: 1));
  }, msg: "Data fetched successfully");
}
```

---

## 🧪 Testing

To ensure analytics works as expected, include this example test file:

```dart

/// A mock delegate used for testing Analytics events and errors.
class MockAnalyticsDelegate extends AnalyticsDelegate {
  final List<AnalyticsEvent> loggedEvents = [];
  final List<AnalyticsError> loggedErrors = [];
  final List<Map<String, dynamic>> loggedMessages = [];

  @override
  Future<void> event(AnalyticsEvent event) async {
    loggedEvents.add(event);
  }

  @override
  Future<void> error(AnalyticsError error) async {
    loggedErrors.add(error);
  }

  @override
  Future<void> log(String name, String? msg, String reason) async {
    loggedMessages.add({
      'name': name,
      'msg': msg,
      'reason': reason,
    });
  }
}

void main() {
  // Ensures Flutter engine bindings are initialized before any test.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Analytics Tests', () {
    late MockAnalyticsDelegate mock;

    setUp(() {
      mock = MockAnalyticsDelegate();

      // Initialize Analytics singleton
      Analytics.init(
        enabled: true,
        delegate: mock,
        showLogs: false,
        showSuccessLogs: false,
      );
    });

    test('logs an event successfully', () async {
      Analytics.event("user_signup", msg: "User created an account");

      await Future.delayed(const Duration(milliseconds: 10));

      expect(mock.loggedEvents.length, 1);
      final event = mock.loggedEvents.first;
      expect(event.name, "user_signup");
      expect(event.msg, "User created an account");
      expect(event.platform?.isNotEmpty, isTrue);
    });

    test('logs an error using delegate', () async {
      final error = AnalyticsError(
        msg: "Test error",
        platform: "ios",
        time: DateTime.now().toIso8601String(),
      );

      await mock.error(error);
      expect(mock.loggedErrors.length, 1);
      expect(mock.loggedErrors.first.msg, "Test error");
    });

    test('logs a message with reason', () async {
      Analytics.log("api_call", "init", msg: "Fetching user profile");

      await Future.delayed(const Duration(milliseconds: 10));

      expect(mock.loggedMessages.length, 1);
      final log = mock.loggedMessages.first;
      expect(log['name'], "api_call");
      expect(log['reason'], "init");
      expect(log['msg'], "Fetching user profile");
    });

    test('wraps async calls with Analytics.call()', () async {
      await Analytics.call("fetch_data", () async {
        await Future.delayed(const Duration(milliseconds: 5));
      }, msg: "Data fetched successfully");

      await Future.delayed(const Duration(milliseconds: 10));

      expect(mock.loggedMessages.isNotEmpty, true);
      expect(mock.loggedMessages.first['name'], "fetch_data");
    });
  });
}
```

Run it with:
```bash
flutter test
```

---

## 🧰 Delegate Example

```dart
class MyAnalyticsDelegate extends AnalyticsDelegate {
  @override
  Future<void> event(AnalyticsEvent event) async {
    print('📦 Event logged: ${event.name}');
  }

  @override
  Future<void> error(AnalyticsError error) async {
    print('⚠️ Error: ${error.msg}');
  }

  @override
  Future<void> log(String name, String? msg, String reason) async {
    print('📝 Log [$name]: $reason - ${msg ?? ""}');
  }
}
```

---

## 📘 Summary

| Feature | Description |
|----------|--------------|
| ✅ Custom event tracking | Use `Analytics.event()` |
| ⚠️ Error capturing | Automatic via Flutter and platform |
| 🔌 Delegate integration | Plug into any backend or logger |
| 🧩 Safe async calls | Use `Analytics.call()` |
| 🧠 Minimal setup | Just `Analytics.init()` once |
