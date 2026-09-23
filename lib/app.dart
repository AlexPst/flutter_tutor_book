import 'package:flutter/material.dart';
import 'package:flutter_tutor_book/core/constants.dart';
import 'package:flutter_tutor_book/core/theme/app_theme.dart';
import 'package:flutter_tutor_book/features/finance/finance_screen.dart';
import 'package:flutter_tutor_book/features/settings/settings_screen.dart';
import 'package:flutter_tutor_book/features/students/students_screen.dart';
import 'package:flutter_tutor_book/features/today/today_screen.dart';
import 'package:flutter_tutor_book/features/week/week_screen.dart';
import 'package:flutter_tutor_book/shared/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/today",
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: "/today", builder: (_, _) => const TodayScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: "/week", builder: (_, _) => const WeekScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/students",
              builder: (_, _) => const StudentsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: "/finance", builder: (_, _) => const FinanceScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: "/settings",
      builder: (_, _) => const SettingsScreen(),
    ),
  ],
);

class TutorBookApp extends StatelessWidget {
  const TutorBookApp({super.key});

  @override
  Widget build(BuildContext contex) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
