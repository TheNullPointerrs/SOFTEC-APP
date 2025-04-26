import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  // Fetch a random inspirational quote
  static Future<Map<String, dynamic>> fetchQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://quotes-inspirational-quotes-motivational-quotes.p.rapidapi.com/quote?token=ipworld.info'),
        headers: {
          'x-rapidapi-host': 'quotes-inspirational-quotes-motivational-quotes.p.rapidapi.com',
          'x-rapidapi-key': 'bff4060cf8mshead332a0d7939c6p1b4d4fjsn559c7bbad802',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      // Return default quote if API fails
      return {
        'author': 'Theodore Roosevelt',
        'text': 'Believe you can and you\'re halfway there',
      };
    }
  }
}
