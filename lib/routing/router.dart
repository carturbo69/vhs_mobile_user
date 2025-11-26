import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/auth/auth_viewmodel.dart';
import 'package:vhs_mobile_user/ui/auth/forgot_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/login_screen.dart';
import 'package:vhs_mobile_user/ui/auth/register_screen.dart';
import 'package:vhs_mobile_user/ui/auth/reset_password_screen.dart';
import 'package:vhs_mobile_user/ui/auth/verify_otp_screen.dart';
import 'package:vhs_mobile_user/ui/core/bottom_navbar_widget.dart';
import 'package:vhs_mobile_user/ui/profile/change_email_screen.dart';
import 'package:vhs_mobile_user/ui/profile/change_password_screen.dart';
import 'package:vhs_mobile_user/ui/profile/edit_profile_screen.dart';
import 'package:vhs_mobile_user/ui/history/history_screen.dart';
import 'package:vhs_mobile_user/ui/profile/profile_screen.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_page.dart';
import 'package:vhs_mobile_user/ui/service_list/service_list_screen.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_screen.dart';
import 'package:vhs_mobile_user/ui/chat/chat_detail_screen.dart';

/// Helper class để refresh router khi auth state thay đổi
class AuthStateNotifier extends ChangeNotifier {
  final Ref ref;
  ProviderSubscription? _subscription;

  AuthStateNotifier(this.ref) {
    // Listen auth state changes
    _subscription = ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthStateNotifier(ref);
  
  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // Read auth state (refreshListenable sẽ trigger khi auth thay đổi)
      final authState = ref.read(authStateProvider);
      
      // Nếu đang loading, không redirect (đợi load xong)
      // Điều này đảm bảo router đợi auth load xong trước khi quyết định
      if (authState.isLoading) {
        return null;
      }
      
      final isLoggedIn = authState.hasValue && authState.value != null;
      final isLoginPage = state.matchedLocation == Routes.login;
      final isRegisterPage = state.matchedLocation == Routes.register;
      final isForgotPasswordPage = state.matchedLocation == Routes.forgotPassword;
      final isVerifyOtpPage = state.matchedLocation == Routes.verifyOtp;
      final isResetPasswordPage = state.matchedLocation == Routes.resetPassword;
      final isAuthPage = isLoginPage || isRegisterPage || isForgotPasswordPage || isVerifyOtpPage || isResetPasswordPage;
      
      print("🔍 Router redirect check: isLoggedIn=$isLoggedIn, location=${state.matchedLocation}");
      
      // Nếu đã đăng nhập và đang ở trang auth, redirect về home (service list)
      if (isLoggedIn && isAuthPage) {
        print("✅ Redirect về home (đã đăng nhập)");
        return Routes.listService;
      }
      
      // Nếu chưa đăng nhập và không phải trang auth, redirect về login
      if (!isLoggedIn && !isAuthPage) {
        print("✅ Redirect về login (chưa đăng nhập)");
        return Routes.login;
      }
      
      // Không redirect
      return null;
    },
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

      GoRoute(
        path: Routes.chatDetail,
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatDetailScreen(conversationId: conversationId);
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

          // ---------- TAB 2: CHAT LIST ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.chatList,
                builder: (_, __) => const ChatListScreen(),
              ),
            ],
          ),

          // ---------- TAB 3: HISTORY ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (_, __) => const HistoryScreen(),
              ),
            ],
          ),

          // ---------- TAB 4: PROFILE ----------
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
