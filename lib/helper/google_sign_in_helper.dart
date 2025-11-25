import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInHelperV7 {
  final GoogleSignIn _google = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      await _google.initialize(
        clientId:
            "1011562344003-3he6c2c1l47o9i55m68b4ltah3skbpmr.apps.googleusercontent.com",
        serverClientId:
            "1011562344003-vjmoi74tpfbsetd8vo68202vm9l8rkrd.apps.googleusercontent.com",
      ); // 🔥 BẮT BUỘC VỚI V7
      _initialized = true;
    } catch (e) {
      print("GoogleSignIn initialize error: $e");
    }
  }

  /// Sign in with Google using v7 API
  Future<String?> signInAndGetIdToken() async {
    await _ensureInitialized();

    try {
      GoogleSignInAccount? account = await _google
          .attemptLightweightAuthentication();

      if (account == null) {
        account = await _google.authenticate();

        if (account == null) {
          // user closed dialog → return null
          return null;
        }
      }

      final auth = await account.authentication;
      return auth.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User dismissed the Google Sign-In dialog
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _google.disconnect();
  }
}
