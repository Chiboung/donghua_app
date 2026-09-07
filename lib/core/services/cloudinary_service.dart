import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Uploads listing photos to Cloudinary using an **unsigned** upload
/// preset, so no API secret has to live in the app.
///
/// Config below matches the preset shown in the Cloudinary dashboard:
/// cloud name `trwgmqar`, preset `donghua` (unsigned, dynamic folders).
/// If you rename or recreate the preset, update these two constants —
/// they're the only thing that ties the app to your Cloudinary account.
class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  static const String _cloudName = 'trwgmqar';
  static const String _uploadPreset = 'donghua';

  Uri get _endpoint =>
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  /// Uploads raw image bytes and returns the `secure_url` Cloudinary
  /// hands back. Takes bytes (not a File path) so it works the same on
  /// web, where picked images never touch the local filesystem.
  ///
  /// [folder] is optional — the preset has "dynamic folders" on, so
  /// passing e.g. `products` here groups uploads in the Cloudinary
  /// media library without needing a signed request.
  Future<String> uploadImage(
    Uint8List bytes, {
    required String filename,
    String? folder,
  }) async {
    final request = http.MultipartRequest('POST', _endpoint)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );
    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final message = _extractError(response.body) ?? response.body;
      throw CloudinaryUploadException(
        'Image upload failed (${response.statusCode}): $message',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = body['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw const CloudinaryUploadException(
        'Image upload succeeded but Cloudinary returned no URL.',
      );
    }
    return secureUrl;
  }

  String? _extractError(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'] as Map<String, dynamic>?;
      return error?['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}

class CloudinaryUploadException implements Exception {
  final String message;
  const CloudinaryUploadException(this.message);

  @override
  String toString() => message;
}
