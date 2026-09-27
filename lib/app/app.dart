import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../pages/conversation/conversation_page.dart';
import '../pages/home/home_page.dart';
import '../pages/learn/learn_page.dart';
import '../pages/live/live_page.dart';
import '../pages/mail/mail_page.dart';
import '../pages/pdf_summary/pdf_summary_page.dart';
import '../pages/rag_search/rag_search_page.dart';
import '../pages/schedule/schedule_page.dart';
import '../pages/translate/translate_page.dart';
import '../pages/upload/upload_page.dart';
import '../pages/voice_chat/voice_chat_page.dart';
import '../pages/workflow/workflow_page.dart';
import '../services/firestore_service.dart';
import '../services/secretary_session.dart';
import '../shared/layouts/app_shell.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class MyBVoiceSecretaryApp extends StatefulWidget {
  const MyBVoiceSecretaryApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<MyBVoiceSecretaryApp> createState() => _MyBVoiceSecretaryAppState();
}

class _MyBVoiceSecretaryAppState extends State<MyBVoiceSecretaryApp> {
  late final FirestoreService? _firestore;
  late final SecretarySession _session;
  late final ThemeController _theme;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _firestore = widget.firebaseReady ? FirestoreService() : null;
    _session = SecretarySession(_firestore);
    _theme = ThemeController();
    _session.hydrate();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              AppShell(location: state.uri.path, child: child),
          routes: [
            GoRoute(path: '/', builder: (_, _) => const HomePage()),
            GoRoute(path: '/voice', builder: (_, _) => const VoiceChatPage()),
            GoRoute(path: '/pdf', builder: (_, _) => const UploadPage()),
            GoRoute(path: '/talk', builder: (_, _) => const ConversationPage()),
            GoRoute(path: '/rag', builder: (_, _) => const RagSearchPage()),
            GoRoute(path: '/schedule', builder: (_, _) => const SchedulePage()),
            GoRoute(path: '/mail', builder: (_, _) => const MailPage()),
            GoRoute(
              path: '/translate',
              builder: (_, _) => const TranslatePage(),
            ),
            GoRoute(path: '/workflow', builder: (_, _) => const WorkflowPage()),
            GoRoute(path: '/learn', builder: (_, _) => const LearnPage()),
            GoRoute(path: '/live', builder: (_, _) => const LivePage()),
            GoRoute(
              path: '/upload',
              builder: (_, _) => const PortfolioUploadPage(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _session.dispose();
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(value: _theme),
        Provider<bool>.value(value: widget.firebaseReady),
        ChangeNotifierProvider<SecretarySession>.value(value: _session),
      ],
      child: ListenableBuilder(
        listenable: _theme,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'AI 음성 비서',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData(),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
