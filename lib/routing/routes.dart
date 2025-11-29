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
  static const history = "/history";
  static const bookingDetail ="/history/detail";
  static const editProfile = "/profile/edit";
  static const changePassword = "/profile/change-password";
  static const changeEmail = "/profile/change-email";
  // Cart + Booking
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const bookingResult = '/booking-result';

   static const addressList = '/address';
  static const addAddress = '/address/add';
  static const editAddress = '/address/edit';
  static const locationPicker = '/address/location-picker';

}
  // Add other routes here

