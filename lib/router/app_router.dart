import 'package:choi_pos/screens/admin/customer_registration_screen.dart';
import 'package:choi_pos/screens/admin/customers_screen.dart';
import 'package:choi_pos/screens/admin/inventory_screen.dart';
import 'package:choi_pos/screens/admin/modifiers/inventory_form.dart';
import 'package:choi_pos/screens/admin/modifiers/user_form.dart';
import 'package:choi_pos/screens/admin/overview_screen.dart';
import 'package:choi_pos/screens/admin/reports_screen.dart';
import 'package:choi_pos/screens/admin/users_screen.dart';
import 'package:choi_pos/screens/app_screen.dart';
import 'package:choi_pos/screens/forgot_screen.dart';
import 'package:choi_pos/screens/login_screen.dart';
import 'package:go_router/go_router.dart';

// Router setup
final GoRouter appRouter = GoRouter(

  //? Main branch
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgotPassword',
      builder: (context, state) => const ForgotScreen(),
    ),
    GoRoute(
      path: '/app',
      builder: (context, state) => const AppScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const OverviewScreen(),
      routes: [
        GoRoute(
          path: 'customers',
          builder: (context, state) => const CustomersScreen(),
          routes: [
            GoRoute(
              path: 'create-customer',
              builder: (context, state) => const CustomerRegistrationScreen(),
            )
          ]
        ),
        GoRoute(
          path: 'reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: 'users',
          builder: (context, state) => const UsersScreen(),
          routes: [
            GoRoute(
              path: 'create-user',
              builder: (context, state) => const UserFormWidget(),
            )
          ]
        ),
        GoRoute(
          path: 'inventory',
          builder: (context, state) => const InventoryScreen(),
          routes: [
            GoRoute(
              path: 'create-item',
              builder: (context, state) => const InventoryFormWidget()
            )
          ]
        ),
      ],
    ),
  ],
);