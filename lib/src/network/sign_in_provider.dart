import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInProvider {
  static final SignInProvider _instance = SignInProvider._internal();

  factory SignInProvider() {
    return _instance;
  }

  SignInProvider._internal();

  Future<AuthSessionUrlResponse> customSignInWithOAuth(
    Provider provider, {
    String? redirectTo,
    String? scopes,
    Map<String, String>? queryParams,
  }) async {
    final res = await Supabase.instance.client.auth.getOAuthSignInUrl(
      provider: provider,
      redirectTo: redirectTo,
      scopes: scopes,
      queryParams: queryParams,
    );
    final result = await FlutterWebAuth.authenticate(
        url: res.url!, callbackUrlScheme: "com.laundrivr.laundrivr");
    AuthSessionUrlResponse response = await Supabase.instance.client.auth
        .getSessionFromUrl(Uri.parse(result));
    return response;
  }
}
