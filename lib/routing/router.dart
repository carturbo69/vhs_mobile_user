import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';
import 'package:vhs_mobile_user/ui/auth/forgot_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/login_screen.dart';
import 'package:vhs_mobile_user/ui/auth/register_screen.dart';
import 'package:vhs_mobile_user/ui/auth/reset_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/verify_otp_screen.dart';
import 'package:vhs_mobile_user/ui/booking/booking_result_screen.dart';
import 'package:vhs_mobile_user/ui/cart/cart_screen.dart';
import 'package:vhs_mobile_user/ui/checkout/checkout_screen.dart';
import 'package:vhs_mobile_user/ui/core/bottom_navbar_widget.dart';
import 'package:vhs_mobile_user/ui/history/history_screen.dart';
import 'package:vhs_mobile_user/ui/profile/profile_screen.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';
import 'package:vhs_mobile_user/ui/profile/edit_profile_screen.dart';
import 'package:vhs_mobile_user/ui/profile/change_password_screen.dart';
import 'package:vhs_mobile_user/ui/profile/change_email_screen.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_page.dart';
import 'package:vhs_mobile_user/ui/service_list/service_list_screen.dart';
import 'package:vhs_mobile_user/ui/user_address/address_add_screen.dart';
import 'package:vhs_mobile_user/ui/user_address/address_list_screen.dart';
import 'package:vhs_mobile_user/ui/user_address/location_picker_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.login,
  routes: [
    // -------------------------
    // AUTH ROUTES (ngoài shell)
    // -------------------------
    GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),

      GoRoute(path: Routes.register, builder: (_, __) => const RegisterPage()),

      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: Routes.verifyOtp,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return VerifyOtpPage(email: data['email'], mode: data['mode']);
        },
      ),

      GoRoute(
        path: Routes.resetPassword,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ResetPasswordPage(email: data['email'], token: data['token']);
        },
      ),

    GoRoute(
      path: Routes.serviceDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ServiceDetailPage(serviceId: id);
      },
    ),

    GoRoute(path: Routes.addressList, builder: (_, __) => const AddressListPage()),
    GoRoute(path: Routes.addAddress, builder: (_, __) => const AddAddressPage()),
    
    GoRoute(
      path: Routes.mapPicker,
      builder: (_, __) => const LocationPickerScreen(),
    ),

     GoRoute(path: Routes.cart, builder: (_, __) => const CartScreen()),
    GoRoute(path: Routes.checkout, builder: (_, __) => const CheckoutScreen()),
    GoRoute(
      path: Routes.bookingResult,
      builder: (context, state) {
        final res = state.extra as BookingResultModel;
        return BookingResultScreen(result: res);
      },
    ),
     // -------------------------
      // PROFILE ROUTES (ngoài shell)
      // -------------------------
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) {
          // Lấy profile từ extra (được truyền từ profile screen)
          final profile = state.extra as ProfileModel;
          return EditProfileScreen(profile: profile);
        },
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: Routes.changeEmail,
        builder: (context, state) {
          // Lấy profile từ extra (được truyền từ profile screen)
          final profile = state.extra as ProfileModel;
          return ChangeEmailScreen(profile: profile);
        },
      ),

      //  Why flutter of all thing does not have offical nested navigation support yet?
      // ===========================================================
      // MAIN APP SHELL (BOTTOM NAVIGATION)
      // ===========================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavbarWidget(navigationShell: navigationShell);
        },
        branches: [
          // ---------- TAB 1: SERVICE LIST ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.listService,
                builder: (_, __) => const ServiceListScreen(),
              ),
            ],
          ),

          // ---------- TAB 2: HISTORY ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (_, __) => const HistoryScreen(),
              ),
            ],
          ),

          // ---------- TAB 3: PROFILE ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
