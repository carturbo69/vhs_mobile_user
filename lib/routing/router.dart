import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/forgot_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/login_screen.dart';
import 'package:vhs_mobile_user/ui/auth/register_screen.dart';
import 'package:vhs_mobile_user/ui/auth/reset_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/verify_otp_screen.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_page.dart';
import 'package:vhs_mobile_user/ui/service_list/service_list_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.login,
  routes: [
    GoRoute(
      path: Routes.listService,
      builder: (context, state) => const ServiceListScreen(),
    ),
    GoRoute(
      path: Routes.detailService,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ServiceDetailPage(serviceId: id);
      },
    ),
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: Routes.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),

    GoRoute(
      path: Routes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    GoRoute(
      path: Routes.verifyOtp,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return VerifyOtpPage(email: data["email"], mode: data["mode"]);
      },
    ),

    GoRoute(
      path: Routes.resetPassword,
      name: 'resetPassword',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ResetPasswordPage(email: data['email'], token: data['token']);
      },
    ),
  ],
);
