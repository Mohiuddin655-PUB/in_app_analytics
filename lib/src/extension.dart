import 'analytics.dart';

/// Extension on `Future<void>` to easily wrap async operations
/// with analytics logging.
///
/// Provides a convenient `analytics` method that automatically
/// logs success or failure using the global `Analytics` manager.
extension AnalyticsVoidCallback on Future<void> {
  /// Executes the future and logs analytics automatically.
  ///
  /// - `name` — Optional name of the analytics event.
  /// - `reason` — Optional reason for logging, describing the operation.
  /// - `msg` — Optional custom message to include in analytics logs.
  ///
  /// Example:
  /// ```dart
  /// await someAsyncFunction.analytics(
  ///   name: "InitDatabase",
  ///   reason: "Database initialization",
  /// );
  /// ```
  Future<void> call({
    String? name,
    String? reason,
    String? msg,
  }) {
    return Analytics.call(() => this, name: name, reason: reason, msg: msg);
  }
}

/// Extension on `Future<T>` to automatically log analytics
/// for operations returning a value of type `T`.
///
/// Provides `analytics` method that wraps the future and logs
/// success/failure using the global `Analytics` manager.
extension FutureTExecutor<T extends Object?> on Future<T> {
  /// Executes the future and logs analytics automatically.
  ///
  /// - `name` — Optional name of the analytics event.
  /// - `msg` — Optional custom message for logging.
  ///
  /// Returns the original result of the future if successful,
  /// otherwise logs the error.
  ///
  /// Example:
  /// ```dart
  /// final user = await fetchUser.analytics(
  ///   name: "FetchUser",
  ///   msg: "Fetching user profile",
  /// );
  /// ```
  Future<T?> analytics({
    String? name,
    String? msg,
  }) {
    return Analytics.execute(() => this, name: name, msg: msg);
  }
}

/// Extension on `Stream<T>` to automatically log analytics
/// for streaming operations.
///
/// Provides `analytics` method to log each event or error
/// using the global `Analytics` manager.
extension StreamTExecutor<T extends Object?> on Stream<T?> {
  /// Wraps the stream with analytics logging.
  ///
  /// - `name` — Optional name of the analytics event.
  /// - `msg` — Optional custom message for logging.
  ///
  /// Each emitted value and errors will be logged via `Analytics`.
  ///
  /// Example:
  /// ```dart
  /// fetchUpdatesStream.analytics(
  ///   name: "FetchUpdates",
  ///   msg: "Listening to updates stream",
  /// ).listen((data) {
  ///   print("Received: $data");
  /// });
  /// ```
  Stream<T?> analytics({
    String? name,
    String? msg,
  }) {
    return Analytics.stream(() => this, name: name, msg: msg);
  }
}
