import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const REFRESH_TOKEN_KEY = 'refresh_token';
const BACKEND_TOKEN_KEY = 'backend_token';
const GOOGLE_ISSUER = 'https://accounts.google.com';
const GOOGLE_CLIENT_ID_IOS = '';
const GOOGLE_REDIRECT_URI_IOS = '';
const GOOGLE_CLIENT_ID_ANDROID = '<ANDROID-CLIENT-ID>';
const GOOGLE_REDIRECT_URI_ANDROID = 'com.googleusercontent.apps.<ANDROID-CLIENT-ID>:/oauthredirect';

String clientID() {
  if (Platform.isAndroid) {
    return GOOGLE_CLIENT_ID_ANDROID;
  } else if (Platform.isIOS) {
    return GOOGLE_CLIENT_ID_IOS;
  }
  return '';
}

String redirectUrl() {
  if (Platform.isAndroid) {
    return GOOGLE_REDIRECT_URI_ANDROID;
  } else if (Platform.isIOS) {
    return GOOGLE_REDIRECT_URI_IOS;
  }
  return '';
}

class AuthService {
  static final AuthService instance = AuthService._();
  factory AuthService() => instance;
  AuthService._();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> initAuth() async {
    final storedRefreshToken = await _secureStorage.read(key: REFRESH_TOKEN_KEY);
    final TokenResponse? result;

    if (storedRefreshToken == null) {
      return false;
    }

    try {
      // Obtaining token response from refresh token
      result = await _appAuth.token(
        TokenRequest(
          clientID(),
          redirectUrl(),
          issuer: GOOGLE_ISSUER,
          refreshToken: storedRefreshToken,
        ),
      );

      final bool setResult = await _handleAuthResult(result);
      return setResult;
    } catch (e, s) {
      print('error on Refresh Token: $e - stack: $s');
      // logOut() possibly
      return false;
    }
  }

  Future<bool> login() async {
    final AuthorizationTokenRequest authorizationTokenRequest;

    try {
      authorizationTokenRequest = AuthorizationTokenRequest(
        clientID(),
        redirectUrl(),
        issuer: GOOGLE_ISSUER,
        scopes: ['email', 'profile'],
      );

      // Requesting the auth token and waiting for the response
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        authorizationTokenRequest,
      );

      // Taking the obtained result and processing it
      return await _handleAuthResult(result);
    } on PlatformException {
      print("User has cancelled or no internet!");
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> logout() async {
    await _secureStorage.delete(key: REFRESH_TOKEN_KEY);
    return true;
  }

  Future<bool> _handleAuthResult(result) async {
    final bool isValidResult = result != null && result.accessToken != null && result.idToken != null;
    if (isValidResult) {
      // Storing refresh token to renew login on app restart
      if (result.refreshToken != null) {
        await _secureStorage.write(
          key: REFRESH_TOKEN_KEY,
          value: result.refreshToken,
        );
      }

      final String googleAccessToken = result.accessToken;

      // Send request to backend with access token
      // final url = Uri.https(
      //   'api.your-server.com',
      //   '/v1/social-authentication',
      //   {
      //     'access_token': googleAccessToken,
      //   },
      // );
      // final response = await http.get(url);
      // final backendToken = response.token

      // Let's assume it has been successful and a valid token has been returned
      const String backendToken = 'TOKEN';
      if (backendToken != null) {
        await _secureStorage.write(
          key: BACKEND_TOKEN_KEY,
          value: backendToken,
        );
      }
      return true;
    } else {
      return false;
    }
  }
}
