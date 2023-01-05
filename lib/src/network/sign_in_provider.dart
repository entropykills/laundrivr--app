import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInProvider {
  static final SignInProvider _instance = SignInProvider._internal();

  factory SignInProvider() {
    return _instance;
  }

  SignInProvider._internal();

  Future<bool> customSignInWithOAuth(
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
    final url = Uri.parse(res.url!);
    bool result;
    try {
      result = await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webOnlyWindowName: '_self',
      );
      log("Result happened");
    } catch (e) {
      result = false;
    } finally {
      // closeInAppWebView();
    }
    return result;
  }
}
