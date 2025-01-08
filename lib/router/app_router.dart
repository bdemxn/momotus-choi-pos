import 'package:choi_pos/screens/admin/categories_screen.dart';
import 'package:choi_pos/screens/admin/discount_codes_screen.dart';
import 'package:choi_pos/screens/admin/modifiers/customer_registration_screen.dart';
import 'package:choi_pos/screens/admin/customers_screen.dart';
import 'package:choi_pos/screens/admin/inventory_screen.dart';
import 'package:choi_pos/screens/admin/modifiers/category_form.dart';
import 'package:choi_pos/screens/admin/modifiers/inventory_form.dart';
import 'package:choi_pos/screens/admin/modifiers/promo_form.dart';
import 'package:choi_pos/screens/admin/modifiers/tournament_form.dart';
import 'package:choi_pos/screens/admin/modifiers/user_form.dart';
import 'package:choi_pos/screens/admin/overview_screen.dart';
import 'package:choi_pos/screens/admin/payments_screens.dart';
import 'package:choi_pos/screens/admin/reports_screen.dart';
import 'package:choi_pos/screens/admin/support_screen.dart';
import 'package:choi_pos/screens/admin/tournamets_screen.dart';
import 'package:choi_pos/screens/admin/users_screen.dart';
import 'package:choi_pos/screens/app/create_inventory_screen.dart';
import 'package:choi_pos/screens/app/modifiers/cashier_customer_registration.dart';
import 'package:choi_pos/screens/app/checkout_screen.dart';
import 'package:choi_pos/screens/app/modifiers/customers_cashier.dart';
import 'package:choi_pos/screens/app/modifiers/payment_cashier.dart';
import 'package:choi_pos/screens/app/modifiers/receipts_cashier.dart';
import 'package:choi_pos/screens/app_screen.dart';
import 'package:choi_pos/screens/forgot_screen.dart';
import 'package:choi_pos/screens/login_screen.dart';
import 'package:choi_pos/widgets/customers/customer_update_form.dart';
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
            path: 'payments',
            builder: (context, state) => const CashierPaymentsScreen(),
          ),
          GoRoute(
            path: 'checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: 'create-inventory',
            builder: (context, state) => const CreateInventoryCashierScreen(),
          ),
          GoRoute(
            path: 'create-customer',
            builder: (context, state) => const CashierCustomerRegistration(),
          ),
          GoRoute(
            path: 'sales',
            builder: (context, state) => const ReportsScreenCashier(),
          ),
          GoRoute(
            path: 'customers',
            builder: (context, state) => const CustomerScreenCashier(),
          )
        ]),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const OverviewScreen(),
      routes: [
        GoRoute(
          path: 'payments',
          builder: (context, state) => const PaymentsScreen()
        ),
        GoRoute(
          path: 'edit-customer',
          builder: (context, state) {
            final customer = state.extra as Map<String, dynamic>;
            return CustomerUpdateForm(customerData: customer);
          },
        ),
        GoRoute(
          path: 'support',
          builder: (context, state) => const TechnicalSupportForm(),
        ),
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
                  builder: (context, state) => const PromoForm()),
              GoRoute(
                path: 'categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
              GoRoute(
                path: 'discount-codes',
                builder: (context, state) => const DiscountCodesScreen(),
              )
            ]),
        GoRoute(
            path: 'tournaments',
            builder: (context, state) => const TournamentsScreen(),
            routes: [
              GoRoute(
                  path: 'create-tournament',
                  builder: (context, state) => const TournamentForm())
            ])
      ],
    ),
  ],
);
