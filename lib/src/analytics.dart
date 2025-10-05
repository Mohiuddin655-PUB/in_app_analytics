import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'delegate.dart';
import 'event.dart';

/// The default analytics name identifier.
const kAnalytics = "ANALYTICS";

/// The main analytics manager used to record events and errors.
class Analytics {
  /// Whether analytics tracking is enabled.
  final bool enabled;

  /// Whether to show logs in the console.
  final bool showLogs;

  /// Whether to show success logs.
  final bool showSuccessLogs;

  /// Whether to include time in log entries.
  final bool showLogTime;

  /// Log level for error entries.
  final int? errorLogLevel;

  /// Log level for success entries.
  final int? successLogLevel;

  /// Sequence number for success logs.
  final int? successSequenceNumber;

  /// Sequence number for error logs.
  final int? errorSequenceNumber;

  /// The analytics logger name.
  final String name;

  /// The analytics delegate implementation.
  final AnalyticsDelegate? delegate;

  /// Private constructor for [Analytics].
  const Analytics._({
    this.enabled = false,
    this.showLogs = true,
    this.showSuccessLogs = true,
    this.name = kAnalytics,
    this.showLogTime = false,
    this.errorLogLevel,
    this.successLogLevel,
    this.successSequenceNumber,
    this.errorSequenceNumber,
    this.delegate,
  });

  static Analytics? _i;

  /// Returns the current [Analytics] instance.
  static Analytics get i => _i ??= Analytics._();

  /// Writes a formatted log entry.
  void _logs(
    Object? msg, {
    String? name,
    String? status,
    String? icon,
    int? level,
    int? sequenceNumber,
  }) {
    String log = '';
    if (icon != null && icon.isNotEmpty) {
      log = "$log$icon ";
    }
    if (name != null && name.isNotEmpty) {
      log = "$log$name";
    }
    if (msg != null) {
      log = "$log:$msg";
    }
    if (status != null && status.isNotEmpty) {
      log = "$log($status)";
    }
    dev.log(
      log,
      name: this.name,
      level: level ?? 0,
      time: showLogTime ? DateTime.now() : null,
      sequenceNumber: sequenceNumber,
    );
  }

  void _logSuccess(Object? msg, {String? name, String? icon}) {
    if (!enabled || !showSuccessLogs) return;
    _logs(
      msg,
      status: "done!",
      icon: icon ?? "✅",
      name: name,
      level: successLogLevel,
      sequenceNumber: successSequenceNumber,
    );
  }

  void _logError(Object? msg, {String? name, String? icon}) {
    if (!enabled || !showLogs) return;
    _logs(
      msg,
      status: 'failed!',
      icon: icon ?? "️️❌️",
      name: name,
      level: errorLogLevel,
      sequenceNumber: errorSequenceNumber,
    );
  }

  /// Logs ❌ or 🔥 if sending fails
  ///
  void _error(AnalyticsError error, {String? icon}) async {
    if (!enabled || delegate == null) return;
    try {
      await delegate!.error(error);
      _logError(error.msg, name: "error", icon: icon ?? error.sign ?? "❌");
    } catch (msg) {
      _logError(msg, name: "error", icon: "🔥");
    }
  }

  void _event(AnalyticsEvent event, {String? icon}) async {
    if (!enabled || delegate == null) return;
    try {
      await delegate!.event(event);
      _logSuccess(event.msg, name: event.name, icon: icon ?? event.sign ?? "✅");
    } catch (msg) {
      _logError(msg, name: event.name, icon: "⚠️");
    }
  }

  void _log(String name, String reason, {String? msg, String? icon}) async {
    if (!enabled || delegate == null) return;
    try {
      await delegate!.log(name, msg, reason);
      _logSuccess(msg, name: name, icon: icon ?? "👌");
    } catch (msg) {
      _logError(msg, name: name, icon: "❌");
    }
  }

  void _handleWidgetError(FlutterExceptionHandler? handler) {
    FlutterError.onError = (FlutterErrorDetails details) {
      _error(AnalyticsError.error(details));
      if (handler != null) handler(details);
    };
  }

  void _handlePlatformError(ErrorCallback? handler) {
    PlatformDispatcher.instance.onError = (e, st) {
      _error(AnalyticsError.platform(e, st));
      if (handler != null) return handler(e, st);
      return false;
    };
  }

  /// Initializes analytics globally.
  ///
  /// Example:
  /// ```dart
  /// Analytics.init(
  ///   enabled: true,
  ///   delegate: MyAnalyticsDelegate(),
  /// );
  /// ```
  static void init({
    bool enabled = kReleaseMode,
    String name = kAnalytics,
    bool showLogs = true,
    bool showSuccessLogs = true,
    bool showLogTime = false,
    int? errorLogLevel,
    int? errorSequenceNumber,
    int? successLogLevel,
    int? successSequenceNumber,
    AnalyticsDelegate? delegate,
    FlutterExceptionHandler? widgetError,
    ErrorCallback? platformError,
  }) {
    if (!enabled) return;
    _i = Analytics._(
      enabled: enabled,
      name: name,
      showLogs: showLogs,
      showSuccessLogs: showSuccessLogs,
      showLogTime: showLogTime,
      errorLogLevel: errorLogLevel,
      errorSequenceNumber: errorSequenceNumber,
      successLogLevel: successLogLevel,
      successSequenceNumber: successSequenceNumber,
      delegate: delegate,
    );
    i._handleWidgetError(widgetError);
    i._handlePlatformError(platformError);
  }

  /// Logs ✅ normally, ⚠️ if delegate fails
  ///
  /// Logs an analytics event with optional [msg] and [props].
  static void event(
    String name, {
    String? msg,
    String? icon,
    Map<String, String>? props,
  }) async {
    try {
      i._event(AnalyticsEvent.create(name, msg: msg, sign: icon, props: props));
    } catch (msg) {
      i._logError(msg, name: name, icon: "⚠️");
    }
  }

  /// Logs 🟢 on success, 🔴 on failure
  ///
  /// Executes an asynchronous function and logs analytics results.
  static Future<void> call(
    AsyncCallback callback, {
    String? name,
    String? reason,
    String? msg,
  }) async {
    try {
      await callback();
      i._log(name ?? 'call', reason ?? '', msg: msg, icon: "🟢");
    } catch (msg) {
      i._logError(msg, name: name, icon: "🔴");
    }
  }

  /// Logs 🎯 on success, 🔥 on failure
  ///
  /// Executes an asynchronous function and logs analytics results.
  static Future<T?> execute<T extends Object?>(
    Future<T?> Function() callback, {
    String? name,
    String? msg,
  }) async {
    try {
      final result = await callback();
      event(name ?? "execute", msg: msg, icon: '🎯');
      return result;
    } catch (msg) {
      i._logError(msg, name: name, icon: "🔥");
      return null;
    }
  }

  /// Logs 🚀 on success, ⚠️ on failure
  ///
  /// Executes an asynchronous function and logs analytics results.
  static Stream<T?> stream<T extends Object?>(
    Stream<T?> Function() callback, {
    String? name,
    String? msg,
  }) async* {
    try {
      yield* callback();
      event(name ?? "stream", msg: msg, icon: "🚀");
    } catch (msg) {
      i._logError(msg, name: name, icon: "⚠️");
      yield null;
    }
  }

  /// Logs 👌 normally, ❌ if delegate fails
  ///
  /// Logs a custom message to the analytics delegate.
  static void log(String name, String reason, {String? msg}) async {
    try {
      i._log(name, reason, msg: msg, icon: "👌");
    } catch (msg) {
      i._logError(msg, name: name, icon: "❌");
    }
  }
}
