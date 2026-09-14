// Test helpers shared across the share_plus test suite.
//
// These fakes *extend* [SharePlatform] (rather than only implementing it) so
// that they can be assigned to the global [SharePlatform.instance] setter,
// which is guarded by [PlatformInterface.verifyToken].
import 'dart:async';

import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

/// A [SharePlatform] that records every [share] call and returns a configurable
/// [ShareResult], used to verify that the public API forwards the right params.
class RecordingSharePlatform extends SharePlatform {
  RecordingSharePlatform({this.resultToReturn = ShareResult.unavailable});

  final List<ShareParams> recordedCalls = [];
  ShareResult resultToReturn;
  Object? errorToThrow;

  /// The most recently received params, or `null` when [share] was never called.
  ShareParams? get lastParams =>
      recordedCalls.isEmpty ? null : recordedCalls.last;

  @override
  Future<ShareResult> share(ShareParams params) async {
    recordedCalls.add(params);
    if (errorToThrow != null) {
      final error = errorToThrow;
      errorToThrow = null;
      throw error!;
    }
    return resultToReturn;
  }
}

/// A [SharePlatform] that emulates the Android "one pending share at a time"
/// contract: starting a new [share] while a previous one is still in flight
/// makes the previous call resolve with [ShareResult.unavailable].
///
/// This lets unit tests exercise the documented concurrency behaviour without a
/// real platform channel.
class ConcurrencyEmulatingPlatform extends SharePlatform {
  ConcurrencyEmulatingPlatform({
    this.resultToReturn =
        const ShareResult('success-raw', ShareResultStatus.success),
    this.resolveDelay = const Duration(milliseconds: 5),
  });

  final ShareResult resultToReturn;
  final Duration resolveDelay;

  final List<Completer<ShareResult>> _pending = [];

  /// Every params object received by [share], in arrival order.
  final List<ShareParams> recordedCalls = [];

  @override
  Future<ShareResult> share(ShareParams params) async {
    recordedCalls.add(params);
    // A new share pre-empts any pending one, which must report `unavailable`.
    for (final pending in _pending) {
      if (!pending.isCompleted) {
        pending.complete(ShareResult.unavailable);
      }
    }
    _pending.clear();

    final completer = Completer<ShareResult>();
    _pending.add(completer);

    // Simulate the platform taking some time to present the share sheet.
    Future<void>.delayed(resolveDelay, () {
      if (!completer.isCompleted) {
        _pending.remove(completer);
        completer.complete(resultToReturn);
      }
    });

    return completer.future;
  }
}

/// A trivial [SharePlatform] whose [share] always throws, for error-path tests.
class ThrowingSharePlatform extends SharePlatform {
  final Object error;
  ThrowingSharePlatform(this.error);

  @override
  Future<ShareResult> share(ShareParams params) async => throw error;
}
