import 'analytics.dart';

/// Extension on `Future<T>` to automatically log analytics
/// for operations returning a value of type `T`.
///
/// Provides `analytics` method that wraps the future and logs
/// success/failure using the global `Analytics` manager.
extension AnalyticsFuture<T extends Object?> on Future<T> {
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
    return Analytics.future(() => this, name: name, msg: msg);
  }
}

/// Extension on `Stream<T>` to automatically log analytics
/// for streaming operations.
///
/// Provides `analytics` method to log each event or error
/// using the global `Analytics` manager.
extension AnalyticsStream<T extends Object?> on Stream<T?> {
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
