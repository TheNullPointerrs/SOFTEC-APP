import 'package:http/http.dart' as http;
import 'dart:convert';

class OCRService {
  final String apiKey = 'K86734045288957';

  Future<String> sendImageUrlToOCR(String imageUrl) async {
    try {
      final uri = Uri.parse(
          'https://api.ocr.space/parse/imageurl?apikey=$apiKey&url=$imageUrl');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final extractedText = responseData['ParsedResults'][0]['ParsedText'];
        return extractedText;
      } else {
        throw Exception('Failed to fetch OCR data');
      }
    } catch (e) {
      throw Exception('Error in OCR API request: $e');
    }
  }
}