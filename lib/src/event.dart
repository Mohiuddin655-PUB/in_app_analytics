import 'dart:io';

import 'package:flutter/foundation.dart';

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
