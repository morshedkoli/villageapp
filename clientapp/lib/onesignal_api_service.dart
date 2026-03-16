import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Sends push notifications to all OneSignal subscribers via the REST API.
///
/// This allows push delivery without any server (no Firebase Blaze plan needed).
/// Called directly from the app whenever a notification event occurs.
class OneSignalApiService {
  OneSignalApiService._();

  static const String _appId = 'a8ab892b-a4ca-4161-b54b-8828c22dfc8f';

  // Get this from: OneSignal Dashboard → Your App → Settings → Keys & IDs
  // "REST API Key"
  static const String _restApiKey = 'os_v2_app_vcvysk5ezjawdnklraumelp4r4k3ah4c265em4fqk35ir57n4dnr5lfsacescow5jgvse7eqpdnyqgncsamcelgwizhaf2oaa27hjyy';

  /// Send a push notification to ALL subscribers.
  ///
  /// [title] — notification heading
  /// [body]  — notification message
  /// [type]  — optional data tag (e.g. 'donation', 'problem', 'citizen')
  static Future<void> sendToAll({
    required String title,
    required String body,
    String type = 'general',
  }) async {
    if (kIsWeb) return; // Web not supported

    final payload = jsonEncode({
      'app_id': _appId,
      'included_segments': ['All'],
      'headings': {'en': title},
      'contents': {'en': body},
      'data': {'type': type},
    });

    try {
      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
      );
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Basic $_restApiKey');
      request.write(payload);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      debugPrint('OneSignal push sent: ${response.statusCode} $responseBody');
      client.close();
    } catch (e) {
      debugPrint('OneSignal push failed: $e');
    }
  }
}
