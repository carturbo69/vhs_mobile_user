import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInHelperV7 {
  final GoogleSignIn _google = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      await _google.initialize(
        clientId:
            "821141237976-hfpl389iuusi993her38opnba2tagdl5.apps.googleusercontent.com",
        serverClientId:
            "821141237976-87c3p9fuuo5kp523k1avelst4mf4lorm.apps.googleusercontent.com",
      ); // 🔥 BẮT BUỘC VỚI V7
      _initialized = true;
      print("GoogleSignIn initialized successfully");
    } catch (e, stackTrace) {
      print("GoogleSignIn initialize error: $e");
      print("Stack trace: $stackTrace");
      // Re-throw to let caller handle the error
      rethrow;
    }
  }

  /// Sign in with Google using v7 API
  Future<String?> signInAndGetIdToken() async {
    try {
      await _ensureInitialized();
    } catch (e) {
      print("Failed to initialize Google Sign-In: $e");
      rethrow;
    }

    try {
      // Thử sign out trước để đảm bảo không có session cũ gây conflict
      try {
        await _google.disconnect();
        print("Disconnected from previous Google session");
      } catch (e) {
        // Ignore errors when disconnecting (might not be signed in)
        print("No previous session to disconnect: $e");
      }

      print("Attempting lightweight authentication...");
      GoogleSignInAccount? account = await _google
          .attemptLightweightAuthentication();

      if (account == null) {
        print("Lightweight auth failed, trying full authentication...");
        // Use authenticate() for v7 API - this opens the sign-in dialog
        try {
          print("Calling authenticate() to open Google Sign-In dialog...");
          account = await _google.authenticate();
          print("authenticate() returned: ${account != null ? 'account received' : 'null'}");
        } on GoogleSignInException catch (e) {
          print("GoogleSignInException during authenticate(): ${e.code} - $e");
          if (e.code == GoogleSignInExceptionCode.canceled) {
            print("User canceled Google Sign-In dialog");
            return null;
          }
          // Xử lý lỗi unknownError - thường xảy ra trên emulator
          if (e.code == GoogleSignInExceptionCode.unknownError) {
            final errorMessage = e.toString().toLowerCase();
            if (errorMessage.contains('no credential') || 
                errorMessage.contains('no credentials available')) {
              throw Exception(
                "Không thể đăng nhập Google. Vui lòng:\n"
                "1. Đảm bảo emulator có Google Play Services\n"
                "2. Đăng nhập Google account trên emulator\n"
                "3. Hoặc thử trên thiết bị thật"
              );
            }
          }
          // Log other error codes for debugging
          print("Google Sign-In error code: ${e.code}");
          rethrow;
        } catch (e) {
          print("Unexpected error during authenticate(): $e");
          rethrow;
        }

        if (account == null) {
          // user closed dialog → return null
          print("User canceled Google Sign-In dialog (account is null)");
          return null;
        }
      }

      print("Google Sign-In successful, getting authentication...");
      final auth = await account.authentication;
      
      if (auth.idToken == null) {
        print("Warning: idToken is null after authentication");
        throw Exception("Failed to obtain idToken from Google Sign-In. Please ensure the OAuth client is properly configured.");
      }
      
      print("Successfully obtained idToken");
      return auth.idToken;
    } on GoogleSignInException catch (e) {
      print("GoogleSignInException: ${e.code} - $e");
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User dismissed the Google Sign-In dialog
        print("User canceled Google Sign-In dialog");
        return null;
      }
      // Xử lý lỗi unknownError
      if (e.code == GoogleSignInExceptionCode.unknownError) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('no credential') || 
            errorMessage.contains('no credentials available')) {
          throw Exception(
            "Không thể đăng nhập Google. Vui lòng:\n"
            "1. Đảm bảo emulator có Google Play Services\n"
            "2. Đăng nhập Google account trên emulator\n"
            "3. Hoặc thử trên thiết bị thật"
          );
        }
      }
      // Re-throw other GoogleSignInExceptions
      rethrow;
    } catch (e, stackTrace) {
      print("Unexpected error during Google Sign-In: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _google.disconnect();
  }
}
