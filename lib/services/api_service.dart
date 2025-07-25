// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = '.';

  static const Duration _timeout = Duration(seconds: 30);

  /// Financial news and tips API call
  static Future<List<Map<String, dynamic>>> fetchFinancialNews() async {
    try {
      // NewsAPI for financial news
      final response = await http
          .get(
            Uri.parse(
              'https://newsapi.org/v2/everything?q=finance&sortBy=publishedAt&apiKey=c51b7df10f6746e69e90281b1aa3d224',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> articles = data['articles'] ?? [];

        return articles
            .map(
              (article) => {
                'id':
                    article['id'] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                'title': article['title'] ?? 'Financial News',
                'description':
                    article['description'] ?? article['content'] ?? '',
                'url': article['url'] ?? '',
                'publishedAt':
                    article['publishedAt'] ?? DateTime.now().toIso8601String(),
              },
            )
            .toList();
      } else {
        throw Exception(
          'Failed to fetch financial news: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching financial news: $e');

      return _getFallbackNews();
    }
  }

  /// Currency exchange rates API call
  static Future<Map<String, double>> fetchExchangeRates() async {
    try {
      // ExchangeRate-API for currency conversion
      final response = await http
          .get(
            Uri.parse(
              'https://v6.exchangerate-api.com/v6/3feed6344aa426551a09a3fd/latest/USD',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final Map<String, dynamic> rates = data['conversion_rates'] ?? {};

        return rates.map((key, value) => MapEntry(key, value.toDouble()));
      } else {
        throw Exception(
          'Failed to fetch exchange rates: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      // Return fallback rates
      return {'EUR': 0.85, 'GBP': 0.73, 'JPY': 110.0, 'CAD': 1.25};
    }
  }

  /// Financial tips API call
  static Future<List<Map<String, dynamic>>> fetchFinancialTips() async {
    try {
      // Using quotable API for financial wisdom quotes
      final response = await http
          .get(
            Uri.parse('https://api.quotable.io/quotes?tags=wisdom&limit=10'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        // Convert quotes to financial tips format
        return results
            .map(
              (quote) => {
                'id':
                    quote['_id'] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                'title': 'Financial Wisdom',
                'description':
                    quote['content'] ?? 'Save money and invest wisely.',
                'category': 'wisdom',
              },
            )
            .toList()
            .cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch financial tips');
      }
    } catch (e) {
      print('Error fetching financial tips: $e');
      return _getFallbackTips();
    }
  }

  static Future<Map<String, dynamic>?> verifyBankAccount({
    required String accountNumber,
    required String routingNumber,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('YOUR_BANK_VERIFICATION_ENDPOINT'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer YOUR_BANKING_API_KEY',
            },
            body: json.encode({
              'account_number': accountNumber,
              'routing_number': routingNumber,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error verifying bank account: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> makeApiCall({
    required String endpoint,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      late http.Response response;
      final uri = Uri.parse('$_baseUrl$endpoint');

      final defaultHeaders = {'Content-Type': 'application/json', ...?headers};

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: defaultHeaders)
              .timeout(_timeout);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: defaultHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: defaultHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: defaultHeaders)
              .timeout(_timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      print('API call error: $e');
      return null;
    }
  }

  /// Fallback financial news data
  static List<Map<String, dynamic>> _getFallbackNews() {
    return [
      {
        'id': '1',
        'title': 'Smart Budgeting Tips for 2024',
        'description':
            'Learn effective strategies to manage your monthly budget and increase savings.',
        'url': '',
        'publishedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'title': 'Emergency Fund: How Much You Need',
        'description':
            'Financial experts recommend saving 3-6 months of expenses for emergencies.',
        'url': '',
        'publishedAt': DateTime.now()
            .subtract(Duration(days: 1))
            .toIso8601String(),
      },
      {
        'id': '3',
        'title': 'Investment Basics for Beginners',
        'description':
            'Start your investment journey with these fundamental principles.',
        'url': '',
        'publishedAt': DateTime.now()
            .subtract(Duration(days: 2))
            .toIso8601String(),
      },
    ];
  }

  /// Fallback financial tips
  static List<Map<String, dynamic>> _getFallbackTips() {
    return [
      {
        'id': '1',
        'title': 'Track Every Expense',
        'description':
            'Write down or use an app to record every purchase, no matter how small.',
        'category': 'budgeting',
      },
      {
        'id': '2',
        'title': 'Pay Yourself First',
        'description': 'Set aside savings before paying any bills or expenses.',
        'category': 'savings',
      },
      {
        'id': '3',
        'title': 'Use the 50/30/20 Rule',
        'description': '50% needs, 30% wants, 20% savings and debt repayment.',
        'category': 'budgeting',
      },
    ];
  }
}
