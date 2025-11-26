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
  static const editProfile = "/profile/edit";
  static const changePassword = "/profile/change-password";
  static const changeEmail = "/profile/change-email";
}
  // Add other routes here

