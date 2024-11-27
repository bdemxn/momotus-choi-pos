import 'package:choi_pos/screens/admin/overview_screen.dart';
import 'package:choi_pos/screens/admin/reports_screen.dart';
import 'package:choi_pos/screens/app_screen.dart';
import 'package:choi_pos/screens/forgot_screen.dart';
import 'package:choi_pos/screens/login_screen.dart';
import 'package:go_router/go_router.dart';

// Router setup
final GoRouter appRouter = GoRouter(routes: [
  //? Main branch
  GoRoute(
    path: '/',
    builder: (context, state) => const LoginScreen(),
    routes: [
      GoRoute(
        path: '/forgotPassword',
        builder: (context, state) => const ForgotScreen()
      ),
      GoRoute(
        path: '/app',
        builder: (context, state) => const AppScreen()
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const OverviewScreen(),
        routes: [
          GoRoute(
            path: '/admin/reports',
            builder: (context, state) => const ReportsScreen()
          )
        ]
      ),
  ]),
]);
