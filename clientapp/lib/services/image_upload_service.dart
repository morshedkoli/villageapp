import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Uploads user-supplied photos to Cloudinary.
///
/// Extracted from [ProblemService] so the reporting flow reads as a Firestore
/// write and this stays the only place that knows about the upload contract.
class ImageUploadService {
  ImageUploadService._();

  static final ImageUploadService instance = ImageUploadService._();

  static const int maxBytes = 5 * 1024 * 1024;
  static const Duration _uploadTimeout = Duration(seconds: 60);

  // Supplied at build time with --dart-define; never committed.
  static const String _cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const String _apiKey = String.fromEnvironment('CLOUDINARY_API_KEY');
  static const String _apiSecret = String.fromEnvironment(
    'CLOUDINARY_API_SECRET',
  );

  /// Whether upload credentials were compiled into this build.
  static bool get isConfigured =>
      _cloudName.isNotEmpty && _apiKey.isNotEmpty && _apiSecret.isNotEmpty;

  /// Uploads [photo] and returns its secure URL.
  ///
  /// Throws a [StateError] with a user-facing message when the build has no
  /// credentials, the file is over [maxBytes], or the upload fails.
  Future<String> upload(File photo) async {
    if (!isConfigured) {
      throw StateError(
        'Image upload is not configured. Please contact administrator or submit without photo.',
      );
    }

    final bytes = await photo.readAsBytes();
    if (bytes.length > maxBytes) {
      throw StateError(
        'Image size too large. Please select an image smaller than 5MB.',
      );
    }

    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
    )
      ..fields['api_key'] = _apiKey
      ..fields['timestamp'] = timestamp
      ..fields['signature'] = _signature(timestamp)
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'upload.jpg'),
      );

    try {
      final response = await request.send().timeout(_uploadTimeout);
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw StateError(
          'Image upload failed with status ${response.statusCode}',
        );
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final url = json['secure_url'];
      if (url is String && url.isNotEmpty) return url;

      final message =
          (json['error'] as Map<String, dynamic>?)?['message'] ?? 'Unknown error';
      throw StateError('Image upload failed: $message');
    } on StateError {
      rethrow;
    } catch (error) {
      throw StateError('Image upload failed: $error');
    }
  }

  /// Cloudinary signs the sorted parameter string with the API secret.
  static String _signature(String timestamp) {
    return sha1
        .convert(utf8.encode('timestamp=$timestamp$_apiSecret'))
        .toString();
  }
}
