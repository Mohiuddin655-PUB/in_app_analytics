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
  final bool _enabled;

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
    bool enabled = kReleaseMode,
    this.showLogs = true,
    this.showSuccessLogs = true,
    this.name = kAnalytics,
    this.showLogTime = false,
    this.errorLogLevel,
    this.successLogLevel,
    this.successSequenceNumber,
    this.errorSequenceNumber,
    this.delegate,
  }) : _enabled = enabled;

  bool get enabled => _enabled && delegate != null;

  static Analytics? _i;

  /// Returns the current [Analytics] instance.
  static Analytics get i => _i ??= Analytics._();

  /// Writes a formatted log entry.
  void _logs(
    Object? msg, {
    String? name,
    String? reason,
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
    if (reason != null && reason.isNotEmpty) {
      log = "$log[$reason]";
    }
    if (status != null && status.isNotEmpty) {
      log = "$log => $status";
    }
    if (msg != null) {
      log = "$log:$msg";
    }
    dev.log(
      log,
      name: this.name,
      level: level ?? 0,
      time: showLogTime ? DateTime.now() : null,
      sequenceNumber: sequenceNumber,
    );
  }

  void _logSuccess(Object? msg, {String? name, String? reason, String? icon}) {
    if (!showSuccessLogs) return;
    _logs(
      msg,
      status: "done!",
      reason: reason,
      icon: icon ?? "✅",
      name: name,
      level: successLogLevel,
      sequenceNumber: successSequenceNumber,
    );
  }

  void _logError(Object? msg, {String? name, String? reason, String? icon}) {
    if (!showLogs) return;
    _logs(
      msg,
      status: 'failed!',
      reason: reason,
      icon: icon ?? "️️❌️",
      name: name,
      level: errorLogLevel,
      sequenceNumber: errorSequenceNumber,
    );
  }

  /// Logs ❌ or 🔥 if sending fails
  ///
  void _error(AnalyticsError error, {String? icon}) async {
    try {
      if (enabled) await delegate!.error(error);
      _logError(error.msg, name: "error", icon: icon ?? error.sign ?? "❌");
    } catch (msg) {
      _logError(msg, name: "error", icon: "🔥");
    }
  }

  void _event(AnalyticsEvent event, bool success, {String? icon}) async {
    try {
      if (success) {
        if (enabled) await delegate!.event(event);
        _logSuccess(
          event.msg,
          name: event.name,
          reason: event.reason,
          icon: icon ?? event.sign ?? "✅",
        );
        return;
      }
      if (enabled) await delegate!.failure(event);
      _logError(
        event.msg,
        name: event.name,
        reason: event.reason,
        icon: icon ?? event.sign ?? "❌",
      );
    } catch (msg) {
      _logError(msg, name: event.name, icon: "⚠️", reason: event.reason);
    }
  }

  void _log(
    String name,
    bool success, {
    String? reason,
    String? msg,
    String? icon,
  }) async {
    try {
      if (success) {
        if (enabled) {
          await delegate!.log(AnalyticsEvent.create(
            name,
            msg: msg,
            reason: reason,
            sign: icon ?? "✅",
          ));
        }
        _logSuccess(msg, name: name, icon: icon ?? "👌", reason: reason);
        return;
      }
      if (enabled) {
        await delegate!.failure(
          AnalyticsEvent.create(
            name,
            reason: reason,
            msg: msg,
            sign: icon ?? "❌",
          ),
        );
      }
      _logError(msg, name: name, icon: icon ?? "❌", reason: reason);
    } catch (msg) {
      _logError(msg, name: name, icon: "❌", reason: reason);
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

  /// Logs ✅ normally, ⚠️ if fails
  ///
  /// Logs an analytics event with optional [msg] and [props].
  /// Status: true normally, false if fails
  static void event(
    String name, {
    String? reason,
    String? msg,
    bool status = true,
    String? icon,
    Map<String, String>? props,
  }) async {
    try {
      i._event(
        AnalyticsEvent.create(name, msg: msg, sign: icon, props: props),
        status,
      );
    } catch (msg) {
      i._logError(msg, name: name, icon: "⚠️");
    }
  }

  /// Logs 🟢 on success, 🔴 on failure
  ///
  /// Executes an synchronous function and logs analytics results.
  static void call(
    VoidCallback callback, {
    String? name,
    String? reason,
    String? msg,
  }) async {
    try {
      callback();
      i._log(name ?? 'call', true, reason: reason, msg: msg, icon: "🟢");
    } catch (msg) {
      i._log(
        name ?? 'call',
        false,
        reason: reason,
        msg: msg.toString(),
        icon: "🔴",
      );
    }
  }

  /// Logs 🟢 on success, 🔴 on failure
  ///
  /// Executes an asynchronous function and logs analytics results.
  static Future<void> callAsync(
    AsyncCallback callback, {
    String? name,
    String? reason,
    String? msg,
  }) async {
    try {
      await callback();
      i._log(name ?? 'call_async', true, reason: reason, msg: msg, icon: "🟢");
    } catch (msg) {
      i._log(
        name ?? 'call_async',
        false,
        reason: reason,
        msg: msg.toString(),
        icon: "🔴",
      );
    }
  }

  /// Logs 🎯 on success, 🔥 on failure
  ///
  /// Executes an synchronous function and logs analytics results.
  static T? execute<T extends Object?>(
    T? Function() callback, {
    String? name,
    String? reason,
    String? msg,
  }) {
    try {
      final result = callback();
      i._log(name ?? "execute", true, reason: reason, msg: msg, icon: '🎯');
      return result;
    } catch (msg) {
      i._log(
        name ?? "execute",
        false,
        reason: reason,
        msg: msg.toString(),
        icon: "🔥",
      );
      return null;
    }
  }

  /// Logs 🎯 on success, 🔥 on failure
  ///
  /// Executes an asynchronous function and logs analytics results.
  static Future<T?> future<T extends Object?>(
    Future<T?> Function() callback, {
    String? name,
    String? reason,
    String? msg,
  }) async {
    try {
      final result = await callback();
      i._log(name ?? "future", true, reason: reason, msg: msg, icon: '🎯');
      return result;
    } catch (msg) {
      i._log(
        name ?? "future",
        false,
        reason: reason,
        msg: msg.toString(),
        icon: "🔥",
      );
      return null;
    }
  }

  /// Logs 🚀 on success, ⚠️ on failure
  ///
  /// Executes an asynchronous function and logs analytics results.
  static Stream<T?> stream<T extends Object?>(
    Stream<T?> Function() callback, {
    String? name,
    String? reason,
    String? msg,
  }) async* {
    try {
      yield* callback();
      i._log(name ?? "stream", true, reason: reason, msg: msg, icon: '🚀');
    } catch (msg) {
      i._log(
        name ?? "stream",
        false,
        reason: reason,
        msg: msg.toString(),
        icon: "⚠️",
      );
      yield null;
    }
  }

  /// Logs 👌 normally, ❌ if delegate fails
  ///
  /// Logs a custom message to the analytics delegate.
  static void log(
    String name,
    String reason, {
    bool status = true,
    String? msg,
  }) async {
    try {
      i._log(name, status, reason: reason, msg: msg, icon: status ? '👌' : "❌");
    } catch (msg) {
      i._logError(msg, name: name, reason: reason, icon: "❌🟡");
    }
  }

  /// Logs 🟡 normally, ❌ if delegate fails
  ///
  /// Logs a custom warning message to the analytics delegate.
  static void warning(
    String name,
    String reason, {
    bool status = true,
    String? msg,
  }) async {
    try {
      i._log(
        name,
        status,
        reason: reason,
        msg: msg,
        icon: status ? '🟡' : "⚠️",
      );
    } catch (msg) {
      i._logError(msg, name: name, reason: reason, icon: "⚠️");
    }
  }
}
