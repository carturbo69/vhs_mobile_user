import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_item.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';
import 'package:vhs_mobile_user/data/repositories/auth_repository.dart';
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
import 'package:vhs_mobile_user/ui/profile/change_email_screen.dart';
import 'package:vhs_mobile_user/ui/profile/change_password_screen.dart';
import 'package:vhs_mobile_user/ui/profile/edit_profile_screen.dart';
import 'package:vhs_mobile_user/ui/history/history_detail_screen.dart';
import 'package:vhs_mobile_user/ui/history/history_screen.dart';
import 'package:vhs_mobile_user/ui/profile/profile_screen.dart';
import 'package:vhs_mobile_user/ui/profile/profile_summary_screen.dart';
import 'package:vhs_mobile_user/ui/profile/provider_registration_guide_screen.dart';
import 'package:vhs_mobile_user/data/models/user/profile_model.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_page.dart';
import 'package:vhs_mobile_user/ui/service_list/service_list_screen.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_screen.dart';
import 'package:vhs_mobile_user/ui/chat/chat_detail_screen.dart';
import 'package:vhs_mobile_user/ui/user_address/address_add_screen.dart';
import 'package:vhs_mobile_user/ui/user_address/address_list_screen.dart';
import 'package:vhs_mobile_user/ui/user_address/location_picker_screen.dart';
import 'package:vhs_mobile_user/ui/payment/payment_success_screen.dart';
import 'package:vhs_mobile_user/ui/payment/payment_webview_screen.dart';
import 'package:vhs_mobile_user/ui/review/review_screen.dart';
import 'package:vhs_mobile_user/ui/review/review_list_screen.dart';
import 'package:vhs_mobile_user/ui/report/report_screen.dart';
import 'package:vhs_mobile_user/ui/report/report_detail_screen.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_detail_model.dart';
import 'package:vhs_mobile_user/data/models/review/review_list_item.dart';
import 'package:vhs_mobile_user/ui/service_shop/service_shop_screen.dart';
import 'package:vhs_mobile_user/ui/notification/notification_screen.dart';

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
    redirect: (context, state) async {
      late AuthRepository authRepo = ref.read(authRepositoryProvider);
      final isLoggedIn = await authRepo.isLoggedIn();

      final isLoginPage = state.matchedLocation == Routes.login;
      final isRegisterPage = state.matchedLocation == Routes.register;
      final isForgotPasswordPage =
          state.matchedLocation == Routes.forgotPassword;
      final isVerifyOtpPage = state.matchedLocation == Routes.verifyOtp;
      final isResetPasswordPage = state.matchedLocation == Routes.resetPassword;
      final isAuthPage =
          isLoginPage ||
          isRegisterPage ||
          isForgotPasswordPage ||
          isVerifyOtpPage ||
          isResetPasswordPage;

      print(
        "🔍 Router redirect check: isLoggedIn=$isLoggedIn, location=${state.matchedLocation}",
      );

      // Nếu đã đăng nhập và đang ở trang auth, redirect về home (service list)
      if (isLoggedIn && isAuthPage) {
        return Routes.listService;
      }

      // Nếu chưa đăng nhập và không phải trang auth, redirect về login
      if (!isLoggedIn && !isAuthPage) {
        return Routes.login;
      }

      // Không redirect
      return null;
    },
    routes: [
      // -------------------------
      // AUTH ROUTES (ngoài shell)
      // -------------------------
      GoRoute(
        path: Routes.login,
        name: 'login',
        pageBuilder: (_, __) => MaterialPage(
          key: const ValueKey('login'),
          child: const LoginPage(),
        ),
      ),

      GoRoute(
        path: Routes.register,
        name: 'register',
        pageBuilder: (_, __) => MaterialPage(
          key: const ValueKey('register'),
          child: const RegisterPage(),
        ),
      ),

      GoRoute(
        path: Routes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (_, __) => MaterialPage(
          key: const ValueKey('forgotPassword'),
          child: const ForgotPasswordPage(),
        ),
      ),

      GoRoute(
        path: Routes.verifyOtp,
        name: 'verifyOtp',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final email = data['email'] ?? '';
          final mode = data['mode'] ?? '';
          return MaterialPage(
            key: ValueKey('verifyOtp_${email}_$mode'),
            child: VerifyOtpPage(email: email, mode: mode),
          );
        },
      ),

      GoRoute(
        path: Routes.resetPassword,
        name: 'resetPassword',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final email = data['email'] ?? '';
          final token = data['token'] ?? '';
          return MaterialPage(
            key: ValueKey('resetPassword_${email}_$token'),
            child: ResetPasswordPage(email: email, token: token),
          );
        },
      ),

      GoRoute(
        path: Routes.detailService,
        name: 'detailService',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            key: ValueKey('detailService_$id'),
            child: ServiceDetailPage(serviceId: id),
          );
        },
      ),
      GoRoute(
        path: Routes.serviceShop,
        name: 'serviceShop',
        pageBuilder: (context, state) {
          final providerId = state.pathParameters['providerId']!;
          return MaterialPage(
            key: ValueKey('serviceShop_$providerId'),
            child: ServiceShopScreen(providerId: providerId),
          );
        },
      ),
      GoRoute(
        path: Routes.bookingDetail,
        name: 'bookingDetail',
        pageBuilder: (context, state) {
          final booking = state.extra as BookingHistoryItem;
          return MaterialPage(
            key: ValueKey('bookingDetail_${booking.bookingId}'),
            child: HistoryDetailScreen(bookingId: booking.bookingId),
          );
        },
      ),

      GoRoute(
        path: Routes.chatDetail,
        name: 'chatDetail',
        pageBuilder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return MaterialPage(
            key: ValueKey('chatDetail_$conversationId'),
            child: ChatDetailScreen(conversationId: conversationId),
          );
        },
      ),

      // -------------------------
      // PROFILE ROUTES (ngoài shell)
      // -------------------------
      GoRoute(
        path: Routes.profileDetail,
        name: 'profileDetail',
        pageBuilder: (_, __) => MaterialPage(
          key: const ValueKey('profileDetail'),
          child: const ProfileDetailScreen(),
        ),
      ),
      GoRoute(
        path: Routes.editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) {
          // Lấy profile từ extra (được truyền từ profile screen)
          final profile = state.extra as ProfileModel;
          return MaterialPage(
            key: ValueKey('editProfile_${profile.accountId ?? DateTime.now().millisecondsSinceEpoch}'),
            child: EditProfileScreen(profile: profile),
          );
        },
      ),
      GoRoute(
        path: Routes.changePassword,
        name: 'changePassword',
        pageBuilder: (_, __) => MaterialPage(
          key: const ValueKey('changePassword'),
          child: const ChangePasswordScreen(),
        ),
      ),
      GoRoute(
        path: Routes.changeEmail,
        name: 'changeEmail',
        pageBuilder: (context, state) {
          // Lấy profile từ extra (được truyền từ profile screen)
          final profile = state.extra as ProfileModel;
          return MaterialPage(
            key: ValueKey('changeEmail_${profile.accountId ?? DateTime.now().millisecondsSinceEpoch}'),
            child: ChangeEmailScreen(profile: profile),
          );
        },
      ),
      GoRoute(
        path: Routes.providerRegistrationGuide,
        name: 'providerRegistrationGuide',
        pageBuilder: (context, state) => MaterialPage(
          key: const ValueKey('providerRegistrationGuide'),
          child: const ProviderRegistrationGuideScreen(),
        ),
      ),
      // -------------------------
      // ADDRESS ROUTES
      // -------------------------
      GoRoute(
        path: Routes.addressList,
        name: 'addressList',
        pageBuilder: (context, state) => MaterialPage(
          key: const ValueKey('addressList'),
          child: const AddressListPage(),
        ),
      ),
      GoRoute(
        path: Routes.addAddress,
        name: 'addAddress',
        pageBuilder: (_, __) => MaterialPage(
          key: ValueKey('addAddress_${DateTime.now().millisecondsSinceEpoch}'),
          child: const AddAddressPage(),
        ),
      ),
      GoRoute(
        path: Routes.locationPicker,
        name: 'locationPicker',
        pageBuilder: (_, __) => MaterialPage(
          key: ValueKey('locationPicker_${DateTime.now().millisecondsSinceEpoch}'),
          child: const LocationPickerScreen(),
        ),
      ),

      // Route riêng cho cart khi push từ bên ngoài shell
      GoRoute(
        path: Routes.cartPush,
        name: 'cartPush',
        pageBuilder: (context, state) {
          // Sử dụng fullPath và extra để tạo key unique
          // Nếu có extra, sử dụng hash của nó, nếu không thì dùng fullPath
          final extra = state.extra;
          final keySuffix = extra != null 
              ? '_${extra.hashCode}' 
              : '_${state.uri.toString()}';
          return MaterialPage(
            key: ValueKey('cartPush$keySuffix'),
            child: const CartScreen(),
          );
        },
      ),
      GoRoute(
        path: Routes.checkout,
        name: 'checkout',
        pageBuilder: (context, state) {
          final extra = state.extra;
          final selectedItemIds = extra is List<String> ? extra : null;
          final keyValue = selectedItemIds?.join(',') ?? 'checkout';
          return MaterialPage(
            key: ValueKey('checkout_$keyValue'),
            child: CheckoutScreen(selectedItemIds: selectedItemIds),
          );
        },
      ),
      GoRoute(
        path: Routes.bookingResult,
        name: 'bookingResult',
        pageBuilder: (context, state) {
          final result = state.extra as BookingResultModel;
          final keyValue = result.bookingIds.isNotEmpty 
              ? result.bookingIds.join(',') 
              : DateTime.now().millisecondsSinceEpoch.toString();
          return MaterialPage(
            key: ValueKey('bookingResult_$keyValue'),
            child: BookingResultScreen(result: result),
          );
        },
      ),
      GoRoute(
        path: Routes.paymentWebView,
        name: 'paymentWebView',
        pageBuilder: (context, state) {
          final paymentUrl = state.extra as String? ?? '';
          return MaterialPage(
            key: ValueKey('paymentWebView_${paymentUrl.hashCode}'),
            child: PaymentWebViewScreen(paymentUrl: paymentUrl),
          );
        },
      ),
      GoRoute(
        path: Routes.paymentSuccess,
        name: 'paymentSuccess',
        pageBuilder: (context, state) {
          final data = state.extra as PaymentSuccessData;
          final keyValue = data.transactionId.isNotEmpty 
              ? data.transactionId 
              : DateTime.now().millisecondsSinceEpoch.toString();
          return MaterialPage(
            key: ValueKey('paymentSuccess_$keyValue'),
            child: PaymentSuccessScreen(data: data),
          );
        },
      ),
      // Review routes - reviewList phải đứng trước review để tránh conflict
      GoRoute(
        path: Routes.reviewList,
        name: 'reviewList',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: const ValueKey('reviewList'),
            child: const ReviewListScreen(),
          );
        },
      ),
      GoRoute(
        path: Routes.review,
        name: 'review',
        pageBuilder: (context, state) {
          final extra = state.extra;
          Widget child;
          ValueKey key;
          if (extra is HistoryBookingDetail) {
            key = ValueKey('review_${extra.bookingId}');
            child = ReviewScreen(bookingDetail: extra);
          } else if (extra is ReviewListItem) {
            // Edit mode
            key = ValueKey('review_edit_${extra.reviewId}');
            child = ReviewScreen(reviewItem: extra);
          } else {
            key = const ValueKey('review_invalid');
            child = const Scaffold(
              body: Center(child: Text('Invalid review data')),
            );
          }
          return MaterialPage(key: key, child: child);
        },
      ),
      GoRoute(
        path: Routes.report,
        name: 'report',
        pageBuilder: (context, state) {
          final detail = state.extra as HistoryBookingDetail;
          return MaterialPage(
            key: ValueKey('report_${detail.bookingId}'),
            child: ReportScreen(bookingDetail: detail),
          );
        },
      ),
      GoRoute(
        path: Routes.reportDetail,
        name: 'reportDetail',
        pageBuilder: (context, state) {
          final reportId = state.pathParameters['id']!;
          return MaterialPage(
            key: ValueKey('reportDetail_$reportId'),
            child: ReportDetailScreen(reportId: reportId),
          );
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
                name: 'listService',
                builder: (_, __) => const ServiceListScreen(),
              ),
            ],
          ),

          // ---------- TAB 2: NOTIFICATIONS ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.notifications,
                name: 'notifications',
                builder: (_, __) => const NotificationScreen(),
              ),
            ],
          ),

          // ---------- TAB 3: CHAT LIST ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.chatList,
                name: 'chatList',
                builder: (_, __) => const ChatListScreen(),
              ),
            ],
          ),

          // ---------- TAB 4: HISTORY ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                name: 'history',
                builder: (_, __) => const HistoryScreen(),
              ),
            ],
          ),

          // ---------- TAB 5: PROFILE ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                name: 'profile',
                builder: (_, __) => const ProfileSummaryScreen(),
              ),
            ],
          ),

          // ---------- TAB 6: CART ----------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.cart,
                name: 'cart',
                builder: (_, __) => const CartScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
