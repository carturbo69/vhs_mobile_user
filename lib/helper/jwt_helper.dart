// jwt_helper.dart
import 'dart:convert';

class JwtHelper {
  /// Decode JWT token và lấy accountId từ claims
  static String? getAccountIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;
    
    try {
      // JWT có format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      // Decode payload (phần thứ 2)
      final payload = parts[1];
      
      // Thêm padding nếu cần (base64url có thể thiếu padding)
      final normalizedPayload = _normalizeBase64(payload);
      
      // Decode base64
      final decodedBytes = base64Decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final payloadMap = jsonDecode(decodedString) as Map<String, dynamic>;
      
      // Lấy accountId từ claims (có thể là nameidentifier hoặc accountId)
      final accountId = payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] as String?;
      if (accountId != null && accountId.isNotEmpty) {
        return accountId;
      }
      
      // Fallback: thử các key khác
      return payloadMap['accountId'] as String? ?? 
             payloadMap['AccountID'] as String? ?? 
             payloadMap['accountID'] as String?;
    } catch (e) {
      print('[JwtHelper] Error decoding token: $e');
      return null;
    }
  }
  
  /// Normalize base64 string (thêm padding nếu cần)
  static String _normalizeBase64(String base64) {
    var normalized = base64.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 1:
        normalized += '===';
        break;
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }
    return normalized;
  }
}

