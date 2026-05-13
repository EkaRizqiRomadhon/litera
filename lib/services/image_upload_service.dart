import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  // Ganti dengan API Key milik Anda dari imgbb.com
  static const String _apiKey = '153e543852cbe2fd9306bed5c7f54860';

  Future<String> uploadImage(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload'),
    );

    request.fields['key'] = _apiKey;
    request.files.add(
      await http.MultipartFile.fromPath('image', file.path),
    );

    final streamedResponse = await request.send();
    final result = await http.Response.fromStream(streamedResponse);

    if (result.statusCode != 200) {
      throw Exception('Upload gagal (${result.statusCode}): ${result.body}');
    }

    final data = jsonDecode(result.body);
    final url = data['data']['display_url'] as String;

    return url;
  }
}