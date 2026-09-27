import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/mail/domain/mail_draft.dart';
import '../../features/translate/domain/phrase_book.dart';
import '../config/app_config.dart';
import '../utils/extractive_summarizer.dart';

/// Calls `/api/*`. Direct provider calls use dotenv keys when the API is down.
class ApiClient {
  static Future<String> summarize(String text, {int sentences = 3}) async {
    final remote = await _post('/summarize', {
      'text': text,
      'sentences': sentences,
    });
    if (remote != null) return remote;
    final gemini = await _gemini(
      '다음 글을 한국어로 $sentences문장 이내로 요약해 주세요.\n\n$text',
    );
    if (gemini != null && gemini.isNotEmpty) return gemini;
    return ExtractiveSummarizer.summarize(text, maxSentences: sentences);
  }

  static Future<String> draftEmail(String text) async {
    final gemini = await _gemini(
      '다음 말을 한국어 이메일 초안으로 바꿔 주세요. 제목과 본문만 적어 주세요.\n\n$text',
    );
    if (gemini != null && gemini.isNotEmpty) return gemini;
    return MailDraft.compose(text).fileText;
  }

  static Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    final gemini = await _gemini(
      'Translate the following from $from to $to. Return only the translation.\n\n$text',
    );
    if (gemini != null && gemini.isNotEmpty) return gemini;
    return PhraseBook.translate(text, from: from, to: to);
  }

  static Future<String> weather(String city) {
    return _live(
      path: '/weather',
      query: {'q': city},
      missingKey: AppConfig.openWeatherApiKey.isEmpty,
      missingMessage: 'OpenWeather 키를 읽지 못했어요.',
      direct: () => _openWeather(city),
    );
  }

  static Future<String> exchange({
    required String base,
    required String quote,
  }) {
    return _live(
      path: '/exchange',
      query: {'base': base, 'quote': quote},
      missingKey: AppConfig.exchangeRateApiKey.isEmpty,
      missingMessage: '환율 키를 읽지 못했어요.',
      direct: () => _exchangeRate(base, quote),
    );
  }

  static Future<String> place(String query) async {
    final remote = await _get('/maps', {'q': query});
    if (remote != null) return remote;
    final found = await _geocode(query);
    if (found != null) return found;
    if (AppConfig.googleMapsApiKey.isEmpty) return '지도 키를 읽지 못했어요.';
    return '지도를 찾지 못했어요. Google 키에 Geocoding API가 허용되지 않았습니다.';
  }

  static Future<String> _live({
    required String path,
    required Map<String, String> query,
    required bool missingKey,
    required String missingMessage,
    required Future<String?> Function() direct,
  }) async {
    final remote = await _get(path, query);
    if (remote != null) return remote;
    if (missingKey) return missingMessage;
    return await direct() ?? missingMessage;
  }

  static Future<String?> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.base.resolve('${AppConfig.apiPrefix}$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));
      return _summary(response);
    } catch (e) {
      debugPrint('api $path fallback: $e');
      return null;
    }
  }

  static Future<String?> _get(String path, Map<String, String> query) async {
    try {
      final response = await http
          .get(
            Uri.base
                .resolve('${AppConfig.apiPrefix}$path')
                .replace(queryParameters: query),
          )
          .timeout(const Duration(seconds: 8));
      return _summary(response);
    } catch (e) {
      debugPrint('api $path fallback: $e');
      return null;
    }
  }

  static String? _summary(http.Response response) {
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body);
    final summary = body is Map ? body['summary'] as String? : null;
    if (summary == null || summary.trim().isEmpty) return null;
    return summary.trim();
  }

  static const _geminiModels = ['gemini-3.8-flash', 'gemini-flash-latest'];

  static Future<String?> _gemini(String prompt) async {
    final key = AppConfig.geminiApiKey;
    if (key.isEmpty || prompt.trim().isEmpty) return null;
    for (final model in _geminiModels) {
      final text = await _geminiModel(model, prompt, key);
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  static Future<String?> _geminiModel(
    String model,
    String prompt,
    String key,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
            ),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': key,
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        debugPrint('gemini $model status ${response.statusCode}');
        return null;
      }
      final body = jsonDecode(response.body);
      if (body is! Map) return null;
      final candidates = body['candidates'];
      if (candidates is! List || candidates.isEmpty) return null;
      final first = candidates.first;
      if (first is! Map) return null;
      final content = first['content'];
      if (content is! Map) return null;
      final parts = content['parts'];
      if (parts is! List) return null;
      final text = parts
          .map((part) => part is Map ? part['text'] as String? ?? '' : '')
          .join()
          .trim();
      return text.isEmpty ? null : text;
    } catch (e) {
      debugPrint('gemini $model fallback: $e');
      return null;
    }
  }

  static Future<String?> _openWeather(String city) async {
    final key = AppConfig.openWeatherApiKey;
    try {
      final response = await http
          .get(
            Uri.https('api.openweathermap.org', '/data/2.5/weather', {
              'q': city,
              'appid': key,
              'units': 'metric',
              'lang': 'kr',
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body is! Map) return null;
      final weather = body['weather'];
      final description = weather is List && weather.isNotEmpty
          ? weather.first['description'] as String? ?? '날씨'
          : '날씨';
      final temp = (body['main']?['temp'] as num?)?.round() ?? 0;
      final name = body['name'] as String? ?? city;
      return '$name: $description, $temp°C';
    } catch (e) {
      debugPrint('openweather fallback: $e');
      return null;
    }
  }

  static Future<String?> _exchangeRate(String base, String quote) async {
    final key = AppConfig.exchangeRateApiKey;
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://v6.exchangerate-api.com/v6/$key/pair/$base/$quote',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body is! Map || body['result'] != 'success') return null;
      return '1 $base = ${body['conversion_rate']} $quote';
    } catch (e) {
      debugPrint('exchange fallback: $e');
      return null;
    }
  }

  static Future<String?> _geocode(String query) async {
    final google = await _googleGeocode(query);
    if (google != null) return google;
    return _nominatim(query);
  }

  static Future<String?> _googleGeocode(String query) async {
    final key = AppConfig.googleMapsApiKey;
    if (key.isEmpty) return null;
    try {
      final response = await http
          .get(
            Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
              'address': query,
              'key': key,
              'language': 'ko',
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body is! Map || body['status'] != 'OK') {
        debugPrint('maps google: ${body is Map ? body['status'] : 'invalid'}');
        return null;
      }
      final results = body['results'];
      if (results is! List || results.isEmpty || results.first is! Map) {
        return null;
      }
      final first = results.first as Map;
      final address = first['formatted_address'] as String? ?? query;
      final location = first['geometry']?['location'];
      final lat = location is Map ? location['lat'] : null;
      final lng = location is Map ? location['lng'] : null;
      return _formatPlace(address, lat, lng);
    } catch (e) {
      debugPrint('maps google fallback: $e');
      return null;
    }
  }

  static Future<String?> _nominatim(String query) async {
    try {
      final response = await http
          .get(
            Uri.https('nominatim.openstreetmap.org', '/search', {
              'q': query,
              'format': 'jsonv2',
              'limit': '1',
              'accept-language': 'ko',
            }),
            headers: const {
              'User-Agent': 'MYBVoiceSecretary/1.0 (https://mybvoice-secretary.vercel.app)',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body is! List || body.isEmpty || body.first is! Map) return null;
      final first = body.first as Map;
      return _formatPlace(
        first['display_name'] as String? ?? query,
        first['lat'],
        first['lon'],
      );
    } catch (e) {
      debugPrint('maps nominatim fallback: $e');
      return null;
    }
  }

  static String _formatPlace(String name, Object? lat, Object? lng) {
    final mapUrl = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$lat,$lng',
    });
    return '$name\n$lat, $lng\n$mapUrl';
  }
}
