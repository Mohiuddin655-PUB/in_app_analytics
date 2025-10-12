## 1.0.7

* Add AnalyticsEventItem with fields instances

## 1.0.6

* Analytics pros improved

## 1.0.5

* LogThrowEnabled support

## 1.0.4

- Add warning log feature

## 1.0.3

- Improved log feature

## 1.0.2

- Improve analytics

## 1.0.1

- Improved analytics

## 1.0.0

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
- Unified `call()` helper for safe execution of async functions with automatic success/failure
  tracking.
- Provides built-in **logging and performance measurement hooks**.
- Works seamlessly in both **Flutter UI** and **background isolates**.
- Minimal dependencies and **zero setup overhead** — works out of the box.


