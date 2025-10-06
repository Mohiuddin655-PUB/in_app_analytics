import 'event.dart';

/// Defines a delegate to handle analytics operations.
abstract class AnalyticsDelegate {
  /// Called when an error is logged.
  Future<void> error(AnalyticsError error);

  /// Called when an event is logged.
  Future<void> event(AnalyticsEvent event);

  /// Called when an event is logged failed.
  Future<void> failure(AnalyticsEvent event);

  /// Called when a generic log message is written.
  Future<void> log(AnalyticsEvent event);
}
