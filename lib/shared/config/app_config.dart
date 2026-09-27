import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-wide config from `.env` / Vercel environment variables.
class AppConfig {
  static const String defaultTitle = 'MYB Voice Secretary';
  static const String defaultDescription =
      '음성 대화, PDF 요약, 대화 요약, RAG 검색을 담은 밝고 즐거운 파스텔 톤 음성 비서. 웹과 모바일을 함께 씁니다.';
  static const String defaultAuthor = 'MyBranch Team';
  static const String defaultIconUrl = '/icons/Icon-512.png';
  static const String defaultGithubUrl =
      'https://github.com/nfriend02/mybvoice_secretary/tree/feature/hswarehouse-upload';
  static const String defaultVercelUrl =
      'https://mybvoice-secretary.vercel.app';

  static String get apiPrefix => '/api';

  static String get title => _env('APP_TITLE', defaultTitle);

  static String get description {
    final value = _env('APP_DESCRIPTION', defaultDescription);
    if (value.length <= 200) return value;
    return '${value.substring(0, 197)}...';
  }

  static String get author => _env('APP_AUTHOR', defaultAuthor);

  static String get iconUrl => _env('APP_ICON_URL', defaultIconUrl);

  static String get githubBranchUrl =>
      _env('GITHUB_BRANCH_URL', defaultGithubUrl);

  static String get vercelSiteUrl => _env('VERCEL_SITE_URL', defaultVercelUrl);

  static String get openWeatherApiKey => _env('OPENWEATHER_API_KEY', '');

  static String get exchangeRateApiKey => _env('EXCHANGE_RATE_API_KEY', '');

  static String get geminiApiKey => _env('GEMINI_API_KEY', '');

  static String get googleMapsApiKey => _env('YOUR_GOOGLE_MAPS_API_KEY', '');

  static bool get hasLiveKeys =>
      openWeatherApiKey.isNotEmpty &&
      exchangeRateApiKey.isNotEmpty &&
      geminiApiKey.isNotEmpty &&
      googleMapsApiKey.isNotEmpty;

  static Map<String, String> uploadChecklistMeta() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'iconUrl': iconUrl,
      'githubBranchUrl': githubBranchUrl,
      'vercelSiteUrl': vercelSiteUrl,
    };
  }

  static String _env(String key, String fallback) {
    if (!dotenv.isInitialized) return fallback;
    final value = dotenv.env[key]?.trim().replaceAll(
      RegExp(r'''^['"]|['"]$'''),
      '',
    );
    if (value == null || value.isEmpty) return fallback;
    return value;
  }
}
