import 'package:google_sign_in/google_sign_in.dart';

/// Custom exception for emulator-specific Google Sign-In errors
class GoogleSignInEmulatorException implements Exception {
  final String message;
  
  GoogleSignInEmulatorException(this.message);
  
  @override
  String toString() => message;
}

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
      GoogleSignInAccount? account;
      
      try {
        account = await _google.attemptLightweightAuthentication();
      } catch (e) {
        print("Lightweight authentication error (non-fatal): $e");
        // Continue to full authentication
      }

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
            
            // Check for common emulator/credential issues
            if (errorMessage.contains('no credential') || 
                errorMessage.contains('no credentials available')) {
              // Return a more descriptive error that can be handled by the UI
              throw GoogleSignInEmulatorException(
                "Không thể đăng nhập Google trên emulator này.\n\n"
                "Vui lòng:\n"
                "• Sử dụng emulator có Google Play Services\n"
                "• Đăng nhập Google account trên emulator (Settings > Accounts)\n"
                "• Hoặc thử trên thiết bị thật"
              );
            }
            
            // Handle other unknown errors
            print("Google Sign-In unknown error: $e");
            throw Exception(
              "Lỗi đăng nhập Google: Không xác định được lỗi\n\n"
              "Vui lòng thử lại hoặc sử dụng đăng nhập bằng username/password."
            );
          }
          
          // Log other error codes for debugging
          print("Google Sign-In error code: ${e.code}, error: $e");
          throw Exception(
            "Lỗi đăng nhập Google: Mã lỗi ${e.code}"
          );
        } catch (e) {
          // Re-throw if it's already a custom exception
          if (e is GoogleSignInEmulatorException || e is Exception) {
            rethrow;
          }
          print("Unexpected error during authenticate(): $e");
          throw Exception("Lỗi không xác định khi đăng nhập Google: $e");
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
        throw Exception(
          "Không thể lấy idToken từ Google Sign-In.\n"
          "Vui lòng kiểm tra cấu hình OAuth client."
        );
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
          throw GoogleSignInEmulatorException(
            "Không thể đăng nhập Google trên emulator này.\n\n"
            "Vui lòng:\n"
            "• Sử dụng emulator có Google Play Services\n"
            "• Đăng nhập Google account trên emulator (Settings > Accounts)\n"
            "• Hoặc thử trên thiết bị thật"
          );
        }
        
        throw Exception(
          "Lỗi đăng nhập Google: Không xác định được lỗi"
        );
      }
      
      // Re-throw other GoogleSignInExceptions as generic exceptions
      throw Exception("Lỗi đăng nhập Google: Mã lỗi ${e.code}");
    } on GoogleSignInEmulatorException {
      // Re-throw emulator-specific exceptions
      rethrow;
    } catch (e, stackTrace) {
      print("Unexpected error during Google Sign-In: $e");
      print("Stack trace: $stackTrace");
      // If it's already an Exception, rethrow it
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Lỗi không xác định khi đăng nhập Google: $e");
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _google.disconnect();
  }
}
