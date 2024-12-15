import 'package:choi_pos/screens/admin/modifiers/customer_registration_screen.dart';
import 'package:choi_pos/screens/admin/customers_screen.dart';
import 'package:choi_pos/screens/admin/inventory_screen.dart';
import 'package:choi_pos/screens/admin/modifiers/category_form.dart';
import 'package:choi_pos/screens/admin/modifiers/inventory_form.dart';
import 'package:choi_pos/screens/admin/modifiers/promo_form.dart';
import 'package:choi_pos/screens/admin/modifiers/tournament_form.dart';
import 'package:choi_pos/screens/admin/modifiers/user_form.dart';
import 'package:choi_pos/screens/admin/overview_screen.dart';
import 'package:choi_pos/screens/admin/reports_screen.dart';
import 'package:choi_pos/screens/admin/tournamets_screen.dart';
import 'package:choi_pos/screens/admin/users_screen.dart';
import 'package:choi_pos/screens/app/cashier_customer_registration.dart';
import 'package:choi_pos/screens/app/checkout_screen.dart';
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
        routes: [
          GoRoute(
            path: 'checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: 'create-customer',
            builder: (context, state) => const CashierCustomerRegistration(),
          ),
        ]),
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
            ]),
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
            ]),
        GoRoute(
            path: 'inventory',
            builder: (context, state) => const InventoryScreen(),
            routes: [
              GoRoute(
                  path: 'create-item',
                  builder: (context, state) => const InventoryFormWidget()),
              GoRoute(
                path: 'create-category',
                builder: (context, state) => const CategoryFormWidget(),
              ),
              GoRoute(
                  path: 'create-promo',
                  builder: (context, state) => const PromoForm())
            ]),
        GoRoute(
          path: 'tournaments',
          builder: (context, state) => const TournamentsScreen(),
          routes: [
            GoRoute(
              path: 'create-tournament',
              builder: (context, state) => const TournamentForm()
            )
          ]
        )
      ],
    ),
  ],
);
