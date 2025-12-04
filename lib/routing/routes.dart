abstract final class Routes {
  static const home = '/';
  static const listService = '/list-service';
  static const detailService = '/services/:id';
  static String detailServicePath(String id) => '/services/$id';
  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot";
  static const verifyOtp = "/verify-otp";
  static const resetPassword = "/reset-password";
  static const profile = "/profile";
  static const profileDetail = "/profile/detail";
  static const providerRegistrationGuide = "/profile/provider-registration-guide";
  static const history = "/history";
  static const bookingDetail ="/history/detail";
  static const editProfile = "/profile/edit";
  static const changePassword = "/profile/change-password";
  static const changeEmail = "/profile/change-email";
  static const chatList = "/chat";
  static const chatDetail = "/chat/:conversationId";
  static String chatDetailPath(String conversationId) => '/chat/$conversationId';
  static const notifications = "/notifications";
  // Cart + Booking
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const bookingResult = '/booking-result';

   static const addressList = '/address';
  static const addAddress = '/address/add';
  static const editAddress = '/address/edit';
  static const locationPicker = '/address/location-picker';
  
  // Payment
  static const paymentWebView = '/payment/webview';
  static const paymentSuccess = '/payment/success';

  // Review
  static const review = '/review';
  static const reviewList = '/my-reviews';

  // Report
  static const report = '/report';
  static const reportDetail = '/report/:id';
  static String reportDetailPath(String id) => '/report/$id';

  // Service Shop
  static const serviceShop = '/service-shop/:providerId';
  static String serviceShopPath(String providerId) => '/service-shop/$providerId';

}
  // Add other routes here

