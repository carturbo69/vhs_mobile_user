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
}
  // Add other routes here

