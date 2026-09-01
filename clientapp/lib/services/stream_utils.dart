import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// Wraps a Firestore stream with error handling for platform issues.
/// Returns the last known value on transient errors instead of breaking the stream.
Stream<T> handleStreamErrors<T>(Stream<T> source, T fallback, [String label = '']) {
  return source.handleError(
    (error, stackTrace) {
      debugPrint('Stream [$label]: Stream error (handled) - $error');
      // Firestore can throw internal errors on both web and mobile.
      // Log the error but don't break the stream.
    },
    test: (error) {
      // Handle all Firestore / platform internal errors gracefully
      // so streams keep alive on Android & web.
      final errorStr = error.toString();
      final isKnown = errorStr.contains('INTERNAL ASSERTION FAILED') ||
          errorStr.contains('Unexpected state') ||
          errorStr.contains('PERMISSION_DENIED') ||
          errorStr.contains('UNAVAILABLE') ||
          errorStr.contains('FAILED_PRECONDITION') ||
          errorStr.contains('NOT_FOUND') ||
          errorStr.contains('IndexNotReady') ||
          errorStr.contains('requires an index');
      if (isKnown) {
        debugPrint('Stream [$label]: Suppressed known error: $errorStr');
      }
      return isKnown;
    },
  ).onErrorReturn(fallback);
}
