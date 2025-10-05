import 'event.dart';

abstract class AnalyticsDelegate {
  Future<void> error(AnalyticsError error);

  Future<void> event(AnalyticsEvent event);

  Future<void> log(String name, String? msg, String reason);
}
