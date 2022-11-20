import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/laundrivr_theme.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  static final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'help@laundrivr.com',
  );

  static final Uri privacyPolicyUri = Uri(
    scheme: 'https',
    path: 'laundrivr.com/privacy',
  );

  static final Uri termsOfUseUri = Uri(
    scheme: 'https',
    path: 'laundrivr.com/terms',
  );

  static final Uri websiteUri = Uri(
    scheme: 'https',
    path: 'laundrivr.com',
  );

  bool _loadingPackageInfo = true;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      _loadingPackageInfo = false;
    });
  }

  @override
  void initState() {
    _initPackageInfo();
    super.initState();
  }

  void _launchURL(Uri uri) async {
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset("assets/images/laundrivr_logo+text_golden.svg",
                semanticsLabel: 'Laundrivr Logo', width: 200, height: 200),
            const SizedBox(
              height: 25,
            ),
            Column(
              children: [
                // if loading do a loading indicator
                if (_loadingPackageInfo)
                  const CircularProgressIndicator()
                else
                  // else show the package info
                  Text(
                    'Version: ${_packageInfo.version}+${_packageInfo.buildNumber}',
                    style: laundrivrTheme.primaryTextStyle!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '© 2022 Laundrivr',
                  style: laundrivrTheme.primaryTextStyle!.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: 320,
                  height: 75,
                  child: Container(
                    decoration: BoxDecoration(
                      color: laundrivrTheme.brightBadgeBackgroundColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextButton(
                      onPressed: () {
                        _launchURL(privacyPolicyUri);
                      },
                      child: Text(
                        'Privacy Policy',
                        style: laundrivrTheme.primaryTextStyle!.copyWith(
                          color: laundrivrTheme.primaryBrightTextColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: 320,
                  height: 75,
                  child: Container(
                    decoration: BoxDecoration(
                      color: laundrivrTheme.brightBadgeBackgroundColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextButton(
                      onPressed: () {
                        _launchURL(termsOfUseUri);
                      },
                      child: Text(
                        'Terms of Use',
                        style: laundrivrTheme.primaryTextStyle!.copyWith(
                          color: laundrivrTheme.primaryBrightTextColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: 320,
                  height: 75,
                  child: Container(
                    decoration: BoxDecoration(
                      color: laundrivrTheme.brightBadgeBackgroundColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextButton(
                      onPressed: () {
                        _launchURL(websiteUri);
                      },
                      child: Text(
                        'Visit the Website',
                        style: laundrivrTheme.primaryTextStyle!.copyWith(
                          color: laundrivrTheme.primaryBrightTextColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const Expanded(
              child: SizedBox(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have a question?',
                    style: laundrivrTheme.primaryTextStyle!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  RichText(
                    text: TextSpan(
                        text: 'Mail us!',
                        style: laundrivrTheme.primaryTextStyle!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchURL(emailLaunchUri);
                          }),
                  ),
                ],
              ),
            )
            // version info from pubspec.yaml
          ],
        ),
      ),
    );
  }
}
