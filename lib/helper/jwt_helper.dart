import 'dart:convert';

class JwtHelper {
  /// Decode JWT token and extract claims
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalizedPayload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Get accountId from JWT token
  static String? getAccountIdFromToken(String token) {
    final claims = decodeToken(token);
    if (claims == null) return null;

    // Try different possible claim names
    return claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] as String? ??
        claims['nameidentifier'] as String? ??
        claims['sub'] as String? ??
        claims['accountId'] as String? ??
        claims['AccountID'] as String?;
  }
}


