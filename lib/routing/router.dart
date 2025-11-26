import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/forgot_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/login_screen.dart';
import 'package:vhs_mobile_user/ui/auth/register_screen.dart';
import 'package:vhs_mobile_user/ui/auth/reset_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/verify_otp_screen.dart';
import 'package:vhs_mobile_user/ui/core/bottom_navbar_widget.dart';
import 'package:vhs_mobile_user/ui/chat/chat_detail_screen.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_screen.dart';
import 'package:vhs_mobile_user/ui/profile/change_email_screen.dart';
import 'package:vhs_mobile_user/ui/profile/change_password_screen.dart';
import 'package:vhs_mobile_user/ui/profile/edit_profile_screen.dart';
import 'package:vhs_mobile_user/ui/profile/profile_screen.dart';
import 'package:vhs_mobile_user/ui/profile/profile_viewmodel.dart';
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

    // Profile routes (outside shell for full-screen experience)
    GoRoute(
      path: Routes.editProfile,
      builder: (context, state) => const _EditProfileRoute(),
    ),
    GoRoute(
      path: Routes.changePassword,
      builder: (_, __) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: Routes.changeEmail,
      builder: (context, state) => const _ChangeEmailRoute(),
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

        // ---------- TAB 2: CHAT ----------
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.chatList,
              builder: (_, __) => const ChatListScreen(),
            ),
            GoRoute(
              path: Routes.chatDetail,
              builder: (context, state) {
                final conversationId = state.pathParameters['conversationId']!;
                return ChatDetailScreen(conversationId: conversationId);
              },
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

// Helper widgets to handle async profile loading in routes
class _EditProfileRoute extends ConsumerWidget {
  const _EditProfileRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return profileAsync.when(
      data: (profile) => EditProfileScreen(profile: profile),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Lỗi tải hồ sơ')),
      ),
    );
  }
}

class _ChangeEmailRoute extends ConsumerWidget {
  const _ChangeEmailRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return profileAsync.when(
      data: (profile) => ChangeEmailScreen(profile: profile),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Lỗi tải hồ sơ')),
      ),
    );
  }
}
