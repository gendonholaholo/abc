import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/session_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/dashboard_page.dart';

class HrisAttendanceApp extends ConsumerWidget {
  const HrisAttendanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);

    return MaterialApp(
      title: 'HRIS Attendance',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: sessionState.maybeWhen(
        authenticated: (_) => const DashboardPage(),
        orElse: () => const LoginPage(),
      ),
    );
  }
}
