import 'dart:developer';

import 'package:flutter/foundation.dart';

/// Lightweight performance trace helper wrapping [dart:developer] Timeline.
///
/// Events appear in the DevTools Performance view in profile/debug builds.
/// In release builds all calls are no-ops to avoid overhead and noisy logs.
///
/// Usage:
/// ```dart
/// // Wrap a synchronous block:
/// PerfTrace.timeSync('deck.load', () {
///   // ... work ...
/// });
///
/// // Time an async operation:
/// await PerfTrace.timeAsync('deck.fetchDue', () async {
///   return await db.fetchDueCards(...);
/// });
/// ```
class PerfTrace {
  PerfTrace._();

  /// Whether tracing is active (only in debug or profile mode).
  static bool get _active => kDebugMode || kProfileMode;

  /// Wrap a synchronous block with a Timeline trace event.
  static T timeSync<T>(String label, T Function() fn) {
    if (!_active) return fn();
    return Timeline.timeSync(label, fn);
  }

  /// Wrap an asynchronous block with a Timeline async trace event.
  static Future<T> timeAsync<T>(String label, Future<T> Function() fn) async {
    if (!_active) return fn();
    final flow = Flow.begin();
    Timeline.timeSync('$label.start', () {});
    Flow.end(flow.id);
    try {
      final result = await fn();
      Timeline.timeSync('$label.end', () {});
      return result;
    } catch (e) {
      Timeline.timeSync('$label.error', () {});
      rethrow;
    }
  }

  /// Track a synchronous block. Returns the result of [fn].
  static T track<T>(String label, T Function() fn) {
    if (!_active) return fn();
    return Timeline.timeSync(label, fn);
  }
}
