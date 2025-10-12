import 'dart:io';

import 'package:flutter/foundation.dart';

/// Returns the current platform identifier as a string.
/// Supported values: `web`, `wasm`, `android`, `ios`, `fuchsia`, `macos`, `windows`, `linux`.
String? get _platform => kIsWeb
    ? "web"
    : kIsWasm
        ? 'wasm'
        : Platform.isAndroid
            ? "android"
            : Platform.isIOS
                ? "ios"
                : Platform.isFuchsia
                    ? "fuchsia"
                    : Platform.isMacOS
                        ? "macos"
                        : Platform.isWindows
                            ? "windows"
                            : Platform.isLinux
                                ? "linux"
                                : null;

/// Defines possible types of analytics errors.
enum AnalyticsErrorType {
  /// Represents an [AssertionError].
  assertion,

  /// Represents a runtime widget error or exception.
  widget,

  /// Represents a platform-level error.
  platform;

  /// Parses a [source] value into an [AnalyticsErrorType] if possible.
  static AnalyticsErrorType? parse(Object? source) {
    try {
      return values.firstWhere((e) {
        if (e == source) return true;
        if (e.index == source) return true;
        if (e.name == source) return true;
        return false;
      });
    } catch (_) {
      return null;
    }
  }
}

/// Represents an analytics error, including time, platform, and details.
class AnalyticsError {
  /// The timestamp when the error occurred.
  final String? time;

  /// The platform where the error occurred.
  final String? platform;

  /// The error message.
  final String? msg;

  /// The error sign.
  final String? sign;

  /// Additional error details or stack trace.
  final String? details;

  /// The type of the analytics error.
  final AnalyticsErrorType? type;

  /// Creates an empty [AnalyticsError] instance.
  const AnalyticsError.empty() : this();

  /// Creates a new [AnalyticsError].
  const AnalyticsError({
    this.time,
    this.platform,
    this.msg,
    this.sign,
    this.details,
    this.type,
  });

  /// Creates an error report from a [FlutterErrorDetails] object.
  factory AnalyticsError.error(FlutterErrorDetails details) {
    return AnalyticsError(
      platform: _platform,
      time: DateTime.now().toIso8601String(),
      msg: details.exception.toString(),
      details: details.exceptionAsString(),
      sign: details.exception is AssertionError
          ? "🧨"
          : details.exception is Exception || details.exception is Error
              ? "🚨"
              : "💥",
      type: details.exception is AssertionError
          ? AnalyticsErrorType.assertion
          : AnalyticsErrorType.widget,
    );
  }

  /// Creates a platform-specific error report from an [exception] and [stackTrace].
  factory AnalyticsError.platform(Object exception, StackTrace stackTrace) {
    return AnalyticsError(
      platform: _platform,
      time: DateTime.now().toIso8601String(),
      type: AnalyticsErrorType.platform,
      sign: "🛑",
      msg: exception.toString(),
      details: stackTrace.toString(),
    );
  }

  /// Parses a JSON-like [Map] into an [AnalyticsError] instance.
  factory AnalyticsError.parse(Object? source) {
    if (source is! Map || source.isEmpty) return AnalyticsError.empty();
    final time = source['time'];
    final platform = source['platform'];
    final msg = source['msg'];
    final sign = source['sign'];
    final details = source['details'];
    final type = source['type'];
    return AnalyticsError(
      time: time is String ? time : null,
      platform: platform is String ? platform : null,
      msg: msg is String ? msg : null,
      sign: sign is String ? sign : null,
      details: details is String ? details : null,
      type: AnalyticsErrorType.parse(type),
    );
  }

  /// Returns this object as a JSON-compatible [Map].
  Map<String, dynamic>? get json {
    final x = {
      if ((time ?? '').isNotEmpty) "time": time,
      if ((platform ?? '').isNotEmpty) "platform": platform,
      if ((msg ?? '').isNotEmpty) "msg": msg,
      if ((sign ?? '').isNotEmpty) "sign": sign,
      if (type != null) "type": type?.name,
      if (details != null) "details": details,
    };
    return x.isEmpty ? null : x;
  }

  @override
  String toString() {
    return "$AnalyticsError($sign ${type?.name ?? 'error'}: $msg - $details)";
  }
}

/// Represents a logged analytics event.
class AnalyticsEvent {
  /// The event name.
  final String name;

  /// The event reason.
  final String? reason;

  /// The timestamp in milliseconds.
  final int time;

  /// The platform where the event was logged.
  final String? platform;

  /// An optional event message.
  final String? msg;

  /// The optional message sign.
  final String? sign;

  /// Optional custom event properties.
  final Map<String, Object>? props;

  /// Creates an empty [AnalyticsEvent].
  const AnalyticsEvent.empty() : this(name: '');

  /// Creates a new analytics event.
  const AnalyticsEvent({
    required this.name,
    this.reason,
    this.time = 0,
    this.sign,
    this.platform,
    this.msg,
    this.props,
  });

  /// Creates an [AnalyticsEvent] from the current time and platform.
  factory AnalyticsEvent.create(
    String name, {
    String? reason,
    String? sign,
    String? msg,
    Map<String, Object>? props,
  }) {
    return AnalyticsEvent(
      platform: _platform,
      time: DateTime.now().millisecondsSinceEpoch,
      name: name,
      reason: reason,
      sign: sign ?? "✅",
      msg: msg,
      props: props,
    );
  }

  /// Parses a JSON-like [Map] into an [AnalyticsEvent].
  factory AnalyticsEvent.parse(Object? source) {
    if (source is! Map || source.isEmpty) return AnalyticsEvent.empty();
    final name = source['name'];
    if (name is! String || name.isEmpty) return AnalyticsEvent.empty();
    final time = source['time'];
    final reason = source['reason'];
    final platform = source['platform'];
    final sign = source['sign'];
    final msg = source['msg'];
    final props = source['props'];
    return AnalyticsEvent(
      name: name,
      time: time is num ? time.toInt() : 0,
      platform: platform is String ? platform : null,
      reason: reason is String ? reason : null,
      sign: sign is String ? sign : null,
      msg: msg is String ? msg : null,
      props: props is Map
          ? props.map((k, v) => MapEntry(k.toString(), v.toString()))
          : null,
    );
  }

  /// Returns this event as a JSON-compatible [Map].
  Map<String, dynamic>? get json {
    final x = {
      if (name.isNotEmpty) "name": name,
      if (time > 0) "time": time,
      if ((platform ?? '').isNotEmpty) "platform": platform,
      if ((reason ?? '').isNotEmpty) "reason": reason,
      if ((sign ?? '').isNotEmpty) "sign": sign,
      if ((msg ?? '').isNotEmpty) "msg": msg,
      if (props != null || props!.isNotEmpty) "props": props,
    };
    return x.isEmpty ? null : x;
  }

  @override
  String toString() {
    return "$AnalyticsEvent($sign $name${reason != null ? "[$reason]" : ''}: $msg)";
  }
}
