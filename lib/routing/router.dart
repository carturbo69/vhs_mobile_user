import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/forgot_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/login_screen.dart';
import 'package:vhs_mobile_user/ui/auth/register_screen.dart';
import 'package:vhs_mobile_user/ui/auth/reset_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/verify_otp_screen.dart';
import 'package:vhs_mobile_user/ui/core/bottom_navbar_widget.dart';
import 'package:vhs_mobile_user/ui/profile/profile_screen.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_page.dart';
import 'package:vhs_mobile_user/ui/service_list/service_list_screen.dart';

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
      path: Routes.detailService,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ServiceDetailPage(serviceId: id);
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

        // ---------- TAB 2: PROFILE ----------
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
