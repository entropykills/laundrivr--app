import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/laundrivr_theme.dart';

class SignInWebView extends StatefulWidget {
  final WebViewController controller;

  const SignInWebView({super.key, required this.controller});

  @override
  State<SignInWebView> createState() => _SignInWebViewState();
}

class _SignInWebViewState extends State<SignInWebView> {
  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: laundrivrTheme.opaqueBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Sign In'),
      ),
      body: SafeArea(child: WebViewWidget(controller: widget.controller)),
    );
  }
}
