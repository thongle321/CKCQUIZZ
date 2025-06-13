# Persistent Login Implementation

## Overview
This implementation provides persistent login functionality for the CKC Quiz Flutter mobile app while maintaining security requirements for the web version.

## Features

### ✅ Mobile App Features
- **Auto-login on app restart**: Users remain logged in when reopening the app
- **Token persistence**: JWT tokens stored securely using SharedPreferences
- **Session validation**: Automatic token validation on app startup
- **Token refresh**: Automatic token refresh when expired
- **Seamless UX**: No login screen flash before redirecting to dashboard

### 🔒 Web App Security
- **Always starts at /login**: Web version maintains security requirement
- **No auto-redirect**: Users must explicitly navigate from login screen
- **Explicit authentication**: Web users must always login manually

## Implementation Details

### 1. Token Storage (`http_client_service.dart`)
```dart
// Store authentication tokens
await httpClient.storeAuthTokens(
  accessToken,
  refreshToken,
  expiryTime: DateTime.now().add(Duration(hours: 24)),
);

// Check login status
final isLoggedIn = await httpClient.isLoggedIn();

// Check token expiration
final isExpired = await httpClient.isTokenExpired();
```

### 2. Session Validation (`auth_service.dart`)
```dart
// Validate existing session
final user = await authService.validateSession();
if (user != null) {
  // User has valid session
} else {
  // User needs to login
}
```

### 3. Persistent Login Initialization (`main.dart`)
```dart
// Mobile: Check for persistent login
if (!kIsWeb) {
  final user = await authService.validateSession();
  if (user != null) {
    userNotifier.setUser(user);
  }
}
```

### 4. Platform-Specific Routing
```dart
// Web: Stay on login page for security
if (isWeb && isLoginRoute) {
  return null; // Stay on login page
}

// Mobile: Auto-redirect to dashboard
return _getInitialRoute(currentUser.quyen);
```

## Storage Keys
The following keys are used in SharedPreferences:

- `auth_token`: JWT access token
- `refresh_token`: JWT refresh token
- `user_data`: Serialized user information
- `is_logged_in`: Boolean login status
- `token_expiry`: Token expiration timestamp
- `last_login`: Last login timestamp

## Security Considerations

### ✅ Implemented Security Features
- **Token expiration handling**: Automatic logout when tokens expire
- **Secure token storage**: Tokens stored in SharedPreferences
- **Session validation**: API calls to verify token validity
- **Automatic cleanup**: Clear invalid sessions automatically
- **Platform separation**: Different behavior for web vs mobile

### 🔒 Security Best Practices
- Tokens are cleared on explicit logout
- Invalid sessions are automatically cleaned up
- Web version always requires explicit login
- Theme preferences preserved during logout
- Error handling for network failures

## Usage Examples

### Login Flow
```dart
// User logs in
final user = await authService.login(email, password);
if (user != null) {
  // Tokens automatically stored
  // User redirected to dashboard
}
```

### App Startup (Mobile)
```dart
// App starts
// Automatic session validation
// If valid: redirect to dashboard
// If invalid: show login screen
```

### Logout Flow
```dart
// User logs out
await authService.logout();
// All auth data cleared
// User redirected to login
// Theme preferences preserved
```

## Testing

Run the persistent login tests:
```bash
flutter test test/persistent_login_test.dart
```

Tests cover:
- Token storage and retrieval
- Session validation
- Logout cleanup
- Theme preservation
- Platform-specific behavior

## Configuration

### API Endpoints
- Login: `/api/Auth/signin`
- Logout: `/api/Auth/logout`
- Refresh: `/api/Auth/refresh-token`
- Validate: `/api/Auth/validate-token`

### Token Expiry
- Default: 24 hours
- Configurable in `auth_service.dart`
- Automatic refresh when expired

## Troubleshooting

### Common Issues
1. **Tokens not persisting**: Check SharedPreferences permissions
2. **Auto-login not working**: Verify token expiration settings
3. **Web security issues**: Ensure web always starts at /login
4. **Network errors**: Check API connectivity and endpoints

### Debug Information
Enable debug prints in development:
- Login success/failure messages
- Token storage confirmations
- Session validation results
- Logout completion status

## Future Enhancements
- Biometric authentication
- Secure storage for sensitive data
- Background token refresh
- Multi-device session management
- Enhanced error handling
