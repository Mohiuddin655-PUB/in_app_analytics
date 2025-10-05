import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

const kAnalytics = "ANALYTICS";

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

enum AnalyticsErrorType {
  assertion,
  error,
  platform;

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

class AnalyticsError {
  final String? time;
  final String? platform;
  final String? msg;
  final String? details;
  final AnalyticsErrorType? type;

  const AnalyticsError.empty() : this();

  const AnalyticsError({
    this.time,
    this.platform,
    this.msg,
    this.details,
    this.type,
  });

  factory AnalyticsError.error(FlutterErrorDetails details) {
    return AnalyticsError(
      platform: _platform,
      time: DateTime.now().toIso8601String(),
      msg: details.exception.toString(),
      details: details.exceptionAsString(),
      type: details.exception is AssertionError
          ? AnalyticsErrorType.assertion
          : AnalyticsErrorType.error,
    );
  }

  factory AnalyticsError.platform(Object exception, StackTrace stackTrace) {
    return AnalyticsError(
      platform: _platform,
      time: DateTime.now().toIso8601String(),
      type: AnalyticsErrorType.platform,
      msg: exception.toString(),
      details: stackTrace.toString(),
    );
  }

  factory AnalyticsError.parse(Object? source) {
    if (source is! Map || source.isEmpty) return AnalyticsError.empty();
    final time = source['time'];
    final platform = source['platform'];
    final msg = source['msg'];
    final details = source['details'];
    final type = source['type'];
    return AnalyticsError(
      time: time is String ? time : null,
      platform: platform is String ? platform : null,
      msg: msg is String ? msg : null,
      details: details is String ? details : null,
      type: AnalyticsErrorType.parse(type),
    );
  }

  Map<String, dynamic>? get json {
    final x = {
      if ((time ?? '').isNotEmpty) "time": time,
      if ((platform ?? '').isNotEmpty) "platform": platform,
      if ((msg ?? '').isNotEmpty) "msg": msg,
      if (type != null) "type": type?.name,
      if (details != null) "details": details,
    };
    return x.isEmpty ? null : x;
  }

  @override
  String toString() => "$AnalyticsError(msg: $msg, details: $details)";
}

class AnalyticsEvent {
  final String name;
  final int time;
  final String? platform;
  final String? msg;
  final Map<String, String>? props;

  const AnalyticsEvent.empty() : this(name: '');

  const AnalyticsEvent({
    required this.name,
    this.time = 0,
    this.platform,
    this.msg,
    this.props,
  });

  factory AnalyticsEvent.create(
      String name, {
        String? msg,
        Map<String, String>? props,
      }) {
    return AnalyticsEvent(
      platform: _platform,
      time: DateTime.now().millisecondsSinceEpoch,
      name: name,
      msg: msg,
      props: props,
    );
  }

  factory AnalyticsEvent.parse(Object? source) {
    if (source is! Map || source.isEmpty) return AnalyticsEvent.empty();
    final name = source['name'];
    if (name is! String || name.isEmpty) return AnalyticsEvent.empty();
    final time = source['time'];
    final platform = source['platform'];
    final msg = source['msg'];
    final props = source['props'];
    return AnalyticsEvent(
      name: name,
      time: time is num ? time.toInt() : 0,
      platform: platform is String ? platform : null,
      msg: msg is String ? msg : null,
      props: props is Map
          ? props.map((k, v) => MapEntry(k.toString(), v.toString()))
          : null,
    );
  }

  Map<String, dynamic>? get json {
    final x = {
      if (name.isNotEmpty) "name": name,
      if (time > 0) "time": time,
      if ((platform ?? '').isNotEmpty) "platform": platform,
      if ((msg ?? '').isNotEmpty) "msg": msg,
      if (props != null || props!.isNotEmpty) "props": props,
    };
    return x.isEmpty ? null : x;
  }

  @override
  String toString() => "$AnalyticsEvent(name: $name, msg: $msg)";
}

abstract class AnalyticsDelegate {
  Future<void> error(AnalyticsError error);

  Future<void> event(AnalyticsEvent event);

  Future<void> log(String name, String? msg, String reason);
}

class Analytics {
  final bool enabled;
  final bool showLogs;
  final bool showSuccessLogs;
  final bool showLogTime;
  final int? errorLogLevel;
  final int? successLogLevel;
  final int? successSequenceNumber;
  final int? errorSequenceNumber;
  final String name;
  final AnalyticsDelegate? delegate;

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

  static Analytics get i => _i ??= Analytics._();

  void _logs(
    Object? msg, {
    String? name,
    String? status,
    int? level,
    int? sequenceNumber,
  }) {
    String log = '';
    if (name != null && name.isNotEmpty) {
      log = name;
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

  void _logSuccess(Object? msg, {String? name}) {
    if (!enabled || !showSuccessLogs) return;
    _logs(
      msg,
      status: "done!",
      name: name,
      level: successLogLevel,
      sequenceNumber: successSequenceNumber,
    );
  }

  void _logError(Object? msg, {String? name}) {
    if (!enabled || !showLogs) return;
    _logs(
      msg,
      status: 'failed!',
      name: name,
      level: errorLogLevel,
      sequenceNumber: errorSequenceNumber,
    );
  }

  void _error(AnalyticsError error) async {
    if (!enabled) return;
    if (delegate == null) return;
    try {
      await delegate!.error(error);
    } catch (msg) {
      _logError(msg, name: "error");
    }
  }

  void _event(AnalyticsEvent event) async {
    if (!enabled) return;
    if (delegate == null) return;
    try {
      await delegate!.event(event);
      _logSuccess(event.msg, name: event.name);
    } catch (msg) {
      _logError(msg, name: event.name);
    }
  }

  void _log(String name, String reason, {String? msg}) async {
    if (!enabled) return;
    if (delegate == null) return;
    try {
      await delegate!.log(name, msg, reason);
      _logSuccess(msg, name: name);
    } catch (msg) {
      _logError(msg, name: name);
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
      successSequenceNumber: successLogLevel,
      delegate: delegate,
    );
    i._handleWidgetError(widgetError);
    i._handlePlatformError(platformError);
  }

  static Future<void> call(
    String name,
    AsyncCallback callback, {
    String? msg,
  }) async {
    try {
      await callback();
      i._log(name, "init", msg: msg);
    } catch (msg) {
      i._logError(msg, name: name);
    }
  }

  static void log(String name, String reason, {String? msg}) async {
    try {
      i._log(name, reason, msg: msg);
    } catch (msg) {
      i._logError(msg, name: name);
    }
  }

  static void event(
    String name, {
    String? msg,
    Map<String, String>? props,
  }) async {
    try {
      i._event(AnalyticsEvent.create(name, msg: msg, props: props));
    } catch (msg) {
      i._logError(msg, name: name);
    }
  }
}
