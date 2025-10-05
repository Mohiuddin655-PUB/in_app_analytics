import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_analytics/in_app_analytics.dart';

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
      await Analytics.call(name: "fetch_data", () async {
        await Future.delayed(const Duration(milliseconds: 5));
      }, msg: "Data fetched successfully");

      await Future.delayed(const Duration(milliseconds: 10));

      expect(mock.loggedMessages.isNotEmpty, true);
      expect(mock.loggedMessages.first['name'], "fetch_data");
    });
  });
}
