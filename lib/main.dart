import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundrivr/src/ble/ble_reactive_instance.dart';
import 'package:laundrivr/src/features/root/root_screen.dart';
import 'package:laundrivr/src/features/scan_qr/scan_qr_screen.dart';
import 'package:laundrivr/src/features/sign_in/sign_in_screen.dart';
import 'package:laundrivr/src/features/splash/splash_screen.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:laundrivr/src/network/package_fetcher.dart';
import 'package:laundrivr/src/network/user_metadata_fetcher.dart';
import 'package:skeletons/skeletons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/constants.dart';
import 'src/features/number_entry/number_entry_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
  );

  // fetch user metadata
  UserMetadataFetcher().fetchMetadata();
  // fetch packages
  PackageFetcher().fetchPackages();

  runApp(const LaundrivrApp());
}

class LaundrivrApp extends StatelessWidget {
  const LaundrivrApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsFlutterBinding.ensureInitialized();
    // initialize ble
    BleReactiveInstance().ble.initialize();

    return SkeletonTheme(
      darkShimmerGradient: const LinearGradient(
        colors: [
          Color(0xff0F162A),
          Color(0xff14223D),
          Color(0xff14223D),
          Color(0xff0F162A),
        ],
        stops: [
          0.0,
          0.3,
          1,
          1,
        ],
        begin: Alignment(-1, 0),
        end: Alignment(1, 0),
      ),
      child: MaterialApp(
        title: 'Laundrivr',
        theme: ThemeData.dark().copyWith(extensions: <ThemeExtension<dynamic>>[
          LaundrivrTheme(
            opaqueBackgroundColor: const Color(0xff0F162A),
            secondaryOpaqueBackgroundColor: const Color(0xff182243),
            tertiaryOpaqueBackgroundColor: const Color(0xff14223D),
            primaryBrightTextColor: const Color(0xffffffff),
            primaryTextStyle: GoogleFonts.urbanist(),
            selectedIconColor: const Color(0xffb3b8c8),
            unselectedIconColor: const Color(0xff546087),
            goldenTextColor: const Color(0xffFDDD02),
            bottomNavBarBackgroundColor: const Color(0xff273563),
            brightBadgeBackgroundColor: const Color(0xff479ade),
            pricingGreen: const Color(0xff6EF54C),
            backButtonBackgroundColor: const Color(0xD9D9D9D9),
            pinCodeInactiveColor: const Color(0xff546087),
            pinCodeActiveValidColor: const Color(0xff6EF54C),
            pinCodeActiveInvalidColor: const Color(
              0xffFF0000,
            ),
          )
        ]),
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (_) => const SplashScreen(), // rename to splash screen
          '/signin': (_) => const SignInScreen(),
          '/home': (_) => const RootScreen(), // actually make a home page
          '/number_entry': (_) => const NumberEntryScreen(),
          '/scan_qr': (_) => const ScanQrScreen(),
        },
      ),
    );
  }
}
