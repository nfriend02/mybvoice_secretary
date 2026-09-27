import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/extractive_summarizer.dart';

/// Calls `/api/*`. Local extractive summary is used when the endpoint is down.
class ApiClient {
  static Future<String> summarize(String text, {int sentences = 3}) async {
    try {
      final response = await http
          .post(
            Uri.base.resolve('${AppConfig.apiPrefix}/summarize'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text, 'sentences': sentences}),
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final summary = body is Map ? body['summary'] as String? : null;
        if (summary != null && summary.trim().isNotEmpty) {
          return summary.trim();
        }
      }
    } catch (e) {
      debugPrint('api summarize fallback: $e');
    }
    return ExtractiveSummarizer.summarize(text, maxSentences: sentences);
  }
}
