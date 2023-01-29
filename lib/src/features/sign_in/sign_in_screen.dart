import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:laundrivr/src/network/sign_in_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants.dart';
import '../../network/user_metadata_fetcher.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final StreamSubscription<AuthState> _authStateSubscription;
  bool _redirecting = false;

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      // clear the cache for metadata
      UserMetadataFetcher().clear();

      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        // in 500 milliseconds, redirect to the home screen
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _signInWithProvider(Provider provider) async {
    try {
      AuthSessionUrlResponse response = await SignInProvider()
          .customSignInWithOAuth(provider,
              redirectTo: "com.laundrivr.laundrivr://login-callback/");
      log("auth response: ${response.session}");
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      log(error.toString());
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
  }

  Future<void> _signInWithGoogle() async {
    await _signInWithProvider(Provider.google);
  }

  Future<void> _signInWithApple() async {
    await _signInWithProvider(Provider.apple);
  }

  @override
  Widget build(BuildContext context) {
    final Widget laundrivrLogoWidget = SvgPicture.asset(
      "assets/images/laundrivr_logo+text_golden.svg",
      semanticsLabel: 'Laundrivr Logo',
      width: 100,
      height: 100,
    );
    final Widget googleLogoWidget = SvgPicture.asset(
      "assets/images/google_logo.svg",
      semanticsLabel: 'Google Logo',
      width: 20,
      height: 20,
    );
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: laundrivrTheme.opaqueBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.only(top: constraints.minHeight < 700 ? 50 : 75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: laundrivrLogoWidget,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: Text('Sign In',
                        style: TextStyle(
                            color: laundrivrTheme.primaryBrightTextColor,
                            fontFamily:
                                laundrivrTheme.primaryTextStyle!.fontFamily,
                            fontSize: 64,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.8,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: TextButton(
                        onPressed: () {
                          _signInWithGoogle();
                        },
                        child: ContinueWithGoogleContainer(
                            googleLogoWidget: googleLogoWidget,
                            laundrivrTheme: laundrivrTheme),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.8,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: TextButton(
                        onPressed: () {
                          _signInWithApple();
                        },
                        child: ContinueWithAppleContainer(
                            laundrivrTheme: laundrivrTheme),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ContinueWithAppleContainer extends StatelessWidget {
  const ContinueWithAppleContainer({
    Key? key,
    required this.laundrivrTheme,
  }) : super(key: key);

  final LaundrivrTheme laundrivrTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.apple,
          size: 30,
          color: Colors.black,
        ),
        const SizedBox(
          width: 15,
        ),
        Text(
          'Continue with Apple',
          style: TextStyle(
              color: Colors.black,
              fontFamily: laundrivrTheme.primaryTextStyle!.fontFamily,
              fontSize: 23,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class ContinueWithGoogleContainer extends StatelessWidget {
  const ContinueWithGoogleContainer({
    Key? key,
    required this.googleLogoWidget,
    required this.laundrivrTheme,
  }) : super(key: key);

  final Widget googleLogoWidget;
  final LaundrivrTheme laundrivrTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        googleLogoWidget,
        const SizedBox(
          width: 15,
        ),
        Text(
          'Continue with Google',
          style: TextStyle(
              color: Colors.grey,
              fontFamily: laundrivrTheme.primaryTextStyle!.fontFamily,
              fontSize: 23,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
