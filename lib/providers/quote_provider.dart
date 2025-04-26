import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

class QuoteNotifier extends StateNotifier<Map<String, dynamic>> {
  QuoteNotifier() : super({
    'author': '',
    'text': 'Believe you can and you\'re halfway there',
  });

  Future<void> fetchQuote() async {
    try {
      final quote = await DatabaseService.fetchQuote();
      state = quote;
    } catch (e) {
      // Keep existing quote if there's an error
    }
  }
}

final quoteProvider = StateNotifierProvider<QuoteNotifier, Map<String, dynamic>>((ref) {
  return QuoteNotifier();
}); 