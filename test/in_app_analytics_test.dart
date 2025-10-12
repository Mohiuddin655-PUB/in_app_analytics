import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_analytics/in_app_analytics.dart';

/// A mock delegate to simulate Analytics delegate behavior.
class MockAnalyticsDelegate extends AnalyticsDelegate {
  final List<AnalyticsEvent> events = [];
  final List<AnalyticsEvent> failures = [];
  final List<AnalyticsError> errors = [];
  final List<AnalyticsEvent> logs = [];

  @override
  Future<void> event(AnalyticsEvent event) async {
    events.add(event);
  }

  @override
  Future<void> failure(AnalyticsEvent event) async {
    failures.add(event);
  }

  @override
  Future<void> error(AnalyticsError error) async {
    errors.add(error);
  }

  @override
  Future<void> log(AnalyticsEvent event) async {
    logs.add(event);
  }
}

void main() {
  late MockAnalyticsDelegate delegate;

  setUp(() {
    delegate = MockAnalyticsDelegate();
    Analytics.init(
      enabled: true,
      logThrowEnabled: false,
      delegate: delegate,
      showLogs: false,
      showSuccessLogs: false,
    );
  });

  // ---------------------------------------------------------------------------
  // ANALYTICS CORE TESTS
  // ---------------------------------------------------------------------------

  test('Analytics initializes correctly', () {
    expect(Analytics.i.enabled, isTrue);
    expect(Analytics.i.delegate, isNotNull);
    expect(Analytics.i.name, equals('ANALYTICS'));
  });

  test('Logs an event successfully', () async {
    Analytics.event(
      'user_login',
      msg: 'User logged in successfully',
      status: true,
    );
    await Future.delayed(const Duration(milliseconds: 100));
    expect(delegate.events.length, equals(1));
    expect(delegate.events.first.name, equals('user_login'));
  });

  test('Logs an event failure', () async {
    Analytics.event(
      'user_login',
      msg: 'User login failed',
      status: false,
    );
    await Future.delayed(const Duration(milliseconds: 100));
    expect(delegate.failures.length, equals(1));
    expect(delegate.failures.first.name, equals('user_login'));
  });

  test('Logs a synchronous call success', () async {
    Analytics.call(() {
      // success
    }, name: 'sync_test');
    await Future.delayed(const Duration(milliseconds: 100));
    expect(delegate.logs.length, equals(1));
    expect(delegate.logs.first.name, equals('sync_test'));
  });

  test('Logs a synchronous call failure', () async {
    Analytics.call(() {
      throw Exception('Test failure');
    }, name: 'sync_fail');
    await Future.delayed(const Duration(milliseconds: 100));
    expect(delegate.failures.length, equals(1));
  });

  test('Logs an asynchronous call success', () async {
    await Analytics.callAsync(() async {});
    expect(delegate.logs.isNotEmpty, isTrue);
  });

  test('Logs execute function success', () {
    final result = Analytics.execute(() => 'Hello');
    expect(result, equals('Hello'));
  });

  test('Logs execute function failure', () {
    final result = Analytics.execute(() {
      throw Exception('Error');
    });
    expect(result, isNull);
  });

  test('Logs future success', () async {
    final result = await Analytics.future(() async => 123);
    expect(result, equals(123));
  });

  test('Logs stream success', () async {
    final stream = Analytics.stream(() async* {
      yield 'stream_data';
    });
    final values = await stream.toList();
    expect(values.contains('stream_data'), isTrue);
  });

  test('Logs custom message', () async {
    Analytics.log('custom_log', 'testing', msg: 'Message OK');
    await Future.delayed(const Duration(milliseconds: 100));
    expect(delegate.logs.length, greaterThan(0));
  });

  // ---------------------------------------------------------------------------
  // EXTENSIONS TESTS (FutureTExecutor & StreamTExecutor)
  // ---------------------------------------------------------------------------

  test('AnalyticsFuture logs success', () async {
    final result = await Future.value('Success').analytics(
      name: 'FutureTest',
      msg: 'Testing future extension',
    );
    expect(result, equals('Success'));
    await Future.delayed(const Duration(milliseconds: 100));
    expect(delegate.logs.any((e) => e.name == 'FutureTest'), isTrue);
  });

  test('AnalyticsFuture logs failure', () async {
    final result = await Future.error(Exception('Failed')).analytics(
      name: 'FutureFail',
      msg: 'Testing future failure',
    );
    expect(result, isNull);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(delegate.failures.any((e) => e.name == 'FutureFail'), isTrue);
  });

  test('AnalyticsStream logs stream success', () async {
    final stream = Stream.value('StreamOK').analytics(
      name: 'StreamTest',
      msg: 'Testing stream extension',
    );
    final values = await stream.toList();
    expect(values, equals(['StreamOK']));
    expect(delegate.logs.any((e) => e.name == 'StreamTest'), isTrue);
  });
}
